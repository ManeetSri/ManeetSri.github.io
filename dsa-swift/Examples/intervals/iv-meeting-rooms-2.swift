// Generated from src/dsa/content/lessons/intervals/iv-meeting-rooms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minRooms(_ meetings: [[Int]]) -> Int {
    let starts = meetings.map { $0[0] }.sorted()
    let ends = meetings.map { $0[1] }.sorted()
    var rooms = 0
    var most = 0
    var e = 0                                         // the next end to process
    for start in starts {
        while e < ends.count && ends[e] <= start {    // half-open: ending at `start` frees a room
            rooms -= 1
            e += 1
        }
        rooms += 1
        most = max(most, rooms)
        print("start \(start): \(rooms) in use")
    }
    return most
}

print(minRooms([[0, 30], [5, 10], [15, 20], [10, 15], [25, 35], [8, 12]]))
