// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-pure.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct OpeningHours {
    /// Weekday (1 is Sunday) to opening time, in minutes after midnight
    let byWeekday: [Int: Range<Int>]
}

func statusLabel(for hours: OpeningHours, at now: Date, in calendar: Calendar) -> String {
    let parts = calendar.dateComponents([.weekday, .hour, .minute], from: now)
    guard let weekday = parts.weekday, let hour = parts.hour, let minute = parts.minute else { return "Closed" }
    let minutes = hour * 60 + minute
    guard let open = hours.byWeekday[weekday], open.contains(minutes) else { return "Closed" }
    if open.upperBound - minutes <= 30 { return "Closing soon" }
    return "Open until " + String(format: "%02d:%02d", open.upperBound / 60, open.upperBound % 60)
}

var london = Calendar(identifier: .gregorian)
london.timeZone = TimeZone(identifier: "Europe/London")!
var newYork = london
newYork.timeZone = TimeZone(identifier: "America/New_York")!

let hours = OpeningHours(byWeekday: [2: 480..<1050, 1: 600..<960])   // Monday 08:00–17:30, Sunday 10:00–16:00
let mondayMorning = london.date(from: DateComponents(year: 2025, month: 3, day: 3, hour: 9, minute: 15))!
let mondayLate = mondayMorning.addingTimeInterval(8 * 3600)          // 17:15 in London

print(statusLabel(for: hours, at: mondayMorning, in: london))
print(statusLabel(for: hours, at: mondayLate, in: london))
print(statusLabel(for: hours, at: mondayMorning, in: newYork))
