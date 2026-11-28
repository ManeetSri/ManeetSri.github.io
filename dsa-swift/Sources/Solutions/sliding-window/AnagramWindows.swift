// Reference solution: Anagram windows. A window as long as the pattern slides over the text, with
// 26-slot counts for the pattern and the window. `matches` is the number of slots where the two
// counts agree; each slide changes two slots, so `matches` is updated in O(1), and the window is an
// anagram exactly when all 26 slots agree. O(n + m) time, O(1) space besides the result.

public enum AnagramWindows {
    public static func starts(of pattern: String, in text: String) -> [Int] {
        let p = Array(pattern.utf8)
        let t = Array(text.utf8)
        let m = p.count
        guard m > 0, m <= t.count else { return [] }
        let a = UInt8(ascii: "a")
        var need = [Int](repeating: 0, count: 26)
        var have = [Int](repeating: 0, count: 26)
        for byte in p {
            need[Int(byte - a)] += 1
        }
        var matches = 0
        for slot in 0..<26 where need[slot] == 0 {
            matches += 1                        // both counts start at zero
        }

        // Changes one slot of the window's counts and keeps `matches` up to date
        func change(_ slot: Int, by delta: Int) {
            if have[slot] == need[slot] { matches -= 1 }
            have[slot] += delta
            if have[slot] == need[slot] { matches += 1 }
        }

        var result: [Int] = []
        for right in 0..<t.count {
            change(Int(t[right] - a), by: 1)
            if right >= m {
                change(Int(t[right - m] - a), by: -1)
            }
            if right >= m - 1 && matches == 26 {
                result.append(right - m + 1)
            }
        }
        return result
    }
}
