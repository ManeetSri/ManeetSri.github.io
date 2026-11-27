// Generated from src/dsa/content/lessons/dp-knapsack/dpk-last-stone.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Two piles from the DP: 12 + 5 = 17 and 8 + 3 + 9 = 20. Smash one stone from each pile at a time,
// and put whatever is left back on the pile of the heavier stone.
var heavier = [8, 3, 9]
var lighter = [12, 5]
while !heavier.isEmpty && !lighter.isEmpty {
    let a = heavier.removeLast()
    let b = lighter.removeLast()
    if a > b {
        heavier.append(a - b)
    } else if b > a {
        lighter.append(b - a)
    }
    let gap = heavier.reduce(0, +) - lighter.reduce(0, +)
    print("smash \(a) and \(b): piles \(heavier) and \(lighter), gap \(gap)")
}
