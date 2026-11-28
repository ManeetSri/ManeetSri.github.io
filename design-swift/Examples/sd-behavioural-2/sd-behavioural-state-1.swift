// Generated from src/dsa/design/content/lessons/sd-behavioural-2/sd-behavioural-state.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Episode: Equatable, CustomStringConvertible {
    let id: String
    let title: String
    var description: String { id }
}

enum Playback: Equatable {
    case idle
    case loading(Episode)
    case playing(Episode, at: Int)
    case paused(Episode, at: Int)
    case failed(Episode, reason: String)

    enum Event {
        case select(Episode)
        case loaded
        case loadFailed(String)
        case tick
        case togglePlayPause
        case retry
    }

    enum Effect: Equatable {
        case startLoading(Episode)
        case play(from: Int)
        case pause
        case savePosition(Int)
        case showError(String)
    }

    mutating func handle(_ event: Event) -> [Effect] {
        switch (self, event) {
        case (_, .select(let episode)):
            self = .loading(episode)
            return [.startLoading(episode)]
        case (.loading(let episode), .loaded):
            self = .playing(episode, at: 0)
            return [.play(from: 0)]
        case (.loading(let episode), .loadFailed(let reason)):
            self = .failed(episode, reason: reason)
            return [.showError(reason)]
        case (.playing(let episode, let seconds), .tick):
            self = .playing(episode, at: seconds + 1)
            return []
        case (.playing(let episode, let seconds), .togglePlayPause):
            self = .paused(episode, at: seconds)
            return [.pause, .savePosition(seconds)]
        case (.paused(let episode, let seconds), .togglePlayPause):
            self = .playing(episode, at: seconds)
            return [.play(from: seconds)]
        case (.failed(let episode, _), .retry):
            self = .loading(episode)
            return [.startLoading(episode)]
        case (.idle, _), (.loading, _), (.playing, _), (.paused, _), (.failed, _):
            return []   // any other pair: this state ignores this event
        }
    }
}

let episode = Episode(id: "ep42", title: "Designing for offline")
var playback = Playback.idle
let events: [Playback.Event] = [.togglePlayPause, .select(episode), .loadFailed("timed out"), .retry, .loaded, .tick, .tick, .togglePlayPause, .tick, .togglePlayPause]

for event in events {
    let effects = playback.handle(event).map { "\($0)" }.joined(separator: ", ")
    let line = "\(event) → \(playback)"
    print(effects.isEmpty ? line : "\(line) · \(effects)")
}
