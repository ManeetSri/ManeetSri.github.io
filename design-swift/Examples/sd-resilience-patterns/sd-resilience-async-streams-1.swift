// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-async-streams.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The producer runs ahead: five location fixes arrive before the consumer reads any
func received(with policy: AsyncStream<Int>.Continuation.BufferingPolicy) async -> [Int] {
    let (fixes, continuation) = AsyncStream.makeStream(of: Int.self, bufferingPolicy: policy)
    for fix in 1...5 {
        continuation.yield(fix)
    }
    continuation.finish()

    var seen: [Int] = []
    for await fix in fixes {
        seen.append(fix)
    }
    return seen
}

print("unbounded:         ", await received(with: .unbounded))
print("bufferingNewest(1):", await received(with: .bufferingNewest(1)))
print("bufferingOldest(2):", await received(with: .bufferingOldest(2)))
