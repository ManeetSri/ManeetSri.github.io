// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-debounce-throttle.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Any number of requests while idle become one run; requests during a run become exactly one more
@MainActor
final class Coalescer {
    private var needsRun = false
    private var running: Task<Void, Never>?
    private let work: @MainActor () async -> Void

    init(_ work: @escaping @MainActor () async -> Void) {
        self.work = work
    }

    func setNeedsRun() {
        needsRun = true
        guard running == nil else { return }
        running = Task {
            while needsRun {
                needsRun = false
                await work()
            }
            running = nil
        }
    }

    func idle() async {
        await running?.value
    }
}

var fetches = 0
var badge: Coalescer?
badge = Coalescer {
    fetches += 1
    print("Fetching the unread count (fetch \(fetches))")
    if fetches == 1 {
        badge?.setNeedsRun() // another notification arrives while the first fetch runs
    }
}

for _ in 1...20 {
    badge?.setNeedsRun() // a burst of 20 push notifications
}
await badge?.idle()
print("21 requests, \(fetches) fetches")
