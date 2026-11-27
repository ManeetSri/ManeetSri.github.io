// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["sun", "cloud", "rain", "storm"]

let loud = words.lazy
    .filter { word -> Bool in
        print("filter \(word)")
        return word.count > 3
    }
    .map { word -> String in
        print("map \(word)")
        return word.uppercased()
    }

print("nothing has run yet")
for word in loud {
    print("got \(word)")
    if word == "RAIN" {
        break
    }
}
