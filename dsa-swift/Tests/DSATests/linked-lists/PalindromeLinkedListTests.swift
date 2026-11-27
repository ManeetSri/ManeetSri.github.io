import Testing
import DSAKit
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

/// The identities of every node in a list, front to back.
private func identities(_ head: ListNode?) -> [ObjectIdentifier] {
    var result: [ObjectIdentifier] = []
    var current = head
    while let node = current, result.count <= 200_000 {
        result.append(ObjectIdentifier(node))
        current = node.next
    }
    return result
}

@Suite struct PalindromeLinkedListTests {
    @Test("Palindromes", arguments: [
        [Int](),
        [5],
        [1, 1],
        [1, 2, 1],
        [1, 2, 2, 1],
        [3, 0, 7, 0, 3],
        [-4, 9, 9, -4],
    ])
    func palindromes(values: [Int]) {
        #expect(PalindromeLinkedList.isPalindrome(ListNode.make(values)))
    }

    @Test("Not palindromes", arguments: [
        [1, 2],
        [1, 2, 3],
        [1, 2, 2, 3],
        [1, 2, 1, 1],
        [1, 1, 2, 1],
        [3, 0, 7, 1, 3],
        [10, 1],
    ])
    func notPalindromes(values: [Int]) {
        #expect(!PalindromeLinkedList.isPalindrome(ListNode.make(values)))
    }

    @Test("Leaves the list exactly as it found it", arguments: [
        [1, 2, 3, 2, 1],
        [1, 2, 2, 1],
        [1, 2, 3, 4],
        [1, 2, 3, 4, 5],
        [7, 7],
        [4],
    ])
    func unchanged(values: [Int]) throws {
        let head = try #require(ListNode.make(values))
        let before = identities(head)
        _ = PalindromeLinkedList.isPalindrome(head)
        #expect(identities(head) == before)
        #expect(head.values == values)
    }

    @Test("Matches reversing an array, for every small list of 0s and 1s")
    func matchesArray() {
        for length in 0...10 {
            for bits in 0..<(1 << length) {
                let values = (0..<length).map { (bits >> $0) & 1 }
                if PalindromeLinkedList.isPalindrome(ListNode.make(values)) != (values == values.reversed()) {
                    Issue.record("wrong answer for \(values)")
                    return
                }
            }
        }
    }

    @Test("Stays fast on 100,000 nodes")
    func large() throws {
        let half = Array(0..<50_000)
        #expect(PalindromeLinkedList.isPalindrome(ListNode.make(half + half.reversed())))
        #expect(PalindromeLinkedList.isPalindrome(ListNode.make(half + [7] + half.reversed())))
        let head = try #require(ListNode.make(half + [1] + half))
        #expect(!PalindromeLinkedList.isPalindrome(head))
        #expect(head.count == 100_001, "the list must not be changed")
    }
}
