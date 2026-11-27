// Generated from src/dsa/content/lessons/bs-on-answer/bsa-aggressive-cows.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cowsPlaced(_ sortedStalls: [Int], gap: Int) -> [Int] {
    var chosen = [sortedStalls[0]]
    for stall in sortedStalls.dropFirst() where stall - chosen[chosen.count - 1] >= gap {
        chosen.append(stall)
    }
    return chosen
}

let stalls = [3, 14, 1, 9, 6, 17].sorted()
print(stalls)
for gap in [3, 5, 8, 9] {
    let chosen = cowsPlaced(stalls, gap: gap)
    print("gap \(gap): \(chosen.count) cows at \(chosen)")
}
