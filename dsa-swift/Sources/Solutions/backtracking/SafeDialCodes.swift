// Reference solution: Codes for a safe dial. Backtracking with the choose, explore, unchoose template:
// the state is the digits chosen so far and their sum, the choices are the digits 0...9, and two rules
// prune a choice before the recursive call: it can't equal the previous digit, and after it the sum
// must stay reachable (no more than the target, and the remaining digits, at 9 each, must be able to
// make up the rest). Digits are tried in increasing order, so codes come out sorted. The tree has at
// most 10 · 9^(length - 1) leaves, but pruning visits only branches that lead to answers or die early.

public enum SafeDialCodes {
    public static func codes(length: Int, digitSum: Int) -> [String] {
        var code: [Int] = []                                  // the state: the path from the root
        var found: [String] = []
        func explore(_ sum: Int) {
            if code.count == length {                         // goal: a complete code
                if sum == digitSum { found.append(code.map(String.init).joined()) }
                return
            }
            let remainingAfter = length - code.count - 1      // digits still to choose after this one
            for digit in 0...9 where digit != code.last {
                let newSum = sum + digit
                if newSum > digitSum { break }                // bigger digits only overshoot further
                if newSum + 9 * remainingAfter < digitSum { continue }   // can't catch up any more
                code.append(digit)                            // choose
                explore(newSum)                               // explore
                code.removeLast()                             // unchoose
            }
        }
        explore(0)
        return found
    }
}
