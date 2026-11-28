// Reference solution: Price feed with corrections. A Dictionary from time to price handles corrections
// and the latest price. For the highest and lowest, a SortedMap counts how many times currently hold each
// price: a sorted multiset. A correction takes one away from the old price's count (removing the price
// when it reaches zero) and adds one to the new price's. The smallest and largest keys are then the
// lowest and highest prices. O(log n) per record and per query, O(n) space.

import DSAKit

public enum PriceFeedCorrections {
    public struct Feed {
        private var priceAt: [Int: Int] = [:]                // time → current price
        private var timesAtPrice = SortedMap<Int, Int>()     // price → how many times hold it
        private var latestTime: Int?

        public init() {}

        public mutating func record(time: Int, price: Int) {
            if let old = priceAt[time] {
                let remaining = timesAtPrice[old, default: 0] - 1
                timesAtPrice[old] = remaining == 0 ? nil : remaining
            }
            priceAt[time] = price
            timesAtPrice[price, default: 0] += 1
            if latestTime.map({ time > $0 }) ?? true {
                latestTime = time
            }
        }

        public var latest: Int? {
            latestTime.flatMap { priceAt[$0] }
        }

        public var highest: Int? {
            timesAtPrice.last?.key
        }

        public var lowest: Int? {
            timesAtPrice.first?.key
        }
    }
}
