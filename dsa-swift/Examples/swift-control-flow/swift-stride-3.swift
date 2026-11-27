// Generated from src/dsa/content/lessons/swift-control-flow/swift-stride.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

for n in stride(from: 10, through: 0, by: -2) {
    print(n, terminator: " ")
}
print()

for n in stride(from: 5, to: 0, by: -1) {
    print(n, terminator: " ")
}
print("Lift off")
