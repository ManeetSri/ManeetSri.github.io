// Generated from src/dsa/content/lessons/swift-control-flow/swift-switch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let letter: Character = "e"

switch letter {
case "a", "e", "i", "o", "u":
    print("\(letter) is a vowel")
case "y":
    print("\(letter) is sometimes a vowel")
default:
    print("\(letter) is a consonant")
}
