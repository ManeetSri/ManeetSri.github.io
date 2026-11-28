// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-isp.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Profile: Sendable {
    var name: String
}

protocol ProfileLoading: Sendable {
    func profile() async throws -> Profile
}

protocol ProfileSaving: Sendable {
    func save(_ profile: Profile) async throws
}

@MainActor final class ProfileModel {
    private let account: any ProfileLoading & ProfileSaving
    private(set) var name = ""

    init(account: any ProfileLoading & ProfileSaving) {
        self.account = account
    }

    func load() async throws {
        name = try await account.profile().name
    }

    func rename(to newName: String) async throws {
        try await account.save(Profile(name: newName))
        name = newName
    }
}

// The whole fake a test or preview needs: two methods, no fatalError stubs
actor FakeAccount: ProfileLoading, ProfileSaving {
    private var stored = Profile(name: "Maneet")
    func profile() -> Profile { stored }
    func save(_ profile: Profile) { stored = profile }
}

let fake = FakeAccount()
let model = ProfileModel(account: fake)
try await model.load()
print("Loaded:", model.name)
try await model.rename(to: "Maneet S.")
print("Saved:", await fake.profile().name)
