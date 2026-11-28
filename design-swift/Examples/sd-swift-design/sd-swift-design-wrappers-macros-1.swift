// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-wrappers-macros.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>
    // $property: whether the last write had to be pulled back into range
    private(set) var projectedValue = false

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Value {
        get { value }
        set {
            value = min(max(newValue, range.lowerBound), range.upperBound)
            projectedValue = value != newValue
        }
    }
}

struct PlayerSettings {
    @Clamped(0...100) var volume = 50
    @Clamped(0.5...2.0) var speed = 1.0
}

var settings = PlayerSettings()
settings.volume = 140
settings.speed = 1.25
print(settings.volume, settings.$volume)
print(settings.speed, settings.$speed)
