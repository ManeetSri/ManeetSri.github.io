// Generated from src/dsa/content/lessons/string-algorithms/sa-z.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func zFunction<T: Equatable>(_ s: [T], trace: Bool = false) -> [Int] {
    let n = s.count
    var z = [Int](repeating: 0, count: n)
    var l = 0, r = 0                            // the Z-box: s[l..<r] equals s[0..<(r - l)]
    for i in s.indices.dropFirst() {
        var known = 0
        if i < r {
            known = min(r - i, z[i - l])        // copied from the matching spot near the start
            z[i] = known
        }
        while i + z[i] < n && s[z[i]] == s[i + z[i]] {
            z[i] += 1                           // compare beyond what the box covers
        }
        if trace {
            print("i = \(i)  box [\(l), \(r))  known \(known)  z = \(z[i])")
        }
        if i + z[i] > r {
            l = i
            r = i + z[i]
        }
    }
    return z
}

print(zFunction(Array("aabxaab".utf8)))
print(zFunction(Array("abacabadabacaba".utf8)))
_ = zFunction(Array("aabaacaabaab".utf8), trace: true)
