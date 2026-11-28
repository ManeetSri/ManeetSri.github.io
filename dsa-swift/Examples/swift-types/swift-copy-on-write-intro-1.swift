// Generated from src/dsa/content/lessons/swift-types/swift-copy-on-write-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sharesStorage(_ first: [Int], _ second: [Int]) -> Bool {
    first.withUnsafeBufferPointer { one in
        second.withUnsafeBufferPointer { two in
            one.baseAddress == two.baseAddress
        }
    }
}

let original = [1, 2, 3]
var copy = original
print("After copying:", sharesStorage(original, copy))

copy.append(4)
print("After a write:", sharesStorage(original, copy))
print(original)
print(copy)
