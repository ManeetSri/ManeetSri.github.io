// Generated from src/dsa/content/lessons/intervals/iv-meeting-rooms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minRooms(_ meetings: [[Int]]) -> Int {
    var events: [(time: Int, change: Int)] = []
    for meeting in meetings {
        events.append((meeting[0], 1))      // a meeting starts: one more room in use
        events.append((meeting[1], -1))     // a meeting ends: one room freed
    }
    // By time; at the same time, -1 sorts before +1, so ends come first
    events.sort { ($0.time, $0.change) < ($1.time, $1.change) }
    var rooms = 0
    var most = 0
    for event in events {
        rooms += event.change
        most = max(most, rooms)
    }
    return most
}

print(minRooms([[0, 30], [5, 10], [15, 20], [10, 15], [25, 35], [8, 12]]))
print(minRooms([[1, 5], [5, 10], [10, 15]]))
print(minRooms([]))
