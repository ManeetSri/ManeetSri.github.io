// Reference solution: Digit sums, recursively. Each call removes one digit, so digitSum makes
// d calls for a d-digit number: O(d) time and O(d) stack space. digitalRoot shrinks the number fast.

public enum RecursiveDigitSum {
    public static func digitSum(_ n: Int) -> Int {
        if n < 10 {
            return n                            // base case: a single digit
        }
        return n % 10 + digitSum(n / 10)        // last digit + digit sum of the rest
    }

    public static func digitalRoot(_ n: Int) -> Int {
        if n < 10 {
            return n
        }
        return digitalRoot(digitSum(n))
    }
}
