import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct LockedStatsRecorderTests {
    @Test("The examples")
    func examples() {
        let list = LockedStatsRecorder.LockedValue([1, 2])
        let count = list.withLock { items -> Int in
            items.append(3)
            return items.count
        }
        #expect(count == 3)
        #expect(list.withLock { $0 } == [1, 2, 3])

        let stats = LockedStatsRecorder.RequestStats()
        stats.record(milliseconds: 40)
        stats.record(milliseconds: 15)
        let expected = LockedStatsRecorder.Summary(requests: 2, totalMilliseconds: 55, slowest: 40)
        #expect(stats.summary == expected)
        #expect(stats.drain() == expected)
        #expect(stats.summary == LockedStatsRecorder.Summary())

        let tickets = LockedStatsRecorder.TicketDispenser(startingAt: 100)
        #expect(tickets.next() == 100)
        #expect(tickets.next() == 101)
        #expect(tickets.next(batch: 3) == 102..<105)
        #expect(tickets.next() == 105)
        #expect(tickets.next(batch: 0).isEmpty)
        #expect(tickets.next() == 106)
    }

    @Test("withLock passes errors through and keeps working afterwards")
    func throwing() {
        struct Refused: Error {}
        let counter = LockedStatsRecorder.LockedValue(0)
        #expect(throws: Refused.self) {
            try counter.withLock { value in
                value += 1
                throw Refused()
            }
        }
        counter.withLock { $0 += 10 }
        #expect(counter.withLock { $0 } == 11)
    }

    @Test("Concurrent increments through withLock are never lost")
    func concurrentIncrements() async {
        let counter = LockedStatsRecorder.LockedValue(0)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<200 {
                group.addTask {
                    for _ in 0..<100 {
                        counter.withLock { $0 += 1 }
                    }
                }
            }
        }
        #expect(counter.withLock { $0 } == 20_000)
    }

    @Test("300 tasks recording at once")
    func concurrentRecords() async {
        let stats = LockedStatsRecorder.RequestStats()
        await withTaskGroup(of: Void.self) { group in
            for task in 0..<300 {
                group.addTask {
                    for request in 0..<50 {
                        stats.record(milliseconds: (task * 50 + request) % 997)
                    }
                }
            }
        }
        let expectedTotal = (0..<15_000).reduce(0) { $0 + $1 % 997 }
        #expect(stats.summary == LockedStatsRecorder.Summary(requests: 15_000, totalMilliseconds: expectedTotal, slowest: 996))
    }

    @Test("Summaries taken during recording are consistent snapshots")
    func consistentSnapshots() async {
        let stats = LockedStatsRecorder.RequestStats()
        // Every request takes exactly 1 ms, so in any true snapshot the total equals the count
        let inconsistent = await withTaskGroup(of: Int.self) { group -> Int in
            for _ in 0..<100 {
                group.addTask {
                    for _ in 0..<200 {
                        stats.record(milliseconds: 1)
                    }
                    return 0
                }
            }
            for _ in 0..<20 {
                group.addTask {
                    var bad = 0
                    for _ in 0..<500 {
                        let summary = stats.summary
                        if summary.totalMilliseconds != summary.requests || summary.slowest > 1 { bad += 1 }
                    }
                    return bad
                }
            }
            var total = 0
            for await bad in group { total += bad }
            return total
        }
        #expect(inconsistent == 0, "\(inconsistent) summaries mixed figures from different moments")
        #expect(stats.summary == LockedStatsRecorder.Summary(requests: 20_000, totalMilliseconds: 20_000, slowest: 1))
    }

    @Test("Draining while recording loses nothing and counts nothing twice")
    func drainsWhileRecording() async {
        let stats = LockedStatsRecorder.RequestStats()
        let drained = await withTaskGroup(of: [LockedStatsRecorder.Summary].self) { group -> [LockedStatsRecorder.Summary] in
            for task in 0..<100 {
                group.addTask {
                    for request in 0..<100 {
                        stats.record(milliseconds: task + request)
                    }
                    return []
                }
            }
            for _ in 0..<10 {
                group.addTask {
                    (0..<200).map { _ in stats.drain() }
                }
            }
            var all: [LockedStatsRecorder.Summary] = []
            for await batch in group { all += batch }
            return all
        }
        let rest = stats.drain()
        let requests = drained.reduce(rest.requests) { $0 + $1.requests }
        let total = drained.reduce(rest.totalMilliseconds) { $0 + $1.totalMilliseconds }
        let slowest = drained.reduce(rest.slowest) { max($0, $1.slowest) }
        #expect(requests == 10_000)
        #expect(total == (0..<100).reduce(0) { sum, task in sum + (0..<100).reduce(0) { $0 + task + $1 } })
        #expect(slowest == 198)
        #expect(stats.summary == LockedStatsRecorder.Summary())
    }

    @Test("Tickets from many tasks are unique and leave no gaps")
    func uniqueTickets() async {
        let tickets = LockedStatsRecorder.TicketDispenser(startingAt: 1)
        let handedOut = await withTaskGroup(of: [Int].self) { group -> [Int] in
            for task in 0..<100 {
                group.addTask {
                    var mine: [Int] = []
                    for i in 0..<50 {
                        if (task + i).isMultiple(of: 5) {
                            mine += Array(tickets.next(batch: 4))
                        } else {
                            mine.append(tickets.next())
                        }
                    }
                    return mine
                }
            }
            var all: [Int] = []
            for await batch in group { all += batch }
            return all
        }
        // 100 tasks × 50 calls: 1,000 batches of 4 and 4,000 single tickets
        #expect(handedOut.count == 8_000)
        #expect(handedOut.sorted() == Array(1...8_000))
        #expect(tickets.next() == 8_001)
    }
}
