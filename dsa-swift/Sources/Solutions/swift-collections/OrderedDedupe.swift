// Reference solution: Remove duplicates, keep the order.
// A Set remembers what we've already kept, so each check is O(1) on average.
// O(n) time, O(n) extra space.

public enum OrderedDedupe {
    public static func dedupe(_ numbers: [Int]) -> [Int] {
        var seen = Set<Int>()
        var result: [Int] = []
        for number in numbers where seen.insert(number).inserted {
            result.append(number)
        }
        return result
    }
}
