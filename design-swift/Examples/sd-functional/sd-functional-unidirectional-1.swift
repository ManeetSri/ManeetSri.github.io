// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-unidirectional.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct RecipesState: Equatable {
    var favourites: Set<Int> = []
    var pending: Set<Int> = []
    var toast: String?
}

enum RecipesAction {
    case favouriteTapped(Int)
    case saveFinished(Int, succeeded: Bool)
}

enum RecipesEffect: Equatable {
    case save(recipe: Int, isFavourite: Bool)
}

func reduce(_ state: inout RecipesState, _ action: RecipesAction) -> [RecipesEffect] {
    switch action {
    case .favouriteTapped(let id):
        guard !state.pending.contains(id) else { return [] }   // one request per recipe at a time
        let isFavourite = !state.favourites.contains(id)
        if isFavourite { state.favourites.insert(id) } else { state.favourites.remove(id) }
        state.pending.insert(id)
        state.toast = nil
        return [.save(recipe: id, isFavourite: isFavourite)]
    case .saveFinished(let id, succeeded: true):
        state.pending.remove(id)
        return []
    case .saveFinished(let id, succeeded: false):
        state.pending.remove(id)
        // Roll back the optimistic change
        if state.favourites.contains(id) { state.favourites.remove(id) } else { state.favourites.insert(id) }
        state.toast = "Couldn't update favourites. Check your connection."
        return []
    }
}

// Two screens, one state: the list row and the detail page both draw from `favourites`
func heart(_ state: RecipesState, _ id: Int) -> String { state.favourites.contains(id) ? "♥" : "♡" }

let actions: [RecipesAction] = [
    .favouriteTapped(42),
    .favouriteTapped(42),
    .saveFinished(42, succeeded: false),
    .favouriteTapped(42),
    .saveFinished(42, succeeded: true),
]

var state = RecipesState()
for action in actions {
    let effects = reduce(&state, action)
    var line = "\(action) → list \(heart(state, 42)), detail \(heart(state, 42))"
    if state.toast != nil { line += ", toast shown" }
    if let effect = effects.first { line += ", effect: \(effect)" }
    print(line)
}
