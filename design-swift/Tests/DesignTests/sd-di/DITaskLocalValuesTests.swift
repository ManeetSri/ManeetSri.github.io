import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

private typealias Values = DITaskLocalValues.DependencyValues

/// The API host: a different one in tests, and the live one in previews
private enum ServerKey: DITaskLocalValues.DependencyKey {
    static let liveValue = "api.shelf.example"
    static let testValue = "localhost"
}

/// A feature flag that previews turn on
private enum NewShelfKey: DITaskLocalValues.DependencyKey {
    static let liveValue = false
    static let previewValue = true
    static let testValue = false
}

/// The time, as a function, as it usually is
private enum NowKey: DITaskLocalValues.DependencyKey {
    static let liveValue: @Sendable () -> Date = { Date() }
    static let testValue: @Sendable () -> Date = { Date(timeIntervalSince1970: 0) }
}

extension DITaskLocalValues.DependencyValues {
    fileprivate var server: String {
        get { self[ServerKey.self] }
        set { self[ServerKey.self] = newValue }
    }

    fileprivate var newShelf: Bool {
        get { self[NewShelfKey.self] }
        set { self[NewShelfKey.self] = newValue }
    }

    fileprivate var now: @Sendable () -> Date {
        get { self[NowKey.self] }
        set { self[NowKey.self] = newValue }
    }
}

@Suite struct DITaskLocalValuesTests {
    /// A model that reads its dependencies through the property wrapper
    final class ShelfModel {
        @DITaskLocalValues.Dependency(\.server) var server: String
        @DITaskLocalValues.Dependency(\.newShelf) var newShelf: Bool
    }

    /// The wrapper is Sendable, so value types that must cross tasks can use it too
    struct Banner: Sendable {
        @DITaskLocalValues.Dependency(\.server) var server: String
    }

    @Test("Each context falls back to its own defaults")
    func contexts() {
        #expect(Values(context: .live).server == "api.shelf.example")
        #expect(Values(context: .test).server == "localhost")
        #expect(Values(context: .preview).server == "api.shelf.example")
        #expect(Values(context: .preview).newShelf == true)
        #expect(Values(context: .test).now() == Date(timeIntervalSince1970: 0))
    }

    @Test("An override beats the context's default, leaves other keys alone, and copies are independent")
    func overrides() {
        var values = Values(context: .test)
        values.server = "staging.shelf.example"
        #expect(values.server == "staging.shelf.example")
        #expect(values.newShelf == false)

        var copy = values
        copy.server = "other"
        copy.newShelf = true
        #expect(values.server == "staging.shelf.example")
        #expect(values.newShelf == false)
        #expect(copy.server == "other")

        values.context = .preview
        #expect(values.server == "staging.shelf.example")
        #expect(values.newShelf == true)
    }

    @Test("withDependencies changes the values for its operation only, and returns its result")
    func scoped() {
        let seen = DITaskLocalValues.withDependencies {
            $0.server = "staging.shelf.example"
        } operation: {
            Values.current.server
        }
        #expect(seen == "staging.shelf.example")
        #expect(Values.current.server == "api.shelf.example")
    }

    @Test("Nested scopes start from the outer one, and the inner override wins")
    func nested() {
        DITaskLocalValues.withDependencies {
            $0.server = "staging.shelf.example"
        } operation: {
            DITaskLocalValues.withDependencies {
                $0.newShelf = true
            } operation: {
                #expect(Values.current.server == "staging.shelf.example")
                #expect(Values.current.newShelf == true)
            }
            DITaskLocalValues.withDependencies {
                $0.server = "localhost"
            } operation: {
                #expect(Values.current.server == "localhost")
            }
            #expect(Values.current.server == "staging.shelf.example")
            #expect(Values.current.newShelf == false)
        }
    }

    @Test("Switching the context changes every default nobody overrode")
    func switchContext() {
        DITaskLocalValues.withDependencies {
            $0.context = .test
            $0.newShelf = true
        } operation: {
            #expect(Values.current.server == "localhost")
            #expect(Values.current.newShelf == true)
            #expect(Values.current.now() == Date(timeIntervalSince1970: 0))
        }
    }

    @Test("Child tasks inherit the override; detached tasks start from the default")
    func childTasks() async {
        await DITaskLocalValues.withDependencies {
            $0.server = "staging.shelf.example"
        } operation: {
            async let fromAsyncLet = Values.current.server
            let fromTask = Task { Values.current.server }
            let fromDetached = Task.detached { Values.current.server }
            await Task.yield()
            #expect(Values.current.server == "staging.shelf.example")
            #expect(await fromAsyncLet == "staging.shelf.example")
            #expect(await fromTask.value == "staging.shelf.example")
            #expect(await fromDetached.value == "api.shelf.example")
        }
        #expect(Values.current.server == "api.shelf.example")
    }

    @Test("Concurrent scopes don't see each other's overrides")
    func concurrentScopes() async {
        let results = await withTaskGroup(of: (Int, String).self) { group in
            for index in 0..<20 {
                group.addTask {
                    await DITaskLocalValues.withDependencies {
                        $0.server = "server-\(index)"
                    } operation: {
                        await Task.yield()
                        return (index, Values.current.server)
                    }
                }
            }
            var results: [Int: String] = [:]
            for await (index, server) in group {
                results[index] = server
            }
            return results
        }
        #expect(results.count == 20)
        for (index, server) in results {
            #expect(server == "server-\(index)")
        }
    }

    @Test("The property wrapper keeps the values in force when its owner was created")
    func wrapperCaptures() {
        let model = DITaskLocalValues.withDependencies {
            $0.server = "staging.shelf.example"
            $0.newShelf = true
        } operation: {
            ShelfModel()
        }
        #expect(model.server == "staging.shelf.example")
        #expect(model.newShelf == true)

        let plain = ShelfModel()
        DITaskLocalValues.withDependencies {
            $0.server = "localhost"
        } operation: {
            #expect(plain.server == "api.shelf.example")
            #expect(model.server == "staging.shelf.example")
        }
    }

    @Test("A captured value travels with a Sendable value into another task")
    func wrapperAcrossTasks() async {
        let banner = DITaskLocalValues.withDependencies {
            $0.server = "staging.shelf.example"
        } operation: {
            Banner()
        }
        let server = await Task.detached { banner.server }.value
        #expect(server == "staging.shelf.example")
    }
}
