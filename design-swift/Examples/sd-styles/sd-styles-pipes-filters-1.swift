// Generated from src/dsa/design/content/lessons/sd-styles/sd-styles-pipes-filters.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

/// A pipeline is filters joined end to end. Each filter sees only its input and returns its output.
struct Pipeline<Input, Output> {
    let run: (Input) -> Output

    func then<Next>(_ filter: @escaping (Output) -> Next) -> Pipeline<Input, Next> {
        Pipeline<Input, Next> { input in filter(run(input)) }
    }
}

// Filters for turning a recipe title into search terms
let fold: (String) -> String = { $0.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil) }
let tokenise: (String) -> [String] = { $0.split { !$0.isLetter && !$0.isNumber }.map(String.init) }
let stopWords: Set<String> = ["a", "and", "of", "the", "with"]
let dropStopWords: ([String]) -> [String] = { $0.filter { !stopWords.contains($0) } }
let dropRepeats: ([String]) -> [String] = { words in
    var seen = Set<String>()
    return words.filter { seen.insert($0).inserted }
}

let searchTerms = Pipeline<String, String> { $0 }
    .then(fold)
    .then(tokenise)
    .then(dropStopWords)
    .then(dropRepeats)

print(searchTerms.run("The Crème Brûlée of CRÈME brûlée"))

// The same filters in another order: stop words are dropped before folding, so "The" survives
let wrongOrder = Pipeline<String, [String]> { tokenise($0) }
    .then(dropStopWords)
    .then { $0.map(fold) }
    .then(dropRepeats)

print(wrongOrder.run("The Crème Brûlée of CRÈME brûlée"))
