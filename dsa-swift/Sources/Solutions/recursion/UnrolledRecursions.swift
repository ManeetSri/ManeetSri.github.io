// Reference solution: Unroll two recursions. survivor builds its answer on the way back up, so loop
// bottom up from the base case; hops is tail-recursive, so its parameters become loop variables.
// O(n) time, O(1) space.

public enum UnrolledRecursions {
    public static func survivor(people n: Int, step k: Int) -> Int {
        var answer = 0                       // survivor(1, k)
        if n >= 2 {                          // 2...1 would trap
            for m in 2...n {
                answer = (answer + k) % m    // survivor(m, k) from survivor(m − 1, k)
            }
        }
        return answer
    }

    public static func hops(_ jumps: [Int]) -> Int {
        var position = 0
        var count = 0
        while position < jumps.count {       // the base case's condition, negated
            position += jumps[position]
            count += 1
        }
        return count
    }
}
