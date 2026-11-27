import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DeadCodeEliminatorTests {
    @Test("An assignment nothing reads is removed")
    func unusedAssignment() {
        let program = ["a = 4", "b = a * 2", "c = 7", "print b"]
        #expect(DeadCodeEliminator.optimise(program) == ["a = 4", "b = a * 2", "print b"])
    }

    @Test("A value overwritten before it's read is removed")
    func overwritten() {
        #expect(DeadCodeEliminator.optimise(["x = 1", "x = 2", "print x"]) == ["x = 2", "print x"])
    }

    @Test("Updating a variable from itself keeps the whole chain")
    func selfUpdate() {
        let program = ["total = 0", "total = total + 5", "total = total + 6", "print total"]
        #expect(DeadCodeEliminator.optimise(program) == program)
    }

    @Test("With no print, everything is removed")
    func noPrint() {
        #expect(DeadCodeEliminator.optimise(["a = 1", "b = a + 1", "c = b * b"]) == [])
    }

    @Test("Work after the last print is removed")
    func afterLastPrint() {
        #expect(DeadCodeEliminator.optimise(["n = 10", "print n", "n = n + 1"]) == ["n = 10", "print n"])
    }

    @Test("Every print is kept, even of a number")
    func prints() {
        let program = ["print 5", "x = 3", "print x", "print x"]
        #expect(DeadCodeEliminator.optimise(program) == program)
    }

    @Test("A variable printed twice keeps the value each print reads")
    func readTwice() {
        let program = ["x = 1", "print x", "x = 2", "y = x - 1", "print x", "x = 3"]
        #expect(DeadCodeEliminator.optimise(program) == ["x = 1", "print x", "x = 2", "print x"])
    }

    @Test("Dead code can make earlier code dead too")
    func cascade() {
        let program = ["a = 2", "b = a + 3", "c = b * 4", "d = 9", "print d"]
        #expect(DeadCodeEliminator.optimise(program) == ["d = 9", "print d"])
    }

    @Test("Both operands of a kept line become needed")
    func bothOperands() {
        let program = ["p = 6", "q = 7", "r = 1", "s = p * q", "print s"]
        #expect(DeadCodeEliminator.optimise(program) == ["p = 6", "q = 7", "s = p * q", "print s"])
    }

    @Test("Copies between variables")
    func copies() {
        let program = ["a = 5", "b = a", "a = 0", "print b"]
        #expect(DeadCodeEliminator.optimise(program) == ["a = 5", "b = a", "print b"])
    }

    @Test("An empty program stays empty")
    func empty() {
        #expect(DeadCodeEliminator.optimise([]) == [])
    }

    @Test("A long program where only the last few lines matter")
    func longProgram() {
        var program: [String] = []
        for index in 0..<10_000 {
            program.append("junk = junk + \(index)")
        }
        program += ["answer = 42", "print answer"]
        #expect(DeadCodeEliminator.optimise(program) == ["answer = 42", "print answer"])
    }
}
