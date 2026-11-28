// Kata: One unread rule, three badges (D05 · DRY vs the wrong abstraction (AHA))

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

    /// The one rule every surface shares. The unread messages, in the order given: not read, not sent by
    /// me, and in a conversation listed in `conversations` that's neither muted nor archived.
    public static func unreadMessages(_ messages: [Message], in conversations: [Conversation]) -> [Message] {
        // Write your solution here, then run:
        // swift test --filter PrinciplesUnreadBadgesTests
        return []
    }

    /// The tab bar badge: `nil` when nothing is unread, then the number up to 99, then "99+"
    public static func tabBadge(unreadCount: Int) -> String? {
        return nil
    }

    /// The inbox header: "No unread messages", "1 unread message", "12 unread messages"
    public static func inboxHeader(unreadCount: Int) -> String {
        return ""
    }

    /// The summary line of a grouped notification, or `nil` when nothing is unread:
    /// "1 new message in Family", "3 new messages in Family", "5 new messages in 2 conversations"
    public static func notificationSummary(messages: [Message], conversations: [Conversation]) -> String? {
        return nil
    }
}
