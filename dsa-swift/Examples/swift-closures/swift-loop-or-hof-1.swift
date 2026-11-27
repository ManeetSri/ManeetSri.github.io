// Generated from src/dsa/content/lessons/swift-closures/swift-loop-or-hof.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = Array(1...1_000)

var checks = 0
let viaFilter = numbers.filter { n in
    checks += 1
    return n > 100
}.first
print(viaFilter ?? -1, "after", checks, "checks")

checks = 0
let viaFirst = numbers.first { n in
    checks += 1
    return n > 100
}
print(viaFirst ?? -1, "after", checks, "checks")

func firstOver(_ limit: Int, in values: [Int]) -> Int? {
    for value in values {
        if value > limit {
            return value
        }
    }
    return nil
}
print(firstOver(100, in: numbers) ?? -1)
