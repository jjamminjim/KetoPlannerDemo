/*
[TP] SwiftData — Demo Talking Points

- Why SwiftData: @Model macro, automatic schema, tight SwiftUI integration.
- Core patterns in this app: @Environment(\.modelContext), @Query, FetchDescriptor + #Predicate.
- Data integrity: delete rules, uniqueness, indexing.
- Versioning: @available markers for newer features.
- Subclassing in SwiftData: base `@Model` with `final` subclasses for polymorphism.
- Availability gates: mark base and subclasses with `@available` to avoid schema drift on older OSes.
- Type-based queries: fetch `BaseMessage` to get all, or `UserMessage`/`AssistantMessage` for filtered types.
- Migrations: adding subclasses later is a lightweight additive change; removing/merging requires a migration plan.
- Delete rules: relationships declared on the base apply to all subclasses (e.g., cascade from thread to any message type).
- Indexing/uniqueness: define indexes on the base so constraints apply uniformly across subclasses.
- UI polymorphism: render different SwiftUI rows based on dynamic type (`is UserMessage`).
*/

import Foundation
import SwiftData


/*
[TP]

- ChatThread is a root entity for conversations.
- `@Attribute(.unique)` on `chatID` ensures stable identity.
- `@Relationship(deleteRule: .cascade)` removes messages when a thread is deleted.
- Constructor provides defaults for easy seeding in demos/tests.
*/
@Model
final class ChatThread {
    @Attribute(.unique) var chatID: UUID
    var title: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var messages: [BaseMessage]

    init(id: UUID = .init(), title: String = "Keto Chat", createdAt: Date = .now, messages: [BaseMessage] = []) {
        self.chatID = id
        self.title = title
        self.createdAt = createdAt
        self.messages = messages
    }
}

protocol MessageItem {
    var messageID: UUID { get }
    var text: String { get }
    var createdAt: Date { get }
    var userMessage: Bool { get }
}

/*
[TP] Subclassing & Polymorphism in SwiftData

- BaseMessage is the abstract root. It's marked @Model so it participates in persistence, but it's not instantiated directly in UI.
- `#Index` and `#Unique` live on the base so constraints and performance benefits flow to all subclasses.
- `@Attribute(.preserveValueOnDeletion)` on the base preserves identity even if a subclass instance is deleted.
- Use `@available` to scope these types to newer OSes without breaking older deployments.
- Querying:
  - Fetch `BaseMessage` to get a heterogeneous collection (both user + assistant).
  - Fetch `UserMessage` or `AssistantMessage` to narrow by concrete type.
  - Predicates can filter by type with `is` checks when needed.
- Relationships:
  - The `ChatThread.messages: [BaseMessage]` relationship accepts any subclass. Cascade delete will remove all derived instances.
- Migrations:
  - Adding a new subclass (e.g., SystemMessage) is additive; ensure schema version bump if shipping.
  - Moving properties from base to subclass (or vice versa) is a breaking change and needs a migration.
- UI:
  - Prefer protocol `MessageItem` for view consumption to decouple UI from persistence types.
*/
@available(iOS 26, *)
@Model class BaseMessage {
    #Index<BaseMessage>([\.messageID])
    #Unique<BaseMessage>([\.messageID])
    
    @Attribute(.preserveValueOnDeletion) var messageID: UUID

    var text: String
    var createdAt: Date

    fileprivate init(id: UUID, text: String, createdAt: Date) {
        self.messageID = id
        self.text = text
        self.createdAt = createdAt
    }
}

extension BaseMessage: MessageItem {
    @Transient @objc var userMessage: Bool {
        fatalError("userMessage getter must be implemented in subclass")
    }
}

/*
[TP] Subclasses
- `UserMessage` and `AssistantMessage` are concrete leaf types that inherit from `BaseMessage` and override `userMessage` for UI logic.
- Marked `final` to keep the hierarchy shallow and avoid unintended further subclassing.
- Constructors delegate to the base to keep a single source of truth for stored properties.
- You can add additional subclasses later (e.g., `SystemMessage`, `ToolMessage`) without changing the relationship on `ChatThread`.
- When seeding or importing, you can create mixed arrays: `[UserMessage(...), AssistantMessage(...)]` and assign to `messages` in one shot.
*/
@available(iOS 26, *)
@Model final class UserMessage: BaseMessage {
    override init(id: UUID = .init(), text: String, createdAt: Date = .now) {
        super.init(id: id, text: text, createdAt: createdAt)
    }
    
    override var userMessage: Bool { true }
}

@available(iOS 26, *)
@Model final class AssistantMessage: BaseMessage {
    override init(id: UUID = .init(), text: String, createdAt: Date = .now) {
        super.init(id: id, text: text, createdAt: createdAt)
    }
    
    override var userMessage: Bool { false }
}
