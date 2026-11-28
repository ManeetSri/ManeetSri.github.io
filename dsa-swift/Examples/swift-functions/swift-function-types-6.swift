// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func addOne(_ n: Int) -> Int { n + 1 }
func double(_ n: Int) -> Int { n * 2 }
func square(_ n: Int) -> Int { n * n }

let steps: [(Int) -> Int] = [addOne, double, square]

var value = 3
for step in steps {
    value = step(value)
    print(value)
}
