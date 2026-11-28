// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let countdown = [1, 2, 3, 4, 5]

for number in countdown.reversed() {
    print(number, terminator: " ")
}
print()

let backwards = Array(countdown.reversed())
print(backwards)
print(countdown)
