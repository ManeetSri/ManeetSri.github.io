// Reference solution: One unread rule, three badges. What counts as unread is one piece of knowledge, so
// it has one home that every surface calls. How each surface shows a number is separate knowledge, owned
// by separate people, so each gets its own small function instead of a shared formatter with flags.

public enum PrinciplesUnreadBadges {
    public struct Conversation: Sendable, Equatable {
        public let id: String
        public let title: String
        public let isMuted: Bool
        public let isArchived: Bool

        public init(id: String, title: String, isMuted: Bool = false, isArchived: Bool = false) {
            self.id = id
            self.title = title
            self.isMuted = isMuted
            self.isArchived = isArchived
        }
    }

    public struct Message: Sendable, Equatable {
        public let id: String
        public let conversationID: String
        public let isRead: Bool
        public let isFromMe: Bool

        public init(id: String, conversationID: String, isRead: Bool = false, isFromMe: Bool = false) {
            self.id = id
            self.conversationID = conversationID
            self.isRead = isRead
            self.isFromMe = isFromMe
        }
    }

    public static func unreadMessages(_ messages: [Message], in conversations: [Conversation]) -> [Message] {
        let counted = Set(conversations.filter { !$0.isMuted && !$0.isArchived }.map(\.id))
        return messages.filter { !$0.isRead && !$0.isFromMe && counted.contains($0.conversationID) }
    }

    public static func tabBadge(unreadCount: Int) -> String? {
        guard unreadCount > 0 else { return nil }
        return unreadCount > 99 ? "99+" : String(unreadCount)
    }

    public static func inboxHeader(unreadCount: Int) -> String {
        switch unreadCount {
        case ...0: "No unread messages"
        case 1: "1 unread message"
        default: "\(unreadCount) unread messages"
        }
    }

    public static func notificationSummary(messages: [Message], conversations: [Conversation]) -> String? {
        let unread = unreadMessages(messages, in: conversations)
        guard let first = unread.first else { return nil }
        let noun = unread.count == 1 ? "message" : "messages"
        let conversationIDs = Set(unread.map(\.conversationID))
        if conversationIDs.count == 1, let conversation = conversations.first(where: { $0.id == first.conversationID }) {
            return "\(unread.count) new \(noun) in \(conversation.title)"
        }
        return "\(unread.count) new \(noun) in \(conversationIDs.count) conversations"
    }
}
