// Reference solution: Merge contact cards. Give every distinct email an index with a dictionary,
// and union each card's emails with its first email, so emails that appear together end up in one
// set. Then group the emails by their set's root, sort each group, put the owner's name in front,
// and sort the cards by name and then first email so the output is always in the same order.
// O(E log E) time for E emails in total (the sorting dominates the near-constant unions), O(E) space.

import DSAKit

public enum ContactCardMerge {
    public static func merge(_ cards: [[String]]) -> [[String]] {
        var indexOf: [String: Int] = [:]
        var emails: [String] = []
        var ownerOf: [String] = []
        for card in cards {
            for email in card.dropFirst() where indexOf[email] == nil {
                indexOf[email] = emails.count
                emails.append(email)
                ownerOf.append(card[0])
            }
        }

        var sets = UnionFind(count: emails.count)
        for card in cards where card.count > 1 {
            let first = indexOf[card[1]]!
            for email in card.dropFirst(2) {
                sets.union(first, indexOf[email]!)
            }
        }

        var emailsOfRoot: [Int: [String]] = [:]
        for (index, email) in emails.enumerated() {
            emailsOfRoot[sets.find(index), default: []].append(email)
        }
        let merged = emailsOfRoot.map { root, group in [ownerOf[root]] + group.sorted() }
        return merged.sorted { $0[0] != $1[0] ? $0[0] < $1[0] : $0[1] < $1[1] }
    }
}
