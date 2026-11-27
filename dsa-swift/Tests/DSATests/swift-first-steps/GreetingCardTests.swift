import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GreetingCardTests {
    @Test("Writes a birthday card")
    func birthday() {
        let card = GreetingCard.card(to: "Ada", from: "Maneet", message: "Happy birthday!")
        #expect(card == "To: Ada\n\"Happy birthday!\"\nFrom: Maneet")
    }

    @Test("Has exactly three lines, with no newline at the end")
    func threeLines() {
        let card = GreetingCard.card(to: "Sam", from: "Priya", message: "Good luck")
        #expect(card.split(separator: "\n", omittingEmptySubsequences: false).count == 3)
        #expect(!card.hasSuffix("\n"))
    }

    @Test("Keeps spaces and punctuation in every part")
    func spacesAndPunctuation() {
        let card = GreetingCard.card(to: "Grace Hopper", from: "The Team", message: "Thanks, and see you soon.")
        #expect(card == "To: Grace Hopper\n\"Thanks, and see you soon.\"\nFrom: The Team")
    }

    @Test("Still quotes an empty message")
    func emptyMessage() {
        #expect(GreetingCard.card(to: "Ada", from: "Maneet", message: "") == "To: Ada\n\"\"\nFrom: Maneet")
    }
}
