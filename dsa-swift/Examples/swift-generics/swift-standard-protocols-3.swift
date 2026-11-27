// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ClockTime: Comparable {
    var hour: Int
    var minute: Int

    static func < (lhs: ClockTime, rhs: ClockTime) -> Bool {
        if lhs.hour != rhs.hour {
            return lhs.hour < rhs.hour
        }
        return lhs.minute < rhs.minute
    }
}

let alarms = [ClockTime(hour: 9, minute: 30), ClockTime(hour: 7, minute: 45), ClockTime(hour: 9, minute: 5)]
let earliest = alarms.min()!
print(earliest.hour, earliest.minute)
for alarm in alarms.sorted() {
    print(alarm.hour, alarm.minute)
}
print(ClockTime(hour: 12, minute: 0) > ClockTime(hour: 11, minute: 59))
