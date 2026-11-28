// Reference solution: Repaint for the longest run. A window can be made one letter with
// (length - count of its most common letter) changes, so it's valid while that's at most k. When the
// window becomes invalid it slides instead of growing, so its length is always the best found so far;
// `maxCount` never needs to go down, because only a bigger count can make a longer window valid.
// O(n) time, O(1) space.

public enum RepaintLongestRun {
    public static func longest(_ text: String, changes k: Int) -> Int {
        let bytes = Array(text.utf8)
        let a = UInt8(ascii: "A")
        var counts = [Int](repeating: 0, count: 26)
        var maxCount = 0
        var left = 0
        var best = 0
        for right in 0..<bytes.count {
            let slot = Int(bytes[right] - a)
            counts[slot] += 1
            maxCount = max(maxCount, counts[slot])
            if (right - left + 1) - maxCount > k {
                counts[Int(bytes[left] - a)] -= 1
                left += 1
            }
            best = max(best, right - left + 1)
        }
        return best
    }
}
