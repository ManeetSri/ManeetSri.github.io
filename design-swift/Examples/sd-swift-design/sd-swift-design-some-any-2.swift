// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-some-any.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

func isEqual<T: Equatable>(_ lhs: T, _ rhs: any Equatable) -> Bool {
    guard let rhs = rhs as? T else { return false }
    return lhs == rhs
}

let a: any Equatable = 42
let b: any Equatable = 42
let c: any Equatable = "42"
print(isEqual(a, b))
print(isEqual(a, c))
