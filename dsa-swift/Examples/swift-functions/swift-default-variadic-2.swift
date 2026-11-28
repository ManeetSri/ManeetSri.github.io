// Generated from src/dsa/content/lessons/swift-functions/swift-default-variadic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func power(_ base: Int, exponent: Int = 2, verbose: Bool = false) -> Int {
    var result = 1
    for _ in 0..<exponent {
        result *= base
    }
    if verbose {
        print("\(base) to the power \(exponent) is \(result)")
    }
    return result
}

print(power(5))
print(power(2, exponent: 10))
_ = power(3, verbose: true)
