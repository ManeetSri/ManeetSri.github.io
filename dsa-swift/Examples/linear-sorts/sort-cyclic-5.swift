// Generated from src/dsa/content/lessons/linear-sorts/sort-cyclic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func findDuplicate(_ input: [Int]) -> Int? {
    var numbers = input
    var i = 0
    while i < numbers.count {
        let home = numbers[i] - 1
        if home == i {
            i += 1                                // already home
        } else if numbers[home] == numbers[i] {
            return numbers[i]                     // its home is taken by a copy of itself
        } else {
            numbers.swapAt(i, home)
        }
    }
    return nil
}

print(findDuplicate([2, 5, 1, 4, 5, 3]) ?? 0)
print(findDuplicate([1, 4, 4, 2, 4]) ?? 0)
