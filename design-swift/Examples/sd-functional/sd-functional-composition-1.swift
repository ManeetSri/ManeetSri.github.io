// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-composition.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

enum Route: Equatable {
    case product(id: Int)
    case order(id: String)
}

enum LinkError: Error, Equatable {
    case notALink
    case wrongScheme(String)
    case unknownScreen(String)
    case badProductID(String)
}

func components(of link: String) -> Result<URLComponents, LinkError> {
    guard let parts = URLComponents(string: link), parts.scheme != nil else { return .failure(.notALink) }
    return .success(parts)
}

func checkingScheme(_ parts: URLComponents) -> Result<URLComponents, LinkError> {
    parts.scheme == "myshop" ? .success(parts) : .failure(.wrongScheme(parts.scheme ?? ""))
}

func route(from parts: URLComponents) -> Result<Route, LinkError> {
    let id = String(parts.path.dropFirst())   // "/42" → "42"
    switch parts.host {
    case "product":
        guard let number = Int(id), number > 0 else { return .failure(.badProductID(id)) }
        return .success(.product(id: number))
    case "order":
        return .success(.order(id: id))
    default:
        return .failure(.unknownScreen(parts.host ?? ""))
    }
}

func parse(_ link: String) -> Result<Route, LinkError> {
    components(of: link)
        .flatMap(checkingScheme)
        .flatMap(route(from:))
}

for link in ["myshop://product/42", "myshop://order/A-1009", "https://product/42", "myshop://product/abc", "myshop://basket", "not a link"] {
    switch parse(link) {
    case .success(let route): print("\(link) → \(route)")
    case .failure(let error): print("\(link) ✗ \(error)")
    }
}
