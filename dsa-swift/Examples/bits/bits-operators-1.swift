// Generated from src/dsa/content/lessons/bits/bits-operators.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: UInt8) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

let a: UInt8 = 0b1100
let b: UInt8 = 0b1010

print(binary(a & b), a & b)
print(binary(a | b), a | b)
print(binary(a ^ b), a ^ b)
