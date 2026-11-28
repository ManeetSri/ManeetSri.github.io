// Generated from src/dsa/content/lessons/intervals/iv-intersections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstSharedSlot(_ a: [[Int]], _ b: [[Int]], minutes: Int) -> [Int]? {
    var i = 0
    var j = 0
    while i < a.count && j < b.count {
        let start = max(a[i][0], b[j][0])
        let end = min(a[i][1], b[j][1])
        if end - start >= minutes {
            return [start, start + minutes]
        }
        if a[i][1] < b[j][1] { i += 1 } else { j += 1 }
    }
    return nil
}

let mayaFree = [[540, 600], [660, 720], [840, 960]]     // minutes after midnight
let omarFree = [[570, 615], [700, 780], [900, 1020]]
print(firstSharedSlot(mayaFree, omarFree, minutes: 30) ?? [])
print(firstSharedSlot(mayaFree, omarFree, minutes: 45) ?? [])
print(firstSharedSlot(mayaFree, omarFree, minutes: 90) ?? [])
