// Problem: A ledger with every version kept (M60 · Persistent segment trees)

public enum VersionedLedgerSums {
    /// Member balances where every deposit makes a new version from any existing one, and every
    /// version stays readable. Deposits and queries are O(log n).
    public struct Ledger {
        // Write your solution here, then run:
        // swift test --filter VersionedLedgerSumsTests
        // Add whatever private storage you need: parallel node arrays and one root per version.

        /// Version 0 holds `balances` (at least one member).
        public init(_ balances: [Int]) {}

        /// How many versions exist so far.
        public var versionCount: Int {
            return 0
        }

        /// Makes the next version: `version` with `amount` added to member `index`. Returns its number.
        public mutating func deposit(_ amount: Int, into index: Int, basedOn version: Int) -> Int {
            return 0
        }

        /// The sum of balances[left...right] in `version`.
        public func total(from left: Int, through right: Int, in version: Int) -> Int {
            return 0
        }

        /// The smallest index i with balances[0] + … + balances[i] ≥ target in `version`, or nil if
        /// the whole ledger falls short. Balances are never negative.
        public func firstReaching(_ target: Int, in version: Int) -> Int? {
            return nil
        }
    }
}
