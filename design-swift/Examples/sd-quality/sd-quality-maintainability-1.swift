// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-maintainability.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct TrialBanner {
    let trialLength = 14
    let calendar: Calendar

    func text(trialStart: Date, now: Date) -> String {
        let used = calendar.dateComponents([.day], from: trialStart, to: now).day ?? 0
        switch trialLength - used {
        case ...0: return "Your trial has ended"
        case 1: return "Last day of your trial"
        case let left: return "\(left) days left in your trial"
        }
    }
}

var calendar = Calendar(identifier: .gregorian)
calendar.timeZone = TimeZone(identifier: "Europe/London")!
let banner = TrialBanner(calendar: calendar)
let start = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1, hour: 9))!

for day in [1, 14, 15, 20] {
    let now = calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: 10))!
    print("March \(day): \(banner.text(trialStart: start, now: now))")
}
