// Reference solution: shared superview. Each view knows only its superview, so walk up from both views.
// Measure both depths first, lift the deeper view until they're level, then lift both together: they
// meet at the nearest common superview, or both run out (different windows). O(depth) time and O(1)
// extra space. The path is the walk up from a to that view, then the walk up from b reversed.

public enum SharedSuperview {
    private static func depth(of view: String, _ superviewOf: [String: String]) -> Int {
        var depth = 0
        var current = view
        while let parent = superviewOf[current] {
            depth += 1
            current = parent
        }
        return depth
    }

    /// Walks up `steps` levels.
    private static func lift(_ view: String, by steps: Int, _ superviewOf: [String: String]) -> String {
        var current = view
        for _ in 0..<steps {
            current = superviewOf[current]!          // safe: steps never exceed the depth
        }
        return current
    }

    public static func nearestCommonSuperview(_ a: String, _ b: String, superviewOf: [String: String]) -> String? {
        let depthA = depth(of: a, superviewOf), depthB = depth(of: b, superviewOf)
        var x = lift(a, by: max(0, depthA - depthB), superviewOf)
        var y = lift(b, by: max(0, depthB - depthA), superviewOf)
        while x != y {
            guard let upX = superviewOf[x], let upY = superviewOf[y] else { return nil }
            x = upX
            y = upY
        }
        return x
    }

    public static func path(from a: String, to b: String, superviewOf: [String: String]) -> [String]? {
        guard let shared = nearestCommonSuperview(a, b, superviewOf: superviewOf) else { return nil }
        var up: [String] = [a]
        while up.last! != shared {
            up.append(superviewOf[up.last!]!)
        }
        var down: [String] = [b]
        while down.last! != shared {
            down.append(superviewOf[down.last!]!)
        }
        down.removeLast()                            // `shared` is already the end of `up`
        return up + down.reversed()
    }
}
