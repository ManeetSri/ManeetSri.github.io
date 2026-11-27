import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct HelloSwiftTests {
    @Test("Greets a name")
    func greetsName() {
        #expect(HelloSwift.greet("Maneet") == "Hello, Maneet!")
    }

    @Test("Keeps spaces inside the name")
    func keepsSpaces() {
        #expect(HelloSwift.greet("Ada Lovelace") == "Hello, Ada Lovelace!")
    }

    @Test("Greets the world when the name is empty")
    func greetsWorld() {
        #expect(HelloSwift.greet("") == "Hello, world!")
    }
}
