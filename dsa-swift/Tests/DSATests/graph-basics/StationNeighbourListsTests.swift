import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StationNeighbourListsTests {
    @Test("Small networks", arguments: [
        (4, [[1, 2], [2, 3], [1, 3], [3, 4]], [[2, 3], [1, 3], [1, 2, 4], [3]]),
        (3, [[3, 1]], [[3], [], [1]]),
        (5, [[5, 1], [1, 4], [1, 2], [1, 3]], [[2, 3, 4, 5], [1], [1], [1], [1]]),
        (2, [[1, 2], [2, 1], [1, 2]], [[2], [1]]),                       // one track, listed three times
        (4, [[4, 3], [2, 1], [3, 4], [1, 2], [2, 3]], [[2], [1, 3], [2, 4], [3]]),
    ])
    func small(stationCount: Int, links: [[Int]], expected: [[Int]]) {
        #expect(StationNeighbourLists.build(stationCount: stationCount, links: links) == expected)
    }

    @Test("Stations with no tracks still get a list")
    func isolated() {
        #expect(StationNeighbourLists.build(stationCount: 1, links: []) == [[]])
        #expect(StationNeighbourLists.build(stationCount: 3, links: []) == [[], [], []])
        #expect(StationNeighbourLists.build(stationCount: 6, links: [[2, 5]]) == [[], [5], [], [], [2], []])
    }

    @Test("The last station is included")
    func lastStation() {
        // A list of n - 1 entries, or an index out of range, means station n was forgotten
        let lists = StationNeighbourLists.build(stationCount: 3, links: [[2, 3], [3, 1]])
        #expect(lists.count == 3)
        #expect(lists == [[3], [3], [1, 2]])
    }

    @Test("100,000 stations and about 150,000 listed tracks")
    func large() {
        let count = 100_000
        var links: [[Int]] = []
        for station in 1..<count {
            links.append([station, station + 1])
            if station.isMultiple(of: 2) {
                links.append([station + 1, station])                    // listed again, reversed
            }
        }
        for station in stride(from: 1_000, through: count, by: 1_000) {
            links.append([station, 1])                                   // express trains to station 1
        }
        var expected: [[Int]] = []
        for station in 1...count {
            var next: [Int] = []
            if station > 1 { next.append(station - 1) }
            if station < count { next.append(station + 1) }
            if station.isMultiple(of: 1_000) { next.append(1) }
            if station == 1 { next.append(contentsOf: Array(stride(from: 1_000, through: count, by: 1_000))) }
            expected.append(Array(Set(next)).sorted())
        }
        let lists = StationNeighbourLists.build(stationCount: count, links: links)
        #expect(lists.count == count)
        // Report the first wrong station rather than printing 100,000 lists
        if let wrong = (0..<min(lists.count, count)).first(where: { lists[$0] != expected[$0] }) {
            Issue.record("station \(wrong + 1): expected \(expected[wrong].prefix(10)), got \(lists[wrong].prefix(10))")
        }
    }
}
