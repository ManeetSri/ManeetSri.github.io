// Generated from src/dsa/content/lessons/elementary-sorts/sort-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension MutableCollection where Self: RandomAccessCollection {
    mutating func insertionSort(by areInIncreasingOrder: (Element, Element) -> Bool) {
        guard !isEmpty else { return }
        var next = index(after: startIndex)
        while next != endIndex {
            let key = self[next]
            var gap = next
            while gap != startIndex {
                let before = index(before: gap)
                guard areInIncreasingOrder(key, self[before]) else { break }
                self[gap] = self[before]
                gap = before
            }
            self[gap] = key
            formIndex(after: &next)
        }
    }
}

extension MutableCollection where Self: RandomAccessCollection, Element: Comparable {
    mutating func insertionSort() {
        insertionSort(by: <)
    }
}

var numbers = [9, 8, 7, 6, 5, 4, 3]
numbers[2..<5].insertionSort()                   // sorts indexes 2, 3 and 4 in place
print(numbers)

var tail = numbers[4...]                         // a separate slice: indexes 4, 5 and 6
tail.insertionSort()
print(tail, tail.startIndex, tail[4])
print(numbers)

var letters: ContiguousArray = ["c", "a", "b"]
letters.insertionSort(by: >)
print(letters)
