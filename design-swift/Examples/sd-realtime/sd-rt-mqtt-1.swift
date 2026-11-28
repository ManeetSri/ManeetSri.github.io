// Generated from src/dsa/design/content/lessons/sd-realtime/sd-rt-mqtt.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// Does an MQTT topic filter match a topic? `+` matches exactly one level; `#` matches the rest, if any.
func matches(filter: String, topic: String) -> Bool {
    let filterLevels = filter.split(separator: "/", omittingEmptySubsequences: false)
    let topicLevels = topic.split(separator: "/", omittingEmptySubsequences: false)
    // A filter starting with a wildcard never matches broker topics such as $SYS/…
    if topic.hasPrefix("$"), filterLevels.first == "+" || filterLevels.first == "#" {
        return false
    }
    for (index, level) in filterLevels.enumerated() {
        if level == "#" { return true }              // only valid as the last level
        guard index < topicLevels.count else { return false }
        if level != "+", level != topicLevels[index] { return false }
    }
    return filterLevels.count == topicLevels.count
}

let topics = [
    "home/kitchen/temperature", "home/kitchen/humidity", "home/garage/door",
    "home", "garden/sprinkler", "$SYS/broker/clients",
]
for filter in ["home/kitchen/temperature", "home/+/temperature", "home/kitchen/+", "home/#", "+/+", "#"] {
    let hits = topics.filter { matches(filter: filter, topic: $0) }
    print("\(filter) → \(hits.isEmpty ? "nothing" : hits.joined(separator: ", "))")
}
