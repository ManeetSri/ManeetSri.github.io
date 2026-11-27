// Reference solution: Triples that split into equal XORs. Two pieces have equal XORs exactly when the
// whole stretch has XOR 0, which is when two prefix XOR values are equal; such a stretch from position q
// to position p has p - q - 1 cut points. A dictionary from each prefix value to how many times it has
// appeared and the sum of those positions adds them all up in one pass. O(n) time, O(n) space.

public enum EqualXorTriples {
    public static func count(in items: [Int]) -> Int {
        var seen: [Int: (count: Int, positionSum: Int)] = [0: (1, 0)]
        var running = 0
        var total = 0
        for (index, value) in items.enumerated() {
            running ^= value
            let position = index + 1
            let earlier = seen[running, default: (0, 0)]
            total += earlier.count * (position - 1) - earlier.positionSum
            seen[running] = (earlier.count + 1, earlier.positionSum + position)
        }
        return total
    }
}
