// Reference solution: Binary strings without adjacent 1s. Build each string one character at a time,
// trying "0" before "1" so the results come out sorted, and only offering "1" when the previous
// character isn't one. Every call leads to at least one valid string, so the work is proportional
// to the output: about fib(n + 2) strings of n characters. O(n) stack space.

public enum NoAdjacentOnes {
    public static func strings(length: Int) -> [String] {
        var result: [String] = []
        var current: [Character] = []

        func build() {
            if current.count == length {
                result.append(String(current))          // a finished string
                return
            }
            current.append("0")                          // "0" is always allowed
            build()
            current.removeLast()
            if current.last != "1" {                     // "1" only after a "0" or at the start
                current.append("1")
                build()
                current.removeLast()
            }
        }

        build()
        return result
    }
}
