// Problem: Chat previews (M04 · Optional chaining)

public enum ChatPreviewChains {
    /// Returns the newest (last) message in `chat`, or nil if the chat is missing or empty.
    public static func newestMessage(in chat: String, from chats: [String: [String]]) -> String? {
        // Write your solution here, then run:
        // swift test --filter ChatPreviewChainsTests
        return nil
    }

    /// Returns how many characters the newest message in `chat` has, or 0 if there isn't one.
    public static func newestLength(in chat: String, from chats: [String: [String]]) -> Int {
        return 0
    }

    /// Returns true when the newest message in `chat` contains "@" followed by `name`;
    /// false otherwise, including when there's no newest message.
    public static func newestMentions(_ name: String, in chat: String, from chats: [String: [String]]) -> Bool {
        return false
    }
}
