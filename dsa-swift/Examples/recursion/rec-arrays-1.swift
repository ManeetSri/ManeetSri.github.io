// Generated from src/dsa/content/lessons/recursion/rec-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copied = 0

func sumByCopying(_ items: [Int]) -> Int {
    if items.isEmpty {
        return 0
    }
    let rest = Array(items.dropFirst())    // a brand-new array
    copied += rest.count
    return items[0] + sumByCopying(rest)
}

for n in [10, 100, 1_000] {
    copied = 0
    let total = sumByCopying(Array(1...n))
    print("n = \(n): sum \(total), \(copied) elements copied")
}
