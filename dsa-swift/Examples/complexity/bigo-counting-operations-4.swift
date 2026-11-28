// Generated from src/dsa/content/lessons/complexity/bigo-counting-operations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = Array(1...1_000)
var checks = 0
for target in [10, 500, 2_000] {
    if numbers.contains(where: { value in
        checks += 1
        return value == target
    }) {
        print(target, "found")
    } else {
        print(target, "missing")
    }
}
print("comparisons:", checks)
