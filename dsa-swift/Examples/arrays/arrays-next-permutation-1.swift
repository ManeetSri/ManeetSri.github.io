// Generated from src/dsa/content/lessons/arrays/arrays-next-permutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Rearranges numbers into the next permutation and returns true, or returns false (and leaves
// numbers alone) if it's already the last one
func nextPermutation(_ numbers: inout [Int]) -> Bool {
    // 1. The pivot: the rightmost element smaller than the one after it
    var pivot = numbers.count - 2
    while pivot >= 0 && numbers[pivot] >= numbers[pivot + 1] {
        pivot -= 1
    }
    guard pivot >= 0 else { return false }

    // 2. The rightmost element bigger than the pivot, which is the smallest such element
    var successor = numbers.count - 1
    while numbers[successor] <= numbers[pivot] {
        successor -= 1
    }
    numbers.swapAt(pivot, successor)

    // 3. The ending is still non-increasing: reverse it to make it as small as possible
    numbers[(pivot + 1)...].reverse()
    return true
}

var order = [1, 2, 3]
print(order)
while nextPermutation(&order) {
    print(order)
}

var repeats = [1, 1, 2]
var arrangements = 1
while nextPermutation(&repeats) {
    arrangements += 1
}
print("arrangements of [1, 1, 2]:", arrangements)

var example = [1, 5, 8, 4, 7, 6, 5, 3, 1]
_ = nextPermutation(&example)
print(example)
