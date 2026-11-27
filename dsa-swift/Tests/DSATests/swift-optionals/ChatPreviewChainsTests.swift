import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ChatPreviewChainsTests {
    let chats: [String: [String]] = [
        "family": ["Dinner at 7?", "@Ana can you bring dessert"],
        "work": ["Standup moved"],
        "book club": [],
        "team": ["@Ben ready?", "Sure"],
        "fans": ["🎉🎉", "Go @Kai 🎉"],
    ]

    @Test("Finds the newest message", arguments: [
        ("work", "Standup moved"),
        ("family", "@Ana can you bring dessert"),
        ("team", "Sure"),
        ("fans", "Go @Kai 🎉"),
    ])
    func newestMessage(chat: String, expected: String) {
        #expect(ChatPreviewChains.newestMessage(in: chat, from: chats) == expected)
    }

    @Test("No newest message for an empty or missing chat")
    func noNewestMessage() {
        #expect(ChatPreviewChains.newestMessage(in: "book club", from: chats) == nil)
        #expect(ChatPreviewChains.newestMessage(in: "gym", from: chats) == nil)
        #expect(ChatPreviewChains.newestMessage(in: "Work", from: chats) == nil)
        #expect(ChatPreviewChains.newestMessage(in: "work", from: [:]) == nil)
    }

    @Test("Counts the newest message's characters", arguments: [
        ("work", 13),
        ("family", 26),
        ("team", 4),
        ("fans", 9),
    ])
    func newestLength(chat: String, expected: Int) {
        #expect(ChatPreviewChains.newestLength(in: chat, from: chats) == expected)
    }

    @Test("Length is 0 when there's no newest message")
    func lengthWithoutMessage() {
        #expect(ChatPreviewChains.newestLength(in: "book club", from: chats) == 0)
        #expect(ChatPreviewChains.newestLength(in: "gym", from: chats) == 0)
        #expect(ChatPreviewChains.newestLength(in: "quiet", from: ["quiet": [""]]) == 0)
    }

    @Test("Spots a mention in the newest message")
    func mentions() {
        #expect(ChatPreviewChains.newestMentions("Ana", in: "family", from: chats))
        #expect(ChatPreviewChains.newestMentions("Kai", in: "fans", from: chats))
        #expect(!ChatPreviewChains.newestMentions("Ana", in: "work", from: chats))
    }

    @Test("Only the newest message counts")
    func onlyNewest() {
        // "@Ben ready?" is older than "Sure".
        #expect(!ChatPreviewChains.newestMentions("Ben", in: "team", from: chats))
    }

    @Test("A mention needs the @ and the exact name")
    func exactMention() {
        let room: [String: [String]] = ["room": ["Ana is late, @ana knows"]]
        #expect(!ChatPreviewChains.newestMentions("Ana", in: "room", from: room))
        #expect(ChatPreviewChains.newestMentions("ana", in: "room", from: room))
    }

    @Test("No mention without a newest message")
    func mentionsWithoutMessage() {
        #expect(!ChatPreviewChains.newestMentions("Ana", in: "book club", from: chats))
        #expect(!ChatPreviewChains.newestMentions("Ana", in: "gym", from: chats))
    }
}
