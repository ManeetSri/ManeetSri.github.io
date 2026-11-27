// Generated from src/dsa/content/lessons/intervals/iv-meeting-rooms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func canAttendAll(_ meetings: [[Int]]) -> Bool {
    let sorted = meetings.sorted { $0[0] < $1[0] }
    for i in sorted.indices.dropFirst() {
        if sorted[i][0] < sorted[i - 1][1] {          // starts before the previous one ends
            print("clash:", sorted[i - 1], sorted[i])
            return false
        }
    }
    return true
}

print(canAttendAll([[9, 10], [13, 14], [10, 12]]))
print(canAttendAll([[9, 10], [13, 15], [10, 12], [14, 16]]))
