// Generated from src/dsa/content/lessons/interview-playbook/int-thinking-aloud.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestStreak(_ days: [Int]) -> Int {
    let opened = Set(days)
    var best = 0
    for day in opened where !opened.contains(day - 1) {   // a streak starts here
        var length = 1
        while opened.contains(day + length) {
            length += 1
        }
        best = max(best, length)
    }
    return best
}

print(longestStreak([5, 1, 3, 2, 9, 2, 10]))
print(longestStreak([]))
print(longestStreak([7, 7, 7]))
