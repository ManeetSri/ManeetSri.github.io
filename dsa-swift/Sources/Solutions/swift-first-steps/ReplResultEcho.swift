// Reference solution: What the REPL shows. The REPL counts its temporary names from 0, so the
// position-th result is $R(position - 1). O(1) time and space.

public enum ReplResultEcho {
    public static func line(position: Int, value: Int) -> String {
        let resultNumber = position - 1
        return "$R\(resultNumber): Int = \(value)"
    }
}
