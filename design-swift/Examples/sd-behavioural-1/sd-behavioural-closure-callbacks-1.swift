// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-closure-callbacks.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum LookupError: Error {
    case notFound
}

/// A callback API, as many older SDKs offer
func lookUpPrice(for sku: String, completion: @escaping @Sendable (Result<Int, LookupError>) -> Void) {
    let prices = ["mug": 12, "beans": 9]
    if let price = prices[sku] {
        completion(.success(price))
    } else {
        completion(.failure(.notFound))
    }
}

/// The same lookup as an async function: it returns or throws exactly once
func price(for sku: String) async throws -> Int {
    try await withCheckedThrowingContinuation { continuation in
        lookUpPrice(for: sku) { result in
            continuation.resume(with: result)
        }
    }
}

for sku in ["mug", "kettle"] {
    do {
        let pounds = try await price(for: sku)
        print("\(sku): £\(pounds)")
    } catch {
        print("\(sku): \(error)")
    }
}
