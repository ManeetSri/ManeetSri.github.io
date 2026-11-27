import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ElementAtAddressTests {
    @Test("Finds where an element starts", arguments: [
        (5, 100, 8, 140),
        (0, 4096, 16, 4096),
        (1, 0, 1, 1),
        (3, 1_000, 3, 1_009),
        (7, 64, 24, 232),
    ])
    func addresses(index: Int, base: Int, stride: Int, expected: Int) {
        #expect(ElementAtAddress.address(ofIndex: index, base: base, stride: stride) == expected)
    }

    @Test("Finds the element that owns a byte", arguments: [
        (140, 100, 8, 8, 10, 5 as Int?),
        (147, 100, 8, 8, 10, 5),
        (100, 100, 8, 8, 10, 0),
        (179, 100, 8, 8, 10, 9),
        (124, 100, 9, 16, 4, 1),
        (116, 100, 9, 16, 4, 1),
        (5, 0, 1, 1, 6, 5),
    ])
    func owners(address: Int, base: Int, size: Int, stride: Int, count: Int, expected: Int?) {
        #expect(ElementAtAddress.owner(ofByte: address, base: base, size: size, stride: stride, count: count) == expected)
    }

    @Test("Bytes outside every element belong to nobody", arguments: [
        (180, 100, 8, 8, 10),      // where element 10 would start
        (99, 100, 8, 8, 10),       // just before the array
        (93, 100, 8, 8, 10),       // -7 / 8 is 0 in Swift
        (-50, 0, 4, 4, 100),
        (125, 100, 9, 16, 4),      // the first padding byte of element 1
        (131, 100, 9, 16, 4),      // the last padding byte of element 1
        (100, 100, 8, 8, 0),       // an empty array owns nothing
    ])
    func nobody(address: Int, base: Int, size: Int, stride: Int, count: Int) {
        #expect(ElementAtAddress.owner(ofByte: address, base: base, size: size, stride: stride, count: count) == nil)
    }

    @Test("Agrees with checking every element, byte by byte")
    func matchesScan() {
        var mismatches = 0
        for (size, stride) in [(1, 1), (8, 8), (3, 4), (9, 16), (1, 5)] {
            let base = 1_000
            let count = 6
            for address in (base - 2 * stride)...(base + (count + 2) * stride) {
                var expected: Int? = nil
                for index in 0..<count {
                    let start = base + index * stride
                    if address >= start && address < start + size { expected = index }
                }
                if ElementAtAddress.owner(ofByte: address, base: base, size: size, stride: stride, count: count) != expected {
                    mismatches += 1
                }
            }
        }
        #expect(mismatches == 0)
    }

    @Test("Stays O(1) for an array of a trillion elements")
    func trillion() {
        let count = 1_000_000_000_000
        let base = 1 << 40
        let last = count - 1
        #expect(ElementAtAddress.address(ofIndex: last, base: base, stride: 16) == base + last * 16)
        let lastStart = base + last * 16
        #expect(ElementAtAddress.owner(ofByte: lastStart + 11, base: base, size: 12, stride: 16, count: count) == last)
        #expect(ElementAtAddress.owner(ofByte: lastStart + 12, base: base, size: 12, stride: 16, count: count) == nil)
        #expect(ElementAtAddress.owner(ofByte: lastStart + 16, base: base, size: 12, stride: 16, count: count) == nil)
        #expect(ElementAtAddress.owner(ofByte: base + 500_000_000_000 * 16 + 3, base: base, size: 12, stride: 16, count: count) == 500_000_000_000)
    }
}
