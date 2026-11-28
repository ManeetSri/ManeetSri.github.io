import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RefCountSimulatorTests {
    typealias Outcome = RefCountSimulator.Outcome

    @Test("An object survives until its last reference goes")
    func twoReferences() {
        #expect(RefCountSimulator.simulate(["new a 7", "set b a", "clear a"]) == Outcome(freed: [], alive: [7]))
        #expect(RefCountSimulator.simulate(["new a 7", "set b a", "clear a", "clear b"]) == Outcome(freed: [7], alive: []))
    }

    @Test("Giving a variable a new object frees the old one")
    func replacing() {
        #expect(RefCountSimulator.simulate(["new a 1", "new a 2"]) == Outcome(freed: [1], alive: [2]))
        #expect(RefCountSimulator.simulate(["new a 1", "new b 2", "set a b"]) == Outcome(freed: [1], alive: [2]))
    }

    @Test("Copying from an empty variable empties the target")
    func setFromNil() {
        #expect(RefCountSimulator.simulate(["new a 1", "set a b"]) == Outcome(freed: [1], alive: []))
    }

    @Test("Setting a variable to itself changes nothing")
    func setSelf() {
        #expect(RefCountSimulator.simulate(["new a 1", "set a a"]) == Outcome(freed: [], alive: [1]))
    }

    @Test("Freeing the head of a list frees the chain behind it, in order")
    func chainFrees() {
        let commands = ["new head 1", "new b 2", "new c 3", "link b c", "link head b", "clear b", "clear c", "clear head"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [1, 2, 3], alive: []))
    }

    @Test("Moving head forward frees one node at a time")
    func followFrees() {
        let commands = [
            "new head 1", "new b 2", "new c 3", "link b c", "link head b", "clear b", "clear c",
            "follow head", "follow head", "follow head",
        ]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [1, 2, 3], alive: []))
        let partway = Array(commands.prefix(8))
        #expect(RefCountSimulator.simulate(partway) == Outcome(freed: [1], alive: [2, 3]))
    }

    @Test("A node another variable still holds stops the chain")
    func chainStops() {
        let commands = ["new a 1", "new b 2", "new c 3", "link a b", "link b c", "clear c", "clear a"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [1], alive: [2, 3]))
    }

    @Test("Relinking releases the old next")
    func relink() {
        let commands = ["new a 1", "new b 2", "new c 3", "link a b", "clear b", "link a c"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [2], alive: [1, 3]))
        #expect(RefCountSimulator.simulate(["new a 1", "new b 2", "link a b", "clear b", "link a b"]) == Outcome(freed: [2], alive: [1]))
    }

    @Test("Linking to the same object again changes nothing")
    func relinkSame() {
        let commands = ["new a 1", "new b 2", "link a b", "link a b", "clear b"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [], alive: [1, 2]))
    }

    @Test("Two objects pointing at each other are never freed")
    func cycle() {
        let commands = ["new a 1", "new b 2", "link a b", "link b a", "clear a", "clear b"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [], alive: [1, 2]))
    }

    @Test("An object pointing at itself is never freed")
    func selfCycle() {
        #expect(RefCountSimulator.simulate(["new a 5", "link a a", "clear a"]) == Outcome(freed: [], alive: [5]))
    }

    @Test("Unlinking breaks a cycle so both can be freed")
    func breakCycle() {
        let commands = ["new a 1", "new b 2", "link a b", "link b a", "unlink b", "clear b", "clear a"]
        #expect(RefCountSimulator.simulate(commands) == Outcome(freed: [1, 2], alive: []))
    }

    @Test("Following into nothing empties the variable")
    func followToNil() {
        #expect(RefCountSimulator.simulate(["new a 4", "follow a"]) == Outcome(freed: [4], alive: []))
    }

    @Test("No commands, no objects")
    func noCommands() {
        #expect(RefCountSimulator.simulate([]) == Outcome(freed: [], alive: []))
    }

    @Test("Clearing the head of a 10,000-node list frees every node")
    func longChain() {
        var commands = ["new head 0", "set tail head"]
        for id in 1..<10_000 {
            commands += ["new node \(id)", "link tail node", "set tail node"]
        }
        commands += ["clear node", "clear tail"]
        let kept = RefCountSimulator.simulate(commands)
        #expect(kept.freed == [])
        #expect(kept.alive.count == 10_000)

        commands.append("clear head")
        let outcome = RefCountSimulator.simulate(commands)
        #expect(outcome.freed == Array(0..<10_000))
        #expect(outcome.alive == [])
    }
}
