// Reference solution: Pizza party maths. Swift never mixes Int and Double, so convert the Int
// values explicitly, and convert before dividing so the fraction isn't lost. O(1) time and space.

public enum PizzaParty {
    public static func cost(pizzas: Int, pricePerPizza: Double) -> Double {
        Double(pizzas) * pricePerPizza
    }

    public static func slicesPerPerson(slices: Int, people: Int) -> Double {
        Double(slices) / Double(people)
    }
}
