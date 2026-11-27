// Generated from src/dsa/content/lessons/intervals/iv-merge-insert.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Interval {
    let start: Int
    let end: Int
}

let asStructs = [Interval(start: 1, end: 3), Interval(start: 5, end: 8)]
let asTuples = [(start: 1, end: 3), (start: 5, end: 8)]
let asPairs = [[1, 3], [5, 8]]

print(asStructs[1].end, asTuples[1].end, asPairs[1][1])
print(asStructs[0])
print(asPairs)
print(asPairs == [[1, 3], [5, 8]])
