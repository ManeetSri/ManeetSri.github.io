// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-immutability.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum QuantityError: Error {
    case notPositive(Int)
    case overLimit(Int)
}

struct Quantity {
    static let limit = 10
    let value: Int

    init(_ value: Int) throws(QuantityError) {
        guard value > 0 else { throw .notPositive(value) }
        guard value <= Self.limit else { throw .overLimit(value) }
        self.value = value
    }
}

for input in [3, 0, 12] {
    do {
        let quantity = try Quantity(input)
        print("\(input): accepted \(quantity.value)")
    } catch {
        print("\(input): rejected, \(error)")
    }
}
