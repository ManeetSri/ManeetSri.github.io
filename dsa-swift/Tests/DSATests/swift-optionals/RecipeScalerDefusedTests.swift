import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct RecipeScalerDefusedTests {
    let recipe: [String: Int] = ["flour": 500, "sugar": 250, "butter": 125, "water": 0, "yeast": 7]

    @Test("Scales an ingredient from 4 servings", arguments: [
        ("flour", "8", 1_000),
        ("flour", "4", 500),
        ("sugar", "6", 375),
        ("sugar", "2", 125),
        ("flour", "1", 125),
    ])
    func scales(ingredient: String, servingsText: String, expected: Int) {
        #expect(RecipeScalerDefused.scaledGrams(of: ingredient, servingsText: servingsText, recipe: recipe) == expected)
    }

    @Test("Rounds down like integer division")
    func roundsDown() {
        #expect(RecipeScalerDefused.scaledGrams(of: "butter", servingsText: "3", recipe: recipe) == 93) // 93.75
        #expect(RecipeScalerDefused.scaledGrams(of: "yeast", servingsText: "1", recipe: recipe) == 1) // 1.75
        #expect(RecipeScalerDefused.scaledGrams(of: "yeast", servingsText: "5", recipe: recipe) == 8) // 8.75
    }

    @Test("Zero grams is a real answer, not a missing one")
    func zeroGrams() {
        #expect(RecipeScalerDefused.scaledGrams(of: "water", servingsText: "4", recipe: recipe) == 0)
        #expect(RecipeScalerDefused.scaledGrams(of: "water", servingsText: "100", recipe: recipe) == 0)
    }

    @Test("Accepts any text that Int(_:) accepts")
    func acceptedText() {
        #expect(RecipeScalerDefused.scaledGrams(of: "flour", servingsText: "+8", recipe: recipe) == 1_000)
        #expect(RecipeScalerDefused.scaledGrams(of: "flour", servingsText: "08", recipe: recipe) == 1_000)
    }

    @Test("Returns nil instead of crashing on odd servings", arguments: [
        "two", "", " 4", "4 ", "4.5", "4a", "99999999999999999999", "0", "-3", "-1000000",
    ])
    func oddServings(servingsText: String) {
        #expect(RecipeScalerDefused.scaledGrams(of: "flour", servingsText: servingsText, recipe: recipe) == nil)
    }

    @Test("Returns nil for an ingredient the recipe doesn't use")
    func missingIngredient() {
        #expect(RecipeScalerDefused.scaledGrams(of: "salt", servingsText: "4", recipe: recipe) == nil)
        #expect(RecipeScalerDefused.scaledGrams(of: "Flour", servingsText: "4", recipe: recipe) == nil)
        #expect(RecipeScalerDefused.scaledGrams(of: "flour", servingsText: "4", recipe: [:]) == nil)
    }

    @Test("Returns nil when both inputs are bad")
    func bothBad() {
        #expect(RecipeScalerDefused.scaledGrams(of: "salt", servingsText: "lots", recipe: recipe) == nil)
    }

    @Test("Handles the largest amounts allowed")
    func largest() {
        let big = ["cheese": 10_000]
        #expect(RecipeScalerDefused.scaledGrams(of: "cheese", servingsText: "1000000", recipe: big) == 2_500_000_000)
    }
}
