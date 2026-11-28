// Generated from src/dsa/design/content/lessons/sd-mvvm/sd-mvvm-combine.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine

struct Offline: Error {}

/// A check that fails for "bob" and succeeds for everyone else
func check(_ name: String) -> AnyPublisher<String, any Error> {
    name == "bob"
        ? Fail(error: Offline()).eraseToAnyPublisher()
        : Just("\(name) is available").setFailureType(to: (any Error).self).eraseToAnyPublisher()
}

func run(_ label: String, catchInside: Bool) {
    let typed = PassthroughSubject<String, Never>()
    let results: AnyPublisher<String, Never> = catchInside
        ? typed.flatMap { name in check(name).catch { _ in Just("\(name) couldn't be checked") } }.eraseToAnyPublisher()
        : typed.setFailureType(to: (any Error).self).flatMap { check($0) }.catch { _ in Just("check failed") }.eraseToAnyPublisher()
    let subscription = results.sink { print("\(label): \($0)") }
    for name in ["ada", "bob", "cy"] {
        typed.send(name)
    }
    subscription.cancel()
}

run("inside", catchInside: true)
run("outside", catchInside: false)
