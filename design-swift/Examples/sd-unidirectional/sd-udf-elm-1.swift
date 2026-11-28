// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-elm.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Model: Equatable {
    var isRunning = false
    var elapsed = 0
    var laps: [Int] = []
}

enum Msg {
    case startTapped, pauseTapped, lapTapped, tick
}

/// A description of one-shot work. The runtime performs it.
enum Cmd: Equatable {
    case none
    case haptic(String)
}

/// What the program wants to listen to. The runtime starts and stops it.
enum Sub: Hashable {
    case everySecond
}

func update(_ msg: Msg, _ model: Model) -> (Model, Cmd) {
    var model = model
    switch msg {
    case .startTapped:
        model.isRunning = true
        return (model, .haptic("start"))
    case .pauseTapped:
        model.isRunning = false
        return (model, .none)
    case .lapTapped:
        guard model.isRunning else { return (model, .none) }
        model.laps.append(model.elapsed)
        return (model, .haptic("lap"))
    case .tick:
        model.elapsed += 1
        return (model, .none)
    }
}

func view(_ model: Model) -> String {
    "\(model.isRunning ? "running" : "paused"), \(model.elapsed)s, laps \(model.laps)"
}

func subscriptions(_ model: Model) -> Set<Sub> {
    model.isRunning ? [.everySecond] : []
}

/// Owns the model, performs commands, and keeps subscriptions in step with the model
final class Runtime {
    private(set) var model = Model()
    private var active: Set<Sub> = []

    func send(_ msg: Msg) {
        print(msg)
        let (next, cmd) = update(msg, model)
        model = next
        if case .haptic(let style) = cmd { print("  perform haptic: \(style)") }
        let wanted = subscriptions(model)
        for sub in wanted.subtracting(active) { print("  start \(sub)") }
        for sub in active.subtracting(wanted) { print("  stop \(sub)") }
        active = wanted
        print("  view: \(view(model))")
    }

    /// Stands in for real time: an active timer fires once a second
    func advance(seconds: Int) {
        for _ in 0..<seconds where active.contains(.everySecond) {
            send(.tick)
        }
    }
}

let runtime = Runtime()
runtime.send(.startTapped)
runtime.advance(seconds: 2)
runtime.send(.lapTapped)
runtime.send(.pauseTapped)
runtime.advance(seconds: 3)
runtime.send(.lapTapped)
