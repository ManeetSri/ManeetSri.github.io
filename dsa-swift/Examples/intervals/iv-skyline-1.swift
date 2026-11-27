// Generated from src/dsa/content/lessons/intervals/iv-skyline.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func skylineBruteForce(_ buildings: [[Int]]) -> [[Int]] {
    let edges = Set(buildings.flatMap { [$0[0], $0[1]] }).sorted()
    var points: [[Int]] = []
    for x in edges {
        var height = 0
        for building in buildings where building[0] <= x && x < building[1] {
            height = max(height, building[2])
        }
        if points.last?[1] != height {          // a change of height is a key point
            points.append([x, height])
        }
    }
    return points
}

print(skylineBruteForce([[1, 5, 3], [2, 4, 6], [3, 8, 4], [10, 12, 2]]))
