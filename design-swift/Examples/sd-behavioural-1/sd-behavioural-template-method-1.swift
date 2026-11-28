// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-template-method.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol ReportExporter {
    // Steps every exporter must provide
    func header() -> String
    func row(_ values: [String]) -> String
    // A hook: declared here so conforming types can customise it, with a default below
    func footer(rowCount: Int) -> String
}

extension ReportExporter {
    /// The template method. It isn't a requirement, so no conforming type can replace it.
    func export(_ rows: [[String]]) -> String {
        ([header()] + rows.map(row) + [footer(rowCount: rows.count)])
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
    }

    func footer(rowCount: Int) -> String { "" }

    // Not a requirement: a conforming type's own version is NOT used through the protocol
    func fileExtension() -> String { "txt" }
}

struct CSVExporter: ReportExporter {
    func header() -> String { "date,amount" }
    func row(_ values: [String]) -> String { values.joined(separator: ",") }
    func fileExtension() -> String { "csv" } // looks like an override; isn't one
}

struct MarkdownExporter: ReportExporter {
    func header() -> String { "| date | amount |\n| --- | --- |" }
    func row(_ values: [String]) -> String { "| " + values.joined(separator: " | ") + " |" }
    func footer(rowCount: Int) -> String { "Total: \(rowCount) rows" }
}

let rows = [["1 Nov", "12.50"], ["2 Nov", "8.00"]]
let exporters: [any ReportExporter] = [CSVExporter(), MarkdownExporter()]
for exporter in exporters {
    print("--- file.\(exporter.fileExtension())")
    print(exporter.export(rows))
}
print("--- but CSVExporter().fileExtension() is \(CSVExporter().fileExtension())")
