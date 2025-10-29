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

//@available(iOS 26, *)
//@Model final class UserMessage: BaseMessage {
//    override init(id: UUID = .init(), text: String, createdAt: Date = .now) {
//        responseCount = 0
//        super.init(id: id, text: text, createdAt: createdAt)
//    }
//    
//    var responseCount: Int
//}
//
//@available(iOS 26, *)
//@Model final class AssistantMessage: BaseMessage {
//    override init(id: UUID = .init(), text: String, createdAt: Date = .now) {
//        responseCount = 0
//        super.init(id: id, text: text, createdAt: createdAt)
//    }
//    
//    var responseCount: Int
//}
