// Reference solution: Grade bands. A switch on ranges picks the band, then the last digit decides
// the "+". O(1) time and space.

public enum GradeBands {
    public static func grade(for score: Int) -> String {
        let letter: String
        switch score {
        case 90...100:
            return "A"
        case 80...89:
            letter = "B"
        case 70...79:
            letter = "C"
        case 60...69:
            letter = "D"
        case 0...59:
            return "F"
        default:
            return "Invalid"
        }
        return score % 10 >= 7 ? letter + "+" : letter
    }
}
