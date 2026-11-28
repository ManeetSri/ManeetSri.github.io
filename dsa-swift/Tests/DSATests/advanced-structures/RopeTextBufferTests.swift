import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run tests the same inputs
private struct RopeRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

/// Calls undo() outside #expect, which can't call mutating methods on a captured variable.
private func undoing(_ buffer: inout RopeTextBuffer.Buffer) -> Bool {
    buffer.undo()
}

@Suite struct RopeTextBufferTests {
    @Test("The example from the statement")
    func statementExample() {
        var buffer = RopeTextBuffer.Buffer("Hello, world!")
        #expect(buffer.count == 13)
        #expect(buffer.character(at: 7) == "w")
        buffer.insert("brave new ", at: 7)
        #expect(buffer.text == "Hello, brave new world!")
        buffer.delete(from: 5, count: 1)
        #expect(buffer.text == "Hello brave new world!")
        #expect(buffer.slice(from: 6, count: 5) == "brave")
        #expect(undoing(&buffer) == true)
        #expect(buffer.text == "Hello, brave new world!")
        #expect(undoing(&buffer) == true)
        #expect(buffer.text == "Hello, world!")
        #expect(undoing(&buffer) == false)
        #expect(buffer.text == "Hello, world!")
    }

    @Test("An empty buffer, and edits at both ends")
    func ends() {
        var buffer = RopeTextBuffer.Buffer()
        #expect(buffer.count == 0)
        #expect(buffer.text == "")
        #expect(buffer.slice(from: 0, count: 0) == "")
        buffer.insert("middle", at: 0)
        buffer.insert("[", at: 0)
        buffer.insert("]", at: buffer.count)
        #expect(buffer.text == "[middle]")
        buffer.delete(from: 0, count: 1)
        buffer.delete(from: buffer.count - 1, count: 1)
        #expect(buffer.text == "middle")
        buffer.delete(from: 0, count: buffer.count)
        #expect(buffer.text == "")
        #expect(buffer.count == 0)
    }

    @Test("Empty inserts and deletes still count as edits")
    func emptyEdits() {
        var buffer = RopeTextBuffer.Buffer("abc")
        buffer.insert("", at: 1)
        buffer.delete(from: 2, count: 0)
        #expect(buffer.text == "abc")
        #expect(undoing(&buffer) == true)
        #expect(undoing(&buffer) == true)
        #expect(undoing(&buffer) == false)
        #expect(buffer.text == "abc")
    }

    @Test("Characters, not bytes: emoji and accented letters count once")
    func characters() {
        var buffer = RopeTextBuffer.Buffer("café 🙂 ok")
        #expect(buffer.count == 9)
        #expect(buffer.character(at: 3) == "é")
        #expect(buffer.character(at: 5) == "🙂")
        buffer.insert("🇬🇧", at: 5)
        #expect(buffer.text == "café 🇬🇧🙂 ok")
        #expect(buffer.slice(from: 5, count: 2) == "🇬🇧🙂")
        buffer.delete(from: 3, count: 1)
        #expect(buffer.text == "caf 🇬🇧🙂 ok")
    }

    @Test("A copy is independent, undo history included")
    func copies() {
        var original = RopeTextBuffer.Buffer("draft")
        original.insert(" one", at: 5)
        var copy = original
        copy.insert(" two", at: copy.count)
        original.delete(from: 0, count: 1)
        #expect(original.text == "raft one")
        #expect(copy.text == "draft one two")
        #expect(undoing(&copy) == true)
        #expect(copy.text == "draft one")
        #expect(undoing(&copy) == true)
        #expect(copy.text == "draft")
        #expect(original.text == "raft one")
    }

    @Test("Matches an array through thousands of random edits and undos", arguments: [1, 2, 3] as [UInt64])
    func matchesModel(seed: UInt64) {
        var random = RopeRandom(seed: seed)
        let letters = Array("abcdefghij XYZ")
        var buffer = RopeTextBuffer.Buffer("start")
        var model = Array("start")
        var history: [[Character]] = []
        for step in 0..<3_000 {
            switch Int.random(in: 0..<10, using: &random) {
            case 0..<5:
                let piece = (0..<Int.random(in: 0...6, using: &random)).map { _ in letters.randomElement(using: &random)! }
                let index = Int.random(in: 0...model.count, using: &random)
                history.append(model)
                model.insert(contentsOf: piece, at: index)
                buffer.insert(String(piece), at: index)
            case 5..<8:
                let start = Int.random(in: 0...model.count, using: &random)
                let length = Int.random(in: 0...min(5, model.count - start), using: &random)
                history.append(model)
                model.removeSubrange(start..<(start + length))
                buffer.delete(from: start, count: length)
            case 8:
                let expected = history.popLast()
                if let expected { model = expected }
                if buffer.undo() != (expected != nil) {
                    Issue.record("undo() returned the wrong answer at step \(step)")
                    return
                }
            default:
                guard !model.isEmpty else { continue }
                let index = Int.random(in: 0..<model.count, using: &random)
                let length = Int.random(in: 0...(model.count - index), using: &random)
                if buffer.character(at: index) != model[index]
                    || buffer.slice(from: index, count: length) != String(model[index..<(index + length)]) {
                    Issue.record("character(at:) or slice is wrong at step \(step)")
                    return
                }
            }
            if buffer.count != model.count {
                Issue.record("count is wrong at step \(step)")
                return
            }
        }
        #expect(buffer.text == String(model))
    }

    @Test("10,000 edits to a 50,000-character document, then undo them all")
    func large() {
        var random = RopeRandom(seed: 2_024)
        let original = String((0..<50_000).map { Character(UnicodeScalar(UInt8(97 + $0 % 26))) })
        var buffer = RopeTextBuffer.Buffer(original)
        var model = Array(original.utf8)           // one byte per letter: a fast model to check against
        var halfway: [UInt8] = []
        for edit in 0..<10_000 {
            if edit == 5_000 { halfway = model }
            if Int.random(in: 0..<3, using: &random) < 2 {
                let piece = (0..<Int.random(in: 1...8, using: &random)).map { _ in UInt8.random(in: 65...90, using: &random) }
                let index = Int.random(in: 0...model.count, using: &random)
                model.insert(contentsOf: piece, at: index)
                buffer.insert(String(decoding: piece, as: UTF8.self), at: index)
            } else {
                let start = Int.random(in: 0..<model.count, using: &random)
                let length = min(Int.random(in: 1...8, using: &random), model.count - start)
                model.removeSubrange(start..<(start + length))
                buffer.delete(from: start, count: length)
            }
            if edit % 500 == 0 {
                let index = Int.random(in: 0..<model.count, using: &random)
                if buffer.character(at: index) != Character(UnicodeScalar(model[index])) {
                    Issue.record("character(at: \(index)) is wrong after edit \(edit)")
                    return
                }
            }
        }
        #expect(buffer.count == model.count)
        #expect(buffer.text == String(decoding: model, as: UTF8.self))
        for _ in 0..<5_000 {
            buffer.undo()
        }
        #expect(buffer.text == String(decoding: halfway, as: UTF8.self))
        for _ in 0..<5_000 {
            buffer.undo()
        }
        #expect(buffer.text == original)
        #expect(undoing(&buffer) == false)
    }
}
