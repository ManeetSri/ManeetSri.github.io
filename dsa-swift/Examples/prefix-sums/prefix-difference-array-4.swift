// Generated from src/dsa/content/lessons/prefix-sums/prefix-difference-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let meetings = [9..<11, 10..<12, 10..<11, 13..<15]

var diff = Array(repeating: 0, count: 25)
for meeting in meetings {
    diff[meeting.lowerBound] += 1     // a meeting starts
    diff[meeting.upperBound] -= 1     // and stops being counted at its end hour
}

var running = 0
var busiestHour = 0
var most = 0
for hour in 0..<24 {
    running += diff[hour]
    if running > most {
        most = running
        busiestHour = hour
    }
}
print("busiest hour \(busiestHour):00 with \(most) meetings")
