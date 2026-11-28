// Generated from src/dsa/content/lessons/divide-conquer/dc-fast-power.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Top-down: the recursion halves n on the way down and builds the answer on the way back up
func power(_ x: Int, _ n: Int) -> Int {
    if n == 0 { return 1 }
    let half = power(x, n / 2)
    let result = n % 2 == 0 ? half * half : half * half * x
    print("power(\(x), \(n)) = \(result)")
    return result
}

// The same steps as a loop: read n's bits from the top, squaring for each bit and multiplying for each 1
func powerFromTop(_ x: Int, _ n: Int) -> Int {
    var result = 1
    var exponent = 0                              // result is always x^exponent
    for bit in String(n, radix: 2) {
        result *= result                          // doubles the exponent
        exponent *= 2
        if bit == "1" {
            result *= x                           // adds one to the exponent
            exponent += 1
        }
        print("bit \(bit): \(x)^\(exponent) = \(result)")
    }
    return result
}

print(String(13, radix: 2))
_ = power(3, 13)
_ = powerFromTop(3, 13)
