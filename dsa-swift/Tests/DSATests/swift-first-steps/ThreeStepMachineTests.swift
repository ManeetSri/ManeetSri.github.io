import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ThreeStepMachineTests {
    @Test("Runs the three steps in order", arguments: [
        (1, 13),
        (0, 10),
        (10, 40),
        (2, 16),
        (7, 31),
    ])
    func runsSteps(input: Int, expected: Int) {
        #expect(ThreeStepMachine.run(input) == expected)
    }

    @Test("Adds before multiplying")
    func additionComesFirst() {
        // Multiplying first, input + 4 * 3 - 2, would give 11 and 13 here.
        #expect(ThreeStepMachine.run(1) == 13)
        #expect(ThreeStepMachine.run(3) == 19)
    }

    @Test("Handles negative inputs", arguments: [
        (-4, -2),
        (-1, 7),
        (-10, -20),
    ])
    func negatives(input: Int, expected: Int) {
        #expect(ThreeStepMachine.run(input) == expected)
    }

    @Test("Works at both ends of the allowed range")
    func extremes() {
        #expect(ThreeStepMachine.run(1_000) == 3_010)
        #expect(ThreeStepMachine.run(-1_000) == -2_990)
    }
}
