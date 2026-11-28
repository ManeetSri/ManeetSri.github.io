// Reference solution: Defuse the recipe scaler. The constant 4 needs no unwrapping at all; the two
// values that come from the user are unwrapped with one guard let, which also rules out fewer
// than 1 serving. O(s) time for s characters of servingsText, O(1) extra space.

public enum RecipeScalerDefused {
    public static func scaledGrams(of ingredient: String, servingsText: String, recipe: [String: Int]) -> Int? {
        let baseServings = 4 // every recipe in the app serves 4
        guard let servings = Int(servingsText), servings >= 1,
              let grams = recipe[ingredient] else {
            return nil
        }
        return grams * servings / baseServings
    }
}
