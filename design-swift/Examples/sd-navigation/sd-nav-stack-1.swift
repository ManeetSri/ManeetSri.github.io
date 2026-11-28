// Generated from src/dsa/design/content/lessons/sd-navigation/sd-nav-stack.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import SwiftUI

enum ShopRoute: Hashable, Codable {
    case product(id: Int)
    case reviews(productID: Int)
}

struct Category: Hashable, Codable {
    var slug: String
}

var path = NavigationPath()
path.append(Category(slug: "shoes"))
path.append(ShopRoute.product(id: 7))
path.append(ShopRoute.reviews(productID: 7))

// Each element is saved as its type's name and its own JSON, last element first
if let representation = path.codable {
    let data = try JSONEncoder().encode(representation)
    print(String(decoding: data, as: UTF8.self))
}

// One element that isn't Codable, and the whole path can't be saved
struct Draft: Hashable {
    var text: String
}
var withDraft = path
withDraft.append(Draft(text: "Great shoes"))
print("\(withDraft.count) screens, codable: \(withDraft.codable == nil ? "nil" : "yes")")

// Restoring doesn't check the elements: a renamed type still "decodes"
let fromOldBuild = #"["main.ProductRoute","{\"product\":{\"id\":7}}"]"#
let old = try JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: Data(fromOldBuild.utf8))
print("restored \(NavigationPath(old).count) screen of a type that no longer exists")
