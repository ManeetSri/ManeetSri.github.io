// Generated from src/dsa/content/lessons/intervals/iv-non-overlapping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minArrows(_ balloons: [[Int]]) -> Int {
    let sorted = balloons.sorted { $0[1] < $1[1] }
    var arrows = 0
    var arrowAt = Int.min
    for balloon in sorted {
        if balloon[0] > arrowAt {               // the last arrow missed this balloon
            arrows += 1
            arrowAt = balloon[1]                // shoot as far right as this balloon allows
            print("arrow at", arrowAt)
        }
    }
    return arrows
}

print(minArrows([[10, 16], [2, 8], [1, 6], [7, 12], [12, 14]]))
