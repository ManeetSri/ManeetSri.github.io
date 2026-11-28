// Generated from src/dsa/design/content/lessons/sd-swiftui/sd-swiftui-observable.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Observation
import Synchronization

// Option 1: the list holds structs
struct ChecklistItem {
    var title: String
    var isDone = false
}

@Observable
final class ValueChecklist {
    var items = [ChecklistItem(title: "Book flights"), ChecklistItem(title: "Renew passport"), ChecklistItem(title: "Pack")]
}

// Option 2: every item is an observable object of its own
@Observable
final class ChecklistTask {
    var title: String
    var isDone = false

    init(title: String) {
        self.title = title
    }
}

@Observable
final class ObjectChecklist {
    var items = [ChecklistTask(title: "Book flights"), ChecklistTask(title: "Renew passport"), ChecklistTask(title: "Pack")]
}

// onChange is @Sendable, so the invalidated rows are recorded behind a Mutex
let invalidated = Mutex<[Int]>([])

func row(_ index: Int, reads read: () -> Void) {
    withObservationTracking(read) {
        invalidated.withLock { $0.append(index) }
    }
}

func report(_ label: String) {
    let rows = invalidated.withLock { rows in
        defer { rows = [] }
        return rows.sorted()
    }
    print("\(label): rows \(rows) need new bodies")
}

// Each row reads only its own item's isDone, as a row view's body would
let values = ValueChecklist()
for index in values.items.indices {
    row(index) { _ = values.items[index].isDone }
}
values.items[1].isDone = true
report("Array of structs")

let objects = ObjectChecklist()
for (index, task) in objects.items.enumerated() {
    row(index) { _ = task.isDone }
}
objects.items[1].isDone = true
report("Array of objects")
