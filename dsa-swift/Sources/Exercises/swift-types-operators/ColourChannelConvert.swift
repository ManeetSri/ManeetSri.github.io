// Problem: Colour channel conversions (M02 · Converting between types)

public enum ColourChannelConvert {
    /// Returns `channel` multiplied by `factor`, rounded to the nearest whole number (halves up)
    /// and capped at 255. Must never crash.
    public static func brightened(_ channel: UInt8, by factor: Double) -> UInt8 {
        // Write your solution here, then run:
        // swift test --filter ColourChannelConvertTests
        return 0
    }

    /// Returns true when `text` is a whole number from 0 to 255 that Swift's integer conversions
    /// accept, such as "128", "+7" or "007".
    public static func isValidChannel(_ text: String) -> Bool {
        return false
    }
}
