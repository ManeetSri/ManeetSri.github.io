// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-auto-layout-engine.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct RowLabel {
    let name: String
    let natural: Double
    var hugging = 250.0
    var compression = 750.0
}

// One row's horizontal axis: margins, labels separated by spacing, filling `width` exactly.
// Each label brings two optional constraints: width ≤ natural (at its hugging priority)
// and width ≥ natural (at its compression resistance).
func layOut(_ labels: [RowLabel], in width: Double, margins: Double = 16, spacing: Double = 8) -> [Double] {
    var widths = labels.map(\.natural)
    let gaps = margins * 2 + spacing * Double(labels.count - 1)
    var spare = width - gaps - widths.reduce(0, +)
    if spare < 0 {
        // Too little room: the lowest compression resistance gives way first
        for index in labels.indices.sorted(by: { labels[$0].compression < labels[$1].compression }) where spare < 0 {
            let give = min(widths[index], -spare)
            widths[index] -= give
            spare += give
        }
    } else if spare > 0, let index = labels.indices.min(by: { labels[$0].hugging < labels[$1].hugging }) {
        // Room to spare: the lowest hugging priority stretches
        widths[index] += spare
    }
    return widths
}

func show(_ case: String, _ labels: [RowLabel], in width: Double) {
    let parts = zip(labels, layOut(labels, in: width)).map { label, width in "\(label.name) \(Int(width)) pt" }
    print("\(`case`): \(parts.joined(separator: ", "))")
}

var date = RowLabel(name: "date", natural: 60, hugging: 251, compression: 751)
show("Room to spare", [RowLabel(name: "title", natural: 180), date], in: 320)
show("Long title", [RowLabel(name: "title", natural: 300), date], in: 320)

date.compression = 749
show("Date resists less", [RowLabel(name: "title", natural: 300), date], in: 320)
