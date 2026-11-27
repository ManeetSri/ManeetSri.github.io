// Reference solution: Counting references by hand. Every strong reference, from a variable or a next
// property, is one count on its object. Replacing a reference retains the new object before releasing
// the old one. A release that reaches zero frees the object and then releases its next, which may free
// more objects in a chain: a loop, so long chains can't overflow the stack. O(1) amortised per command.

public enum RefCountSimulator {
    public struct Outcome: Equatable {
        public let freed: [Int]
        public let alive: [Int]

        public init(freed: [Int], alive: [Int]) {
            self.freed = freed
            self.alive = alive
        }
    }

    public static func simulate(_ commands: [String]) -> Outcome {
        var count: [Int: Int] = [:]        // strong references to each live object
        var next: [Int: Int] = [:]         // the object each object's next points at
        var holds: [String: Int] = [:]     // the object each variable holds
        var freed: [Int] = []

        func retain(_ object: Int?) {
            if let object {
                count[object]! += 1
            }
        }

        func release(_ object: Int?) {
            var current = object
            while let object = current {
                count[object]! -= 1
                guard count[object]! == 0 else {
                    return
                }
                count[object] = nil
                freed.append(object)
                current = next.removeValue(forKey: object)   // its next goes when it does
            }
        }

        for command in commands {
            let words = command.split(separator: " ").map(String.init)
            let name = words[1]
            switch words[0] {
            case "new":
                let object = Int(words[2])!
                count[object] = 1
                release(holds[name])
                holds[name] = object
            case "set":
                let object = holds[words[2]]
                retain(object)
                release(holds[name])
                holds[name] = object
            case "clear":
                release(holds[name])
                holds[name] = nil
            case "link":
                let owner = holds[name]!
                let object = holds[words[2]]
                retain(object)
                release(next[owner])
                next[owner] = object
            case "unlink":
                let owner = holds[name]!
                release(next[owner])
                next[owner] = nil
            default:                        // "follow": the variable moves on to its object's next
                let object = next[holds[name]!]
                retain(object)
                release(holds[name])
                holds[name] = object
            }
        }
        return Outcome(freed: freed, alive: count.keys.sorted())
    }
}
