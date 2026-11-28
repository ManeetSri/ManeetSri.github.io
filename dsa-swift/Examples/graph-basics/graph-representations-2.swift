// Generated from src/dsa/content/lessons/graph-basics/graph-representations.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Weighted and directed: flight prices, out of each airport
var flights = Array(repeating: [(to: Int, price: Int)](), count: 4)
flights[0].append((to: 1, price: 120))
flights[0].append((to: 2, price: 80))
flights[2].append((to: 1, price: 30))
flights[1].append((to: 3, price: 200))
for (to, price) in flights[0] {
    print("0 → \(to) costs \(price)")
}

// Named vertices: which Swift package targets each target depends on
var dependsOn: [String: [String]] = [:]
dependsOn["App", default: []].append("Networking")
dependsOn["App", default: []].append("Models")
dependsOn["Networking", default: []].append("Models")
for target in dependsOn.keys.sorted() {
    print(target, "depends on", dependsOn[target]!)
}
print("Models depends on", dependsOn["Models", default: []])
