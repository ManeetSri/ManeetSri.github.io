// Reference solution: Colour channel conversions. Brightening goes up to Double, rounds, then comes
// back down through Int with UInt8(clamping:) capping at 255. UInt8(text) rejects anything that
// isn't a whole number or doesn't fit in 0...255. O(1) time and space.

public enum ColourChannelConvert {
    public static func brightened(_ channel: UInt8, by factor: Double) -> UInt8 {
        let scaled = (Double(channel) * factor).rounded()
        return UInt8(clamping: Int(scaled))
    }

    public static func isValidChannel(_ text: String) -> Bool {
        UInt8(text) != nil
    }
}
