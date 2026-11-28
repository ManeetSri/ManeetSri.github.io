// Generated from src/dsa/design/content/lessons/sd-diagnostics/sd-diag-production-debugging.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Where does this crash concentrate? Compare each group's share of the crashes with its share of sessions.
// A group with 4% of sessions and 58% of crashes is a lead; one with 31% of each is just a big group.
struct Slice {
    let dimension: String
    let value: String
    let sessionShare: Double     // share of all 5.2.0 sessions
    let crashShare: Double       // share of this crash's reports
}

let slices = [
    Slice(dimension: "device", value: "iPhone 15", sessionShare: 0.31, crashShare: 0.30),
    Slice(dimension: "device", value: "iPhone 12", sessionShare: 0.12, crashShare: 0.13),
    Slice(dimension: "os", value: "iOS 18.4", sessionShare: 0.64, crashShare: 0.66),
    Slice(dimension: "locale", value: "en_GB", sessionShare: 0.71, crashShare: 0.06),
    Slice(dimension: "locale", value: "de_DE", sessionShare: 0.04, crashShare: 0.58),
    Slice(dimension: "locale", value: "fr_FR", sessionShare: 0.03, crashShare: 0.33),
    Slice(dimension: "network", value: "cellular", sessionShare: 0.38, crashShare: 0.40),
]

// Lift: how many times more often a group appears among the crashes than among all sessions
let ranked = slices
    .map { (slice: $0, lift: $0.crashShare / $0.sessionShare) }
    .sorted { $0.lift > $1.lift }

for (slice, lift) in ranked {
    let flag = lift >= 3 ? "  <- look here" : ""
    let percent = Int((slice.crashShare * 100).rounded())
    print("\(slice.dimension)=\(slice.value): \(percent)% of crashes, lift \(String(format: "%.1f", lift))\(flag)")
}
