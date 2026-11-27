// Generated from src/dsa/content/lessons/swift-functions/swift-default-variadic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func average(of values: Double..., roundedTo places: Int = 2) -> Double {
    guard !values.isEmpty else { return 0 }
    var total = 0.0
    for value in values {
        total += value
    }
    let mean = total / Double(values.count)
    var scale = 1.0
    for _ in 0..<places {
        scale *= 10
    }
    return (mean * scale).rounded() / scale
}

print(average(of: 1, 2, 2))
print(average(of: 1, 2, 2, roundedTo: 0))
