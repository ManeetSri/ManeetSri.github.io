// Reference solution: Leaderboard with custom tie-breaks. `tieBreak` is declared in the protocol, so it's
// looked up through each type's conformance (and a class's vtable), while the extension still supplies a
// default of 0. A member that lived only in the extension would be chosen statically, and generic or
// `any Entry` code would always get the default. Both rankings share a generic helper that sorts indices
// by (points, tieBreak) descending, then input order. O(n log n) time.

public enum LeaderboardDispatch {
    public protocol Entry {
        var points: Int { get }
        var tieBreak: Int { get }                 // a requirement, so conforming types can customise it
    }

    private static func ranked<T>(_ items: [T], count k: Int, key: (T) -> (Int, Int)) -> [T] {
        guard k > 0 else { return [] }
        let keys = items.map(key)
        let order = items.indices.sorted { a, b in
            keys[a] != keys[b] ? keys[a] > keys[b] : a < b
        }
        return order.prefix(k).map { items[$0] }
    }

    public static func top<E: Entry>(_ entries: [E], count k: Int) -> [E] {
        ranked(entries, count: k) { ($0.points, $0.tieBreak) }
    }

    public static func top(mixed entries: [any Entry], count k: Int) -> [any Entry] {
        ranked(entries, count: k) { ($0.points, $0.tieBreak) }
    }
}

extension LeaderboardDispatch.Entry {
    public var tieBreak: Int { 0 }
}
