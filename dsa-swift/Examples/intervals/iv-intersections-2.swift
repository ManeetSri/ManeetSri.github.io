// Generated from src/dsa/content/lessons/intervals/iv-intersections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func intersect(_ a: [[Int]], _ b: [[Int]]) -> [[Int]] {
    var result: [[Int]] = []
    var i = 0
    var j = 0
    while i < a.count && j < b.count {
        let start = max(a[i][0], b[j][0])
        let end = min(a[i][1], b[j][1])
        if start <= end {
            result.append([start, end])
        }
        // Whichever ends first can't overlap anything later in the other list
        if a[i][1] < b[j][1] {
            i += 1
        } else {
            j += 1
        }
    }
    return result
}

let frontDoor = [[0, 2], [5, 10], [13, 23], [24, 25]]
let backDoor = [[1, 5], [8, 12], [15, 24], [25, 26]]
print(intersect(frontDoor, backDoor))
