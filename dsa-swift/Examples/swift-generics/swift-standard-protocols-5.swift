// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ClockTime: CustomStringConvertible {
    var hour: Int
    var minute: Int

    var description: String {
        let paddedMinute = minute < 10 ? "0\(minute)" : "\(minute)"
        return "\(hour):\(paddedMinute)"
    }
}

let lunch = ClockTime(hour: 12, minute: 5)
print(lunch)
print("Lunch is at \(lunch)")
print([lunch, ClockTime(hour: 18, minute: 30)])
