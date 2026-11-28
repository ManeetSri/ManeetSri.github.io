// Generated from src/dsa/design/content/lessons/sd-di/sd-di-containers.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct NotRegistered: Error, CustomStringConvertible {
    let type: String
    var description: String { "nothing is registered for \(type)" }
}

/// The smallest possible runtime container: a type-keyed table of factories
final class Container {
    private var factories: [ObjectIdentifier: (Container) throws -> Any] = [:]

    func register<T>(_ type: T.Type, factory: @escaping (Container) throws -> T) {
        factories[ObjectIdentifier(type)] = factory
    }

    func resolve<T>(_ type: T.Type) throws -> T {
        guard let factory = factories[ObjectIdentifier(type)], let value = try factory(self) as? T else {
            throw NotRegistered(type: String(describing: type))
        }
        return value
    }
}

protocol PaymentsClient {}
struct LivePaymentsClient: PaymentsClient {}
struct Basket {}
struct TripsModel {}
struct CheckoutModel {
    let basket: Basket
    let payments: any PaymentsClient
}
struct SettingsModel {
    let payments: any PaymentsClient
}

let container = Container()
container.register(Basket.self) { _ in Basket() }
container.register(TripsModel.self) { _ in TripsModel() }
// The bug: the concrete type is registered, but every factory asks for the protocol
container.register(LivePaymentsClient.self) { _ in LivePaymentsClient() }
container.register(CheckoutModel.self) { try CheckoutModel(basket: $0.resolve(Basket.self), payments: $0.resolve((any PaymentsClient).self)) }
container.register(SettingsModel.self) { try SettingsModel(payments: $0.resolve((any PaymentsClient).self)) }

// The smoke test: resolve every screen's model, as the app eventually will
let screens: [(String, () throws -> Any)] = [
    ("TripsModel", { try container.resolve(TripsModel.self) }),
    ("CheckoutModel", { try container.resolve(CheckoutModel.self) }),
    ("SettingsModel", { try container.resolve(SettingsModel.self) }),
]
for (name, resolve) in screens {
    do {
        _ = try resolve()
        print("ok      \(name)")
    } catch {
        print("FAILED  \(name): \(error)")
    }
}
