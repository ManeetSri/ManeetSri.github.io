// Generated from src/dsa/design/content/lessons/sd-state/sd-state-view-state.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Article: Equatable {
    let title: String
}

enum Content: Equatable {
    case idle
    case loading
    case loaded([Article])
    case empty
    case failed(message: String)
}

enum Event {
    case appeared
    case retryTapped
    case fetched([Article])
    case fetchFailed(message: String)
}

enum Effect {
    case fetch
}

/// Pure: no networking and no UI. It decides the next state, and which work to start.
func reduce(_ content: inout Content, _ event: Event) -> Effect? {
    switch (content, event) {
    case (.idle, .appeared), (.failed, .retryTapped):
        content = .loading
        return .fetch
    case let (.loading, .fetched(articles)):
        content = articles.isEmpty ? .empty : .loaded(articles)
    case let (.loading, .fetchFailed(message)):
        content = .failed(message: message)
    default:
        break   // an event this state ignores, such as appearing a second time
    }
    return nil
}

var content = Content.idle
let events: [Event] = [
    .appeared,
    .fetchFailed(message: "Offline"),
    .appeared,
    .retryTapped,
    .fetched([Article(title: "Swift 6 in practice"), Article(title: "Observation, explained")]),
]
for event in events {
    let effect = reduce(&content, event)
    print(describe(event), "→", describe(content), effect == nil ? "" : "+ start a fetch")
}

func describe(_ event: Event) -> String {
    switch event {
    case .appeared: "appeared"
    case .retryTapped: "retryTapped"
    case .fetched(let articles): "fetched \(articles.count) articles"
    case .fetchFailed(let message): "fetchFailed(\(message))"
    }
}

func describe(_ content: Content) -> String {
    switch content {
    case .idle: "idle"
    case .loading: "loading"
    case .loaded(let articles): "loaded(\(articles.count) articles)"
    case .empty: "empty"
    case .failed(let message): "failed(\(message))"
    }
}
