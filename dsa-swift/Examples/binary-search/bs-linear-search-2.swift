// Generated from src/dsa/content/lessons/binary-search/bs-linear-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let ages = [34, 7, 19, 52, 7, 41]
print(ages.firstIndex(of: 7) as Any)
print(ages.lastIndex(of: 7) as Any)
print(ages.contains(52))
print(ages.firstIndex { $0 > 40 } as Any)
print(ages.first { $0 > 40 } as Any)
print(ages.firstIndex(of: 99) as Any)
