import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

// enter and changePin are mutating, and #expect can't call a mutating method,
// so each result is stored in a constant first.
@Suite struct GuardedPinLockTests {
    typealias Lock = GuardedPinLock.Lock

    /// Enters each guess in turn and returns what each call returned.
    private static func enter(_ guesses: [String], into lock: inout Lock) -> [Bool] {
        guesses.map { lock.enter($0) }
    }

    @Test("Valid PINs are exactly four digits", arguments: ["1234", "0000", "9876"])
    func validPins(pin: String) {
        #expect(Lock(pin: pin) != nil)
    }

    @Test("Anything else is refused", arguments: ["", "123", "12345", "12a4", "12 4", "-123", "٤٣٢١"])
    func invalidPins(pin: String) {
        #expect(Lock(pin: pin) == nil)
    }

    @Test("A new lock is closed with three attempts")
    func newLock() throws {
        let lock = try #require(Lock(pin: "1234"))
        #expect(!lock.isOpen)
        #expect(lock.attemptsLeft == 3)
        #expect(!lock.isBlocked)
    }

    @Test("The right PIN opens the lock, and close closes it")
    func opens() throws {
        var lock = try #require(Lock(pin: "1234"))
        let opened = lock.enter("1234")
        #expect(opened)
        #expect(lock.isOpen)
        lock.close()
        #expect(!lock.isOpen)
        let reopened = lock.enter("1234")
        #expect(reopened)
    }

    @Test("Each wrong PIN uses an attempt; three block the lock for good")
    func blocks() throws {
        var lock = try #require(Lock(pin: "1234"))
        let first = lock.enter("0000")
        #expect(!first)
        #expect(lock.attemptsLeft == 2)
        let more = Self.enter(["1111", "4321"], into: &lock)
        #expect(more == [false, false])
        #expect(lock.attemptsLeft == 0)
        #expect(lock.isBlocked)
        let blocked = lock.enter("1234")
        #expect(!blocked, "A blocked lock ignores even the right PIN")
        #expect(!lock.isOpen)
        #expect(lock.attemptsLeft == 0)
    }

    @Test("The right PIN restores all three attempts")
    func resetsAttempts() throws {
        var lock = try #require(Lock(pin: "2468"))
        let results = Self.enter(["1111", "2222", "2468"], into: &lock)
        #expect(results == [false, false, true])
        #expect(lock.attemptsLeft == 3)
        lock.close()
        let later = Self.enter(["1111", "2222"], into: &lock)
        #expect(later == [false, false])
        #expect(lock.attemptsLeft == 1)
        #expect(!lock.isBlocked)
    }

    @Test("A wrong PIN closes an open lock")
    func wrongPinCloses() throws {
        var lock = try #require(Lock(pin: "1234"))
        let results = Self.enter(["1234", "9999"], into: &lock)
        #expect(results == [true, false])
        #expect(!lock.isOpen)
        #expect(lock.attemptsLeft == 2)
    }

    @Test("The PIN can only change while open, to a valid PIN")
    func changePin() throws {
        var lock = try #require(Lock(pin: "1234"))
        let whileClosed = lock.changePin(to: "5678")
        #expect(!whileClosed, "Closed locks can't change their PIN")
        let opened = lock.enter("1234")
        #expect(opened)
        let tooShort = lock.changePin(to: "56")
        let notDigits = lock.changePin(to: "five")
        #expect(!tooShort)
        #expect(!notDigits)
        let changed = lock.changePin(to: "5678")
        #expect(changed)
        lock.close()
        let results = Self.enter(["1234", "5678"], into: &lock)
        #expect(results == [false, true], "The old PIN no longer works; the new one does")
    }

    @Test("Copies of a lock are independent")
    func copies() throws {
        let lock = try #require(Lock(pin: "1234"))
        var copy = lock
        let wrong = copy.enter("0000")
        #expect(!wrong)
        #expect(copy.attemptsLeft == 2)
        #expect(lock.attemptsLeft == 3)
    }
}
