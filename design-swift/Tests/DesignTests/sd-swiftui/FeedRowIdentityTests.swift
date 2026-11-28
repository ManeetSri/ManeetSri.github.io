import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FeedRowIdentityTests {
    typealias Item = FeedRowIdentity.Item
    typealias Row = FeedRowIdentity.Row
    typealias Changes = FeedRowIdentity.Changes

    private func ids(_ items: [Item]) -> [String] {
        FeedRowIdentity.rows(from: items).map(\.id)
    }

    @Test("A client id wins over a server id; otherwise the server id is used")
    func identityRules() {
        #expect(FeedRowIdentity.identity(of: Item(serverID: "s1", clientID: "c1", title: "Confirmed draft")) == "client:c1")
        #expect(FeedRowIdentity.identity(of: Item(serverID: "s2", title: "From another device")) == "server:s2")
        #expect(FeedRowIdentity.identity(of: Item(clientID: "c3", title: "Draft", isPending: true)) == "client:c3")
        #expect(ids([Item(serverID: "s2", title: "From another device"), Item(clientID: "c3", title: "Draft")]) == ["server:s2", "client:c3"])
    }

    @Test("Server and client ids never collide, even with the same text")
    func namespaces() {
        let items = [Item(serverID: "7", title: "Server item 7"), Item(clientID: "7", title: "Local draft 7")]
        #expect(ids(items) == ["server:7", "client:7"])
    }

    @Test("Items with no usable id are left out")
    func unidentifiable() {
        let items = [
            Item(title: "No ids at all"),
            Item(serverID: "s1", title: "Fine"),
            Item(serverID: "", clientID: "", title: "Empty ids"),
        ]
        #expect(FeedRowIdentity.identity(of: items[0]) == nil)
        #expect(FeedRowIdentity.identity(of: items[2]) == nil)
        #expect(FeedRowIdentity.rows(from: items) == [Row(id: "server:s1", title: "Fine", isPending: false)])
    }

    @Test("A repeated item keeps its first position and its latest content")
    func duplicates() {
        // Page 2 repeats an item from page 1, fetched later and since renamed
        let items = [
            Item(serverID: "a", title: "Old title"),
            Item(serverID: "b", title: "B"),
            Item(serverID: "a", title: "New title"),
            Item(serverID: "c", title: "C"),
        ]
        #expect(FeedRowIdentity.rows(from: items) == [
            Row(id: "server:a", title: "New title", isPending: false),
            Row(id: "server:b", title: "B", isPending: false),
            Row(id: "server:c", title: "C", isPending: false),
        ])
    }

    @Test("A local draft and its confirmed copy in one list become one row")
    func draftAndConfirmedCopy() {
        let items = [
            Item(clientID: "c9", title: "Hello", isPending: true),
            Item(serverID: "s1", title: "Older post"),
            Item(serverID: "s42", clientID: "c9", title: "Hello"),
        ]
        #expect(FeedRowIdentity.rows(from: items) == [
            Row(id: "client:c9", title: "Hello", isPending: false),
            Row(id: "server:s1", title: "Older post", isPending: false),
        ])
    }

    @Test("Confirming a draft is an update to the same row, not a removal and an insertion")
    func confirmationKeepsIdentity() {
        let before = FeedRowIdentity.rows(from: [Item(clientID: "c9", title: "Hello", isPending: true)])
        let after = FeedRowIdentity.rows(from: [Item(serverID: "s42", clientID: "c9", title: "Hello")])

        #expect(before.map(\.id) == ["client:c9"])
        #expect(after.map(\.id) == ["client:c9"])
        #expect(FeedRowIdentity.changes(from: before, to: after) == Changes(updated: ["client:c9"]))
    }

    @Test("The same items always give the same ids")
    func deterministic() {
        let items = [Item(serverID: "s1", title: "One"), Item(clientID: "c2", title: "Two"), Item(serverID: "s3", title: "Three")]
        let first = FeedRowIdentity.rows(from: items)
        let second = FeedRowIdentity.rows(from: items)
        #expect(first.count == 3)
        #expect(first == second)
    }

    @Test("Changes list insertions, removals and updates, and ignore moves")
    func changes() {
        let old = [
            Row(id: "server:a", title: "A", isPending: false),
            Row(id: "server:b", title: "B", isPending: false),
            Row(id: "server:c", title: "C", isPending: false),
        ]
        let new = [
            Row(id: "server:c", title: "C, edited", isPending: false),
            Row(id: "server:a", title: "A", isPending: false),
            Row(id: "client:d", title: "D", isPending: true),
        ]
        #expect(FeedRowIdentity.changes(from: old, to: new) == Changes(inserted: ["client:d"], removed: ["server:b"], updated: ["server:c"]))
        #expect(FeedRowIdentity.changes(from: [], to: old) == Changes(inserted: ["server:a", "server:b", "server:c"]))
        #expect(FeedRowIdentity.changes(from: old, to: old) == Changes())
    }
}
