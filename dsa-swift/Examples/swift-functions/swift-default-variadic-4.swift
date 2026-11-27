// Generated from src/dsa/content/lessons/swift-functions/swift-default-variadic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func formatPrice(_ pence: Int, currency: String = "£", showPence: Bool = true) -> String {
    let pounds = pence / 100
    let remainder = pence % 100
    guard showPence else {
        return "\(currency)\(pounds)"
    }
    let penceText = remainder < 10 ? "0\(remainder)" : "\(remainder)"
    return "\(currency)\(pounds).\(penceText)"
}

print(formatPrice(1250))
print(formatPrice(1205, showPence: false))
print(formatPrice(999, currency: "€"))
