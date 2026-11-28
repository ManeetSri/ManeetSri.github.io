import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A passive view that records every call the presenter makes, in order
@MainActor
private final class RecipeViewSpy: MVPRecipeDetail.RecipeView {
    enum Call: Equatable {
        case loading(Bool)
        case header(title: String, duration: String)
        case servings(String, canDecrease: Bool, canIncrease: Bool)
        case ingredients([String])
        case favourite(Bool)
        case error(String)
    }

    private(set) var calls: [Call] = []

    func setLoading(_ isLoading: Bool) { calls.append(.loading(isLoading)) }
    func showHeader(title: String, duration: String) { calls.append(.header(title: title, duration: duration)) }
    func showServings(_ text: String, canDecrease: Bool, canIncrease: Bool) { calls.append(.servings(text, canDecrease: canDecrease, canIncrease: canIncrease)) }
    func showIngredients(_ lines: [String]) { calls.append(.ingredients(lines)) }
    func setFavourite(_ isFavourite: Bool) { calls.append(.favourite(isFavourite)) }
    func showError(_ message: String) { calls.append(.error(message)) }

    /// Forgets the calls so far, so a test can look only at what an interaction added
    func reset() { calls.removeAll() }
}

/// Answers recipe requests at once, and holds each favourite request until the test finishes it
private actor StubRecipeService: MVPRecipeDetail.RecipeService {
    private let result: Result<MVPRecipeDetail.Recipe, any Error>
    private(set) var recipeRequests: [String] = []
    private(set) var favouriteRequests: [Bool] = []
    private var waiting: [CheckedContinuation<Void, any Error>] = []

    init(_ result: Result<MVPRecipeDetail.Recipe, any Error>) {
        self.result = result
    }

    func recipe(id: String) async throws -> MVPRecipeDetail.Recipe {
        recipeRequests.append(id)
        return try result.get()
    }

    func setFavourite(_ isFavourite: Bool, recipeID: String) async throws {
        favouriteRequests.append(isFavourite)
        try await withCheckedThrowingContinuation { continuation in
            waiting.append(continuation)
        }
    }

    /// Finishes the oldest waiting favourite request; does nothing if none is waiting, so a stub that never
    /// calls the service fails its expectations instead of hanging
    func finishFavourite(throwing error: (any Error)? = nil) {
        guard !waiting.isEmpty else { return }
        let continuation = waiting.removeFirst()
        if let error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume()
        }
    }
}

