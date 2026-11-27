# Writing content for the DSA console

Everything a lesson, quiz or practice problem needs, in one place. Read `lessons/orientation/` for finished examples: they follow every rule below.

## Who it's for

Maneet: learning Swift and DSA **from zero**. Treat every term as new until a lesson has taught it. Explain it plainly the first time it appears, then use it freely.

- **Voice:** warm, direct and concrete. Second person ("you"). Short sentences. One idea per paragraph. No hype, no emojis, no "simply" or "just".
- **Spelling:** British English (organise, colour, behaviour, optimise), as the existing lessons use.
- **Accuracy first:** Swift 6 compiler in Swift 5 language mode. Every claim about Swift must be true today. Don't teach concurrency before Part IX.
- **Length:** match the lesson's minutes in `src/dsa/data/curriculum.js`. Roughly 120–150 words per minute of reading, plus code and quiz time. A 20-minute lesson is about 900–1,400 words of prose.

## Files you create

| What | Where |
| --- | --- |
| Lesson | `src/dsa/content/lessons/<module-id>/<lesson-id>.mdx`. The id and title come from `curriculum.js`; never change them there. |
| Problem metadata | `src/dsa/data/problems/<module-id>.js` (the default export is an array) |
| Problem statement | `src/dsa/content/problems/<problem-id>.mdx` |
| Exercise stub | `dsa-swift/Sources/Exercises/<module-id>/<TypeName>.swift` |
| Reference solution | `dsa-swift/Sources/Solutions/<module-id>/<TypeName>.swift` |
| Tests | `dsa-swift/Tests/DSATests/<module-id>/<TypeName>Tests.swift` |
| Runnable examples | Generated into `dsa-swift/Examples/<module-id>/` by `npm run dsa:examples`. Never edit them by hand. |

Don't edit shared files (`curriculum.js`, `problems.js`, components, scripts) without being asked to. The lesson title is shown by the page, so the file doesn't repeat it.

## Lesson structure

Every lesson follows this shape. Use `##` for sections, which become the "On this page" list, and `###` inside them.

1. `## Why it matters`: two to four sentences. Where this shows up in real code (iOS examples are welcome) and in DSA.
2. **Concept sections** (`## …` with descriptive titles). Build the idea in small steps:
   - plain explanation;
   - a small code example with its output;
   - what to notice.

   Use an analogy callout where it genuinely helps.
3. **Swift gotchas and common mistakes**, as `<Callout kind="gotcha">` or a short section.
4. **Practice** (only if the lesson has problems): a short `## Practice` section saying what to try and why. The page lists the problems themselves straight after the lesson, under "Practice problems".
5. A ` ```cards ` block: 2–4 key takeaways.
6. A ` ```quiz ` block: 3–6 questions, ending the lesson.

## MDX rules (the build fails otherwise)

- In prose, `{`, `}`, `<` and `>` must be inside inline code (`` `a < b` ``) or replaced with words. `≤`, `≥`, `→` and `×` are fine.
- Components need a blank line before and after:

```mdx
<Callout kind="gotcha" title="Swift gotcha: integer division">
Text with **markdown**, `code` and lists.
</Callout>
```

  `kind` is one of `note`, `tip`, `gotcha` (Swift-specific traps), `warning` or `analogy`. `title` is optional.
- Tables are GitHub-style. Keep cells short.
- Link to another lesson with `[its title](/dsa/learn/<lesson-id>)`, using ids from `curriculum.js`. For lessons that come later, say "you'll meet this in M04" rather than linking ahead.

## Code blocks

````mdx
```swift title="Optional title" highlight=2,4-5
let answer = 42
print(answer)
```
````

- **Runnable examples.** Add the bare word `run` to the meta of a Swift block that is a complete program, and follow it **immediately** with an ` ```output ` block holding exactly what it prints:

````mdx
```swift run
let apples = 7
let people = 2
print(apples / people)
print(apples % people)
```

```output
3
1
```
````

  `npm run dsa:examples -- --verify --module <id>` runs every `run` block with `swift <file>` and fails if the output differs, so **always run it**. Rules for `run` blocks:
  - Each block is its own program: declare everything it uses. Top-level code, functions, types, extensions and protocols are all fine.
  - The output must be **deterministic**. Never print a whole `Dictionary` or `Set`, because their order changes between runs: print sorted keys or single lookups. No randomness, dates or timing.
  - It must not crash, read input or take more than a moment to run.
- **Code that crashes** (overflow, force unwrapping `nil`, index out of range) gets no `run`. Show the crash message in a ` ```text title="What you'll see" ` block and say it's what Swift reports.
- Code fragments that aren't whole programs can go in plain ` ```swift ` blocks without `run`. They should still be valid Swift in context.
- Terminal commands use ` ```bash `.
- **Know these print formats exactly:**
  - `print(3.0)` prints `3.0`, and `print(7.0 / 2)` prints `3.5`.
  - `print([1, 2])` prints `[1, 2]`, and `print(["a", "b"])` prints `["a", "b"]`.
  - `print(Optional(5))` prints `Optional(5)`, and `print(nil as Int?)` prints `nil`.
  - `print("a", "b")` prints `a b`.
  - `print(x, terminator: "")` prints no newline.

  When unsure, run it.

## Takeaways (` ```cards `)

