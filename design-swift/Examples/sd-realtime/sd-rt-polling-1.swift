// Generated from src/dsa/design/content/lessons/sd-realtime/sd-rt-polling.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// How long to wait before the next poll: soon while things are changing, longer while they aren't
struct PollSchedule {
    let fastest: Int
    let slowest: Int
    private(set) var interval: Int

    init(fastest: Int, slowest: Int) {
        self.fastest = fastest
        self.slowest = slowest
        interval = fastest
    }

    mutating func next(changed: Bool, serverMinimum: Int? = nil) -> Int {
        // A change means someone is active: look again soon. Nothing new: wait twice as long.
        interval = changed ? fastest : min(slowest, interval * 2)
        // The server can always ask for less traffic, never more
        if let serverMinimum {
            interval = max(interval, serverMinimum)
        }
        return interval
    }
}

var schedule = PollSchedule(fastest: 5, slowest: 60)
let polls: [(changed: Bool, serverMinimum: Int?)] = [
    (false, nil), (false, nil), (false, nil), (true, nil), (false, nil), (false, 30), (false, nil), (false, nil),
]
var now = 0
for (index, poll) in polls.enumerated() {
    let wait = schedule.next(changed: poll.changed, serverMinimum: poll.serverMinimum)
    let result = poll.changed ? "changed" : "no change"
    let hint = poll.serverMinimum.map { ", server asks for \($0) s" } ?? ""
    print("Poll \(index + 1) at \(now) s: \(result)\(hint), next in \(wait) s")
    now += wait
}
