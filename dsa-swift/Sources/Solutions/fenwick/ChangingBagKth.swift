// Reference solution: Kth smallest in a changing bag. Values are at most 1,000,000, so keep a Fenwick
// tree indexed by value, holding how many copies of each value are in the bag, plus a plain array of
// the same counts to check that a removal is possible. The kth smallest is the first value whose
// running count reaches k, found by binary lifting: from the largest power of two down, jump over a
// block of values whenever it holds fewer than the scores still needed. O(log V) per operation,
// O(V) space, for V = 1,000,000.

public enum ChangingBagKth {
    private static let largestValue = 1_000_000

    public static func process(_ operations: [[Int]]) -> [Int] {
        var tree = Array(repeating: 0, count: largestValue + 1)   // 1-indexed by value
        var copies = Array(repeating: 0, count: largestValue + 1)
        var size = 0
        var highestStep = 1
        while highestStep * 2 <= largestValue { highestStep *= 2 }

        func change(_ value: Int, by delta: Int) {
            var i = value
            while i <= largestValue {
                tree[i] += delta
                i += i & -i
            }
        }

        var answers: [Int] = []
        for operation in operations {
            switch operation[0] {
            case 0:
                change(operation[1], by: 1)
                copies[operation[1]] += 1
                size += 1
            case 1:
                guard copies[operation[1]] > 0 else { continue }  // not in the bag: nothing happens
                change(operation[1], by: -1)
                copies[operation[1]] -= 1
                size -= 1
            default:
                let k = operation[1]
                guard k <= size else {
                    answers.append(-1)
                    continue
                }
                var position = 0, remaining = k, step = highestStep
                while step > 0 {
                    let next = position + step
                    if next <= largestValue && tree[next] < remaining {
                        position = next                           // values up to next hold too few
                        remaining -= tree[next]
                    }
                    step /= 2
                }
                answers.append(position + 1)
            }
        }
        return answers
    }
}
