// Reference solution: An MVP recipe presenter. The presenter keeps the screen's state (the recipe, the
// servings, the favourite) and turns it into strings and flags for a view it holds weakly. Every rule is
// plain Swift on the main actor, so a spy view can check it without UIKit.
import Foundation

public enum MVPRecipeDetail {
    public struct Ingredient: Equatable, Sendable {
        public let name: String
        public let quantity: Double
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
    public static let servingsRange = 1...12

    @MainActor
    public final class Presenter {
        /// Weak: the view controller owns the presenter, so a strong reference here would be a cycle
        public weak var view: (any RecipeView)?

        private let recipeID: String
        private let service: any RecipeService
        private var recipe: Recipe?
        private var isLoading = false
        private var servings = 0
        private var isFavourite = false
        private var isUpdatingFavourite = false

        public init(recipeID: String, service: any RecipeService) {
            self.recipeID = recipeID
            self.service = service
        }

        public func viewDidLoad() async {
            guard recipe == nil, !isLoading else { return }
            isLoading = true
            view?.setLoading(true)
            defer { isLoading = false }
            do {
                let recipe = try await service.recipe(id: recipeID)
                self.recipe = recipe
                servings = min(max(recipe.servings, MVPRecipeDetail.servingsRange.lowerBound), MVPRecipeDetail.servingsRange.upperBound)
                isFavourite = recipe.isFavourite
                view?.setLoading(false)
                view?.showHeader(title: recipe.title, duration: MVPRecipeDetail.duration(minutes: recipe.minutes))
                showServings()
                view?.setFavourite(isFavourite)
            } catch {
                view?.setLoading(false)
                if !(error is CancellationError) {
                    view?.showError(MVPRecipeDetail.loadFailedMessage)
                }
            }
        }

        public func increaseServingsTapped() {
            changeServings(by: 1)
        }

        public func decreaseServingsTapped() {
            changeServings(by: -1)
        }

        public func favouriteTapped() async {
            guard let recipe, !isUpdatingFavourite else { return }
            let wanted = !isFavourite
            isFavourite = wanted
            isUpdatingFavourite = true
            view?.setFavourite(wanted)
            defer { isUpdatingFavourite = false }
            do {
                try await service.setFavourite(wanted, recipeID: recipe.id)
            } catch {
                isFavourite = !wanted
                view?.setFavourite(!wanted)
                if !(error is CancellationError) {
                    view?.showError(MVPRecipeDetail.favouriteFailedMessage)
                }
            }
        }

        private func changeServings(by step: Int) {
            guard recipe != nil else { return }
            let next = servings + step
            guard MVPRecipeDetail.servingsRange.contains(next) else { return }
            servings = next
            showServings()
        }

        private func showServings() {
            guard let recipe else { return }
            let range = MVPRecipeDetail.servingsRange
            view?.showServings(servings == 1 ? "1 serving" : "\(servings) servings", canDecrease: servings > range.lowerBound, canIncrease: servings < range.upperBound)
            view?.showIngredients(recipe.ingredients.map { line(for: $0, base: recipe.servings) })
        }

        private func line(for ingredient: Ingredient, base: Int) -> String {
            let scaled = ingredient.quantity * Double(servings) / Double(max(base, 1))
            let amount = MVPRecipeDetail.amount(scaled)
            return ingredient.unit.isEmpty ? "\(amount) \(ingredient.name)" : "\(amount) \(ingredient.unit) \(ingredient.name)"
        }
    }

    /// "35 min", "1 h", "1 h 15 min"
    static func duration(minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes) min" }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
    }

    /// Rounded to one decimal place, with no ".0" on whole numbers: "125", "1.5", "0.8"
    static func amount(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        return rounded == rounded.rounded() ? String(Int(rounded)) : String(format: "%.1f", rounded)
    }
}
