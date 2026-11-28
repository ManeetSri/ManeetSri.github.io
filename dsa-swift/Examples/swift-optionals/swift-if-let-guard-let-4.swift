// Generated from src/dsa/content/lessons/swift-optionals/swift-if-let-guard-let.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func ticketMessage(seatText: String) -> String {
    guard let seat = Int(seatText) else {
        return "\"\(seatText)\" isn't a seat number"
    }
    guard seat >= 1 && seat <= 200 else {
        return "Seat \(seat) doesn't exist"
    }
    return "You're in seat \(seat), row \((seat - 1) / 20 + 1)"
}

print(ticketMessage(seatText: "57"))
print(ticketMessage(seatText: "A3"))
print(ticketMessage(seatText: "450"))
