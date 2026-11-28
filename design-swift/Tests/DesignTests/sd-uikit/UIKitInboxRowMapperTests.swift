import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UIKitInboxRowMapperTests {
    private typealias Message = UIKitInboxRowMapper.Message
    private static let now = Date(timeIntervalSince1970: 1_800_000_000)

    private func message(
        id: String = "m1", name: String = "Anna Lee", address: String = "anna@example.com", subject: String = "Lunch on Friday?",
        body: String = "Are you free?", secondsAgo: TimeInterval = 300, isRead: Bool = true, isFlagged: Bool = false, attachments: Int = 0
    ) -> Message {
        Message(id: id, senderName: name, senderAddress: address, subject: subject, body: body, sentAt: Self.now.addingTimeInterval(-secondsAgo), isRead: isRead, isFlagged: isFlagged, attachmentCount: attachments)
    }

    private func row(_ message: Message) -> UIKitInboxRowMapper.RowState {
        UIKitInboxRowMapper.row(for: message, now: Self.now)
    }

    @Test("Shows the sender's name, trimmed, or the address when there's no name")
    func sender() {
        #expect(row(message(id: "m7", name: "  Anna Lee \n")).sender == "Anna Lee")
        #expect(row(message(id: "m7")).id == "m7")
        #expect(row(message(name: "   ")).sender == "anna@example.com")
        #expect(row(message(name: "")).sender == "anna@example.com")
    }

    @Test("Trims the subject, with a placeholder when it's empty")
    func subject() {
        #expect(row(message(subject: "  Invoice 42 ")).subject == "Invoice 42")
        #expect(row(message(subject: " \n ")).subject == "(No subject)")
    }

    @Test("Collapses whitespace in the preview")
    func previewWhitespace() {
        #expect(row(message(body: "Hi Anna,\n\n  Lunch  on\tFriday?  ")).preview == "Hi Anna, Lunch on Friday?")
        #expect(row(message(body: "Short and sweet")).preview == "Short and sweet")
    }

    @Test("Cuts a long preview to 80 characters, ending in an ellipsis")
    func previewTruncation() {
        let exactly80 = String(repeating: "a", count: 80)
        #expect(row(message(body: exactly80)).preview == exactly80)

        let long = String(repeating: "b", count: 200)
        let preview = row(message(body: long)).preview
        #expect(preview == String(repeating: "b", count: 79) + "…")
        #expect(preview.count == 80)

        // The 79th character is a space: it's dropped before the ellipsis
        let spaced = String(repeating: "c", count: 78) + " " + String(repeating: "d", count: 30)
        #expect(row(message(body: spaced)).preview == String(repeating: "c", count: 78) + "…")
    }

    @Test("Shows the age in the largest whole unit", arguments: [
        (0.0, "Now"), (59, "Now"), (-120, "Now"), (60, "1m"), (3_599, "59m"), (3_600, "1h"), (86_399, "23h"),
        (86_400, "1d"), (604_799, "6d"), (604_800, "1w"), (1_900_000, "3w"),
    ] as [(TimeInterval, String)])
    func age(secondsAgo: TimeInterval, expected: String) {
        #expect(row(message(secondsAgo: secondsAgo)).age == expected)
    }

    @Test("Shows the unread dot and the flag and attachment symbols")
    func indicators() {
        let busy = row(message(isRead: false, isFlagged: true, attachments: 2))
        #expect(busy.showsUnreadDot)
        #expect(busy.symbols == ["flag.fill", "paperclip"])

        let attachmentOnly = row(message(attachments: 1))
        #expect(attachmentOnly.symbols == ["paperclip"])
        #expect(!attachmentOnly.showsUnreadDot)
        #expect(row(message()).symbols.isEmpty)
    }

    @Test("Builds one spoken label for VoiceOver")
    func accessibilityLabel() {
        let busy = row(message(isRead: false, isFlagged: true, attachments: 2))
        #expect(busy.accessibilityLabel == "Unread, Flagged, From Anna Lee, Lunch on Friday?, 5 minutes ago, 2 attachments")

        let plain = row(message(name: "", subject: "", secondsAgo: 10))
        #expect(plain.accessibilityLabel == "From anna@example.com, (No subject), Just now")

        let singular = row(message(secondsAgo: 3_600, attachments: 1))
        #expect(singular.accessibilityLabel == "From Anna Lee, Lunch on Friday?, 1 hour ago, 1 attachment")
    }
}
