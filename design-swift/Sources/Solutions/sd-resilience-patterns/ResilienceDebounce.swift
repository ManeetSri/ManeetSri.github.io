// Reference solution: Debounce an async stream. One task reads upstream; each element replaces the
// pending one and restarts its timer. A timer that wakes checks it's still the newest before emitting, so
// a timer that lost the race to a newer element (or to cancellation) does nothing.

public enum ResilienceDebounce {
    public static func debounce<Element: Sendable>(_ upstream: AsyncStream<Element>, for quiet: Duration, clock: some Clock<Duration>) -> AsyncStream<Element> {
        let (output, continuation) = AsyncStream.makeStream(of: Element.self)
        let pending = Pending(output: continuation)
        let reader = Task {
            for await element in upstream {
                await pending.replace(with: element, after: quiet, on: clock)
            }
            // Upstream finished, or the consumer stopped and cancelled this task
            await pending.flush()
            continuation.finish()
        }
        continuation.onTermination = { _ in reader.cancel() }
        return output
    }

    /// The element waiting for its quiet period, and the timer that will emit it
    private actor Pending<Element: Sendable> {
        private let output: AsyncStream<Element>.Continuation
        private var element: Element?
        private var generation = 0
        private var timer: Task<Void, Never>?

        init(output: AsyncStream<Element>.Continuation) {
            self.output = output
        }

        func replace(with element: Element, after quiet: Duration, on clock: some Clock<Duration>) {
            self.element = element
            generation += 1
            let mine = generation
            timer?.cancel()
            timer = Task {
                do {
                    try await clock.sleep(for: quiet)
                } catch {
                    return
                }
                self.emit(ifStill: mine)
            }
        }

        func flush() {
            timer?.cancel()
            timer = nil
            if let element {
                self.element = nil
                output.yield(element)
            }
        }

        private func emit(ifStill generation: Int) {
            guard generation == self.generation, let element else { return }
            self.element = nil
            output.yield(element)
        }
    }
}
