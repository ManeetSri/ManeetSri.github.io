// Generated from src/dsa/content/lessons/patterns/pat-recognition.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Rough step counts for the usual complexity classes, to compare against a budget of about 10⁸
import Foundation

func steps(_ n: Double) -> [(String, Double)] {
    [("n", n), ("n log n", n * log2(n)), ("n²", n * n), ("2ⁿ", pow(2, n))]
}

for n in [20.0, 5_000, 100_000] {
    let fits = steps(n).filter { $0.1 <= 1e8 }.map { $0.0 }
    print("n = \(Int(n)): fits \(fits.joined(separator: ", "))")
}
