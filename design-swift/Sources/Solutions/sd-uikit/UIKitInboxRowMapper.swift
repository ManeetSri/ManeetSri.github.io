// Reference solution: Inbox row state. Every rule a cell might be tempted to apply (fallbacks, cleaning
// the preview, the age buckets, which symbols show, what VoiceOver reads) is decided here, in plain
// Foundation, so it's tested without UIKit and shared by every screen that lists messages.
import Foundation

public enum UIKitInboxRowMapper {
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

    public struct RowState: Equatable, Sendable {
        public let id: String
        public let sender: String
        public let subject: String
        public let preview: String
        public let age: String
        public let showsUnreadDot: Bool
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

    private static let previewLimit = 80

    /// How long ago, in the largest whole unit that fits: (count, short suffix, spoken unit)
    private static func age(of seconds: TimeInterval) -> (count: Int, short: String, spoken: String)? {
        let units: [(seconds: TimeInterval, short: String, spoken: String)] = [
            (604_800, "w", "week"), (86_400, "d", "day"), (3_600, "h", "hour"), (60, "m", "minute"),
        ]
        for unit in units where seconds >= unit.seconds {
            return (Int(seconds / unit.seconds), unit.short, unit.spoken)
        }
        return nil
    }

    private static func counted(_ count: Int, _ noun: String) -> String {
        "\(count) \(noun)\(count == 1 ? "" : "s")"
    }

    public static func row(for message: Message, now: Date) -> RowState {
        let name = message.senderName.trimmingCharacters(in: .whitespacesAndNewlines)
        let sender = name.isEmpty ? message.senderAddress : name

        let trimmedSubject = message.subject.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = trimmedSubject.isEmpty ? "(No subject)" : trimmedSubject

        var preview = message.body.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        if preview.count > previewLimit {
            var cut = String(preview.prefix(previewLimit - 1))
            while cut.last == " " { cut.removeLast() }
            preview = cut + "…"
        }

        let elapsed = age(of: now.timeIntervalSince(message.sentAt))
        let shortAge = elapsed.map { "\($0.count)\($0.short)" } ?? "Now"
        let spokenAge = elapsed.map { counted($0.count, $0.spoken) + " ago" } ?? "Just now"

        var symbols: [String] = []
        if message.isFlagged { symbols.append("flag.fill") }
        if message.attachmentCount > 0 { symbols.append("paperclip") }

        var spoken: [String] = []
        if !message.isRead { spoken.append("Unread") }
        if message.isFlagged { spoken.append("Flagged") }
        spoken += ["From \(sender)", subject, spokenAge]
        if message.attachmentCount > 0 { spoken.append(counted(message.attachmentCount, "attachment")) }

        return RowState(
            id: message.id,
            sender: sender,
            subject: subject,
            preview: preview,
            age: shortAge,
            showsUnreadDot: !message.isRead,
            symbols: symbols,
            accessibilityLabel: spoken.joined(separator: ", ")
        )
    }
}
