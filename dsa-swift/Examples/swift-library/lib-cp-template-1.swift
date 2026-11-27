// Generated from src/dsa/content/lessons/swift-library/lib-cp-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// MARK: Input: read all of standard input once, then scan the bytes
struct FastReader {
    private let bytes: [UInt8]
    private var position = 0

    init(bytes: [UInt8]) {
        self.bytes = bytes
    }

    init() {
        self.init(bytes: [UInt8](FileHandle.standardInput.readDataToEndOfFile()))
    }

    /// Skips spaces, tabs, newlines and anything else at or below ASCII 32.
    private mutating func skipSeparators() {
        while position < bytes.count && bytes[position] <= 32 {
            position += 1
        }
    }

    /// True when only separators are left.
    mutating func isAtEnd() -> Bool {
        skipSeparators()
        return position >= bytes.count
    }

    /// The next integer, with an optional leading minus sign.
    mutating func int() -> Int {
        skipSeparators()
        var isNegative = false
        if position < bytes.count && bytes[position] == UInt8(ascii: "-") {
            isNegative = true
            position += 1
        }
        var value = 0
        while position < bytes.count, bytes[position] >= 48, bytes[position] <= 57 {
            value = value * 10 + Int(bytes[position] - 48)
            position += 1
        }
        return isNegative ? -value : value
    }

    /// The next `count` integers.
    mutating func ints(_ count: Int) -> [Int] {
        (0..<count).map { _ in int() }
    }

    /// The next run of non-separator bytes, such as a word or a grid row.
    mutating func bytesToken() -> [UInt8] {
        skipSeparators()
        let start = position
        while position < bytes.count && bytes[position] > 32 {
            position += 1
        }
        return Array(bytes[start..<position])
    }

    /// The next word as a String.
    mutating func word() -> String {
        String(decoding: bytesToken(), as: UTF8.self)
    }
}

// MARK: Output: collect everything, print once at the end
struct OutputBuffer {
    private var text = ""

    mutating func line(_ value: Int) {
        text += String(value)
        text += "\n"
    }

    mutating func line(_ value: String) {
        text += value
        text += "\n"
    }

    mutating func line(_ values: [Int]) {
        text += values.map(String.init).joined(separator: " ")
        text += "\n"
    }

    func flush() {
        print(text, terminator: "")
    }
}

// MARK: Solution: each test case is a name, a count, then that many scores
func solve(_ input: inout FastReader, _ output: inout OutputBuffer) {
    let name = input.word()
    let count = input.int()
    let scores = input.ints(count)
    output.line("\(name) \(scores.reduce(0, +)) \(scores.max()!)")
}

// A fixed input instead of standard input, with deliberately untidy spacing
let sample = """
3
ada 3
4 -1   7
ben 2
10
20
cy 1 -6
"""
var input = FastReader(bytes: Array(sample.utf8))
var output = OutputBuffer()
let testCases = input.int()
for _ in 0..<testCases {
    solve(&input, &output)
}
output.line(input.isAtEnd() ? "all input read" : "input left over")
output.flush()
