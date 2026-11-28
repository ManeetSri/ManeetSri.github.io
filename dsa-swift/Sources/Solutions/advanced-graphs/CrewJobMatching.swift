// Reference solution: Match crew to jobs. Kuhn's algorithm: for each worker in turn, search for an
// augmenting path with DFS. A worker takes a job that's free, or a job whose current worker can move
// to another job (found by the same search, recursively). `seen` marks the jobs tried in this round,
// stamped with the round number so it never needs clearing. A matching with no augmenting path is
// maximum (Berge's theorem). O(V · E) time, O(V + E) space; the recursion is at most `workers` deep.

public enum CrewJobMatching {
    public static func assign(workers: Int, jobs: Int, canDo: [[Int]]) -> [Int] {
        var workerOfJob = [Int](repeating: -1, count: jobs)
        var seen = [Int](repeating: -1, count: jobs)

        func findJob(for worker: Int, round: Int) -> Bool {
            for job in canDo[worker] where seen[job] != round {
                seen[job] = round
                if workerOfJob[job] == -1 || findJob(for: workerOfJob[job], round: round) {
                    workerOfJob[job] = worker              // flip this edge of the augmenting path
                    return true
                }
            }
            return false
        }

        for worker in 0..<workers {
            _ = findJob(for: worker, round: worker)
        }

        var jobOfWorker = [Int](repeating: -1, count: workers)
        for job in 0..<jobs where workerOfJob[job] != -1 {
            jobOfWorker[workerOfJob[job]] = job
        }
        return jobOfWorker
    }
}
