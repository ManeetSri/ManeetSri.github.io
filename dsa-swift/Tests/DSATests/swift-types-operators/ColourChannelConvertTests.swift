import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ColourChannelConvertTests {
    @Test("Brightens and dims channels", arguments: [
        (UInt8(100), 1.5, UInt8(150)),
        (UInt8(40), 2.0, UInt8(80)),
        (UInt8(200), 0.5, UInt8(100)),
        (UInt8(255), 1.0, UInt8(255)),
        (UInt8(10), 1.2, UInt8(12)),
    ])
    func scales(channel: UInt8, factor: Double, expected: UInt8) {
        #expect(ColourChannelConvert.brightened(channel, by: factor) == expected)
    }

    @Test("Rounds to the nearest whole number instead of truncating")
    func rounds() {
        #expect(ColourChannelConvert.brightened(101, by: 0.5) == 51) // 50.5
        #expect(ColourChannelConvert.brightened(3, by: 0.5) == 2) // 1.5
        #expect(ColourChannelConvert.brightened(7, by: 0.25) == 2) // 1.75
        #expect(ColourChannelConvert.brightened(1, by: 0.25) == 0) // 0.25
    }

    @Test("Caps bright results at 255 without crashing")
    func caps() {
        #expect(ColourChannelConvert.brightened(200, by: 2.0) == 255)
        #expect(ColourChannelConvert.brightened(255, by: 10.0) == 255)
        #expect(ColourChannelConvert.brightened(128, by: 1.9921875) == 255) // exactly 255.0
        #expect(ColourChannelConvert.brightened(129, by: 1.9921875) == 255) // about 257
    }

    @Test("A factor of zero, or a black channel, gives 0")
    func zero() {
        #expect(ColourChannelConvert.brightened(80, by: 0.0) == 0)
        #expect(ColourChannelConvert.brightened(0, by: 10.0) == 0)
    }

    @Test("Accepts whole numbers from 0 to 255", arguments: ["0", "7", "128", "255", "007", "+7"])
    func validText(text: String) {
        #expect(ColourChannelConvert.isValidChannel(text))
    }

    @Test("Rejects text that isn't a channel value", arguments: [
        "256", "-1", "1000", "99999999999999999999", "12.5", "7.0", " 7", "7 ", "", "red", "0x1F",
    ])
    func invalidText(text: String) {
        #expect(!ColourChannelConvert.isValidChannel(text))
    }
}
