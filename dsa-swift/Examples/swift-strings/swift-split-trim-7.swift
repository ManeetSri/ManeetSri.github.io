// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

let row = "ada,,grace,linus,"
print(row.components(separatedBy: ","))

let date = "2024--06--15"
print(date.components(separatedBy: "--"))
