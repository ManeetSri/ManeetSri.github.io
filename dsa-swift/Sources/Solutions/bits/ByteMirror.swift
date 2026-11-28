// Reference solution: Byte mirror. Swap the halves, then neighbouring pairs, then neighbouring bits.
// O(1) time and space.

public enum ByteMirror {
    public static func mirrored(_ byte: UInt8) -> UInt8 {
        var b = byte
        b = ((b & 0xF0) >> 4) | ((b & 0x0F) << 4)
        b = ((b & 0xCC) >> 2) | ((b & 0x33) << 2)
        b = ((b & 0xAA) >> 1) | ((b & 0x55) << 1)
        return b
    }
}
