import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct PizzaPartyTests {
    /// Doubles can be off in the last digit, so compare with a small tolerance
    private func isClose(_ actual: Double, _ expected: Double) -> Bool {
        abs(actual - expected) < 1e-9
    }

    @Test("Multiplies the number of pizzas by the price", arguments: [
        (3, 8.5, 25.5),
        (1, 9.99, 9.99),
        (4, 12.25, 49.0),
        (10, 0.5, 5.0),
    ])
    func cost(pizzas: Int, price: Double, expected: Double) {
        #expect(isClose(PizzaParty.cost(pizzas: pizzas, pricePerPizza: price), expected))
    }

    @Test("No pizzas cost nothing")
    func noPizzas() {
        #expect(PizzaParty.cost(pizzas: 0, pricePerPizza: 9.99) == 0)
    }

    @Test("Shares slices evenly", arguments: [
        (16, 4, 4.0),
        (8, 1, 8.0),
        (0, 5, 0.0),
    ])
    func evenShares(slices: Int, people: Int, expected: Double) {
        #expect(isClose(PizzaParty.slicesPerPerson(slices: slices, people: people), expected))
    }

    @Test("Keeps the fraction of a slice", arguments: [
        (7, 2, 3.5),
        (5, 8, 0.625),
        (8, 3, 8.0 / 3.0),
        (10, 4, 2.5),
    ])
    func fractionalShares(slices: Int, people: Int, expected: Double) {
        #expect(isClose(PizzaParty.slicesPerPerson(slices: slices, people: people), expected))
    }
}
