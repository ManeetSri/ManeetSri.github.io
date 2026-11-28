// Generated from src/dsa/content/lessons/stacks/stack-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionsNeeded(_ text: String) -> Int {
    var open = 0
    var added = 0
    for character in text {
        if character == "(" {
            open += 1
        } else if character == ")" {
            if open == 0 {
                added += 1             // insert a ( to match this )
            } else {
                open -= 1
            }
        }
    }
    return added + open                // plus a ) for each one left open
}

print(insertionsNeeded("())"), insertionsNeeded("((("), insertionsNeeded(")(("), insertionsNeeded("(())"))
