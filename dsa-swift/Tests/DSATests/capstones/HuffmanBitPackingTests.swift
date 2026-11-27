import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same codes and texts
private struct BitPackingRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct HuffmanBitPackingTests {
    /// The code the lesson's tree gives "abracadabra"
    private let abracadabra: [Character: String] = ["a": "0", "b": "110", "c": "100", "d": "101", "r": "111"]

    /// Brute force: write the bits out as a string of 0s and 1s, pad it, and read it 8 at a time
    private func referencePack(_ text: String, _ codes: [Character: String]) -> [UInt8] {
        var bits = text.map { codes[$0]! }.joined()
        while bits.count % 8 != 0 { bits += "0" }
        let characters = Array(bits)
        return stride(from: 0, to: characters.count, by: 8).map { UInt8(String(characters[$0..<($0 + 8)]), radix: 2)! }
    }

    /// A random complete prefix-free code: split a random leaf of a binary tree until it has `count`
    /// leaves, then hand the leaves' paths to the symbols
    private func randomCode(_ symbols: [Character], using random: inout BitPackingRandom) -> [Character: String] {
        var leaves = [""]
        while leaves.count < symbols.count {
            let leaf = leaves.remove(at: Int.random(in: 0..<leaves.count, using: &random))
            leaves += [leaf + "0", leaf + "1"]
        }
        return Dictionary(uniqueKeysWithValues: zip(symbols, leaves))
    }

    @Test("Packing abracadabra gives the lesson's three bytes")
    func lessonExample() {
        let bytes = HuffmanBitPacking.pack("abracadabra", codes: abracadabra)
        #expect(bytes == [0b0110_1110, 0b1000_1010, 0b1101_1100])
        #expect(HuffmanBitPacking.unpack(bytes, count: 11, codes: abracadabra) == "abracadabra")
    }

    @Test("Bits go in most significant first, and only the last byte is padded", arguments: [
        ("a", [0b0000_0000] as [UInt8]),
        ("b", [0b1100_0000]),
        ("rr", [0b1111_1100]),
        ("aaaaaaaa", [0b0000_0000]),
        ("rrbad", [0b1111_1111, 0b0010_1000]),
        ("bbbbbbbb", [0b1101_1011, 0b0110_1101, 0b1011_0110]),
        ("", []),
    ])
    func packing(text: String, expected: [UInt8]) {
        #expect(HuffmanBitPacking.pack(text, codes: abracadabra) == expected)
    }

    @Test("Unpacking reads exactly count characters and ignores the padding")
    func unpackCount() {
        let bytes = HuffmanBitPacking.pack("abracadabra", codes: abracadabra)
        #expect(HuffmanBitPacking.unpack(bytes, count: 4, codes: abracadabra) == "abra")
        #expect(HuffmanBitPacking.unpack(bytes, count: 0, codes: abracadabra) == "")
        #expect(HuffmanBitPacking.unpack([], count: 0, codes: abracadabra) == "")
        // The single padding bit is a 0, which is a whole code: a 12th character can be read from it
        #expect(HuffmanBitPacking.unpack(bytes, count: 12, codes: abracadabra) == "abracadabraa")
        #expect(HuffmanBitPacking.unpack(bytes + [0xFF], count: 11, codes: abracadabra) == "abracadabra")
    }

    @Test("Damaged data gives nil, never a crash")
    func damaged() {
        let bytes = HuffmanBitPacking.pack("abracadabra", codes: abracadabra)
        #expect(HuffmanBitPacking.unpack(Array(bytes.dropLast()), count: 11, codes: abracadabra) == nil)
        #expect(HuffmanBitPacking.unpack([], count: 1, codes: abracadabra) == nil)
        #expect(HuffmanBitPacking.unpack(bytes, count: 13, codes: abracadabra) == nil)
        // With only the codes "0" and "10", no code starts with "11"
        let gappy: [Character: String] = ["x": "0", "y": "10"]
        #expect(HuffmanBitPacking.unpack([0b1100_0000], count: 1, codes: gappy) == nil)
        #expect(HuffmanBitPacking.unpack([0b0100_0000], count: 2, codes: gappy) == "xy")
        #expect(HuffmanBitPacking.unpack([0b1000_0000], count: 1, codes: [:]) == nil)
    }

    @Test("A text with one distinct character uses the empty code: no bits at all")
    func singleSymbol() {
        #expect(HuffmanBitPacking.pack("zzzz", codes: ["z": ""]) == [])
        #expect(HuffmanBitPacking.unpack([], count: 4, codes: ["z": ""]) == "zzzz")
        #expect(HuffmanBitPacking.unpack([0xAB], count: 2, codes: ["z": ""]) == "zz")
    }

    @Test("Codes longer than a byte, and any Characters")
    func longCodesAndUnicode() {
        // A skewed code: symbol k gets k ones and then a zero, except the last, which gets ten ones
        let symbols = Array("é🙂ab日cdefgh")
        var skewed: [Character: String] = [:]
        for (k, symbol) in symbols.enumerated() {
            skewed[symbol] = String(repeating: "1", count: k) + (k == symbols.count - 1 ? "" : "0")
        }
        let text = "h🙂éhhaé日h"
        let bytes = HuffmanBitPacking.pack(text, codes: skewed)
        #expect(bytes == referencePack(text, skewed))
        #expect(HuffmanBitPacking.unpack(bytes, count: text.count, codes: skewed) == text)
        // "e" followed by a combining accent is the same Character as "é"
        #expect(HuffmanBitPacking.pack("e\u{301}", codes: skewed) == [0b0000_0000])
    }

    @Test("Round trips with random prefix codes match a brute-force packer")
    func randomRoundTrips() {
        var random = BitPackingRandom(seed: 74)
        let alphabet = Array("abcdefghijklmnopqrstuvwxyz0123456789 .,!?é🙂")
        var firstMismatch: String? = nil
        for _ in 0..<300 where firstMismatch == nil {
            let symbols = Array(alphabet.shuffled(using: &random).prefix(Int.random(in: 2...alphabet.count, using: &random)))
            let codes = randomCode(symbols, using: &random)
            let text = String((0..<Int.random(in: 0...40, using: &random)).map { _ in symbols.randomElement(using: &random)! })
            let bytes = HuffmanBitPacking.pack(text, codes: codes)
            let unpacked = HuffmanBitPacking.unpack(bytes, count: text.count, codes: codes)
            if bytes != referencePack(text, codes) || unpacked != text {
                firstMismatch = "\(text) with \(codes): packed \(bytes), unpacked \(String(describing: unpacked))"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("200,000 characters there and back")
    func large() {
        var random = BitPackingRandom(seed: 2_024)
        let codes: [Character: String] = ["e": "00", "t": "010", "a": "011", " ": "10", "o": "1100", "n": "1101", "s": "1110", "x": "1111"]
        let symbols = Array("eeeettaaa    oonsx")
        let text = String((0..<200_000).map { _ in symbols.randomElement(using: &random)! })
        let bits = text.reduce(0) { $0 + codes[$1]!.count }
        let bytes = HuffmanBitPacking.pack(text, codes: codes)
        #expect(bytes.count == (bits + 7) / 8)
        #expect(HuffmanBitPacking.unpack(bytes, count: text.count, codes: codes) == text)
    }
}
