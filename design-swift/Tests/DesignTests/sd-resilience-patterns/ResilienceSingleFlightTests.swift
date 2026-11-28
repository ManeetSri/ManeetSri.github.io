import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ResilienceSingleFlightTests {
    private typealias Group = ResilienceSingleFlight.Group<String, String>

    private struct RefreshFailed: Error {}

    /// A token endpoint that holds every response until the test releases it, and numbers its runs
    private actor TokenServer {
        private(set) var runs = 0
        private(set) var sawCancellation = false
        private var isOpen: Bool
        private var waiters: [CheckedContinuation<Void, Never>] = []

        init(open: Bool = false) {
            isOpen = open
        }

        func refresh(failing: Bool = false) async throws -> String {
            runs += 1
            let run = runs
            if !isOpen {
                await withCheckedContinuation { waiters.append($0) }
            }
            if Task.isCancelled { sawCancellation = true }
            if failing { throw RefreshFailed() }
            return "token-\(run)"
        }

        func open() {
            isOpen = true
            waiters.forEach { $0.resume() }
            waiters.removeAll()
        }
    }

    /// Lets the callers reach the group: until the server has seen `runs` runs, then a while longer so
    /// that callers joining an existing run have arrived too. Bounded, so a wrong answer can't hang.
    private func letCallersArrive(_ server: TokenServer, runs: Int) async {
        for _ in 0..<10_000 where await server.runs < runs {
            await Task.yield()
        }
        await settle(rounds: 500)
    }

    @Test("Concurrent calls for one key share a single run and all get its result")
    func concurrentCallsShare() async throws {
        let group = Group()
        let server = TokenServer()
        let callers = (0..<3).map { _ in
            Task { try await group.run("refresh") { try await server.refresh() } }
        }
        await letCallersArrive(server, runs: 1)
        #expect(await server.runs == 1)
        #expect(await group.inFlight == 1)

        await server.open()
        for caller in callers {
            #expect(try await caller.value == "token-1")
        }
        #expect(await group.inFlight == 0)
    }

    @Test("Different keys run independently")
    func keysAreSeparate() async throws {
        let group = Group()
        let server = TokenServer()
        let avatar = Task { try await group.run("avatar/1") { try await server.refresh() } }
        let banner = Task { try await group.run("banner/1") { try await server.refresh() } }
        await letCallersArrive(server, runs: 2)
        #expect(await group.inFlight == 2)

        await server.open()
        let values = [try await avatar.value, try await banner.value]
        #expect(Set(values) == ["token-1", "token-2"])
        #expect(await server.runs == 2)
    }

    @Test("Nothing is cached: a call after the run has ended starts a new run")
    func noCaching() async throws {
        let group = Group()
        let server = TokenServer(open: true)
        #expect(try await group.run("refresh") { try await server.refresh() } == "token-1")
        #expect(try await group.run("refresh") { try await server.refresh() } == "token-2")
        #expect(await group.inFlight == 0)
    }

    @Test("Every waiter gets the error, and the next call tries again")
    func errorsAreSharedNotKept() async throws {
        let group = Group()
        let server = TokenServer()
        let callers = (0..<2).map { _ in
            Task { try await group.run("refresh") { try await server.refresh(failing: true) } }
        }
        await letCallersArrive(server, runs: 1)
        await server.open()
        for caller in callers {
            await #expect(throws: RefreshFailed.self) { try await caller.value }
        }
        #expect(await server.runs == 1)
        #expect(await group.inFlight == 0)

        #expect(try await group.run("refresh") { try await server.refresh() } == "token-2")
    }

    @Test("Cancelling one waiter doesn't cancel the work the others are waiting for")
    func cancellingOneCallerKeepsTheWork() async throws {
        let group = Group()
        let server = TokenServer()
        let first = Task { try await group.run("refresh") { try await server.refresh() } }
        await letCallersArrive(server, runs: 1)
        let second = Task { try await group.run("refresh") { try await server.refresh() } }
        await settle(rounds: 500)

        first.cancel()
        await settle()
        await server.open()
        #expect(try await second.value == "token-1")
        #expect(await server.runs == 1)
        #expect(await server.sawCancellation == false)
        _ = try? await first.value
    }
}
