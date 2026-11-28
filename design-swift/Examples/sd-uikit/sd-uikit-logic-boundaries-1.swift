// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-logic-boundaries.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

// Domain: true on every screen and every platform
struct Product: Sendable {
    let id: String
    let name: String
    let price: Decimal
    let wasPrice: Decimal?
    let stock: Int
}

enum CartRules {
    static let maximumPerProduct = 10

    static func canAdd(_ product: Product, alreadyInCart: Int) -> Bool {
        product.stock > alreadyInCart && alreadyInCart < maximumPerProduct
    }
}

enum Pricing {
    /// Whole percent saved, rounded down; nil unless there's a real reduction
    static func percentSaved(_ product: Product) -> Int? {
        guard let was = product.wasPrice, was > product.price else { return nil }
        let saving = (was - product.price) / was * 100
        return NSDecimalNumber(decimal: saving).intValue
    }
}

// Presentation: how this list shows it. Still plain Foundation.
struct ProductRowState: Equatable, Sendable {
    let title: String
    let price: String
    let badge: String?
    let canAdd: Bool
}

struct ProductRowMapper {
    let locale: Locale

    func row(for product: Product, inCart: Int) -> ProductRowState {
        let badge: String? = if let percent = Pricing.percentSaved(product) {
            "Save \(percent)%"
        } else if product.stock == 0 {
            "Sold out"
        } else if product.stock < 5 {
            "Only \(product.stock) left"
        } else {
            nil
        }
        return ProductRowState(
            title: product.name,
            price: product.price.formatted(.currency(code: "GBP").locale(locale)),
            badge: badge,
            canAdd: CartRules.canAdd(product, alreadyInCart: inCart)
        )
    }
}

let mapper = ProductRowMapper(locale: Locale(identifier: "en_GB"))
let products = [
    Product(id: "p1", name: "Desk lamp", price: 24, wasPrice: 30, stock: 12),
    Product(id: "p2", name: "Notebook", price: 4.5, wasPrice: nil, stock: 3),
    Product(id: "p3", name: "Fountain pen", price: 18.99, wasPrice: nil, stock: 0),
]
for product in products {
    let row = mapper.row(for: product, inCart: product.id == "p2" ? 3 : 0)
    print(row.title, row.price, row.badge ?? "-", row.canAdd ? "can add" : "can't add", separator: " · ")
}
