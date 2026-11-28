import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct UIKitSnapshotPlannerTests {
    private typealias Row = UIKitSnapshotPlanner.Row
    private typealias Section = UIKitSnapshotPlanner.Section

    private func row(_ id: String, in section: String, _ title: String = "Title", _ detail: String = "") -> Row {
        Row(id: id, section: section, title: title, detail: detail)
    }

    @Test("Groups rows into sections, in the order each section first appears")
    func groupsBySection() {
        let rows = [row("a", in: "today"), row("b", in: "today"), row("c", in: "earlier"), row("d", in: "today")]
        let plan = UIKitSnapshotPlanner.plan(from: [], to: rows)
        #expect(plan.sections == [Section(id: "today", items: ["a", "b", "d"]), Section(id: "earlier", items: ["c"])])
        #expect(plan.reconfigured.isEmpty)
        #expect(plan.duplicates.isEmpty)
    }

    @Test("Starting from nothing and ending with nothing")
    func emptySides() {
        let rows = [row("a", in: "inbox"), row("b", in: "inbox")]
        let first = UIKitSnapshotPlanner.plan(from: [], to: rows)
        #expect(first.sections == [Section(id: "inbox", items: ["a", "b"])])
        let cleared = UIKitSnapshotPlanner.plan(from: rows, to: [])
        #expect(cleared == UIKitSnapshotPlanner.Plan(sections: [], reconfigured: [], duplicates: []))
    }

    @Test("Keeps the first copy of a repeated identifier and reports it once")
    func dropsDuplicates() {
        // Page 2 of a paginated response repeats "b", once in another section
        let rows = [row("a", in: "s1"), row("b", in: "s1"), row("c", in: "s2"), row("b", in: "s2"), row("b", in: "s1"), row("a", in: "s1")]
        let plan = UIKitSnapshotPlanner.plan(from: [], to: rows)
        #expect(plan.sections == [Section(id: "s1", items: ["a", "b"]), Section(id: "s2", items: ["c"])])
        #expect(plan.duplicates == ["b", "a"])
        #expect(plan.sections.flatMap(\.items).count == Set(plan.sections.flatMap(\.items)).count)
    }

    @Test("Reconfigures items whose title or detail changed, and nothing else")
    func reconfiguresChangedContent() {
        let old = [row("a", in: "s", "Milk"), row("b", in: "s", "Eggs", "6"), row("c", in: "s", "Bread")]
        let new = [row("a", in: "s", "Milk"), row("b", in: "s", "Eggs", "12"), row("c", in: "s", "Rye bread")]
        let plan = UIKitSnapshotPlanner.plan(from: old, to: new)
        #expect(plan.reconfigured == ["b", "c"])
        #expect(plan.sections == [Section(id: "s", items: ["a", "b", "c"])])
    }

    @Test("Inserted, deleted and moved items aren't reconfigured: the diff handles them")
    func identityChangesAreNotReconfigured() {
        let old = [row("a", in: "todo", "Call Sam"), row("b", in: "todo", "Pay rent"), row("gone", in: "todo", "Old")]
        // "a" moves to another section unchanged, "gone" is deleted, "new" is inserted
        let new = [row("b", in: "todo", "Pay rent"), row("new", in: "todo", "Buy milk"), row("a", in: "done", "Call Sam")]
        let plan = UIKitSnapshotPlanner.plan(from: old, to: new)
        #expect(plan.sections == [Section(id: "todo", items: ["b", "new"]), Section(id: "done", items: ["a"])])
        #expect(plan.reconfigured.isEmpty)
    }

    @Test("Lists reconfigured items in the new snapshot's order")
    func reconfiguredOrder() {
        let old = [row("x", in: "s1", "1"), row("y", in: "s2", "1"), row("z", in: "s1", "1")]
        let new = [row("y", in: "s2", "2"), row("z", in: "s1", "2"), row("x", in: "s1", "2")]
        let plan = UIKitSnapshotPlanner.plan(from: old, to: new)
        #expect(plan.sections == [Section(id: "s2", items: ["y"]), Section(id: "s1", items: ["z", "x"])])
        #expect(plan.reconfigured == ["y", "z", "x"])
    }

    @Test("Compares against the first copy on each side when either side repeats an identifier")
    func duplicatesOnBothSides() {
        let old = [row("a", in: "s", "Shown"), row("a", in: "s", "Hidden copy")]
        let new = [row("a", in: "s", "Shown"), row("a", in: "s", "Dropped copy")]
        let plan = UIKitSnapshotPlanner.plan(from: old, to: new)
        #expect(plan.sections == [Section(id: "s", items: ["a"])])
        #expect(plan.reconfigured.isEmpty)
        #expect(plan.duplicates == ["a"])
    }
}
