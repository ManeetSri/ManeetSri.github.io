// Generated from src/dsa/content/lessons/two-pointers/tp-opposite-ends.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pairWithSum(_ items: [Int], _ target: Int) -> (Int, Int)? {
    var left = 0
    var right = items.count - 1
    while left < right {
        let sum = items[left] + items[right]
        if sum == target {
            return (left, right)
        } else if sum < target {
            left += 1
        } else {
            right -= 1
        }
    }
    return nil
}

let items = [1, 3, 4, 6, 8, 11, 14]
for target in [14, 19, 2] {
    if let (i, j) = pairWithSum(items, target) {
        print("target \(target): items[\(i)] + items[\(j)] = \(items[i]) + \(items[j])")
    } else {
        print("target \(target): no pair")
    }
}
