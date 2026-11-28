// Generated from src/dsa/design/content/lessons/sd-functional/sd-functional-composition.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct SignUpForm {
    var email: String
    var password: String
    var age: Int
}

struct NewAccount {
    let email: String
    let password: String
}

enum FieldProblem: Equatable {
    case emailMissingAt
    case passwordTooShort(needs: Int)
    case tooYoung
}

/// Every problem with the form, not only the first: each check is independent of the others
func validate(_ form: SignUpForm) -> Result<NewAccount, ValidationFailure> {
    var problems: [FieldProblem] = []
    if !form.email.contains("@") { problems.append(.emailMissingAt) }
    if form.password.count < 10 { problems.append(.passwordTooShort(needs: 10 - form.password.count)) }
    if form.age < 13 { problems.append(.tooYoung) }
    guard problems.isEmpty else { return .failure(ValidationFailure(problems: problems)) }
    return .success(NewAccount(email: form.email, password: form.password))
}

/// Result's failure must be an Error, and an array isn't one, so wrap it
struct ValidationFailure: Error {
    let problems: [FieldProblem]
}

let forms = [
    SignUpForm(email: "sam@example.com", password: "correct-horse", age: 30),
    SignUpForm(email: "sam.example.com", password: "hunter2", age: 12),
]
for form in forms {
    switch validate(form) {
    case .success(let account):
        print("OK: \(account.email)")
    case .failure(let failure):
        print("\(failure.problems.count) problems:", failure.problems.map { "\($0)" }.joined(separator: ", "))
    }
}