@Suite(.timeLimit(.minutes(1))) @MainActor struct MVPRecipeDetailTests {
    typealias Detail = MVPRecipeDetail
    fileprivate typealias Call = RecipeViewSpy.Call

    static let bananaBread = MVPRecipeDetail.Recipe(
        id: "banana-bread",
        title: "Banana bread",
        minutes: 75,
        servings: 4,
        ingredients: [
            .init(name: "flour", quantity: 250, unit: "g"),
            .init(name: "sugar", quantity: 100, unit: "g"),
            .init(name: "bananas", quantity: 3),
            .init(name: "milk", quantity: 120, unit: "ml"),
        ]
    )

    private func makePresenter(_ result: Result<Detail.Recipe, any Error> = .success(bananaBread)) -> (Detail.Presenter, RecipeViewSpy, StubRecipeService) {
        let service = StubRecipeService(result)
        let presenter = Detail.Presenter(recipeID: "banana-bread", service: service)
        let spy = RecipeViewSpy()
        presenter.view = spy
        return (presenter, spy, service)
    }

    /// A presenter that has loaded the banana bread, with the spy's log cleared
    private func loadedPresenter() async -> (Detail.Presenter, RecipeViewSpy, StubRecipeService) {
        let (presenter, spy, service) = makePresenter()
        await presenter.viewDidLoad()
        spy.reset()
        return (presenter, spy, service)
    }

    @Test("Loading tells the view everything, in order")
    func loadShowsEverything() async {
        let (presenter, spy, service) = makePresenter()

        await presenter.viewDidLoad()

        #expect(await service.recipeRequests == ["banana-bread"])
        #expect(spy.calls == [
            .loading(true),
            .loading(false),
            .header(title: "Banana bread", duration: "1 h 15 min"),
            .servings("4 servings", canDecrease: true, canIncrease: true),
            .ingredients(["250 g flour", "100 g sugar", "3 bananas", "120 ml milk"]),
            .favourite(false),
        ])
    }

    @Test("Durations read as minutes, hours, or both", arguments: [
        (5, "5 min"), (35, "35 min"), (60, "1 h"), (75, "1 h 15 min"), (120, "2 h"), (150, "2 h 30 min"),
    ])
    func durations(minutes: Int, expected: String) async {
        let recipe = Detail.Recipe(id: "r", title: "Soup", minutes: minutes, servings: 2, ingredients: [], isFavourite: true)
        let (presenter, spy, _) = makePresenter(.success(recipe))

        await presenter.viewDidLoad()

        #expect(spy.calls.contains(.header(title: "Soup", duration: expected)))
        #expect(spy.calls.last == .favourite(true))
    }

    @Test("A failed load turns loading off and shows an error")
    func loadFailure() async {
        let (presenter, spy, _) = makePresenter(.failure(URLError(.notConnectedToInternet)))

        await presenter.viewDidLoad()

        #expect(spy.calls == [.loading(true), .loading(false), .error(Detail.loadFailedMessage)])
    }

    @Test("Fewer servings scale every ingredient, rounded to one decimal place")
    func scalingDown() async {
        let (presenter, spy, _) = await loadedPresenter()

        presenter.decreaseServingsTapped()
        #expect(spy.calls == [
            .servings("3 servings", canDecrease: true, canIncrease: true),
            .ingredients(["187.5 g flour", "75 g sugar", "2.3 bananas", "90 ml milk"]),
        ])

        presenter.decreaseServingsTapped()
        presenter.decreaseServingsTapped()
        #expect(spy.calls.suffix(2) == [
            .servings("1 serving", canDecrease: false, canIncrease: true),
            .ingredients(["62.5 g flour", "25 g sugar", "0.8 bananas", "30 ml milk"]),
        ])
    }

    @Test("The stepper stops at 1 and at 12 servings, and says so")
    func servingsBounds() async {
        let (presenter, spy, _) = await loadedPresenter()

        for _ in 0..<3 { presenter.decreaseServingsTapped() }
        spy.reset()
        presenter.decreaseServingsTapped()
        #expect(spy.calls.isEmpty)

        for _ in 0..<11 { presenter.increaseServingsTapped() }
        #expect(spy.calls.suffix(2).first == .servings("12 servings", canDecrease: true, canIncrease: false))
        #expect(spy.calls.last == .ingredients(["750 g flour", "300 g sugar", "9 bananas", "360 ml milk"]))
        spy.reset()
        presenter.increaseServingsTapped()
        #expect(spy.calls.isEmpty)
    }

    @Test("Taps before the recipe has loaded do nothing")
    func tapsBeforeLoad() async {
        let (presenter, spy, service) = makePresenter()

        presenter.increaseServingsTapped()
        presenter.decreaseServingsTapped()
        await presenter.favouriteTapped()

        #expect(spy.calls.isEmpty)
        #expect(await service.favouriteRequests.isEmpty)
    }

    @Test("Favouriting shows at once, before the service answers")
    func optimisticFavourite() async {
        let (presenter, spy, service) = await loadedPresenter()

        let task = Task { await presenter.favouriteTapped() }
        await settle()
        #expect(spy.calls == [.favourite(true)])
        #expect(await service.favouriteRequests == [true])

        await service.finishFavourite()
        await task.value
        #expect(spy.calls == [.favourite(true)])
    }

    @Test("A failed favourite is put back, with an error")
    func favouriteFailure() async {
        let (presenter, spy, service) = await loadedPresenter()

        let task = Task { await presenter.favouriteTapped() }
        await settle()
        await service.finishFavourite(throwing: URLError(.timedOut))
        await task.value

        #expect(spy.calls == [.favourite(true), .favourite(false), .error(Detail.favouriteFailedMessage)])
    }

    @Test("Taps while a favourite request is in flight are ignored")
    func favouriteInFlight() async {
        let (presenter, spy, service) = await loadedPresenter()

        let task = Task { await presenter.favouriteTapped() }
        await settle()
        await presenter.favouriteTapped()
        #expect(await service.favouriteRequests == [true])

        await service.finishFavourite()
        await task.value

        let second = Task { await presenter.favouriteTapped() }
        await settle()
        #expect(await service.favouriteRequests == [true, false])
        await service.finishFavourite()
        await second.value
        #expect(spy.calls == [.favourite(true), .favourite(false)])
    }

    @Test("The presenter doesn't keep its view alive")
    func weakView() async {
        let (presenter, _, _) = makePresenter()
        weak var released: RecipeViewSpy?
        do {
            let spy = RecipeViewSpy()
            presenter.view = spy
            released = spy
        }

        #expect(released == nil)
        await presenter.viewDidLoad()
        presenter.increaseServingsTapped()
    }
}
