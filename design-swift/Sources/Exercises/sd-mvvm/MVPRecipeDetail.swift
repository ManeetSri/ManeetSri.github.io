// Kata: An MVP recipe presenter (D27 · MVP and the passive view; Testing view models)
import Foundation

public enum MVPRecipeDetail {
    public struct Ingredient: Equatable, Sendable {
        public let name: String
        /// How much the recipe uses at its own `servings`
        public let quantity: Double
        /// "g", "ml", "tbsp"…, or empty for things you count, such as bananas
        public let unit: String

        public init(name: String, quantity: Double, unit: String = "") {
            self.name = name
            self.quantity = quantity
            self.unit = unit
        }
    }

    public struct Recipe: Equatable, Sendable {
        public let id: String
        public let title: String
        public let minutes: Int
        /// The number of servings the quantities are written for; at least 1
        public let servings: Int
        public let ingredients: [Ingredient]
        public let isFavourite: Bool

        public init(id: String, title: String, minutes: Int, servings: Int, ingredients: [Ingredient], isFavourite: Bool = false) {
            self.id = id
            self.title = title
            self.minutes = minutes
            self.servings = servings
            self.ingredients = ingredients
            self.isFavourite = isFavourite
        }
    }

    public protocol RecipeService: Sendable {
        func recipe(id: String) async throws -> Recipe
        func setFavourite(_ isFavourite: Bool, recipeID: String) async throws
    }

    /// The passive view: a view controller that shows exactly what it's told and decides nothing
    @MainActor
    public protocol RecipeView: AnyObject {
        func setLoading(_ isLoading: Bool)
        func showHeader(title: String, duration: String)
        func showServings(_ text: String, canDecrease: Bool, canIncrease: Bool)
        func showIngredients(_ lines: [String])
        func setFavourite(_ isFavourite: Bool)
        func showError(_ message: String)
    }

    public static let loadFailedMessage = "Couldn't load this recipe."
    public static let favouriteFailedMessage = "Couldn't update your favourites."
    /// The servings the stepper allows
    public static let servingsRange = 1...12

    /// Holds every presentation decision for the recipe screen and tells its view what to show
    @MainActor
    public final class Presenter {
        /// The view this presenter drives. The view controller owns the presenter, so the presenter
        /// must not keep its view alive.
        public var view: (any RecipeView)?

        public init(recipeID: String, service: any RecipeService) {}

        /// Loads the recipe and shows it: loading on, loading off, then the header, the servings, the
        /// ingredient lines and the favourite state. On failure: loading off, then `loadFailedMessage`.
        public func viewDidLoad() async {
            // Write your solution here, then run:
            // swift test --filter MVPRecipeDetailTests
        }

        /// One more serving, up to `servingsRange.upperBound`: shows the new servings and ingredient lines
        public func increaseServingsTapped() {}

        /// One fewer serving, down to `servingsRange.lowerBound`
        public func decreaseServingsTapped() {}

        /// Flips the favourite at once, then tells the service; puts it back with an error if that fails
        public func favouriteTapped() async {}
    }
}
