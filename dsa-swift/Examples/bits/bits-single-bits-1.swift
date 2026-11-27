// Generated from src/dsa/content/lessons/bits/bits-single-bits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: UInt8) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

let x: UInt8 = 0b0101_0010
print(binary(x), "start")
print(x & (1 << 1) != 0, x & (1 << 3) != 0)
print(binary(x | (1 << 3)), "set bit 3")
print(binary(x & ~(1 << 4)), "clear bit 4")
print(binary(x ^ (1 << 0)), "toggle bit 0")
