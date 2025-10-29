import Foundation
import SwiftData

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
