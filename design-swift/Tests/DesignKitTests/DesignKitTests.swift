import DesignKit
import Foundation
import Testing

@Suite struct TestClockTests {
    @Test("A sleeper wakes only once the clock passes its deadline")
    func wakesOnAdvance() async throws {
        let clock = TestClock()
        let woke = Recorder<Duration>()
        let task = Task {
            try await clock.sleep(for: .seconds(5))
            await woke.record(clock.now.offset)
        }
        while clock.sleeperCount == 0 { await Task.yield() }
        clock.advance(by: .seconds(4))
        await settle()
        #expect(await woke.values.isEmpty)
        clock.advance(by: .seconds(1))
        try await task.value
        #expect(await woke.values == [.seconds(5)])
    }

    @Test("Cancelling a sleeper wakes it with CancellationError")
    func cancellation() async {
        let clock = TestClock()
        let task = Task { try await clock.sleep(for: .seconds(60)) }
        while clock.sleeperCount == 0 { await Task.yield() }
        task.cancel()
        await #expect(throws: CancellationError.self) { try await task.value }
        #expect(clock.sleeperCount == 0)
    }

    @Test("A deadline already passed doesn't wait")
    func pastDeadline() async throws {
        let clock = TestClock()
        clock.advance(by: .seconds(10))
        try await clock.sleep(until: clock.now.advanced(by: .seconds(-1)))
    }
}

@Suite struct HelperTests {
    @Test("Seeded generators repeat exactly")
    func seeded() {
        var first = SeededGenerator(seed: 42)
        var second = SeededGenerator(seed: 42)
        #expect((0..<5).map { _ in first.next() } == (0..<5).map { _ in second.next() })
    }

    @Test("The stub client answers in order and records requests")
    func stubClient() async throws {
        let client = StubHTTPClient([{ _ in (Data("first".utf8), 500) }, { _ in (Data("ok".utf8), 200) }])
        let request = URLRequest(url: URL(string: "https://api.example.com/feed")!)
        let (_, failed) = try await client.send(request)
        let (data, succeeded) = try await client.send(request)
        let (_, again) = try await client.send(request)
        #expect(failed.statusCode == 500 && succeeded.statusCode == 200 && again.statusCode == 200)
        #expect(String(decoding: data, as: UTF8.self) == "ok")
        #expect(await client.requests.count == 3)
    }

    @Test("Unimplemented explains itself")
    func unimplemented() {
        #expect(Unimplemented("refresh()").description == "refresh() isn't written yet")
    }
}
