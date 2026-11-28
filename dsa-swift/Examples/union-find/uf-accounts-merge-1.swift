// Generated from src/dsa/content/lessons/union-find/uf-accounts-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from "Path compression and union by rank"
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }

    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root { root = parent[root] }
        var node = x
        while node != root {
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }

    @discardableResult
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return false }
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA
        size[rootA] += size[rootB]
        return true
    }
}

func mergeCards(_ cards: [[String]]) -> [[String]] {
    // 1. An index for every distinct email, and who owns it
    var indexOf: [String: Int] = [:]
    var emails: [String] = []
    var owner: [String] = []
    for card in cards {
        for email in card.dropFirst() where indexOf[email] == nil {
            indexOf[email] = emails.count
            emails.append(email)
            owner.append(card[0])
        }
    }

    // 2. Join every email on a card to the card's first email
    var sets = UnionFind(count: emails.count)
    for card in cards where card.count > 1 {
        let first = indexOf[card[1]]!
        for email in card.dropFirst(2) {
            sets.union(first, indexOf[email]!)
        }
    }

    // 3. Collect each group under its root
    var groups: [Int: [String]] = [:]
    for (index, email) in emails.enumerated() {
        groups[sets.find(index), default: []].append(email)
    }

    // 4. Name first, emails sorted, cards sorted by name and then first email
    let merged = groups.map { root, group in [owner[root]] + group.sorted() }
    return merged.sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
}

let cards = [
    ["Priya", "priya@home.net", "p.shah@work.com"],
    ["Tom", "tom@mail.org"],
    ["Priya", "priya.s@uni.edu"],
    ["Priya", "p.shah@work.com", "shah.p@club.org"],
    ["Tom", "tommy@games.io", "tom@mail.org"],
]
for person in mergeCards(cards) {
    print(person[0] + ":", person.dropFirst().joined(separator: ", "))
}
