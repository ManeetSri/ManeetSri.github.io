// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-event-driven.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Facts the app announces, named in the past tense
enum AppEvent: Sendable {
    case orderPlaced(id: String, pence: Int)
    case signedOut
}

/// Gives every subscriber its own stream, and copies each published event into all of them
actor EventHub {
    private var subscribers: [AsyncStream<AppEvent>.Continuation] = []

    func subscribe() -> AsyncStream<AppEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: AppEvent.self)
        subscribers.append(continuation)
        return stream
    }

    func publish(_ event: AppEvent) {
        for subscriber in subscribers {
            subscriber.yield(event)
        }
    }

    func finish() {
        subscribers.forEach { $0.finish() }
    }
}

let hub = EventHub()

// Two features react to orders. Neither knows about the other, or about checkout.
let analyticsEvents = await hub.subscribe()
let analytics = Task {
    var sent: [String] = []
    for await event in analyticsEvents {
        switch event {
        case .orderPlaced(let id, let pence): sent.append("purchase \(id) value=\(pence)")
        case .signedOut: sent.append("sign_out")
        }
    }
    return sent
}

let badgeEvents = await hub.subscribe()
let badge = Task {
    var newOrders = 0
    for await event in badgeEvents {
        if case .orderPlaced = event { newOrders += 1 }
        if case .signedOut = event { newOrders = 0 }
    }
    return newOrders
}

// Checkout publishes facts and moves on. It never learns who listened.
await hub.publish(.orderPlaced(id: "A12", pence: 1850))
await hub.publish(.orderPlaced(id: "A13", pence: 420))
await hub.publish(.signedOut)
await hub.publish(.orderPlaced(id: "A14", pence: 990))
await hub.finish()

for line in await analytics.value {
    print("analytics:", line)
}
print("badge:", await badge.value, "new order")
