import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct OnePlaceInLineTests {
    @Test("Serves people in the order they joined")
    func order() {
        #expect(OnePlaceInLine.servedOrder(["Ada", "Ben", "Cy", "NEXT", "NEXT", "NEXT"]) == ["Ada", "Ben", "Cy"])
    }

    @Test("Ignores joins from someone already waiting")
    func noDoubleJoin() {
        #expect(OnePlaceInLine.servedOrder(["Dee", "Dee", "Dee", "NEXT", "NEXT"]) == ["Dee"])
        #expect(OnePlaceInLine.servedOrder(["Ada", "Ben", "Ada", "NEXT", "NEXT", "NEXT"]) == ["Ada", "Ben"])
    }

    @Test("Someone served can join again, at the back")
    func rejoin() {
        let events = ["Ada", "Ben", "Ada", "NEXT", "Ada", "NEXT", "NEXT", "NEXT"]
        #expect(OnePlaceInLine.servedOrder(events) == ["Ada", "Ben", "Ada"])
        #expect(OnePlaceInLine.servedOrder(["Eve", "NEXT", "Eve", "NEXT", "Eve", "NEXT"]) == ["Eve", "Eve", "Eve"])
    }

    @Test("NEXT on an empty line does nothing")
    func emptyLine() {
        #expect(OnePlaceInLine.servedOrder(["NEXT", "NEXT", "Fay", "NEXT", "NEXT"]) == ["Fay"])
    }

    @Test("People still waiting at the end aren't served")
    func stillWaiting() {
        #expect(OnePlaceInLine.servedOrder(["NEXT", "Cy"]) == [])
        #expect(OnePlaceInLine.servedOrder(["Gus", "Hal", "Ivy", "NEXT"]) == ["Gus"])
    }

    @Test("No events means nobody is served")
    func noEvents() {
        #expect(OnePlaceInLine.servedOrder([]) == [])
    }

    @Test("Names are matched exactly")
    func exactNames() {
        #expect(OnePlaceInLine.servedOrder(["ada", "Ada", "NEXT", "NEXT"]) == ["ada", "Ada"])
    }

    @Test("Stays fast with 50,000 people waiting at once")
    func large() {
        let names = (0..<50_000).map { "person\($0)" }
        let events = names + names + Array(repeating: "NEXT", count: 50_001)
        #expect(OnePlaceInLine.servedOrder(events) == names)
    }

    @Test("Stays fast when one person joins and is served over and over")
    func churn() {
        var events: [String] = []
        for _ in 0..<25_000 {
            events += ["Zed", "Zed", "NEXT", "NEXT"]
        }
        #expect(OnePlaceInLine.servedOrder(events) == Array(repeating: "Zed", count: 25_000))
    }
}
