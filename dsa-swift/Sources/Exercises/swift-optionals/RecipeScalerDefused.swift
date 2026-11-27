// Problem: Defuse the recipe scaler (M04 · Force unwrapping, and when it is fine)

public enum RecipeScalerDefused {
    /// Returns `recipe[ingredient]` grams scaled from 4 servings to the number in `servingsText`,
    /// rounded down. Returns nil instead of crashing when the text isn't a whole number, the
    /// servings are below 1, or the recipe doesn't use the ingredient.
    public static func scaledGrams(of ingredient: String, servingsText: String, recipe: [String: Int]) -> Int? {
        // Write your solution here, then run:
        // swift test --filter RecipeScalerDefusedTests
        return nil
    }
}
