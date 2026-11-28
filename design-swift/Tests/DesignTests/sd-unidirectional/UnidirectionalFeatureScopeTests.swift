import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A trip planner built from three child features: a packing list (always there), a stop editor
/// (presented as a sheet, so optional) and one row feature per stop (a collection addressed by id)
@Suite struct UnidirectionalFeatureScopeTests {
    private typealias Reducer = UnidirectionalFeatureScope.Reducer
    private typealias ActionCase = UnidirectionalFeatureScope.ActionCase
    private typealias Runtime = UnidirectionalFeatureScope.Runtime

    // MARK: Packing: a child that's always present

    private struct Packing: Equatable {
        var items: [String] = []
        var limit = 3
    }

    private enum PackingAction: Equatable {
        case add(String)
        case clear
        case full
    }

    private static var packing: Reducer<Packing, PackingAction> {
        Reducer { state, action in
            switch action {
            case .add(let item):
                guard state.items.count < state.limit else { return [.full] }
                state.items.append(item)
                return []
            case .clear:
                state.items = []
                return []
            case .full:
                return []
            }
        }
    }

    // MARK: Editor: a child presented as a sheet

    private struct Editor: Equatable {
        var draft = ""
    }

    private enum EditorAction: Equatable {
        case draftChanged(String)
        case saveTapped
        case cancelTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case save(String)
            case cancel
        }
    }

    private static var editor: Reducer<Editor, EditorAction> {
        Reducer { state, action in
            switch action {
            case .draftChanged(let text):
                state.draft = text
                return []
            case .saveTapped:
                state.draft = state.draft.trimmingCharacters(in: .whitespaces)
                return state.draft.isEmpty ? [] : [.delegate(.save(state.draft))]
            case .cancelTapped:
                return [.delegate(.cancel)]
            case .delegate:
                return []
            }
        }
    }

    // MARK: Stop: one row feature per element

    private struct Stop: Identifiable, Equatable {
        let id: Int
        var name: String
        var visited = false
    }

    private enum StopAction: Equatable {
        case visitedToggled
        case removeTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case remove
        }
    }

    private static var stop: Reducer<Stop, StopAction> {
        Reducer { state, action in
            switch action {
            case .visitedToggled:
                state.visited.toggle()
                return []
            case .removeTapped:
                return [.delegate(.remove)]
            case .delegate:
                return []
            }
        }
    }

    // MARK: The parent

    private struct Trip: Equatable {
        var packing = Packing()
        var editor: Editor?
        var stops: [Stop] = []
        var banner: String?
        var nextStopID = 1
        /// What the parent's own reducer saw, to show the order reducers run in
        var parentSaw: [String] = []
    }

    private enum TripAction: Equatable {
        case packing(PackingAction)
        case editor(EditorAction)
        case stops(id: Int, action: StopAction)
        case addStopTapped
        case bannerDismissed
    }

    private static var packingCase: ActionCase<TripAction, PackingAction> {
        ActionCase(
            extract: { if case .packing(let action) = $0 { action } else { nil } },
            embed: TripAction.packing
        )
    }

    private static var editorCase: ActionCase<TripAction, EditorAction> {
        ActionCase(
            extract: { if case .editor(let action) = $0 { action } else { nil } },
            embed: TripAction.editor
        )
    }

    private static var stopsCase: ActionCase<TripAction, (id: Int, action: StopAction)> {
        ActionCase(
            extract: { if case .stops(let id, let action) = $0 { (id, action) } else { nil } },
            embed: { TripAction.stops(id: $0.id, action: $0.action) }
        )
    }

    /// The parent's own logic: it handles its own actions and listens for its children's delegate actions
    private static var tripCore: Reducer<Trip, TripAction> {
        Reducer { state, action in
            switch action {
            case .addStopTapped:
                state.editor = Editor()
            case .editor(.saveTapped):
                state.parentSaw.append("saveTapped, draft \(state.editor?.draft ?? "none")")
            case .editor(.delegate(.save(let name))):
                state.parentSaw.append("save \(name)")
                state.stops.append(Stop(id: state.nextStopID, name: name))
                state.nextStopID += 1
                state.editor = nil
            case .editor(.delegate(.cancel)):
                state.parentSaw.append("cancel")
                state.editor = nil
            case .stops(let id, .delegate(.remove)):
                state.stops.removeAll { $0.id == id }
            case .packing(.full):
                state.banner = "Your bag is full"
            case .bannerDismissed:
                state.banner = nil
            case .editor(let action):
                state.parentSaw.append("editor \(action)")
            case .packing, .stops:
                break
            }
            return []
        }
    }

    /// The whole feature: the packing list scoped in, the editor and the stops attached to the parent's logic
    private static var trip: Reducer<Trip, TripAction> {
        Reducer.combine(
            Reducer.scope(state: \Trip.packing, action: packingCase, child: packing),
            tripCore
                .ifLet(\.editor, action: editorCase, child: editor)
                .forEach(\.stops, action: stopsCase, child: stop)
        )
    }

    private func runtime(_ state: Trip = Trip()) -> Runtime<Trip, TripAction> {
        Runtime(state: state, reducer: Self.trip)
    }

    // MARK: Tests

    @Test("The runtime reduces follow-up actions after the action, first in first out")
    func runtimeFollowUps() {
        let chain = Reducer<[String], String> { log, action in
            log.append(action)
            switch action {
            case "a": return ["b", "c"]
            case "b": return ["d"]
            default: return []
            }
        }
        var runtime = Runtime(state: [String](), reducer: chain)
        runtime.send("a")
        #expect(runtime.log == ["a", "b", "c", "d"])
        #expect(runtime.state == ["a", "b", "c", "d"])
    }

    @Test("combine runs every reducer on the same action, in order, and keeps all their follow-ups")
    func combineInOrder() {
        let first = Reducer<String, Int> { text, number in
            text += "first(\(number)) "
            return number == 1 ? [10] : []
        }
        let second = Reducer<String, Int> { text, number in
            text += "second(\(number)) "
            return number == 1 ? [20] : []
        }
        var runtime = Runtime(state: "", reducer: .combine(first, second))
        runtime.send(1)
        #expect(runtime.log == [1, 10, 20])
        #expect(runtime.state == "first(1) second(1) first(10) second(10) first(20) second(20) ")
    }

    @Test("scope runs the child on its own slice, and leaves the rest of the state alone")
    func scopeRunsChildOnItsSlice() {
        var runtime = runtime(Trip(banner: "Welcome"))
        runtime.send(.packing(.add("Passport")))
        runtime.send(.packing(.add("Charger")))
        #expect(runtime.state.packing.items == ["Passport", "Charger"])
        #expect(runtime.state.banner == "Welcome")
        #expect(runtime.state.stops.isEmpty)
    }

    @Test("scope ignores actions that aren't the child's")
    func scopeIgnoresOtherActions() {
        let scoped = Reducer.scope(state: \Trip.packing, action: Self.packingCase, child: Self.packing)
        var state = Trip(packing: Packing(items: ["Hat"]), banner: "Welcome")
        #expect(scoped.reduce(&state, .bannerDismissed).isEmpty)
        #expect(state == Trip(packing: Packing(items: ["Hat"]), banner: "Welcome"), "the parent's own actions aren't the scope's business")

        #expect(scoped.reduce(&state, .packing(.add("Sunscreen"))).isEmpty)
        #expect(state == Trip(packing: Packing(items: ["Hat", "Sunscreen"]), banner: "Welcome"))
    }

    @Test("A child's follow-up comes back to the parent embedded in the parent's action")
    func childFollowUpsAreEmbedded() {
        var runtime = runtime(Trip(packing: Packing(items: ["a", "b", "c"])))
        runtime.send(.packing(.add("d")))
        #expect(runtime.log == [.packing(.add("d")), .packing(.full)])
        #expect(runtime.state.banner == "Your bag is full")
        #expect(runtime.state.packing.items == ["a", "b", "c"])
    }

    @Test("ifLet runs the child while its state is there, and its delegate action reaches the parent")
    func ifLetPresentedChild() {
        var runtime = runtime()
        runtime.send(.addStopTapped)
        runtime.send(.editor(.draftChanged("  Lisbon ")))
        #expect(runtime.state.editor == Editor(draft: "  Lisbon "))

        runtime.send(.editor(.saveTapped))
        #expect(runtime.state.editor == nil)
        #expect(runtime.state.stops == [Stop(id: 1, name: "Lisbon")])
        #expect(runtime.log.contains(.editor(.delegate(.save("Lisbon")))))
    }

    @Test("ifLet runs the child before the parent, so the parent sees what the child decided")
    func ifLetChildRunsFirst() {
        var runtime = runtime(Trip(editor: Editor(draft: "  Porto ")))
        runtime.send(.editor(.saveTapped))
        #expect(runtime.state.parentSaw == ["saveTapped, draft Porto", "save Porto"])
        #expect(runtime.state.stops == [Stop(id: 1, name: "Porto")])

        runtime.send(.addStopTapped)
        runtime.send(.editor(.cancelTapped))
        #expect(runtime.state.editor == nil)
        #expect(runtime.state.parentSaw.suffix(2) == ["editor cancelTapped", "cancel"])
    }

    @Test("ifLet: a child action that arrives after the child has gone is ignored by the child")
    func ifLetIgnoresActionsWhenNil() {
        var runtime = runtime()
        runtime.send(.editor(.draftChanged("Faro")))
        runtime.send(.editor(.saveTapped))
        #expect(runtime.state.editor == nil)
        #expect(runtime.state.stops.isEmpty)
        #expect(runtime.log == [.editor(.draftChanged("Faro")), .editor(.saveTapped)])
        #expect(runtime.state.parentSaw == ["editor draftChanged(\"Faro\")", "saveTapped, draft none"])
    }

    @Test("forEach sends each action to the element with its id, and only that one")
    func forEachRoutesByID() {
        let stops = [Stop(id: 1, name: "Lisbon"), Stop(id: 2, name: "Porto"), Stop(id: 3, name: "Faro")]
        var runtime = runtime(Trip(stops: stops, nextStopID: 4))
        runtime.send(.stops(id: 2, action: .visitedToggled))
        #expect(runtime.state.stops.map(\.visited) == [false, true, false])

        runtime.send(.stops(id: 99, action: .visitedToggled))
        #expect(runtime.state.stops.map(\.visited) == [false, true, false])
    }

    @Test("forEach: an element's delegate action carries its id, so the parent removes the right one")
    func forEachDelegateCarriesID() {
        let stops = [Stop(id: 1, name: "Lisbon"), Stop(id: 2, name: "Porto"), Stop(id: 3, name: "Faro")]
        var runtime = runtime(Trip(stops: stops, nextStopID: 4))
        runtime.send(.stops(id: 1, action: .removeTapped))
        #expect(runtime.log == [.stops(id: 1, action: .removeTapped), .stops(id: 1, action: .delegate(.remove))])
        #expect(runtime.state.stops.map(\.name) == ["Porto", "Faro"])

        // By index, "the first row" would now be Porto. By id, a late action for stop 1 changes nothing.
        runtime.send(.stops(id: 1, action: .visitedToggled))
        #expect(runtime.state.stops.map(\.visited) == [false, false])
    }
}
