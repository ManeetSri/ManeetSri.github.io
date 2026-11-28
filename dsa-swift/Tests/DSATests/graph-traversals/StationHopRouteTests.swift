import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct StationHopRouteTests {
    /// Checks that route goes from start to goal along real links, using exactly `hops` of them
    private func expectRoute(_ route: [Int], stations: Int, links: [[Int]], from start: Int, to goal: Int, hops: Int) {
        #expect(route.count == hops + 1, "a shortest route has \(hops) links, so \(hops + 1) stations")
        guard route.count == hops + 1 else { return }
        #expect(route.first == start && route.last == goal, "the route should run from \(start) to \(goal)")
        var linked = Set<Int>()
        for link in links {
            linked.insert(link[0] * stations + link[1])
            linked.insert(link[1] * stations + link[0])
        }
        let allLinked = zip(route, route.dropFirst()).allSatisfy { linked.contains($0 * stations + $1) }
        #expect(allLinked, "every consecutive pair of stations on the route must be linked")
    }

    @Test("Finds the route with the fewest links")
    func examples() {
        let links = [[0, 1], [1, 2], [2, 3], [0, 4], [4, 3], [3, 5]]
        #expect(StationHopRoute.route(stations: 6, links: links, from: 0, to: 5) == [0, 4, 3, 5])
        #expect(StationHopRoute.route(stations: 6, links: links, from: 5, to: 1) == [5, 3, 2, 1])
        let line = [[0, 1], [1, 2], [2, 3]]
        #expect(StationHopRoute.route(stations: 4, links: line, from: 3, to: 0) == [3, 2, 1, 0])
    }

    @Test("Ties: any shortest route is accepted")
    func ties() {
        let square = [[0, 1], [1, 3], [0, 2], [2, 3]]
        expectRoute(StationHopRoute.route(stations: 4, links: square, from: 0, to: 3), stations: 4, links: square, from: 0, to: 3, hops: 2)
        let wheel = [[0, 1], [0, 2], [0, 3], [0, 4], [1, 2], [2, 3], [3, 4], [4, 1]]
        expectRoute(StationHopRoute.route(stations: 5, links: wheel, from: 1, to: 3), stations: 5, links: wheel, from: 1, to: 3, hops: 2)
    }

    @Test("Starting at the goal")
    func alreadyThere() {
        #expect(StationHopRoute.route(stations: 3, links: [[0, 1], [1, 2]], from: 1, to: 1) == [1])
        #expect(StationHopRoute.route(stations: 1, links: [], from: 0, to: 0) == [0])
    }

    @Test("Unreachable goals give an empty route")
    func unreachable() {
        #expect(StationHopRoute.route(stations: 4, links: [[0, 1], [2, 3]], from: 0, to: 3) == [])
        #expect(StationHopRoute.route(stations: 3, links: [[0, 1]], from: 0, to: 2) == [])
        #expect(StationHopRoute.route(stations: 2, links: [], from: 1, to: 0) == [])
    }

    @Test("Self links and repeated links")
    func oddLinks() {
        let links = [[0, 0], [0, 1], [0, 1], [1, 2], [2, 2]]
        #expect(StationHopRoute.route(stations: 3, links: links, from: 0, to: 2) == [0, 1, 2])
    }

    @Test("A line of 100,000 stations")
    func longLine() {
        let count = 100_000
        let links = (0..<(count - 1)).map { [$0, $0 + 1] }
        let forwards = StationHopRoute.route(stations: count, links: links, from: 0, to: count - 1) == Array(0..<count)
        #expect(forwards, "the route from 0 to 99,999 should visit every station in order")
        let backwards = StationHopRoute.route(stations: count, links: links.reversed(), from: count - 1, to: 0)
            == Array((0..<count).reversed())
        #expect(backwards, "the route from 99,999 to 0 should visit every station in order")
    }

    @Test("Express links every 1,000 stations")
    func expressLinks() {
        let count = 100_000
        var links = (0..<(count - 1)).map { [$0, $0 + 1] }
        links += stride(from: 0, to: count - 1_000, by: 1_000).map { [$0, $0 + 1_000] }
        // 99 express links to station 99,000, then 999 single links
        let route = StationHopRoute.route(stations: count, links: links, from: 0, to: count - 1)
        expectRoute(route, stations: count, links: links, from: 0, to: count - 1, hops: 99 + 999)
    }

    @Test("Corner to corner across a 300 × 300 grid of stations")
    func grid() {
        let size = 300
        var links: [[Int]] = []
        for row in 0..<size {
            for column in 0..<size {
                if column + 1 < size { links.append([row * size + column, row * size + column + 1]) }
                if row + 1 < size { links.append([row * size + column, (row + 1) * size + column]) }
            }
        }
        let route = StationHopRoute.route(stations: size * size, links: links, from: 0, to: size * size - 1)
        expectRoute(route, stations: size * size, links: links, from: 0, to: size * size - 1, hops: 2 * (size - 1))
    }
}
