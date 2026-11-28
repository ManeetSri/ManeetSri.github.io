/// What an exercise stub throws until you write it. Tests fail with it instead of crashing or hanging.
public struct Unimplemented: Error, CustomStringConvertible, Sendable {
    public let what: String

    public init(_ what: String = #function) {
        self.what = what
    }

    public var description: String { "\(what) isn't written yet" }
}
