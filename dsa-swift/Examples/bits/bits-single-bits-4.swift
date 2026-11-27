// Generated from src/dsa/content/lessons/bits/bits-single-bits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Permissions: OptionSet {
    let rawValue: Int
    static let read = Permissions(rawValue: 1 << 2)
    static let write = Permissions(rawValue: 1 << 1)
    static let execute = Permissions(rawValue: 1 << 0)
}

var file: Permissions = [.read, .write]
print(file.rawValue)
print(file.contains(.write), file.contains(.execute))

file.insert(.execute)
file.remove(.write)
print(file.rawValue)
