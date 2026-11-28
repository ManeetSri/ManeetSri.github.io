// Generated from src/dsa/content/lessons/elementary-sorts/sort-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var lapTimes = [58, 41, 73, 39, 66, 45, 80, 52]
let k = 3
for i in 0..<min(k, lapTimes.count) {
    var smallest = i
    for j in (i + 1)..<lapTimes.count where lapTimes[j] < lapTimes[smallest] {
        smallest = j
    }
    lapTimes.swapAt(i, smallest)
}
print("podium:", lapTimes[..<k])
