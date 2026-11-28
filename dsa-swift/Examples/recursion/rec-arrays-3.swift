// Generated from src/dsa/content/lessons/recursion/rec-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sumSlice(_ items: ArraySlice<Int>) -> Int {
    guard let first = items.first else {
        return 0
    }
    return first + sumSlice(items.dropFirst())
}

let numbers = [3, 1, 4, 1, 5]
print(sumSlice(numbers[...]))
