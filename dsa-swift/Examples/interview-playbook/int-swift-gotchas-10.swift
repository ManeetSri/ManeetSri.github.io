// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let empty: [Int] = []
for i in stride(from: 0, to: empty.count - 1, by: 1) {   // stride is just empty
    print(i)
}
for i in empty.indices.dropLast() {                      // every index but the last
    print(i)
}
let n = 0
if n >= 1 {
    for i in 1...n { print(i) }                          // only built when it's valid
}
print(Array(stride(from: 1, through: n, by: 1)), (0..<0).isEmpty)
