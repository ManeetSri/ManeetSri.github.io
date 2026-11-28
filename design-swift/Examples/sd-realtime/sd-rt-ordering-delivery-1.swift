// Generated from src/dsa/design/content/lessons/sd-realtime/sd-rt-ordering-delivery.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// One message as the server delivers it: `seq` is its place in the conversation, assigned by the server
struct Delivery {
    let seq: Int
    let text: String
}

/// Appends whatever arrives, in arrival order
struct NaiveThread {
    private(set) var lines: [String] = []

    mutating func apply(_ delivery: Delivery) {
        lines.append(delivery.text)
    }
}

/// Keyed by the server's sequence number: a redelivery overwrites itself, and order comes from the server
struct KeyedThread {
    private var bySeq: [Int: String] = [:]
    private(set) var duplicates = 0

    var lines: [String] { bySeq.keys.sorted().compactMap { bySeq[$0] } }

    mutating func apply(_ delivery: Delivery) {
        if bySeq[delivery.seq] != nil { duplicates += 1 }
        bySeq[delivery.seq] = delivery.text
    }
}

// At-least-once delivery on a flaky connection: a resend after a reconnect, one message overtaken
// by the next on another path, and a replay of the start when the app reopened the conversation
let arrivals = [
    Delivery(seq: 1, text: "Hi"),
    Delivery(seq: 2, text: "Are you there?"),
    Delivery(seq: 2, text: "Are you there?"),
    Delivery(seq: 4, text: "See you at 6"),
    Delivery(seq: 3, text: "Running late"),
    Delivery(seq: 1, text: "Hi"),
]

var naive = NaiveThread()
var keyed = KeyedThread()
for delivery in arrivals {
    naive.apply(delivery)
    keyed.apply(delivery)
}
print("Appended as they arrived: \(naive.lines.joined(separator: " | "))")
print("Keyed by sequence number: \(keyed.lines.joined(separator: " | "))")
print("Duplicates absorbed: \(keyed.duplicates)")
