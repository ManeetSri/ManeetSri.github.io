// Generated from src/dsa/content/lessons/elementary-sorts/sort-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var leaderboard: [Int] = []              // kept sorted, highest first
for score in [40, 75, 60, 90, 75] {
    var position = leaderboard.count
    while position > 0 && leaderboard[position - 1] < score {
        position -= 1
    }
    leaderboard.insert(score, at: position)
    print(leaderboard)
}
