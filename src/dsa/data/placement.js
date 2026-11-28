// The optional placement check in onboarding: two questions per group of Part I modules. Answering
// both in a group right on the first try offers to test out of those modules. Questions use the
// same shape as lesson quizzes (see src/dsa/content/AUTHORING.md). Every output was checked by running it.

export const PLACEMENT_GROUPS = [
    {
        id: 'basics',
        title: 'Swift basics: values, types and operators',
        modules: ['swift-first-steps', 'swift-types-operators'],
        questions: [
            {
                id: 'basics-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'let a = 7\nlet b = 2\nprint(a / b, a % b)',
                answer: '3 1',
                explain: 'Dividing two `Int` values drops the remainder, so `7 / 2` is `3`, and `%` gives the remainder, `1`.',
            },
            {
                id: 'basics-2',
                type: 'mcq',
                prompt: 'Which keyword declares a value that can never change after it is set?',
                options: ['`var`', '`let`', '`const`', '`static`'],
                answer: 1,
                explain: '`let` declares a constant. `var` declares a variable, and Swift has no `const` keyword.',
            },
        ],
    },
    {
        id: 'control',
        title: 'Control flow',
        modules: ['swift-control-flow'],
        questions: [
            {
                id: 'control-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'for i in stride(from: 10, to: 0, by: -3) {\n    print(i, terminator: " ")\n}',
                answer: '10 7 4 1',
                explain: '`stride(from:to:by:)` stops *before* reaching `0`, counting down by 3: 10, 7, 4, 1.',
            },
            {
                id: 'control-2',
                type: 'mcq',
                prompt: 'What must the `else` branch of a `guard` statement do?',
                options: [
                    'Print an error message',
                    'Leave the current scope, for example with `return`, `break`, `continue` or `throw`',
                    'Assign a default value',
                    'Nothing: it can be empty',
                ],
                answer: 1,
                explain: '`guard` is for early exit, so the compiler insists its `else` branch leaves the scope.',
            },
        ],
    },
    {
        id: 'optionals',
        title: 'Optionals',
        modules: ['swift-optionals'],
        questions: [
            {
                id: 'optionals-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'let n = Int("12a") ?? -1\nprint(n)',
                answer: '-1',
                explain: '`Int("12a")` is `nil` because the text isn’t a whole number, so `??` supplies the fallback, `-1`.',
            },
            {
                id: 'optionals-2',
                type: 'truefalse',
                prompt: 'The body of `if let x = value { … }` runs when `value` is `nil`.',
                answer: false,
                explain: '`if let` unwraps the optional and runs its body only when there *is* a value.',
            },
        ],
    },
    {
        id: 'functions',
        title: 'Functions and closures',
        modules: ['swift-functions', 'swift-closures'],
        questions: [
            {
                id: 'functions-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'let numbers = [1, 2, 3, 4, 5]\nlet result = numbers.filter { $0 % 2 == 1 }.map { $0 * $0 }.reduce(0, +)\nprint(result)',
                answer: '35',
                explain: 'Keep the odd numbers (1, 3, 5), square them (1, 9, 25) and add them up: 35.',
            },
            {
                id: 'functions-2',
                type: 'mcq',
                prompt: 'Why would `func swapFirstTwo(_ items: inout [Int])` need `inout`?',
                options: [
                    'So it can return two values',
                    'So it can change the caller’s array in place',
                    'So it runs faster',
                    'Because arrays are always passed by reference',
                ],
                answer: 1,
                explain: 'Parameters are constants. `inout` lets the function modify the caller’s variable, which you pass with `&`.',
            },
        ],
    },
    {
        id: 'collections',
        title: 'Collections and strings',
        modules: ['swift-collections', 'swift-strings'],
        questions: [
            {
                id: 'collections-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'var counts: [Character: Int] = [:]\nfor letter in "banana" {\n    counts[letter, default: 0] += 1\n}\nprint(counts["a"]!, counts["n"]!)',
                answer: '3 2',
                explain: '`counts[letter, default: 0] += 1` counts each character: “banana” has three a’s and two n’s.',
            },
            {
                id: 'collections-2',
                type: 'mcq',
                prompt: 'Why can’t you write `word[2]` to get the third character of a Swift `String`?',
                options: [
                    'Strings are immutable',
                    'Characters can take different amounts of memory, so a String is indexed with `String.Index` rather than integers',
                    'Strings start counting at 1',
                    'You can: it works like an array',
                ],
                answer: 1,
                explain: 'A Character can be several Unicode scalars, so jumping to the nth one means walking the string. Swift makes that cost visible with `String.Index`.',
            },
        ],
    },
    {
        id: 'types',
        title: 'Structs, classes, protocols and generics',
        modules: ['swift-types', 'swift-generics'],
        questions: [
            {
                id: 'types-1',
                type: 'output',
                prompt: 'What does this print?',
                code: 'struct Box {\n    var value: Int\n}\nvar a = Box(value: 1)\nvar b = a\nb.value = 2\nprint(a.value, b.value)',
                answer: '1 2',
                explain: 'Structs are value types: `var b = a` makes an independent copy, so changing `b` leaves `a` alone.',
            },
            {
                id: 'types-2',
                type: 'mcq',
                prompt: 'In `func largest<T: Comparable>(_ items: [T]) -> T?`, what does `T: Comparable` let the function do?',
                options: [
                    'Accept only integers',
                    'Compare values of type `T` with `<` and `>`',
                    'Sort the array in place',
                    'Return a non-optional value',
                ],
                answer: 1,
                explain: 'The constraint promises every `T` supports comparison, so the generic function can use `<` and `>` on it.',
            },
        ],
    },
    {
        id: 'memory',
        title: 'Memory and tooling',
        modules: ['swift-memory', 'swift-tooling'],
        questions: [
            {
                id: 'memory-1',
                type: 'mcq',
                prompt: 'Which kind of reference doesn’t keep an object alive, and becomes `nil` once the object is freed?',
                options: ['`strong`', '`weak`', '`unowned`', '`inout`'],
                answer: 1,
                explain: '`weak` references don’t add to the reference count and become `nil` automatically, which is how you break retain cycles.',
            },
            {
                id: 'memory-2',
                type: 'output',
                prompt: 'What does this print?',
                code: 'func demo() {\n    defer { print("one") }\n    defer { print("two") }\n    print("three")\n}\ndemo()',
                answer: 'three\ntwo\none',
                explain: '`defer` blocks run when the function exits, in reverse order of how they were written.',
            },
        ],
    },
];
