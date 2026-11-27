import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ByteMirrorTests {
    @Test("Mirrors the bits", arguments: [
        (UInt8(0b0000_0001), UInt8(0b1000_0000)),
        (0b0000_1101, 0b1011_0000),
        (0b1100_1010, 0b0101_0011),
        (0b1111_0000, 0b0000_1111),
        (0b1000_0000, 0b0000_0001),
        (0b0010_0110, 0b0110_0100),
    ])
    func mirrors(byte: UInt8, expected: UInt8) {
        #expect(ByteMirror.mirrored(byte) == expected)
    }

    @Test("All zeros and all ones stay the same")
    func extremes() {
        #expect(ByteMirror.mirrored(0) == 0)
        #expect(ByteMirror.mirrored(255) == 255)
    }

    @Test("Symmetric bytes don't change", arguments: [UInt8(0b1000_0001), 0b0110_0110, 0b1001_1001, 0b0011_1100])
    func palindromes(byte: UInt8) {
        #expect(ByteMirror.mirrored(byte) == byte)
    }

    @Test("A single bit k moves to bit 7 - k", arguments: 0..<8)
    func singleBits(k: Int) {
        #expect(ByteMirror.mirrored(UInt8(1) << k) == UInt8(1) << (7 - k))
    }

    @Test("Mirroring twice gives back every byte, and keeps the number of set bits")
    func everyByte() {
        var firstWrong: UInt8? = nil
        for value in 0...255 {
            let byte = UInt8(value)
            let once = ByteMirror.mirrored(byte)
            if ByteMirror.mirrored(once) != byte || once.nonzeroBitCount != byte.nonzeroBitCount {
                firstWrong = firstWrong ?? byte
            }
        }
        #expect(firstWrong == nil, "the first byte that doesn't mirror correctly")
    }
}
