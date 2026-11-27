// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func applyToAll(_ numbers: [Int], _ transform: (Int) -> Int) -> [Int] {
    var result: [Int] = []
    for number in numbers {
        result.append(transform(number))
    }
    return result
}

func double(_ n: Int) -> Int { n * 2 }
func square(_ n: Int) -> Int { n * n }
func negate(_ n: Int) -> Int { -n }

let numbers = [1, 2, 3, 4]
print(applyToAll(numbers, double))
print(applyToAll(numbers, square))
print(applyToAll(numbers, negate))
