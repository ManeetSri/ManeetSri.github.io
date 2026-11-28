// Reference solution: Counting copy-on-write copies. Each storage block records how many elements it holds
// and how many variables share it. A write to a shared block first moves the variable to a fresh copy,
// which costs the block's element count. O(1) per command, O(n) overall.

public enum CowCopyCounter {
    public static func elementsCopied(by commands: [String]) -> Int {
        var storageOf: [String: Int] = [:]      // which storage block each variable uses
        var elementCount: [Int: Int] = [:]      // elements in each block
        var sharers: [Int: Int] = [:]           // how many variables use each block
        var nextBlock = 0
        var copied = 0

        func makeBlock(holding count: Int) -> Int {
            nextBlock += 1
            elementCount[nextBlock] = count
            sharers[nextBlock] = 1
            return nextBlock
        }

        func release(_ name: String) {
            guard let block = storageOf[name] else {
                return
            }
            sharers[block]! -= 1
            if sharers[block]! == 0 {
                sharers[block] = nil
                elementCount[block] = nil
            }
        }

        for command in commands {
            let words = command.split(separator: " ").map(String.init)
            let name = words[1]
            switch words[0] {
            case "new":
                release(name)
                storageOf[name] = makeBlock(holding: Int(words[2])!)
            case "copy":
                let block = storageOf[words[2]]!
                if storageOf[name] != block {
                    release(name)
                    storageOf[name] = block
                    sharers[block]! += 1
                }
            case "append", "write", "remove":
                var block = storageOf[name]!
                if sharers[block]! > 1 {            // shared: copy before writing
                    let count = elementCount[block]!
                    copied += count
                    release(name)
                    block = makeBlock(holding: count)
                    storageOf[name] = block
                }
                if words[0] == "append" {
                    elementCount[block]! += 1
                } else if words[0] == "remove" {
                    elementCount[block]! -= 1
                }
            default:                                // "read" never copies
                break
            }
        }
        return copied
    }
}
