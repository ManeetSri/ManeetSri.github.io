// Reference solution: busiest chat minute. A day has only 1,440 minutes, so count into a fixed array
// indexed by minute of the day, skipping every stamp that isn't exactly 1 or 2 ASCII digits, a colon
// and 2 ASCII digits in range. Reading the UTF-8 bytes means any non-ASCII character (full-width or
// Arabic-Indic digits, accents, emoji) simply fails the digit check. O(total length) time, O(1) space.

public enum BusiestChatMinute {
    public static func busiest(_ stamps: [String]) -> String? {
        var counts = [Int](repeating: 0, count: 24 * 60)
        var sawValid = false
        for stamp in stamps {
            guard let minute = minuteOfDay(stamp) else { continue }
            counts[minute] += 1
            sawValid = true
        }
        guard sawValid else { return nil }
        var best = 0
        for minute in counts.indices where counts[minute] > counts[best] {
            best = minute                        // strictly greater: ties keep the earlier minute
        }
        return twoDigits(best / 60) + ":" + twoDigits(best % 60)
    }

    /// The minute of the day for a valid stamp such as "9:05" or "09:05", or nil.
    private static func minuteOfDay(_ stamp: String) -> Int? {
        let bytes = Array(stamp.utf8)
        guard let colon = bytes.firstIndex(of: UInt8(ascii: ":")) else { return nil }
        let hourDigits = bytes[..<colon]
        let minuteDigits = bytes[(colon + 1)...]
        guard (1...2).contains(hourDigits.count), minuteDigits.count == 2,
              hourDigits.allSatisfy(isDigit), minuteDigits.allSatisfy(isDigit) else { return nil }
        let hour = number(hourDigits)
        let minute = number(minuteDigits)
        guard hour < 24, minute < 60 else { return nil }
        return hour * 60 + minute
    }

    private static func isDigit(_ byte: UInt8) -> Bool {
        byte >= UInt8(ascii: "0") && byte <= UInt8(ascii: "9")
    }

    private static func number(_ digits: ArraySlice<UInt8>) -> Int {
        digits.reduce(0) { $0 * 10 + Int($1 - UInt8(ascii: "0")) }
    }

    private static func twoDigits(_ value: Int) -> String {
        value < 10 ? "0\(value)" : "\(value)"
    }
}
