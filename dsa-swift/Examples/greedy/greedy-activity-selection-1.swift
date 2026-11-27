// Generated from src/dsa/content/lessons/greedy/greedy-activity-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let bookings = [
    (name: "podcast", start: 9, end: 11),
    (name: "choir", start: 10, end: 12),
    (name: "drums", start: 11, end: 13),
    (name: "voiceover", start: 9, end: 10),
    (name: "band", start: 12, end: 16),
    (name: "strings", start: 13, end: 14),
    (name: "audiobook", start: 14, end: 17),
]

var accepted: [String] = []
var freeFrom = Int.min                       // when the studio is next free
for booking in bookings.sorted(by: { $0.end < $1.end }) where booking.start >= freeFrom {
    accepted.append(booking.name)
    freeFrom = booking.end
}
print(accepted)
