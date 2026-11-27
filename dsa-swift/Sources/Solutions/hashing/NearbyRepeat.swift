// Reference solution: A repeat close by. A dictionary remembers the last position each value was
// seen at. The nearest earlier copy of a value is always its last one, so it's the only one worth
// checking. O(n) time, O(n) space.

public enum NearbyRepeat {
    public static func hasRepeat(in values: [Int], within distance: Int) -> Bool {
        var lastSeen: [Int: Int] = [:]
        for (index, value) in values.enumerated() {
            if let previous = lastSeen[value], index - previous <= distance {
                return true
            }
            lastSeen[value] = index
        }
        return false
    }
}
