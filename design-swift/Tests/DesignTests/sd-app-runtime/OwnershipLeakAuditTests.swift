import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

// Small stand-ins for the objects of a real screen, for the Tracker tests
private final class Screen {
    var onRefresh: (() -> Void)?
    var model: Model?
}

private final class Model {
    var onChange: (() -> Void)?
    weak var screen: Screen?
}

@Suite struct OwnershipLeakAuditTests {
    typealias Reference = OwnershipLeakAudit.Reference

    private func audit(_ objects: [String], _ references: [Reference], roots: Set<String> = ["app"]) -> OwnershipLeakAudit.Report {
        OwnershipLeakAudit.audit(objects: objects, references: references, roots: roots)
    }

    // The app holds a navigation stack that has just popped the detail screen
    private let objects = ["app", "nav", "list", "detail", "viewModel"]
    private func popped(backReference: OwnershipLeakAudit.Strength) -> [Reference] {
        [Reference("app", "nav"), Reference("nav", "list"), Reference("detail", "viewModel"), Reference("viewModel", "detail", backReference)]
    }

    @Test("A strong cycle the app can no longer reach leaks; a weak back-reference frees it")
    func cycleAfterPop() {
        #expect(audit(objects, popped(backReference: .strong)).leaked == ["detail", "viewModel"])
        #expect(audit(objects, popped(backReference: .weak)).leaked.isEmpty)
        #expect(audit(objects, popped(backReference: .unowned)) == OwnershipLeakAudit.Report())
    }

    @Test("A cycle the app can still reach is in use, not leaked")
    func reachableCycle() {
        let held = [Reference("app", "store"), Reference("store", "observer"), Reference("observer", "store")]
        #expect(audit(["app", "store", "observer"], held).leaked.isEmpty)
        let dropped = [Reference("store", "observer"), Reference("observer", "store")]
        #expect(audit(["app", "store", "observer"], dropped).leaked == ["store", "observer"])
    }

    @Test("Everything a leaked cycle holds strongly leaks with it; weak references don't")
    func leaksSpread() {
        let references = [
            Reference("viewModel", "repository"),
            Reference("timer", "viewModel"),
            Reference("viewModel", "timer"),
            Reference("repository", "cache", .weak),
        ]
        let report = audit(["app", "cache", "repository", "timer", "viewModel"], references)
        #expect(report.leaked == ["repository", "timer", "viewModel"])
    }

    @Test("An object that holds itself, like a stored closure capturing self, leaks on its own")
    func selfReference() {
        #expect(audit(["app", "player"], [Reference("player", "player")]).leaked == ["player"])
        #expect(audit(["app", "player"], [Reference("app", "player"), Reference("player", "player")]).leaked.isEmpty)
    }

    @Test("Roots stay alive and are never reported, even with nothing holding them")
    func rootsAreNotLeaks() {
        let references = [Reference("a", "b"), Reference("b", "a"), Reference("orphan", "orphan"), Reference("b", "lonely", .unowned)]
        let report = audit(["a", "b", "lonely", "orphan"], references, roots: ["a", "lonely"])
        #expect(report.leaked == ["orphan"])
        #expect(report.dangling.isEmpty)
    }

    @Test("An unowned reference dangles when its target is freed first")
    func danglingUnowned() {
        // The flow ended and the app dropped its coordinator, but the screen is still on the stack
        let objects = ["app", "nav", "coordinator", "screen"]
        let screenToCoordinator = Reference("screen", "coordinator", .unowned)
        let dropped = audit(objects, [Reference("app", "nav"), Reference("nav", "screen"), screenToCoordinator])
        #expect(dropped.dangling == [screenToCoordinator])
        #expect(dropped.leaked.isEmpty)
        let kept = audit(objects, [Reference("app", "nav"), Reference("nav", "screen"), Reference("app", "coordinator"), screenToCoordinator])
        #expect(kept.dangling.isEmpty)
    }

    @Test("An unowned reference from a freed object is harmless")
    func unownedFromFreedObject() {
        let references = [Reference("parent", "child"), Reference("child", "parent", .unowned), Reference("child", "gone", .unowned)]
        #expect(audit(["app", "parent", "child", "gone"], references) == OwnershipLeakAudit.Report())
        // Make the parent leak through a cycle, and the child's unowned reference to the freed object dangles
        let leaking = references + [Reference("child", "parent")]
        #expect(audit(["app", "parent", "child", "gone"], leaking) == OwnershipLeakAudit.Report(leaked: ["parent", "child"], dangling: [Reference("child", "gone", .unowned)]))
    }

    @Test("A tracker sees a closure cycle keep a screen alive, and a weak reference let it go")
    func trackerFindsCycle() {
        let tracker = OwnershipLeakAudit.Tracker()
        weak var leakyScreen: Screen? // weak, so the test itself doesn't keep it alive
        do {
            let leaky = Screen()
            leaky.onRefresh = { leaky.model = nil } // the closure captures its owner strongly
            tracker.track(leaky, as: "leaky")
            let fine = Screen()
            fine.onRefresh = { [weak fine] in fine?.model = nil }
            tracker.track(fine, as: "fine")
            leakyScreen = leaky
        }
        #expect(tracker.survivors == ["leaky"])
        // Breaking the cycle frees it
        leakyScreen?.onRefresh = nil
        #expect(tracker.survivors.isEmpty)
    }

    @Test("A screen and its model: strong both ways leaks, a weak back-reference doesn't")
    func trackerAcrossLayers() {
        let tracker = OwnershipLeakAudit.Tracker()
        weak var leakedModel: Model?
        do {
            let screen = Screen()
            let model = Model()
            screen.model = model
            model.screen = screen // weak: fine
            tracker.track(screen, as: "screen")
            tracker.track(model, as: "model")
        }
        #expect(tracker.survivors.isEmpty)
        do {
            let screen = Screen()
            let model = Model()
            screen.model = model
            model.onChange = { _ = screen } // strong, through a closure
            tracker.track(screen, as: "screen 2")
            tracker.track(model, as: "model 2")
            leakedModel = model
        }
        #expect(tracker.survivors == ["screen 2", "model 2"])
        leakedModel?.onChange = nil
        #expect(tracker.survivors.isEmpty)
    }

    @Test("Survivors come back in tracking order, and drop out once released")
    func trackerOrder() {
        let tracker = OwnershipLeakAudit.Tracker()
        let first = Screen()
        var second: Screen? = Screen()
        let third = Screen()
        tracker.track(first, as: "first")
        tracker.track(second!, as: "second")
        tracker.track(third, as: "third")
        withExtendedLifetime((first, third)) {
            #expect(tracker.survivors == ["first", "second", "third"])
            second = nil
            #expect(tracker.survivors == ["first", "third"])
        }
    }
}
