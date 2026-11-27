// Generated from src/dsa/content/lessons/bits/bits-binary-twos-complement.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binary(_ x: UInt8) -> String {
    let digits = String(x, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

let minusFive: Int8 = -5
print(String(minusFive, radix: 2))
print(binary(UInt8(bitPattern: minusFive)))
print(Int8(bitPattern: 0b1111_1011))
print(UInt8(bitPattern: -1))
