// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-async-streams.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Connection: Sendable {
    case offline, connecting, online
}

// One source, many listeners: every subscriber gets its own stream, starting with the current state
actor ConnectionStatus {
    private var current = Connection.offline
    private var subscribers: [Int: AsyncStream<Connection>.Continuation] = [:]
    private var nextID = 0

    func updates() -> AsyncStream<Connection> {
        let (stream, continuation) = AsyncStream.makeStream(of: Connection.self)
        let id = nextID
        nextID += 1
        subscribers[id] = continuation
        continuation.onTermination = { _ in
            Task { await self.unsubscribe(id) }
        }
        continuation.yield(current)
        return stream
    }

    func set(_ state: Connection) {
        current = state
        for continuation in subscribers.values {
            continuation.yield(state)
        }
    }

    func finishAll() {
        for continuation in subscribers.values {
            continuation.finish()
        }
    }

    private func unsubscribe(_ id: Int) {
        subscribers[id] = nil
    }
}

func collect(_ stream: AsyncStream<Connection>) async -> [Connection] {
    var states: [Connection] = []
    for await state in stream {
        states.append(state)
    }
    return states
}

let status = ConnectionStatus()
let banner = await status.updates()
await status.set(.connecting)
await status.set(.online)
let syncEngine = await status.updates()   // subscribes late
await status.set(.offline)
await status.finishAll()

print("banner:     ", await collect(banner).map { "\($0)" }.joined(separator: " → "))
print("sync engine:", await collect(syncEngine).map { "\($0)" }.joined(separator: " → "))
