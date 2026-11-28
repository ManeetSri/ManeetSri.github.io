// Reference solution: An insertion-ordered dictionary with fast removal. Entries live in an array of
// optional slots in insertion order, with a dictionary from key to slot. Removing leaves a nil tombstone,
// so nothing shifts and no slot number goes stale; popFirst skips tombstones from a head index. When
// tombstones outnumber live entries, the slots are compacted in order and every key's slot rewritten,
// which the removals since the last compaction pay for. O(1) amortised per operation.

public enum InsertionOrderedMap {
    public struct Map<Key: Hashable, Value> {
        private var slots: [(key: Key, value: Value)?] = []
        private var slotOf: [Key: Int] = [:]
        private var head = 0                      // no live entry sits before this slot

        public init() {}

        public var count: Int {
            slotOf.count
        }

        public subscript(key: Key) -> Value? {
            get {
                slotOf[key].map { slots[$0]!.value }
            }
            set {
                guard let newValue else {
                    removeValue(forKey: key)
                    return
                }
                if let slot = slotOf[key] {
                    slots[slot]!.value = newValue     // an update keeps its place
                } else {
                    slotOf[key] = slots.count
                    slots.append((key, newValue))
                }
            }
        }

        @discardableResult
        public mutating func removeValue(forKey key: Key) -> Value? {
            guard let slot = slotOf.removeValue(forKey: key) else { return nil }
            let value = slots[slot]!.value
            slots[slot] = nil                         // a tombstone: nothing shifts
            compactIfWasteful()
            return value
        }

        public mutating func popFirst() -> (key: Key, value: Value)? {
            while head < slots.count && slots[head] == nil {
                head += 1
            }
            guard head < slots.count, let entry = slots[head] else { return nil }
            removeValue(forKey: entry.key)
            return entry
        }

        public var keys: [Key] {
            slots.compactMap { $0?.key }
        }

        public var values: [Value] {
            slots.compactMap { $0?.value }
        }

        // Rebuilds the slots without tombstones once they outnumber the live entries
        private mutating func compactIfWasteful() {
            guard slots.count >= 16, slots.count - count > count else { return }
            slots = slots.filter { $0 != nil }
            for (slot, entry) in slots.enumerated() {
                slotOf[entry!.key] = slot
            }
            head = 0
        }
    }
}
