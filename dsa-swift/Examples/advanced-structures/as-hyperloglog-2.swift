// Generated from src/dsa/content/lessons/advanced-structures/as-hyperloglog.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

func hash(_ id: Int) -> UInt64 {
    var z = UInt64(bitPattern: Int64(id)) &+ 0x9E37_79B9_7F4A_7C15
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

struct HyperLogLog {
    let indexBits: Int                           // b: 2^b registers
    private(set) var registers: [UInt8]

    init(indexBits: Int) {
        self.indexBits = indexBits
        registers = Array(repeating: 0, count: 1 << indexBits)
    }

    mutating func add(_ id: Int) {
        let h = hash(id)
        let index = Int(h >> (64 - indexBits))   // the first b bits choose a register
        let rest = h << indexBits                // the remaining bits, moved to the top
        let rank = UInt8(min(rest.leadingZeroBitCount, 64 - indexBits) + 1)
        registers[index] = max(registers[index], rank)
    }

    var estimate: Double {
        let m = Double(registers.count)
        let alpha = 0.7213 / (1 + 1.079 / m)
        let sum = registers.reduce(0.0) { $0 + pow(2, -Double($1)) }
        let raw = alpha * m * m / sum            // a harmonic mean of 2^register, scaled
        let empty = registers.filter { $0 == 0 }.count
        if raw <= 2.5 * m && empty > 0 {
            return m * log(m / Double(empty))    // few items: count the empty registers instead
        }
        return raw
    }

    // The union of two sketches: the larger value in each register
    func merged(with other: HyperLogLog) -> HyperLogLog {
        var result = self
        for i in registers.indices {
            result.registers[i] = max(registers[i], other.registers[i])
        }
        return result
    }
}

for n in [100, 1_000, 10_000, 100_000, 1_000_000] {
    var visitors = HyperLogLog(indexBits: 12)    // 4,096 registers of one byte each
    for id in 0..<n {
        visitors.add(id)
        visitors.add(id)                         // a repeat visit changes nothing
    }
    let error = (visitors.estimate - Double(n)) / Double(n) * 100
    print("distinct \(n): estimate \(Int(visitors.estimate.rounded())), error \(String(format: "%+.1f", error))%")
}

var monday = HyperLogLog(indexBits: 12)
var tuesday = HyperLogLog(indexBits: 12)
for id in 0..<60_000 { monday.add(id) }
for id in 40_000..<100_000 { tuesday.add(id) }
let both = monday.merged(with: tuesday)
print("Monday ≈", Int(monday.estimate.rounded()), " Tuesday ≈", Int(tuesday.estimate.rounded()),
      " either day ≈", Int(both.estimate.rounded()), "(exactly 100000)")
