// Generated from src/dsa/content/lessons/swift-collections/swift-dictionaries.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var routes: [String: [String]] = [:]
routes["home", default: []].append("park")
routes["home", default: []].append("shop")
routes["park", default: []].append("home")

for place in routes.keys.sorted() {
    print(place, routes[place] ?? [])
}
