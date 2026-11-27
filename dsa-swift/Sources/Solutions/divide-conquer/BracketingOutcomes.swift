// Reference solution: Every way to bracket a sum. Divide and conquer on the operators: in any full
// bracketing, one operator is applied last, and it splits the expression into a left part and a right
// part that are bracketed independently. So the values for a range of numbers are every left value
// combined with every right value, over every choice of last operator. Ranges repeat across different
// splits, so each range's list is memoised by (first, last) number: that's dynamic programming. The
// answer itself has Catalan(operators) values, which dominates the cost.

public enum BracketingOutcomes {
    public static func allValues(_ expression: String) -> [Int] {
        var numbers: [Int] = []
        var operators: [Character] = []
        var current = 0
        for character in expression {
            if let digit = character.wholeNumberValue {
                current = current * 10 + digit
            } else {
                numbers.append(current)
                operators.append(character)
                current = 0
            }
        }
        numbers.append(current)

        var memo: [[[Int]?]] = Array(repeating: Array(repeating: nil, count: numbers.count), count: numbers.count)

        // Every value of numbers[first...last] with the operators between them, one per bracketing
        func values(_ first: Int, _ last: Int) -> [Int] {
            if let known = memo[first][last] {
                return known
            }
            if first == last {
                return [numbers[first]]
            }
            var result: [Int] = []
            for split in first..<last {                     // operators[split] is applied last
                let left = values(first, split)
                let right = values(split + 1, last)
                for a in left {
                    for b in right {
                        switch operators[split] {
                        case "+": result.append(a + b)
                        case "-": result.append(a - b)
                        default: result.append(a * b)
                        }
                    }
                }
            }
            memo[first][last] = result
            return result
        }

        return values(0, numbers.count - 1).sorted()
    }
}
