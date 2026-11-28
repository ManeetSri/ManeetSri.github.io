import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor
@Suite struct UnidirectionalReduxStoreTests {
    private struct Basket: Equatable {
        var items: [String] = []
        var isCheckingOut = false
    }

    private enum BasketAction: Equatable {
        case add(String)
        case remove(String)
        case checkoutTapped
        case checkoutStarted
        case restoreSaved
        case noOp
    }

    private typealias Store = UnidirectionalReduxStore.Store<Basket, BasketAction>
    private typealias Middleware = UnidirectionalReduxStore.Middleware<Basket, BasketAction>

    /// A reducer that also records every action it reduces, so tests can see what reached it and in which order
    private final class ReducerLog {
        var actions: [BasketAction] = []
    }

    private func reducer(_ log: ReducerLog) -> (inout Basket, BasketAction) -> Void {
        { state, action in
            log.actions.append(action)
            switch action {
            case .add(let item): state.items.append(item)
            case .remove(let item): state.items.removeAll { $0 == item }
            case .checkoutTapped: break
            case .checkoutStarted: state.isCheckingOut = true
            case .restoreSaved, .noOp: break
            }
        }
    }

    @Test("With no middleware, every action reaches the reducer")
    func reducerOnly() {
        let log = ReducerLog()
        let store = Store(initialState: Basket(), reducer: reducer(log))
        store.dispatch(.add("Milk"))
        store.dispatch(.add("Eggs"))
        store.dispatch(.remove("Milk"))
        #expect(store.state.items == ["Eggs"])
        #expect(log.actions == [.add("Milk"), .add("Eggs"), .remove("Milk")])
    }

    @Test("Middleware runs in order, wrapped around the reducer like layers")
    func middlewareOrder() {
        var trace: [String] = []
        let log = ReducerLog()
        let outer: Middleware = { _, action, next in
            trace.append("outer in")
            next(action)
            trace.append("outer out")
        }
        let inner: Middleware = { context, action, next in
            trace.append("inner in, \(context.state().items.count) items")
            next(action)
            trace.append("inner out, \(context.state().items.count) items")
        }
        let store = Store(initialState: Basket(), reducer: reducer(log), middleware: [outer, inner])
        store.dispatch(.add("Milk"))
        #expect(trace == ["outer in", "inner in, 0 items", "inner out, 1 items", "outer out"])
        #expect(store.state.items == ["Milk"])
    }

    @Test("A middleware that doesn't call next swallows the action")
    func swallow() {
        let log = ReducerLog()
        var notified: [Basket] = []
        let lockDuringCheckout: Middleware = { context, action, next in
            if case .add = action, context.state().isCheckingOut { return }
            next(action)
        }
        let store = Store(initialState: Basket(items: ["Milk"], isCheckingOut: true), reducer: reducer(log), middleware: [lockDuringCheckout])
        store.subscribe { notified.append($0) }
        store.dispatch(.add("Eggs"))
        #expect(store.state.items == ["Milk"])
        #expect(log.actions.isEmpty)
        #expect(notified.count == 1, "only the call made by subscribe itself")
    }

    @Test("A middleware can pass a different action on")
    func transform() {
        let log = ReducerLog()
        let tidyNames: Middleware = { _, action, next in
            if case .add(let item) = action {
                next(.add(item.trimmingCharacters(in: .whitespaces).capitalized))
            } else {
                next(action)
            }
        }
        let store = Store(initialState: Basket(), reducer: reducer(log), middleware: [tidyNames])
        store.dispatch(.add("  oat milk "))
        #expect(store.state.items == ["Oat Milk"])
        #expect(log.actions == [.add("Oat Milk")])
    }

    @Test("Actions dispatched from middleware wait for the current action, then start from the top of the chain")
    func dispatchFromMiddlewareIsQueued() {
        let log = ReducerLog()
        var seenByLogger: [BasketAction] = []
        let logger: Middleware = { _, action, next in
            seenByLogger.append(action)
            next(action)
        }
        let checkout: Middleware = { context, action, next in
            if action == .checkoutTapped {
                context.dispatch(.checkoutStarted)
                #expect(context.state().isCheckingOut == false, "the new action mustn't run in the middle of this one")
            }
            next(action)
        }
        let store = Store(initialState: Basket(), reducer: reducer(log), middleware: [logger, checkout])
        store.dispatch(.checkoutTapped)
        #expect(log.actions == [.checkoutTapped, .checkoutStarted])
        #expect(seenByLogger == [.checkoutTapped, .checkoutStarted])
        #expect(store.state.isCheckingOut)
    }

    @Test("A middleware can turn one action into several, thunk style, without passing it on")
    func thunkStyle() {
        let log = ReducerLog()
        let saved = ["Bread", "Butter", "Jam"]
        let restore: Middleware = { context, action, next in
            guard action == .restoreSaved else { return next(action) }
            for item in saved { context.dispatch(.add(item)) }
        }
        let store = Store(initialState: Basket(), reducer: reducer(log), middleware: [restore])
        store.dispatch(.restoreSaved)
        #expect(store.state.items == saved)
        #expect(log.actions == saved.map(BasketAction.add))
    }

    @Test("Subscribers get the current state at once, then only changes")
    func subscribersHearChangesOnly() {
        let log = ReducerLog()
        var heard: [[String]] = []
        let store = Store(initialState: Basket(items: ["Milk"]), reducer: reducer(log))
        store.subscribe { heard.append($0.items) }
        store.dispatch(.noOp)
        store.dispatch(.add("Eggs"))
        store.dispatch(.remove("Tea"))
        store.dispatch(.remove("Milk"))
        #expect(heard == [["Milk"], ["Milk", "Eggs"], ["Eggs"]])
    }

    @Test("Every subscriber sees a state before an action dispatched from a subscriber runs")
    func dispatchFromSubscriber() {
        let log = ReducerLog()
        var first: [Int] = []
        var second: [Int] = []
        let store = Store(initialState: Basket(), reducer: reducer(log))
        store.subscribe { state in
            first.append(state.items.count)
            if state.items.count == 2 { store.dispatch(.add("Free bag")) }
        }
        store.subscribe { second.append($0.items.count) }
        store.dispatch(.add("Milk"))
        store.dispatch(.add("Eggs"))
        #expect(first == [0, 1, 2, 3])
        #expect(second == [0, 1, 2, 3])
        #expect(store.state.items == ["Milk", "Eggs", "Free bag"])
    }

    @Test("Unsubscribing stops notifications; unknown ids are ignored")
    func unsubscribe() {
        let log = ReducerLog()
        var kept: [Int] = []
        var dropped: [Int] = []
        let store = Store(initialState: Basket(), reducer: reducer(log))
        store.subscribe { kept.append($0.items.count) }
        let id = store.subscribe { dropped.append($0.items.count) }
        store.dispatch(.add("Milk"))
        store.unsubscribe(id)
        store.unsubscribe(id + 100)
        store.dispatch(.add("Eggs"))
        #expect(kept == [0, 1, 2])
        #expect(dropped == [0, 1])
    }
}
