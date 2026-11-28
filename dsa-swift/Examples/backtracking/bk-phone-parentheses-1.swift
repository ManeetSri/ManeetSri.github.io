// Generated from src/dsa/content/lessons/backtracking/bk-phone-parentheses.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let keypad: [Character: String] = [
    "2": "abc", "3": "def", "4": "ghi", "5": "jkl",
    "6": "mno", "7": "pqrs", "8": "tuv", "9": "wxyz",
]

func letterCombinations(_ digits: String) -> [String] {
    let digits = Array(digits)
    guard !digits.isEmpty else { return [] }
    var word: [Character] = []
    var result: [String] = []

    func explore(_ index: Int) {
        if index == digits.count {               // a letter for every digit
            result.append(String(word))
            return
        }
        for letter in keypad[digits[index]]! {
            word.append(letter)                  // choose
            explore(index + 1)                   // explore
            word.removeLast()                    // unchoose
        }
    }

    explore(0)
    return result
}

print(letterCombinations("28"))
print(letterCombinations("79").count, letterCombinations("").count)
