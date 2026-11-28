// Reference solution: Compress runs in place. `read` finds the end of each run and `write` puts down its
// character and, for runs of 2 or more, every digit of its length. A run of length L never needs more
// than L characters, so `write` never overtakes `read`. O(n) time, O(1) extra space.

public enum InPlaceRunCompressor {
    public static func compress(_ chars: inout [Character]) -> Int {
        var write = 0
        var read = 0
        while read < chars.count {
            let character = chars[read]
            var runEnd = read
            while runEnd < chars.count && chars[runEnd] == character {
                runEnd += 1
            }
            chars[write] = character
            write += 1
            let length = runEnd - read
            if length > 1 {
                for digit in String(length) {             // every digit, for runs of 10 or more
                    chars[write] = digit
                    write += 1
                }
            }
            read = runEnd
        }
        return write
    }
}
