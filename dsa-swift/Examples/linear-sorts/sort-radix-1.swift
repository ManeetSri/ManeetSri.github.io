// Generated from src/dsa/content/lessons/linear-sorts/sort-radix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countingPass(_ numbers: [Int], place: Int) -> [Int] {
    var next = [Int](repeating: 0, count: 10)
    for number in numbers {
        next[(number / place) % 10] += 1
    }
    var total = 0                                // counts become starting positions
    for digit in 0..<10 {
        let count = next[digit]
        next[digit] = total
        total += count
    }
    var result = numbers
    for number in numbers {                      // place in input order: stable
        let digit = (number / place) % 10
        result[next[digit]] = number
        next[digit] += 1
    }
    return result
}

func radixSort(_ numbers: [Int]) -> [Int] {
    guard let largest = numbers.max() else { return [] }
    var result = numbers
    var place = 1
    while true {
        result = countingPass(result, place: place)
        print("by the \(place)s digit:", result)
        if place > largest / 10 { break }        // no higher digits left
        place *= 10
    }
    return result
}

let sorted = radixSort([512, 38, 204, 97, 731, 45, 260, 8])
