// Problem: Exchange-rate queries (M45 · DSU with rollback and weighted DSU)

import DSAKit

public enum ExchangeRateQueries {
    /// Each rate (a, b, r) says one unit of a buys r units of b. For each query (c, d), returns how
    /// many units of d one unit of c buys, worked out from the rates, or -1 if the rates don't
    /// determine it.
    public static func answer(rates: [(String, String, Double)], queries: [(String, String)]) -> [Double] {
        // Write your solution here, then run:
        // swift test --filter ExchangeRateQueriesTests
        return []
    }
}
