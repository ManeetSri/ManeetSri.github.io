// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-state-machines.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Connection: Equatable {
    case bluetoothOff
    case idle
    case scanning
    case connecting(device: String, attempt: Int)
    case connected(device: String)
}

enum Event {
    case poweredOn, poweredOff
    case scanTapped, cancelTapped
    case discovered(device: String)
    case didConnect, didFailToConnect, timedOut
    case didDisconnect
}

extension Connection {
    static let maxAttempts = 3

    /// The next state, or nil when the event can't happen in this state
    static func next(_ state: Connection, _ event: Event) -> Connection? {
        switch (state, event) {
        case (_, .poweredOff):
            return .bluetoothOff
        case (.bluetoothOff, .poweredOn):
            return .idle
        case (.idle, .scanTapped):
            return .scanning
        case (.scanning, .discovered(let device)):
            return .connecting(device: device, attempt: 1)
        case (.connecting(let device, _), .didConnect):
            return .connected(device: device)
        case (.connecting(let device, let attempt), .didFailToConnect),
             (.connecting(let device, let attempt), .timedOut):
            return attempt < maxAttempts ? .connecting(device: device, attempt: attempt + 1) : .idle
        case (.connected(let device), .didDisconnect):
            return .connecting(device: device, attempt: 1)
        case (.scanning, .cancelTapped), (.connecting, .cancelTapped), (.connected, .cancelTapped):
            return .idle
        default:
            return nil
        }
    }
}

let events: [Event] = [
    .poweredOn, .scanTapped, .discovered(device: "Polar H10"), .timedOut, .didConnect,
    .didDisconnect, .scanTapped, .cancelTapped, .didConnect, .poweredOff,
]

var state = Connection.bluetoothOff
for event in events {
    if let next = Connection.next(state, event) {
        state = next
        print("\(event) → \(state)")
    } else {
        print("\(event) refused in \(state)")
    }
}
