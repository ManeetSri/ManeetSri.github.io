// Generated from src/dsa/content/lessons/divide-conquer/dc-max-subarray.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Four numbers per range make the combine step O(1)
struct Summary {
    let total: Int      // the sum of the whole range
    let prefix: Int     // the best run that starts at the range's left end
    let suffix: Int     // the best run that ends at the range's right end
    let best: Int       // the best run anywhere in the range
}

func combine(_ left: Summary, _ right: Summary) -> Summary {
    Summary(
        total: left.total + right.total,
        prefix: max(left.prefix, left.total + right.prefix),
        suffix: max(right.suffix, right.total + left.suffix),
        best: max(left.best, right.best, left.suffix + right.prefix)
    )
}

func summarise(_ numbers: [Int], _ low: Int, _ high: Int) -> Summary {
    if high - low == 1 {
        let value = numbers[low]
        return Summary(total: value, prefix: value, suffix: value, best: value)
    }
    let mid = low + (high - low) / 2
    return combine(summarise(numbers, low, mid), summarise(numbers, mid, high))
}

let left = summarise([-2, 1, -3, 4], 0, 4)
let right = summarise([-1, 2, 1, -5, 4], 0, 5)
print("left: ", left.total, left.prefix, left.suffix, left.best)
print("right:", right.total, right.prefix, right.suffix, right.best)
let whole = combine(left, right)
print("whole:", whole.total, whole.prefix, whole.suffix, whole.best)
print(summarise([-3, -1, -2], 0, 3).best)
