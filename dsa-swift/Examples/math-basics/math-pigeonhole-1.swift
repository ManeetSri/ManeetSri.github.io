// Generated from src/dsa/content/lessons/math-basics/math-pigeonhole.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstDuplicate(_ numbers: [Int]) -> Int? {
    var seen = Array(repeating: false, count: numbers.count)
    for x in numbers {
        if seen[x] {
            return x
        }
        seen[x] = true
    }
    return nil
}

print(firstDuplicate([3, 1, 4, 2, 4]) ?? -1)
