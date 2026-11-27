import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ValueReferenceSimulatorTests {
    private static func both(_ commands: [String]) -> (structs: [Int], classes: [Int]) {
        (ValueReferenceSimulator.run(commands, usingClasses: false),
         ValueReferenceSimulator.run(commands, usingClasses: true))
    }

    @Test("Changing a copy: independent for structs, shared for classes")
    func copyThenChange() {
        let result = Self.both(["new a 1", "copy b a", "add b 99", "show a", "show b"])
        #expect(result.structs == [1, 100])
        #expect(result.classes == [100, 100])
    }

    @Test("Changing the original after copying")
    func changeOriginal() {
        let result = Self.both(["new a 5", "copy b a", "add a 2", "show b", "show a"])
        #expect(result.structs == [5, 7])
        #expect(result.classes == [7, 7])
    }

    @Test("A chain of copies all share one object")
    func chain() {
        let commands = ["new a 0", "copy b a", "copy c b", "add c 5", "show a", "show b", "show c"]
        let result = Self.both(commands)
        #expect(result.structs == [0, 0, 5])
        #expect(result.classes == [5, 5, 5])
    }

    @Test("new gives a variable a different thing; the old one is untouched")
    func newReplacesReference() {
        let result = Self.both(["new a 1", "copy b a", "new a 7", "add b 1", "show a", "show b"])
        #expect(result.structs == [7, 2])
        #expect(result.classes == [7, 2])
    }

    @Test("Copying again after a change")
    func copyAgain() {
        let commands = ["new a 1", "copy b a", "add b 1", "copy a b", "add a 10", "show a", "show b"]
        let result = Self.both(commands)
        #expect(result.structs == [12, 2])
        #expect(result.classes == [12, 12])
    }

    @Test("A backup that isn't a backup")
    func backup() {
        let commands = [
            "new score 10", "copy backup score",
            "add score 5", "add score -20",
            "show score", "show backup",
        ]
        let result = Self.both(commands)
        #expect(result.structs == [-5, 10])
        #expect(result.classes == [-5, -5])
    }

    @Test("Copying a variable to itself changes nothing")
    func selfCopy() {
        let result = Self.both(["new a 3", "copy a a", "add a 1", "show a"])
        #expect(result.structs == [4])
        #expect(result.classes == [4])
    }

    @Test("Separate new things never affect each other")
    func separateThings() {
        let result = Self.both(["new a 1", "new b 1", "add a 1", "show a", "show b"])
        #expect(result.structs == [2, 1])
        #expect(result.classes == [2, 1])
    }

    @Test("No show commands, no output")
    func nothingShown() {
        let result = Self.both(["new a 1", "copy b a", "add b 2"])
        #expect(result.structs == [])
        #expect(result.classes == [])
        #expect(Self.both([]).classes == [])
    }

    @Test("Many shared changes add up")
    func manyChanges() {
        var commands = ["new total 0", "copy view total"]
        for _ in 0..<10_000 {
            commands.append("add view 2")
        }
        commands.append("show total")
        let result = Self.both(commands)
        #expect(result.structs == [0])
        #expect(result.classes == [20_000])
    }
}
