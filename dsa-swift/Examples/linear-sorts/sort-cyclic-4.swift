// Generated from src/dsa/content/lessons/linear-sorts/sort-cyclic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func missingNumber(_ input: [Int]) -> Int {
    var numbers = input
    var i = 0
    while i < numbers.count {
        let home = numbers[i]                     // value v belongs at index v
        if home < numbers.count && numbers[i] != numbers[home] {
            numbers.swapAt(i, home)
        } else {
            i += 1                                // already home, or it's n, which has no home
        }
    }
    for index in numbers.indices where numbers[index] != index {
        return index
    }
    return numbers.count
}

print(missingNumber([4, 0, 3, 1]))
print(missingNumber([1, 0]))
