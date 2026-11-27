// Generated from src/dsa/content/lessons/capstones/cap-huffman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A Huffman tree in arrays. Leaves have a symbol; inner nodes have two children.
struct HuffmanTree {
    var weight: [Int] = []
    var symbol: [UInt8?] = []
    var left: [Int] = []
    var right: [Int] = []
    var root = -1

    /// The decoder runs this too, on the frequencies in the header, so every tie must break the
    /// same way: leaves in (count, byte) order, and a leaf before an inner node of equal weight.
    init(frequencies: [(byte: UInt8, count: Int)]) {
        let sorted = frequencies.sorted { ($0.count, $0.byte) < ($1.count, $1.byte) }
        for (byte, count) in sorted {
            weight.append(count); symbol.append(byte); left.append(-1); right.append(-1)
        }
        // Two queues: the sorted leaves, and inner nodes, which are made in order of weight anyway
        var nextLeaf = 0
        var inner: [Int] = []
        var nextInner = 0
        func takeLightest() -> Int {
            if nextLeaf < sorted.count && (nextInner == inner.count || weight[nextLeaf] <= weight[inner[nextInner]]) {
                nextLeaf += 1
                return nextLeaf - 1
            }
            nextInner += 1
            return inner[nextInner - 1]
        }
        for _ in 0..<max(sorted.count - 1, 0) {
            let a = takeLightest(), b = takeLightest()
            weight.append(weight[a] + weight[b]); symbol.append(nil); left.append(a); right.append(b)
            inner.append(weight.count - 1)
        }
        root = weight.count - 1
    }

    /// The code for each byte value: left adds a 0, right a 1. A lone symbol gets an empty code.
    func codes() -> [[UInt8]?] {
        var table = [[UInt8]?](repeating: nil, count: 256)
        guard root >= 0 else { return table }
        var stack: [(node: Int, code: [UInt8])] = [(root, [])]
        while let (node, code) = stack.popLast() {
            if let byte = symbol[node] {
                table[Int(byte)] = code
            } else {
                stack.append((right[node], code + [1]))
                stack.append((left[node], code + [0]))
            }
        }
        return table
    }
}

/// Packs bits into bytes, first bit in the highest position
struct BitWriter {
    private(set) var bytes: [UInt8] = []
    private var current: UInt8 = 0
    private var used = 0

    mutating func write(_ bit: UInt8) {
        current = current << 1 | bit
        used += 1
        if used == 8 {
            bytes.append(current)
            (current, used) = (0, 0)
        }
    }

    mutating func finish() -> [UInt8] {
        if used > 0 {
            bytes.append(current << (8 - used))               // pad the last byte with zeros
            (current, used) = (0, 0)
        }
        return bytes
    }
}

func appendBigEndian<T: FixedWidthInteger>(_ value: T, to bytes: inout [UInt8]) {
    for shift in stride(from: T.bitWidth - 8, through: 0, by: -8) {
        bytes.append(UInt8(truncatingIfNeeded: value >> shift))
    }
}

func readBigEndian<T: FixedWidthInteger>(_ type: T.Type, _ bytes: [UInt8], at offset: inout Int) -> T {
    var value: T = 0
    for _ in 0..<(T.bitWidth / 8) {
        value = value << 8 | T(bytes[offset])
        offset += 1
    }
    return value
}

func frequencies(of input: [UInt8]) -> [(byte: UInt8, count: Int)] {
    var counts = [Int](repeating: 0, count: 256)
    for byte in input { counts[Int(byte)] += 1 }
    return (0..<256).filter { counts[$0] > 0 }.map { (byte: UInt8($0), count: counts[$0]) }
}

/// File layout: "HUF1", length (UInt32), symbol count (UInt16), (byte, count as UInt32) per symbol, bits
func compress(_ input: [UInt8]) -> [UInt8] {
    let frequencies = frequencies(of: input)

    var output = Array("HUF1".utf8)
    appendBigEndian(UInt32(input.count), to: &output)
    appendBigEndian(UInt16(frequencies.count), to: &output)
    for (byte, count) in frequencies {
        output.append(byte)
        appendBigEndian(UInt32(count), to: &output)
    }
    let table = HuffmanTree(frequencies: frequencies).codes()
    var writer = BitWriter()
    for byte in input {
        for bit in table[Int(byte)]! { writer.write(bit) }
    }
    return output + writer.finish()
}

func decompress(_ file: [UInt8]) -> [UInt8]? {
    guard file.count >= 10, Array(file[0..<4]) == Array("HUF1".utf8) else { return nil }
    var offset = 4
    let length = Int(readBigEndian(UInt32.self, file, at: &offset))
    let symbolCount = Int(readBigEndian(UInt16.self, file, at: &offset))
    guard file.count >= offset + 5 * symbolCount else { return nil }
    var frequencies: [(byte: UInt8, count: Int)] = []
    for _ in 0..<symbolCount {
        let byte = file[offset]
        offset += 1
        frequencies.append((byte, Int(readBigEndian(UInt32.self, file, at: &offset))))
    }
    guard frequencies.reduce(0, { $0 + $1.count }) == length else { return nil }   // a damaged header
    let tree = HuffmanTree(frequencies: frequencies)          // the same tree the encoder built
    var output: [UInt8] = []
    output.reserveCapacity(length)
    if let only = tree.root >= 0 ? tree.symbol[tree.root] : nil {
        return [UInt8](repeating: only, count: length)        // one symbol: the length says it all
    }
    var node = tree.root
    var bitIndex = offset * 8
    while output.count < length {
        guard bitIndex / 8 < file.count else { return nil }   // truncated file
        let bit = file[bitIndex / 8] >> (7 - bitIndex % 8) & 1
        bitIndex += 1
        node = bit == 0 ? tree.left[node] : tree.right[node]
        if let byte = tree.symbol[node] {
            output.append(byte)
            node = tree.root
        }
    }
    return output
}

func binary(_ byte: UInt8) -> String {
    let digits = String(byte, radix: 2)
    return String(repeating: "0", count: 8 - digits.count) + digits
}

let word = Array("abracadabra".utf8)
let codes = HuffmanTree(frequencies: frequencies(of: word)).codes()
print(frequencies(of: word).map { "\(Character(UnicodeScalar($0.byte)))=\(codes[Int($0.byte)]!.map(String.init).joined())" }.joined(separator: " "))
let packed = compress(word)
let header = 10 + 5 * frequencies(of: word).count
print("\(word.count) bytes -> \(packed.count): header \(header), payload", packed[header...].map(binary).joined(separator: " "))
print("round trip:", decompress(packed) == word, "| truncated file:", decompress(Array(packed.dropLast())) == nil ? "rejected" : "accepted")

let text = Array(String(repeating: "she sells sea shells by the sea shore. ", count: 20).utf8)
let file = compress(text)
print("\(text.count) bytes -> \(file.count) bytes (\(file.count * 100 / text.count)%), round trip:", decompress(file) == text)

for sample in ["", "aaaaaaaa", "ab"] {
    let bytes = Array(sample.utf8)
    let file = compress(bytes)
    print("\"\(sample)\": \(file.count) bytes, round trip:", decompress(file) == bytes)
}
