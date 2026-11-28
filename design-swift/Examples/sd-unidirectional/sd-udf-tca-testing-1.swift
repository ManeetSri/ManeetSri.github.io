// Generated from src/dsa/design/content/lessons/sd-unidirectional/sd-udf-tca-testing.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct SearchState: Equatable {
    var query = ""
    var results: [String] = []
    var isSearching = false
}

func reduce(_ state: inout SearchState, query: String) {
    state.query = query
    state.isSearching = query.count >= 2
}

/// The fields that differ, the way a test store explains a failure
func differences<T>(_ expected: T, _ actual: T) -> [String] {
    zip(Mirror(reflecting: expected).children, Mirror(reflecting: actual).children).compactMap { want, got in
        let (wanted, actual) = (String(describing: want.value), String(describing: got.value))
        return wanted == actual ? nil : "\(want.label ?? "?"): expected \(wanted), actual \(actual)"
    }
}

/// Applies the test's description of the change to a copy of the previous state, then compares
func check(_ name: String, query: String, _ describe: (inout SearchState) -> Void) {
    let previous = SearchState()
    var actual = previous
    reduce(&actual, query: query)
    var expected = previous
    describe(&expected)
    if expected == actual {
        print("passed: \(name)")
    } else {
        print("failed: \(name)")
        differences(expected, actual).forEach { print("  \($0)") }
    }
}

check("describes every change", query: "dun") {
    $0.query = "dun"
    $0.isSearching = true
}
check("forgets isSearching", query: "dun") {
    $0.query = "dun"
}
check("expects results too early", query: "dun") {
    $0.query = "dun"
    $0.isSearching = true
    $0.results = ["Dune"]
}
