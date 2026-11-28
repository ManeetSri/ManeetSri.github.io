// Generated from src/dsa/design/content/lessons/sd-structural/sd-structural-bridge.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The implementation side: primitives that every output format can provide
protocol ReportRenderer {
    func heading(_ text: String) -> String
    func row(_ cells: [String]) -> String
    func total(_ label: String, pence: Int) -> String
}

struct MarkdownRenderer: ReportRenderer {
    func heading(_ text: String) -> String { "## \(text)" }
    func row(_ cells: [String]) -> String { "| " + cells.joined(separator: " | ") + " |" }
    func total(_ label: String, pence: Int) -> String { "**\(label): £\(pounds(pence))**" }
}

struct CSVRenderer: ReportRenderer {
    func heading(_ text: String) -> String { "# \(text)" }
    func row(_ cells: [String]) -> String { cells.map { $0.contains(",") ? "\"\($0)\"" : $0 }.joined(separator: ",") }
    func total(_ label: String, pence: Int) -> String { "\(label),\(pounds(pence))" }
}

func pounds(_ pence: Int) -> String {
    let remainder = pence % 100
    return "\(pence / 100).\(remainder < 10 ? "0" : "")\(remainder)"
}

// The abstraction side: what each report says, written only with the primitives
struct LineItem {
    let name: String
    let quantity: Int
    let unitPence: Int
}

struct Invoice {
    let renderer: any ReportRenderer
    let number: String
    let items: [LineItem]

    func render() -> [String] {
        let total = items.reduce(0) { $0 + $1.quantity * $1.unitPence }
        return [renderer.heading("Invoice \(number)")]
            + items.map { renderer.row([$0.name, String($0.quantity), pounds($0.quantity * $0.unitPence)]) }
            + [renderer.total("Total", pence: total)]
    }
}

struct MonthlySales {
    let renderer: any ReportRenderer
    let month: String
    let days: [(day: String, pence: Int)]

    func render() -> [String] {
        let total = days.reduce(0) { $0 + $1.pence }
        return [renderer.heading("Sales, \(month)")]
            + days.map { renderer.row([$0.day, pounds($0.pence)]) }
            + [renderer.total("Month", pence: total)]
    }
}

let items = [LineItem(name: "Notebook", quantity: 2, unitPence: 450), LineItem(name: "Pens, pack of 5", quantity: 1, unitPence: 399)]
for renderer: any ReportRenderer in [MarkdownRenderer(), CSVRenderer()] {
    Invoice(renderer: renderer, number: "1042", items: items).render().forEach { print($0) }
    print()
}
MonthlySales(renderer: CSVRenderer(), month: "May", days: [("1 May", 12_050), ("2 May", 9_875)]).render().forEach { print($0) }
