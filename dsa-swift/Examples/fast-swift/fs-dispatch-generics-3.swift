// Generated from src/dsa/content/lessons/fast-swift/fs-dispatch-generics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Greeter {
    func greet() -> String              // a requirement: looked up at run time
}

extension Greeter {
    func greet() -> String { "hello" }
    func farewell() -> String { "goodbye" }   // not a requirement: chosen at compile time
}

struct French: Greeter {
    func greet() -> String { "bonjour" }
    func farewell() -> String { "au revoir" }
}

let direct = French()
let boxed: any Greeter = French()
print(direct.greet(), direct.farewell())
print(boxed.greet(), boxed.farewell())
