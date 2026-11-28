// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-api-smells.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct User: Sendable {
    let name: String
}

struct Order: Sendable {
    let pence: Int
}

struct Profile: Sendable {
    let user: User
    let orders: [Order]
}

enum APIError: Error {
    case offline
}

// The legacy API: completion handlers, which here call back straight away
final class LegacyAPI: Sendable {
    let online: Bool

    init(online: Bool) {
        self.online = online
    }

    func fetchUser(completion: @escaping @Sendable (Result<User, APIError>) -> Void) {
        completion(online ? .success(User(name: "Ada")) : .failure(.offline))
    }

    func fetchOrders(completion: @escaping @Sendable (Result<[Order], APIError>) -> Void) {
        completion(online ? .success([Order(pence: 1299), Order(pence: 450)]) : .failure(.offline))
    }
}

// Step 1: wrap each callback once, at the bottom. Every path resumes exactly once.
extension LegacyAPI {
    func user() async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            fetchUser { continuation.resume(with: $0) }
        }
    }

    func orders() async throws -> [Order] {
        try await withCheckedThrowingContinuation { continuation in
            fetchOrders { continuation.resume(with: $0) }
        }
    }
}

// Step 2: the logic, as straight-line code. Neither request needs the other's result, so they run at the same time.
func loadProfile(from api: LegacyAPI) async throws -> Profile {
    async let user = api.user()
    async let orders = api.orders()
    return try await Profile(user: user, orders: orders)
}

for online in [true, false] {
    do {
        let profile = try await loadProfile(from: LegacyAPI(online: online))
        print("\(profile.user.name): \(profile.orders.count) orders")
    } catch {
        print("Failed: \(error)")
    }
}
