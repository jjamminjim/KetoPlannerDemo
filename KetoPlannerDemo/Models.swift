/*
[TP] SwiftData — Demo Talking Points

- Why SwiftData: @Model macro, automatic schema, tight SwiftUI integration.
- Core patterns in this app: @Environment(\.modelContext), @Query, FetchDescriptor + #Predicate.
- Data integrity: delete rules, uniqueness, indexing.
- Versioning: @available markers for newer features.
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

/*
[TP]

- Messages are a separate entity, linked to a thread; newer OS availability demonstrates forward-looking features.
- `#Index` and `#Unique` on `messageID` speed lookup and enforce uniqueness.
- `@Attribute(.preserveValueOnDeletion)` keeps IDs for auditing/tombstones.
- Notes on potential inheritance (commented subclasses) for polymorphism in SwiftData.
*/
@available(iOS 26, *)
@Model class BaseMessage {
    #Index<BaseMessage>([\.messageID])
    #Unique<BaseMessage>([\.messageID])
    
    @Attribute(.preserveValueOnDeletion) var messageID: UUID

    var text: String
    var createdAt: Date
    var userMessage: Bool

    init(id: UUID = .init(), text: String, userMessage: Bool, createdAt: Date = .now) {
        self.messageID = id
        self.text = text
        self.userMessage = userMessage
        self.createdAt = createdAt
    }
}
