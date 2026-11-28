// Generated from src/dsa/content/lessons/bits/bits-operators.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: UInt8) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

let x: UInt8 = 0b0000_0110
print(binary(x << 1), x << 1)
print(binary(x << 3), x << 3)
print(binary(x >> 1), x >> 1)
print(binary(x >> 2), x >> 2)
print(1 << 10)
