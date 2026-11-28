// Reference solution: Reverse words in a character buffer. Squeeze the spaces with read/write pointers,
// reverse the whole array so the words are in the right order but spelled backwards, then reverse each
// word back. O(n) time, O(1) extra space.

public enum WordBufferReversal {
    public static func reverseWords(_ chars: inout [Character]) {
        // 1. Squeeze: one space between words, none at the ends
        var write = 0
        var read = 0
        while read < chars.count {
            if chars[read] == " " {
                read += 1
                continue
            }
            if write > 0 {
                chars[write] = " "                    // a separator before every word but the first
                write += 1
            }
            while read < chars.count && chars[read] != " " {
                chars[write] = chars[read]
                write += 1
                read += 1
            }
        }
        chars.removeLast(chars.count - write)

        // 2. Reverse everything, then 3. reverse each word back
        reverse(&chars, from: 0, to: chars.count - 1)
        var start = 0
        for index in 0...chars.count where index == chars.count || chars[index] == " " {
            reverse(&chars, from: start, to: index - 1)
            start = index + 1
        }
    }

    private static func reverse(_ chars: inout [Character], from start: Int, to end: Int) {
        var left = start
        var right = end
        while left < right {
            chars.swapAt(left, right)
            left += 1
            right -= 1
        }
    }
}
