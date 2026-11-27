// Reference solution: Word counts in parallel. Each child task splits one document into words and
// counts them in a dictionary of its own, then returns it; nothing is shared, so there's nothing to
// race on. The parent receives the dictionaries one at a time from the group and merges them, so the
// merge needs no protection either. topWords sorts the merged counts by (count descending, word).
// O(total characters) work for counting, spread across the tasks, plus O(u log u) for sorting the u
// distinct words.

public enum ShardedWordTally {
    public static func counts(in documents: [String]) async -> [String: Int] {
        await withTaskGroup(of: [String: Int].self) { group in
            for document in documents {
                group.addTask {
                    var local: [String: Int] = [:]
                    for word in document.split(whereSeparator: { !$0.isLetter }) {
                        local[word.lowercased(), default: 0] += 1
                    }
                    return local
                }
            }
            var total: [String: Int] = [:]
            for await partial in group {
                total.merge(partial, uniquingKeysWith: +)
            }
            return total
        }
    }

    public static func topWords(in documents: [String], count k: Int) async -> [String] {
        let totals = await counts(in: documents)
        let ranked = totals.sorted { ($1.value, $0.key) < ($0.value, $1.key) }
        return ranked.prefix(k).map(\.key)
    }
}
