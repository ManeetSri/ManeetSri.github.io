// Reference solution: Anagrams with 26 slots.
// Count letters up for the first word and down for the second; anagrams leave every slot at 0.
// O(n) time, O(1) extra space (always 26 counters).

public enum AnagramSlots {
    public static func areAnagrams(_ first: String, _ second: String) -> Bool {
        guard first.utf8.count == second.utf8.count else { return false }
        var counts = [Int](repeating: 0, count: 26)
        for byte in first.utf8 {
            counts[Int(byte - 97)] += 1
        }
        for byte in second.utf8 {
            counts[Int(byte - 97)] -= 1
        }
        return counts.allSatisfy { $0 == 0 }
    }
}
