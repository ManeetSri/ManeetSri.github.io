// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-futures-async.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine

func loadAvatar() async -> String {
    print("async function: work starts")
    return "avatar.png"
}

// A Combine Future starts its work the moment it's created, whether or not anyone subscribes
let future = Future<String, Never> { promise in
    print("Future: work starts")
    promise(.success("avatar.png"))
}
print("Future created")

// An async function does nothing until it's called and awaited
let operation = { await loadAvatar() }
print("Async operation created")
let avatar = await operation()
print("Got \(avatar)")
