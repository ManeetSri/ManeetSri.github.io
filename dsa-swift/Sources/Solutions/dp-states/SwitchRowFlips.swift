// Reference solution: Fewest flips to sort a switch row. Two states while reading left to right:
// zeros (everything so far switched off) and ones (already into the on part). A 1 costs a flip in
// zeros; a 0 costs a flip in ones; ones can be entered from either state, but there's no way back to
// zeros. O(n) time, O(1) space.

public enum SwitchRowFlips {
    public static func minimumFlips(_ switches: String) -> Int {
        var zeros = 0
        var ones = 0
        for switchState in switches.utf8 {
            let isOn = switchState == UInt8(ascii: "1")
            (zeros, ones) = (zeros + (isOn ? 1 : 0), min(zeros, ones) + (isOn ? 0 : 1))
        }
        return min(zeros, ones)
    }
}
