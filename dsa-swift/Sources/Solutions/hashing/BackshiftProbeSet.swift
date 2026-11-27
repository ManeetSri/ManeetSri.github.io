// Reference solution: A probing set without tombstones. Linear probing from home `key & mask` in one
// array of optional slots; before an insert would pass three quarters full, double and re-insert in slot
// order. Removal empties the slot, then walks the rest of the run and moves back every key whose home is
// at or before the hole. O(1) average per operation, O(capacity) space.

public enum BackshiftProbeSet {
    public struct ProbeSet {
        public private(set) var slots: [Int?]
        public private(set) var count = 0

        public init(capacity: Int) {
            slots = Array(repeating: nil, count: capacity)
        }

        public var capacity: Int { slots.count }

        private var mask: Int { slots.count - 1 }

        private func home(_ key: Int) -> Int { key & mask }

        private func slot(of key: Int) -> Int? {
            var index = home(key)
            while let stored = slots[index] {
                if stored == key { return index }
                index = (index + 1) & mask
            }
            return nil
        }

        public func contains(_ key: Int) -> Bool {
            slot(of: key) != nil
        }

        @discardableResult
        public mutating func insert(_ key: Int) -> Bool {
            guard slot(of: key) == nil else { return false }
            if (count + 1) * 4 > capacity * 3 {
                let old = slots
                slots = Array(repeating: nil, count: old.count * 2)
                for case let stored? in old {               // old slots from 0 upwards
                    place(stored)
                }
            }
            place(key)
            count += 1
            return true
        }

        private mutating func place(_ key: Int) {
            var index = home(key)
            while slots[index] != nil {
                index = (index + 1) & mask
            }
            slots[index] = key
        }

        @discardableResult
        public mutating func remove(_ key: Int) -> Bool {
            guard var hole = slot(of: key) else { return false }
            slots[hole] = nil
            count -= 1
            var next = (hole + 1) & mask
            while let candidate = slots[next] {              // stop at the end of the run
                let fromHome = (next - home(candidate)) & mask
                let fromHole = (next - hole) & mask
                if fromHome >= fromHole {                    // the hole is on its probe path
                    slots[hole] = candidate
                    slots[next] = nil
                    hole = next
                }
                next = (next + 1) & mask
            }
            return true
        }
    }
}
