// Generated from src/dsa/content/lessons/linear-sorts/sort-cyclic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func missingAndRepeated(_ input: [Int]) -> (missing: [Int], repeated: [Int]) {
    var numbers = input                           // work on a copy, leaving the caller's array alone
    var i = 0
    while i < numbers.count {
        let home = numbers[i] - 1
        if numbers[i] != numbers[home] {
            numbers.swapAt(i, home)
        } else {
            i += 1
        }
    }
    print("after cyclic sort:", numbers)
    var missing: [Int] = []
    var repeated: [Int] = []
    for index in numbers.indices where numbers[index] != index + 1 {
        missing.append(index + 1)                 // nobody lives here…
        repeated.append(numbers[index])           // …except a spare copy
    }
    return (missing, repeated)
}

let result = missingAndRepeated([5, 3, 1, 3, 6, 1])
print("missing:", result.missing, "repeated:", result.repeated)
