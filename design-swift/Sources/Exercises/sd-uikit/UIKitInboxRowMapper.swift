// Kata: Inbox row state (D17 · Where business logic must not live)
import Foundation

public enum UIKitInboxRowMapper {
    /// A message as the domain layer knows it
    public struct Message: Sendable {
        public let id: String
        public let senderName: String
        public let senderAddress: String
        public let subject: String
        public let body: String
        public let sentAt: Date
        public let isRead: Bool
        public let isFlagged: Bool
        public let attachmentCount: Int

        public init(id: String, senderName: String, senderAddress: String, subject: String, body: String, sentAt: Date, isRead: Bool = true, isFlagged: Bool = false, attachmentCount: Int = 0) {
            self.id = id
            self.senderName = senderName
            self.senderAddress = senderAddress
            self.subject = subject
            self.body = body
            self.sentAt = sentAt
            self.isRead = isRead
            self.isFlagged = isFlagged
            self.attachmentCount = attachmentCount
        }
    }

    /// Everything an inbox cell shows, already decided: the cell only copies these into its views
    public struct RowState: Equatable, Sendable {
        public let id: String
        public let sender: String
        public let subject: String
        public let preview: String
        public let age: String
        public let showsUnreadDot: Bool
        /// SF Symbol names, in display order
        public let symbols: [String]
        public let accessibilityLabel: String

        public init(id: String, sender: String, subject: String, preview: String, age: String, showsUnreadDot: Bool, symbols: [String], accessibilityLabel: String) {
            self.id = id
            self.sender = sender
            self.subject = subject
            self.preview = preview
            self.age = age
            self.showsUnreadDot = showsUnreadDot
            self.symbols = symbols
            self.accessibilityLabel = accessibilityLabel
        }
    }

    /// The row an inbox cell shows for `message`, when the time is `now`
    public static func row(for message: Message, now: Date) -> RowState {
        // Write your solution here, then run:
        // swift test --filter UIKitInboxRowMapperTests
        return RowState(id: "", sender: "", subject: "", preview: "", age: "", showsUnreadDot: false, symbols: [], accessibilityLabel: "")
    }
}
