// Generated from src/dsa/content/lessons/sliding-window/sw-min-window.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let t = Array("BANANABREAD".utf8)
let p = Array("ABD".utf8)
var need = [Int](repeating: 0, count: 128)
for byte in p {
    need[Int(byte)] += 1
}
let required = need.filter { $0 > 0 }.count
var have = [Int](repeating: 0, count: 128)
var satisfied = 0
var left = 0
var bestLength = Int.max
for right in 0..<t.count {
    let entering = Int(t[right])
    have[entering] += 1
    if need[entering] > 0 && have[entering] == need[entering] {
        satisfied += 1
    }
    while satisfied == required {
        bestLength = min(bestLength, right - left + 1)
        print(String(decoding: t[left...right], as: UTF8.self), "best", bestLength)
        let leaving = Int(t[left])
        if need[leaving] > 0 && have[leaving] == need[leaving] {
            satisfied -= 1
        }
        have[leaving] -= 1
        left += 1
    }
}
