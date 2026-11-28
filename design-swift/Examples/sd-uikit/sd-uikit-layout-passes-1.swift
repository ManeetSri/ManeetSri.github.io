// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-layout-passes.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class ToyView {
    private(set) var layoutPasses = 0
    private var needsLayout = false

    var text = "" {
        didSet { setNeedsLayout() }
    }

    func setNeedsLayout() {
        needsLayout = true
    }

    func layoutIfNeeded() {
        guard needsLayout else { return }
        needsLayout = false
        layoutPasses += 1
    }
}

// What UIKit does once per run loop turn: lay out every view that's marked
func endOfRunLoopTurn(_ views: [ToyView]) {
    views.forEach { $0.layoutIfNeeded() }
}

let batched = ToyView()
for row in 1...100 {
    batched.text = "Row \(row)"
}
endOfRunLoopTurn([batched])
print("Deferred: 100 changes, \(batched.layoutPasses) layout pass")

let forced = ToyView()
for row in 1...100 {
    forced.text = "Row \(row)"
    forced.layoutIfNeeded() // say, to measure the view after each change
}
endOfRunLoopTurn([forced])
print("Forced: 100 changes, \(forced.layoutPasses) layout passes")
