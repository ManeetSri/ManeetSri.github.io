// Reference solution: Chat previews. Each helper is one optional chain (lookup, then last, then a
// question about the message), finished with nil, ?? 0 or == true. O(m) time for a newest message
// of m characters, O(1) extra space.

public enum ChatPreviewChains {
    public static func newestMessage(in chat: String, from chats: [String: [String]]) -> String? {
        chats[chat]?.last
    }

    public static func newestLength(in chat: String, from chats: [String: [String]]) -> Int {
        chats[chat]?.last?.count ?? 0
    }

    public static func newestMentions(_ name: String, in chat: String, from chats: [String: [String]]) -> Bool {
        chats[chat]?.last?.contains("@\(name)") == true
    }
}
