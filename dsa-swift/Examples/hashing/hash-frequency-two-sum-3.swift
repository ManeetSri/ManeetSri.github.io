// Generated from src/dsa/content/lessons/hashing/hash-frequency-two-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func twoSum(_ numbers: [Int], _ target: Int) -> (Int, Int)? {
    var indexOf: [Int: Int] = [:]            // value -> an index where it appeared
    for (index, number) in numbers.enumerated() {
        if let partner = indexOf[target - number] {
            return (partner, index)
        }
        indexOf[number] = index              // record it only after checking
    }
    return nil
}

if let (i, j) = twoSum([8, 3, 11, 5, 1], 16) {
    print(i, j)
}
if let (i, j) = twoSum([3, 3], 6) {
    print(i, j)
}
print(twoSum([3, 5], 6) == nil)
