import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CowCopyCounterTests {
    @Test("Copies shown in the lesson's table", arguments: [
        (["new a 3", "copy b a", "append b", "append b"], 3),
        (["new a 3", "copy b a"], 0),
        (["new a 3", "append a", "append a", "write a"], 0),
    ])
    func lessonTable(commands: [String], expected: Int) {
        #expect(CowCopyCounter.elementsCopied(by: commands) == expected)
    }

    @Test("Saving snapshots copies the board on every write")
    func snapshots() {
        let commands = [
            "new board 4",
            "copy h0 board", "write board",
            "copy h1 board", "write board",
            "copy h2 board", "write board",
        ]
        #expect(CowCopyCounter.elementsCopied(by: commands) == 12)
    }

    @Test("Reads never copy")
    func reads() {
        let commands = ["new a 1000", "copy b a", "copy c a", "read a", "read b", "read c", "read a"]
        #expect(CowCopyCounter.elementsCopied(by: commands) == 0)
    }

    @Test("A copy pays for the elements it holds at that moment")
    func countAtTimeOfWrite() {
        let commands = ["new a 2", "append a", "append a", "copy b a", "remove b", "remove b", "copy c b", "append c"]
        // b copies 4 elements, then c copies the 2 that b still holds
        #expect(CowCopyCounter.elementsCopied(by: commands) == 6)
    }

    @Test("Three sharers: the first two writers copy, the last one doesn't")
    func threeSharers() {
        let commands = ["new a 2", "copy b a", "copy c a", "write a", "write b", "write c"]
        #expect(CowCopyCounter.elementsCopied(by: commands) == 4)
    }

    @Test("Moving a variable to new storage leaves the other one unique")
    func reassignmentReleases() {
        #expect(CowCopyCounter.elementsCopied(by: ["new a 5", "copy b a", "new b 2", "append a"]) == 0)
        #expect(CowCopyCounter.elementsCopied(by: ["new a 5", "copy b a", "new c 1", "copy b c", "write a"]) == 0)
        #expect(CowCopyCounter.elementsCopied(by: ["new a 5", "copy b a", "new c 1", "copy b c", "write b"]) == 1)
    }

    @Test("Copying a variable to itself or to its own sharer changes nothing")
    func redundantCopies() {
        #expect(CowCopyCounter.elementsCopied(by: ["new a 7", "copy a a", "write a"]) == 0)
        #expect(CowCopyCounter.elementsCopied(by: ["new a 7", "copy b a", "copy b a", "write b", "write a"]) == 7)
    }

    @Test("Copying an empty array costs nothing")
    func emptyArray() {
        #expect(CowCopyCounter.elementsCopied(by: ["new a 0", "copy b a", "append a", "append b"]) == 0)
    }

    @Test("No commands, no copies")
    func noCommands() {
        #expect(CowCopyCounter.elementsCopied(by: []) == 0)
    }

    @Test("A snapshot every step of a long loop")
    func longLoop() {
        var commands = ["new board 1000"]
        for step in 0..<1_000 {
            commands.append("copy snapshot\(step) board")
            commands.append("write board")
        }
        #expect(CowCopyCounter.elementsCopied(by: commands) == 1_000_000)
    }

    @Test("Keeping one old copy only costs once")
    func oneOldCopy() {
        var commands = ["new board 1000", "copy old board"]
        for _ in 0..<1_000 {
            commands.append("write board")
        }
        #expect(CowCopyCounter.elementsCopied(by: commands) == 1_000)
    }
}
