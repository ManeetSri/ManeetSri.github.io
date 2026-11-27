// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let scores = [72, 38, 91, 50, 38]

print(scores.contains(91))
print(scores.contains(where: { $0 < 40 }))
print(scores.first(where: { $0 > 80 }) ?? -1)
print(scores.firstIndex(of: 38) ?? -1)
print(scores.firstIndex(where: { $0 >= 50 && $0 < 60 }) ?? -1)
print(scores.allSatisfy { $0 >= 30 })
print(scores.lastIndex(of: 38) ?? -1)
