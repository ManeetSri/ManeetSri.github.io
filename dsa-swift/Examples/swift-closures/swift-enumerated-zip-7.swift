// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [1, 2, 3, 4, 5, 6]

let firstBigSquare = numbers
    .map { number -> Int in
        print("squaring \(number)")
        return number * number
    }
    .first { $0 > 10 }
print(firstBigSquare ?? 0)
