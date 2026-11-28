// Generated from src/dsa/content/lessons/swift-types/swift-structs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Duration {
    var totalSeconds: Int

    var minutes: Int {
        get { totalSeconds / 60 }
        set { totalSeconds = newValue * 60 + totalSeconds % 60 }
    }
}

var run = Duration(totalSeconds: 135)
print(run.minutes)
run.minutes = 5
print(run.totalSeconds)
