import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PrinciplesUnreadBadgesTests {
    typealias Badges = PrinciplesUnreadBadges

    let conversations = [
        Badges.Conversation(id: "family", title: "Family"),
        Badges.Conversation(id: "work", title: "Work"),
        Badges.Conversation(id: "street", title: "Neighbours", isMuted: true),
        Badges.Conversation(id: "trip", title: "Old trip", isArchived: true),
    ]

    private func unread(in conversationID: String, _ id: String) -> Badges.Message {
        Badges.Message(id: id, conversationID: conversationID)
    }

    @Test("Only unread messages from other people, in active conversations, count")
    func unreadRule() {
        let messages = [
            unread(in: "family", "1"),
            Badges.Message(id: "2", conversationID: "family", isRead: true),
            Badges.Message(id: "3", conversationID: "family", isFromMe: true),
            unread(in: "street", "4"),
            unread(in: "trip", "5"),
            unread(in: "work", "6"),
            unread(in: "deleted", "7"),
        ]
        #expect(Badges.unreadMessages(messages, in: conversations).map(\.id) == ["1", "6"])
    }

    @Test("Unread messages keep the order they were given in")
    func keepsOrder() {
        let messages = [unread(in: "work", "w1"), unread(in: "family", "f1"), unread(in: "work", "w2")]
        #expect(Badges.unreadMessages(messages, in: conversations).map(\.id) == ["w1", "f1", "w2"])
    }

    @Test("The tab badge shows the number, up to 99+", arguments: [(1, "1"), (42, "42"), (99, "99"), (100, "99+"), (2_500, "99+")])
    func tabBadge(count: Int, expected: String) {
        #expect(Badges.tabBadge(unreadCount: count) == expected)
    }

    @Test("No tab badge when nothing is unread", arguments: [0, -3])
    func noTabBadge(count: Int) {
        #expect(Badges.tabBadge(unreadCount: count) == nil)
    }

    @Test("The inbox header is a sentence", arguments: [
        (0, "No unread messages"), (1, "1 unread message"), (12, "12 unread messages"), (1_500, "1500 unread messages"),
    ])
    func inboxHeader(count: Int, expected: String) {
        #expect(Badges.inboxHeader(unreadCount: count) == expected)
    }

    @Test("A notification about one conversation names it")
    func summaryForOneConversation() {
        let one = [unread(in: "family", "1")]
        let three = [unread(in: "family", "1"), unread(in: "family", "2"), unread(in: "family", "3")]
        #expect(Badges.notificationSummary(messages: one, conversations: conversations) == "1 new message in Family")
        #expect(Badges.notificationSummary(messages: three, conversations: conversations) == "3 new messages in Family")
    }

    @Test("A notification about several conversations counts them")
    func summaryForSeveralConversations() {
        let messages = [
            unread(in: "family", "1"), unread(in: "work", "2"), unread(in: "family", "3"),
            unread(in: "work", "4"), unread(in: "family", "5"), unread(in: "street", "6"),
        ]
        #expect(Badges.notificationSummary(messages: messages, conversations: conversations) == "5 new messages in 2 conversations")
    }

    @Test("No notification summary when only muted, archived or read messages are new")
    func noSummary() {
        let messages = [unread(in: "street", "1"), unread(in: "trip", "2"), Badges.Message(id: "3", conversationID: "work", isRead: true)]
        #expect(Badges.notificationSummary(messages: messages, conversations: conversations) == nil)
    }

    @Test("Every surface agrees, because they share one rule")
    func surfacesAgree() {
        let messages = [
            unread(in: "family", "1"), unread(in: "family", "2"),
            unread(in: "street", "3"), unread(in: "street", "4"), unread(in: "street", "5"),
            Badges.Message(id: "6", conversationID: "work", isRead: true),
            Badges.Message(id: "7", conversationID: "family", isFromMe: true),
        ]
        let count = Badges.unreadMessages(messages, in: conversations).count
        #expect(count == 2)
        #expect(Badges.tabBadge(unreadCount: count) == "2")
        #expect(Badges.inboxHeader(unreadCount: count) == "2 unread messages")
        #expect(Badges.notificationSummary(messages: messages, conversations: conversations) == "2 new messages in Family")
    }
}
