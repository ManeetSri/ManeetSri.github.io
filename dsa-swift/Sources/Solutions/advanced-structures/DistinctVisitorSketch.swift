// Reference solution: Distinct visitors in a few kilobytes. A HyperLogLog sketch: the top b bits of an
// id's hash pick one of 2^b one-byte registers, and the register keeps the largest rank (leading zeros of
// the remaining bits, plus 1) it has seen. The estimate is the bias-corrected harmonic mean of 2^register,
// switching to linear counting while it's small. Merging is a register-wise max; the overlap of two days
// is |A| + |B| − |A ∪ B|. add is O(1); estimate, merge and overlap are O(m).

import Foundation

public enum DistinctVisitorSketch {
    /// The fixed 64-bit hash every sketch uses: SplitMix64's mixing steps.
    public static func mix(_ id: Int) -> UInt64 {
        var z = UInt64(bitPattern: Int64(id)) &+ 0x9E37_79B9_7F4A_7C15
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }

    public struct Sketch {
        public let indexBits: Int
        public private(set) var registers: [UInt8]

        public init(indexBits: Int) {
            self.indexBits = indexBits
            registers = Array(repeating: 0, count: 1 << indexBits)
        }

        public mutating func add(_ id: Int) {
            let hash = mix(id)
            let index = Int(hash >> UInt64(64 - indexBits))      // the first b bits choose a register
            let rest = hash << UInt64(indexBits)                 // the remaining bits, moved to the top
            let rank = UInt8(min(rest.leadingZeroBitCount, 64 - indexBits) + 1)
            if rank > registers[index] {
                registers[index] = rank
            }
        }

        public var estimate: Double {
            let m = Double(registers.count)
            let alpha = 0.7213 / (1 + 1.079 / m)
            var sum = 0.0
            var empty = 0
            for register in registers {
                sum += pow(2, -Double(register))
                if register == 0 { empty += 1 }
            }
            let raw = alpha * m * m / sum
            if raw <= 2.5 * m && empty > 0 {
                return m * log(m / Double(empty))                // few items: linear counting
            }
            return raw
        }

        public func merged(with other: Sketch) -> Sketch {
            var result = self
            for i in registers.indices where other.registers[i] > result.registers[i] {
                result.registers[i] = other.registers[i]
            }
            return result
        }
    }

    public static func overlapEstimate(_ first: Sketch, _ second: Sketch) -> Double {
        first.estimate + second.estimate - first.merged(with: second).estimate
    }
}
