// Generated from src/dsa/design/content/lessons/sd-modelling/sd-modelling-contracts.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// The last few things the user searched for.
/// - Invariant: at most `limit` terms, newest first, and no term twice (ignoring case).
struct RecentSearches {
    let limit: Int
    private(set) var terms: [String] = []

    /// - Precondition: `limit` is at least 1. Anything less is a bug in the code that made it.
    init(limit: Int) {
        precondition(limit >= 1, "RecentSearches needs room for at least one term")
        self.limit = limit
    }

    /// Records a search. Blank text comes from the user, so it's ignored, not treated as a bug.
    /// - Postcondition: if `term` isn't blank, it's `terms.first`, trimmed, and appears only once.
    mutating func record(_ term: String) {
        let trimmed = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        terms.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        terms.insert(trimmed, at: 0)
        if terms.count > limit {
            terms.removeLast(terms.count - limit)
        }
        assert(keepsInvariant, "RecentSearches broke its invariant")
    }

    private var keepsInvariant: Bool {
        terms.count <= limit && Set(terms.map { $0.lowercased() }).count == terms.count
    }
}

var recent = RecentSearches(limit: 3)
for search in ["swift", "SwiftUI", "   ", "Swift", "combine", "async"] {
    recent.record(search)
    print("\"\(search)\" -> \(recent.terms)")
}
