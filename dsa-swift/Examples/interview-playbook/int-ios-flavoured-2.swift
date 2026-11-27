// Generated from src/dsa/content/lessons/interview-playbook/int-ios-flavoured.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Debounce: fire `delay` ms after the last event of each burst
func debounce(_ times: [Int], delay: Int) -> [Int] {
    var fires: [Int] = []
    for (index, time) in times.enumerated() {
        let isLast = index == times.count - 1
        if isLast || times[index + 1] - time >= delay {   // the next event is too late to cancel
            fires.append(time + delay)
        }
    }
    return fires
}

// Throttle: act on an event, then ignore events for `interval` ms
func throttle(_ times: [Int], interval: Int) -> [Int] {
    var accepted: [Int] = []
    for time in times {
        if let last = accepted.last, time - last < interval { continue }
        accepted.append(time)
    }
    return accepted
}

let events = [0, 100, 150, 400, 1000, 1050, 1100, 1700]
print(debounce(events, delay: 300))
print(throttle(events, interval: 300))
