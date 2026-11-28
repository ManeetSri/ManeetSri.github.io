// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-debounce-throttle.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

typealias Keystroke = (at: Int, text: String)   // milliseconds since the first key

// "swift" typed at a steady pace, a pause, then one more letter
let typed: [Keystroke] = [(0, "s"), (120, "sw"), (250, "swi"), (380, "swif"), (500, "swift"), (1400, "swifty")]

// Debounce: send a value once `quiet` ms pass with no newer one
func debounce(_ events: [Keystroke], quiet: Int) -> [Keystroke] {
    events.indices.compactMap { index in
        let fireAt = events[index].at + quiet
        let next = index + 1 < events.count ? events[index + 1].at : Int.max
        return next < fireAt ? nil : (fireAt, events[index].text)
    }
}

// Throttle (leading edge): send a value, then ignore everything for `interval` ms
func throttle(_ events: [Keystroke], interval: Int) -> [Keystroke] {
    var sent: [Keystroke] = []
    for event in events {
        if let last = sent.last, event.at - last.at < interval { continue }
        sent.append(event)
    }
    return sent
}

func describe(_ events: [Keystroke]) -> String {
    events.map { "\"\($0.text)\" at \($0.at) ms" }.joined(separator: ", ")
}

print("Every keystroke:", typed.count, "searches")
print("Debounce 300 ms:", describe(debounce(typed, quiet: 300)))
print("Throttle 300 ms:", describe(throttle(typed, interval: 300)))
