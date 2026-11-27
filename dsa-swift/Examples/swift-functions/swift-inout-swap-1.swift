// Generated from src/dsa/content/lessons/swift-functions/swift-inout-swap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func resetFirst(_ scores: [Int]) {
    var copy = scores
    copy[0] = 0
    print("Inside: \(copy)")
}

var myScores = [7, 9, 4]
resetFirst(myScores)
print("Outside: \(myScores)")
