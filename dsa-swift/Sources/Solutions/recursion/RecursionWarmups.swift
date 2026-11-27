// Reference solution: Three recursive warm-ups.
// bounce: n + 1 calls appending into one array, O(n) time and O(n) stack.
// power: halves the exponent, O(log e) calls and stack.
// count: one call per character, O(n) time and O(n) stack, with no copying.

public enum RecursionWarmups {
    public static func bounce(from n: Int) -> [Int] {
        var result: [Int] = []
        func walk(_ k: Int) {
            result.append(k)            // on the way down
            if k == 0 {
                return
            }
            walk(k - 1)
            result.append(k)            // on the way back up
        }
        walk(n)
        return result
    }

    public static func power(_ base: Int, _ exponent: Int) -> Int {
        if exponent == 0 {
            return 1
        }
        let half = power(base, exponent / 2)    // computed once, used twice
        if exponent % 2 == 0 {
            return half * half
        }
        return half * half * base
    }

    public static func count(of character: Character, in text: String) -> Int {
        let chars = Array(text)
        func countFrom(_ index: Int) -> Int {
            if index == chars.count {
                return 0
            }
            let here = chars[index] == character ? 1 : 0
            return here + countFrom(index + 1)
        }
        return countFrom(0)
    }
}