```yaml
- id: integer-division      # kebab-case, unique within the lesson, never renamed later
  front: "What does `7 / 2` give for Int values?"
  back: "`3`. Integer division drops the remainder; use `7 % 2` to get it."
```

The front is a question you could answer from memory. The back is one or two sentences. They become spaced-repetition cards.

## Quizzes (` ```quiz `)

YAML list. Every question has `id` (`q1`, `q2`, …, unique in the lesson), `type`, `prompt` and `explain` (except `recall`, which has `model` instead). Mix at least three types per quiz. The explanation teaches *why*, not just which answer.

**YAML quoting:**
- Put prompts, options and explanations in double quotes. Inside double quotes, write `\"` for a quote and `\\` for a backslash. So Swift interpolation `\(x)` becomes `\\(x)`, or use single quotes, `'\(x)'`, where backslashes are literal.
- Put code in a `|` block. Everything is literal there, so `\(x)` stays as is.
- A value can't start with a backtick unless it's quoted.
- Text supports `code`, **bold** and *emphasis*.

| type | extra fields | notes |
| --- | --- | --- |
| `mcq` | `options` (2+), `answer` (index) | optional `code` shown above the options |
| `multi` | `options`, `answer` (list of indexes) | "Choose all that apply" |
| `truefalse` | `answer: true` or `false` | |
| `output` | `code`, `answer` (exact output) | **Verified by running the code.** Add `verify: false` only if it depends on code defined elsewhere. Multi-line answers use `\|`. Optional `accept: [...]` lists alternatives. |
| `trace` | `answer` (string), optional `code` | Whitespace is ignored when checking, e.g. `"4, 11, 11, 15"` |
| `blank` | `code` containing `___` per blank, `answers` (one per blank; each a string or a list of accepted strings) | |
| `order` | `lines` (3+, in the correct order) | shown shuffled |
| `bigo` | `answer` such as `"O(n)"`, optional `options` | default options: O(1), O(log n), O(n), O(n log n), O(n²), O(2ⁿ) |
| `bug` | `code`, `answer` (1-based line number) | the learner clicks the faulty line |
| `match` | `pairs` (2+ of `[left, right]`) | |
| `recall` | `model` (a model answer) | free text, self-graded |

## Practice problems

Part I modules get **3–5 problems each**, mostly `warmup`/`easy` with one `medium`. Each problem should practise its lesson's idea in a small, satisfying way. Write every statement fresh: never copy from LeetCode or other sites.

**Metadata.** In `src/dsa/data/problems/<module-id>.js`:

```js
export default [
    {
        id: 'temperature-converter',          // permanent, unique, kebab-case
        title: 'Temperature converter',
        difficulty: 'easy',                   // warmup | easy | medium | hard | challenge
        patterns: ['basics'],                 // keys of PATTERNS in src/dsa/data/problems.js
        lessons: ['swift-floating-point'],    // lessons of THIS module that it practises
        swiftTest: 'TemperatureConverterTests',
        lists: [],                            // optional: 'core75', 'patterns150', 'swift'
        minutes: 15,
    },
];
```

**Statement.** In `src/dsa/content/problems/<id>.mdx`, in this order:
1. One or two sentences of task.
2. The exact Swift signature in inline code, e.g. `TemperatureConverter.fahrenheit(fromCelsius:)`.
3. `## Examples` as a table.
4. `## Constraints`.
5. `<Hints>` with two or three `<Hint>` elements, each giving away a little more.
6. `## Solutions` with one or more `<Approach title="…" time="O(n)" space="O(1)">` blocks, each explaining the idea and then giving code.

See `problems/largest-element.mdx`. Code inside `<Approach>` needs a blank line after the opening tag.

**Swift.** The type name is `swiftTest` without `Tests`. It's a caseless `public enum` with `public static` functions, so names never clash.
- **Exercise stub:** a doc comment, a "Write your solution here, then run: swift test --filter XTests" comment, and a **placeholder return value that compiles** (`return 0`, `return ""`, `return []`, `return nil`). Never use `fatalError`.
- **Solution:** the same API, clean and idiomatic, with a short comment on the approach and complexity.
- **Tests:** Swift Testing. Cover normal cases, edge cases (empty, single, negative, large) and anything the statement promises. Prefer `@Test(arguments:)` for tables of cases.

```swift
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct TemperatureConverterTests {
    @Test("Freezing point", arguments: [(0.0, 32.0), (100.0, 212.0), (-40.0, -40.0)])
    func converts(celsius: Double, expected: Double) {
        #expect(TemperatureConverter.fahrenheit(fromCelsius: celsius) == expected)
    }
}
```

## Checking your work

Run all of these for your module before you finish, and fix everything they report:

```bash
npm run dsa:compile -- --module <module-id>                 # MDX, quizzes and cards parse; shows file:line
npm run dsa:examples -- --verify --module <module-id>       # writes the example files; outputs match Swift
npm run dsa:check -- --module <module-id>                   # files, registry and Swift names all connect
cd dsa-swift && swift build --scratch-path /tmp/<you>-build && swift test --scratch-path /tmp/<you>-build -Xswiftc -DSOLUTIONS --filter <Suite>
```

`--scratch-path` keeps your Swift build separate from anyone else's. If the package fails to compile because of a file outside your module that someone else is writing, check yours on its own instead:

```bash
swiftc -typecheck -swift-version 5 dsa-swift/Sources/Solutions/<module-id>/*.swift
```
