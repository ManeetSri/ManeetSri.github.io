// Generated from src/dsa/design/content/lessons/sd-quality/sd-quality-tech-debt.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct SourceFile {
    let name: String
    let commitsLastSixMonths: Int
    let complexity: Int   // for example, cyclomatic complexity summed over the file
}

let files = [
    SourceFile(name: "CheckoutViewController.swift", commitsLastSixMonths: 48, complexity: 310),
    SourceFile(name: "FeedViewModel.swift", commitsLastSixMonths: 35, complexity: 90),
    SourceFile(name: "LegacyReports.swift", commitsLastSixMonths: 2, complexity: 520),
    SourceFile(name: "APIClient.swift", commitsLastSixMonths: 20, complexity: 140),
    SourceFile(name: "SettingsView.swift", commitsLastSixMonths: 12, complexity: 40),
]

let ranked = files.sorted { $0.commitsLastSixMonths * $0.complexity > $1.commitsLastSixMonths * $1.complexity }
for file in ranked {
    print("\(file.name): \(file.commitsLastSixMonths * file.complexity)")
}
