// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-reducers.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Composer {
    struct State: Equatable {
        var text = ""
        var photos: [String] = []
        var isPosting = false
        var error: String?

        var remaining: Int { 280 - text.count }
        var canPost: Bool { !isPosting && remaining >= 0 && (!text.isEmpty || !photos.isEmpty) }
    }

    enum Action {
        case textChanged(String)
        case photoAdded(String)
        case postTapped
        case postFinished(succeeded: Bool)
    }

    enum Effect: Equatable {
        case upload(text: String, photos: [String])
    }

    static func reduce(_ state: inout State, _ action: Action) -> [Effect] {
        switch action {
        case .textChanged(let text):
            guard !state.isPosting else { return [] }
            state.text = text
            state.error = nil
            return []
        case .photoAdded(let id):
            guard !state.isPosting, state.photos.count < 4 else { return [] }
            state.photos.append(id)
            return []
        case .postTapped:
            guard state.canPost else { return [] }
            state.isPosting = true
            state.error = nil
            return [.upload(text: state.text, photos: state.photos)]
        case .postFinished(succeeded: true):
            state = State()
            return []
        case .postFinished(succeeded: false):
            state.isPosting = false
            state.error = "Couldn't post. Your draft is saved."
            return []
        }
    }
}

let actions: [Composer.Action] = [
    .textChanged("Sunset over the bay"),
    .photoAdded("IMG_0412"),
    .postTapped,
    .postTapped,
    .textChanged("Too late to edit"),
    .postFinished(succeeded: false),
    .postTapped,
    .postFinished(succeeded: true),
]

var state = Composer.State()
for action in actions {
    let effects = Composer.reduce(&state, action)
    var line = "\(action) → \(state.isPosting ? "posting" : "editing"), \(state.text.count) chars, \(state.photos.count) photo(s)"
    if state.error != nil { line += ", error shown" }
    if !effects.isEmpty { line += ", effect: upload" }
    print(line)
}

// The state after any sequence of actions is a fold over them
let replayed = actions.reduce(into: Composer.State()) { state, action in _ = Composer.reduce(&state, action) }
print(replayed == state)
