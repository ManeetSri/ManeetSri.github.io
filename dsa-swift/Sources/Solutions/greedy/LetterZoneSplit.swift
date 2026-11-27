// Reference solution: Split a string into letter zones. Record each letter's last index, then walk the
// string extending the current zone's end to the furthest last index of any letter in it. When the
// index reaches that end, every letter in the zone has finished, so cut there. The greedy cuts at
// exactly the positions where a cut is allowed, which gives the most zones. O(n) time, O(1) extra
// space (26 counters).

public enum LetterZoneSplit {
    public static func zoneLengths(_ text: String) -> [Int] {
        let letters = Array(text.utf8).map { Int($0) - 97 }      // a...z as 0...25
        var last = Array(repeating: -1, count: 26)
        for (i, letter) in letters.enumerated() {
            last[letter] = i
        }
        var lengths: [Int] = []
        var start = 0
        var end = 0
        for (i, letter) in letters.enumerated() {
            end = max(end, last[letter])
            if i == end {
                lengths.append(i - start + 1)
                start = i + 1
            }
        }
        return lengths
    }
}
