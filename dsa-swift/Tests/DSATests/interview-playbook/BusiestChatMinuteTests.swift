import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// A small deterministic random number generator, so every run builds the same logs
private struct ChatMinuteRandom: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return state ^ (state >> 29)
    }
}

@Suite struct BusiestChatMinuteTests {
    /// Brute force, written differently: check each Character against the agreed format.
    private func minuteOfDay(_ stamp: String) -> Int? {
        let characters = Array(stamp)
        guard let colon = characters.firstIndex(of: ":") else { return nil }
        let hour = characters[..<colon], minute = characters[(colon + 1)...]
        let asciiDigits = Set("0123456789")
        guard hour.count == 1 || hour.count == 2, minute.count == 2,
              hour.allSatisfy({ asciiDigits.contains($0) }), minute.allSatisfy({ asciiDigits.contains($0) }),
              let h = Int(String(hour)), let m = Int(String(minute)), h < 24, m < 60 else { return nil }
        return h * 60 + m
    }

    private func reference(_ stamps: [String]) -> String? {
        var counts: [Int: Int] = [:]
        for stamp in stamps {
            if let minute = minuteOfDay(stamp) { counts[minute, default: 0] += 1 }
        }
        guard let best = counts.min(by: { ($1.value, $0.key) < ($0.value, $1.key) })?.key else { return nil }
        let h = best / 60, m = best % 60
        return (h < 10 ? "0" : "") + "\(h):" + (m < 10 ? "0" : "") + "\(m)"
    }

    @Test("The statement's examples", arguments: [
        (["9:05", "10:30", "09:05", "10:30", "9:05"], "09:05" as String?),
        (["23:59", "00:00"], "00:00"),
        (["12:00", "12:00", "24:00", "24:00", "24:00", "13:00"], "12:00"),
        (["7:7", "noon", "07:07"], "07:07"),
        ([], nil),
        (["25:00", "12:60", ""], nil),
    ])
    func examples(stamps: [String], expected: String?) {
        #expect(BusiestChatMinute.busiest(stamps) == expected)
    }

    @Test("Valid stamps, written either way, come back as HH:MM", arguments: [
        ("0:00", "00:00"), ("00:00", "00:00"), ("9:05", "09:05"), ("09:05", "09:05"),
        ("12:34", "12:34"), ("23:59", "23:59"), ("1:59", "01:59"), ("20:00", "20:00"),
    ])
    func validStamp(stamp: String, expected: String) {
        #expect(BusiestChatMinute.busiest([stamp]) == expected)
    }

    @Test("Garbled stamps are skipped", arguments: [
        "24:00", "12:60", "99:99", "12:7", "123:00", "009:05", "12:345", " 9:05", "9:05 ", "9 :05",
        "+9:05", "-1:05", "9:+5", "12:05:30", "", ":", "12", "1205", "12:", ":30", "noon", "12h05",
        "١٢:٠٥", "１２:００", "12:0５", "9:0\u{301}5", "9\u{301}:05", "🕘:05", "12;05", "12.05",
    ])
    func garbled(stamp: String) {
        #expect(BusiestChatMinute.busiest([stamp]) == nil, "\(stamp) isn't a valid stamp")
        #expect(BusiestChatMinute.busiest([stamp, stamp, "8:15"]) == "08:15", "\(stamp) mustn't be counted")
    }

    @Test("Ties go to the earliest minute of the day, whatever the input order")
    func ties() {
        #expect(BusiestChatMinute.busiest(["18:00", "6:00", "18:00", "06:00"]) == "06:00")
        #expect(BusiestChatMinute.busiest(["23:59", "23:58", "0:01"]) == "00:01")
        #expect(BusiestChatMinute.busiest(["13:13", "13:13", "1:13", "1:13", "13:13"]) == "13:13")
    }

    @Test("Matches a brute force on random logs with garbage mixed in")
    func randomLogs() {
        var random = ChatMinuteRandom(seed: 71)
        let garbage = ["24:00", "12:60", "7:7", " 9:05", "١٢:٠٥", "+1:00", "noon", ""]
        var firstMismatch: String? = nil
        for _ in 0..<300 where firstMismatch == nil {
            let count = Int.random(in: 0...25, using: &random)
            let stamps: [String] = (0..<count).map { _ in
                if Int.random(in: 0..<5, using: &random) == 0 {
                    return garbage[Int.random(in: 0..<garbage.count, using: &random)]
                }
                let hour = Int.random(in: 0...23, using: &random)
                let minute = [0, 5, 30, 59][Int.random(in: 0..<4, using: &random)]
                let hourText = hour < 10 && Bool.random(using: &random) ? "0\(hour)" : "\(hour)"
                return hourText + ":" + (minute < 10 ? "0" : "") + "\(minute)"
            }
            let got = BusiestChatMinute.busiest(stamps)
            let expected = reference(stamps)
            if got != expected {
                firstMismatch = "\(stamps): got \(String(describing: got)), expected \(String(describing: expected))"
            }
        }
        #expect(firstMismatch == nil)
    }

    @Test("173,000 stamps")
    func large() {
        // Every minute of the day appears 120 times, in a scrambled order; 14:07 gets one extra, and
        // 24:07, which isn't a time, gets many
        var stamps: [String] = []
        stamps.reserveCapacity(173_000)
        for index in 0..<172_800 {
            let minute = (index * 7) % 1_440
            stamps.append("\(minute / 60):" + (minute % 60 < 10 ? "0" : "") + "\(minute % 60)")
        }
        stamps.append("14:07")
        stamps.append(contentsOf: Array(repeating: "24:07", count: 400))
        #expect(BusiestChatMinute.busiest(stamps) == "14:07")
        stamps.append("3:00")
        #expect(BusiestChatMinute.busiest(stamps) == "03:00", "a tie: 03:00 comes first")
    }
}
