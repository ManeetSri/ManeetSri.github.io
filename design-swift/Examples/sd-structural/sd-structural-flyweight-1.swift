// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-flyweight.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Intrinsic state: the same for every pin of a category, and never changed
final class PinStyle: Sendable {
    static let iconBytes = 120 * 120 * 4    // a decoded 120 × 120 px icon, 4 bytes per pixel

    let category: String
    let symbolName: String
    let tint: String

    init(category: String, symbolName: String, tint: String) {
        self.category = category
        self.symbolName = symbolName
        self.tint = tint
    }
}

// The flyweight factory: one shared style per category, created on first request
final class PinStyleFactory {
    private var styles: [String: PinStyle] = [:]
    private let looks = ["cafe": ("cup.and.saucer.fill", "brown"), "pharmacy": ("cross.fill", "green"),
                         "park": ("tree.fill", "teal"), "station": ("tram.fill", "blue")]

    var count: Int { styles.count }

    func style(for category: String) -> PinStyle {
        if let style = styles[category] { return style }
        let (symbol, tint) = looks[category] ?? ("mappin", "red")
        let style = PinStyle(category: category, symbolName: symbol, tint: tint)
        styles[category] = style
        return style
    }
}

// Extrinsic state: different for every pin, kept outside the flyweight
struct Pin {
    let latitude: Double
    let longitude: Double
    let title: String
    let style: PinStyle
}

let categories = ["cafe", "pharmacy", "park", "station"]
let factory = PinStyleFactory()
let pins = (0..<10_000).map { index in
    Pin(latitude: 51.5 + Double(index % 100) / 1_000,
        longitude: -0.12 + Double(index / 100) / 1_000,
        title: "Place \(index)",
        style: factory.style(for: categories[index % categories.count]))
}

let distinctStyles = Set(pins.map { ObjectIdentifier($0.style) }).count
print("\(pins.count) pins share \(distinctStyles) style objects (the factory made \(factory.count))")
print("Icons if every pin had its own: \(pins.count * PinStyle.iconBytes / 1_000_000) MB")
print("Icons shared through the factory: \(factory.count * PinStyle.iconBytes / 1_000) KB")
