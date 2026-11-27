// Reference solution: Reading a timing experiment. Duration is Comparable, so min() and sorted() work
// directly, and dividing one Duration by another gives a plain Double. best and ratios are O(n);
// median sorts, O(n log n).

public enum TimingExperimentReport {
    public static func best(of runs: [Duration]) -> Duration? {
        runs.min()
    }

    // For an even count, (count - 1) / 2 is the lower of the two middle positions: the faster run
    public static func median(of runs: [Duration]) -> Duration? {
        guard !runs.isEmpty else {
            return nil
        }
        return runs.sorted()[(runs.count - 1) / 2]
    }

    public static func milliseconds(_ duration: Duration) -> Double {
        duration / .milliseconds(1)
    }

    public static func ratios(_ times: [Duration]) -> [Double] {
        guard times.count > 1 else {
            return []
        }
        var result: [Double] = []
        for index in 1..<times.count {
            result.append(times[index] / times[index - 1])
        }
        return result
    }

    public static func growth(of times: [Duration]) -> String? {
        let steps = ratios(times)
        guard !steps.isEmpty else {
            return nil
        }
        let average = steps.reduce(0, +) / Double(steps.count)
        if average < 1.5 {
            return "constant"
        } else if average < 3 {
            return "linear"
        } else if average < 6 {
            return "quadratic"
        }
        return "cubic"
    }
}
