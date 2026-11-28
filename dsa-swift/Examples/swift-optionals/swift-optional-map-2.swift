// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let pence: Int? = 1250
let noPence: Int? = nil

let pounds = pence.map { Double($0) / 100 }
let noPounds = noPence.map { Double($0) / 100 }

print(pounds)
print(noPounds)
