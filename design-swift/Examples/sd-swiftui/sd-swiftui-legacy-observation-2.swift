// Generated from src/dsa/design/content/lessons/sd-swiftui/sd-swiftui-legacy-observation.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

var modelsMade = 0

@MainActor
final class FeedModel {
    init() { modelsMade += 1 }
}

@propertyWrapper
struct EagerBox<Value> {              // takes the value: the expression runs at every init
    var wrappedValue: Value
    init(wrappedValue: Value) { self.wrappedValue = wrappedValue }
}

@propertyWrapper
struct DeferredBox<Value> {           // takes an autoclosure, like StateObject
    private let make: () -> Value
    init(wrappedValue: @autoclosure @escaping () -> Value) { make = wrappedValue }
    var wrappedValue: Value { make() }
}

@MainActor struct ScreenA { @EagerBox var model = FeedModel() }
@MainActor struct ScreenB { @DeferredBox var model = FeedModel() }

for _ in 1...3 { _ = ScreenA() }
print("Eager: \(modelsMade) models for 3 view structs")
modelsMade = 0
for _ in 1...3 { _ = ScreenB() }
print("Autoclosure: \(modelsMade) models for 3 view structs")
