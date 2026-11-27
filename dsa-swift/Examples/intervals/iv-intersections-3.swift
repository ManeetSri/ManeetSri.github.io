// Generated from src/dsa/content/lessons/intervals/iv-intersections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func commonFreeTime(_ schedules: [[[Int]]]) -> [[Int]] {
    // 1 and 2: every busy interval in one list, sorted and merged (touching blocks join)
    let all = schedules.flatMap { $0 }.sorted { $0[0] < $1[0] }
    var busy: [[Int]] = []
    for interval in all {
        if let last = busy.last, interval[0] <= last[1] {
            busy[busy.count - 1][1] = max(last[1], interval[1])
        } else {
            busy.append(interval)
        }
    }
    // 3. The gaps between merged blocks are free for everyone
    var free: [[Int]] = []
    for i in busy.indices.dropFirst() {
        free.append([busy[i - 1][1], busy[i][0]])
    }
    return free
}

let ana = [[9, 10], [12, 13], [16, 18]]
let ben = [[9, 11], [15, 16]]
let chloe = [[10, 11], [13, 14]]
print(commonFreeTime([ana, ben, chloe]))
