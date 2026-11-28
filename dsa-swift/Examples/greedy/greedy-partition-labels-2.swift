// Generated from src/dsa/content/lessons/greedy/greedy-partition-labels.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Each person is [height, k]: k people of the same height or taller stand in front of them
func rebuildQueue(_ people: [[Int]]) -> [[Int]] {
    // Tallest first; equal heights in increasing k
    let order = people.sorted { $0[0] != $1[0] ? $0[0] > $1[0] : $0[1] < $1[1] }
    var queue: [[Int]] = []
    for person in order {
        queue.insert(person, at: person[1])       // everyone already in the line counts
        print(person, "->", queue)
    }
    return queue
}

_ = rebuildQueue([[4, 4], [7, 0], [5, 2], [6, 0], [4, 1], [6, 2]])
