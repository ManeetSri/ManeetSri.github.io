// Generated from src/dsa/content/lessons/orientation/start-problem-solving.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func largest(in numbers: [Int]) -> Int? {
    guard var best = numbers.first else { return nil }
    for number in numbers {
        if number > best {
            best = number
        }
    }
    return best
}

for numbers in [[3, 9, 4], [-5, -2, -8], []] {
    if let answer = largest(in: numbers) {
        print("Largest of \(numbers) is \(answer)")
    } else {
        print("\(numbers) is empty")
    }
}
