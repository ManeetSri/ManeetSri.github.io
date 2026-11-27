import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct DependencyCycleFinderTests {
    /// Checks that cycle lists distinct modules, each depending on the next, the last on the first
    private func expectCycle(_ cycle: [Int], modules: Int, dependencies: [[Int]]) {
        #expect(!cycle.isEmpty, "there is a circular dependency, but none was returned")
        guard !cycle.isEmpty else { return }
        #expect(Set(cycle).count == cycle.count, "a module appears twice in the cycle")
        var edges = Set<Int>()
        for pair in dependencies {
            edges.insert(pair[0] * modules + pair[1])
        }
        let closed = cycle.indices.allSatisfy { index in
            let from = cycle[index]
            let to = cycle[(index + 1) % cycle.count]
            return from >= 0 && from < modules && edges.contains(from * modules + to)
        }
        #expect(closed, "each module in the cycle must depend on the next, and the last on the first")
    }

    @Test("Finds a circular dependency", arguments: [
        (3, [[0, 1], [1, 2], [2, 0]]),
        (2, [[0, 1], [1, 0]]),
        (5, [[0, 1], [1, 2], [2, 3], [3, 1], [3, 4]]),
        (6, [[0, 1], [2, 3], [3, 4], [4, 5], [5, 3]]),
        (4, [[0, 1], [0, 2], [1, 3], [2, 3], [3, 0]]),
        (4, [[3, 2], [2, 1], [1, 0], [0, 3]]),
    ])
    func findsCycle(modules: Int, dependencies: [[Int]]) {
        expectCycle(DependencyCycleFinder.cycle(modules, dependencies: dependencies), modules: modules, dependencies: dependencies)
    }

    @Test("A module that depends on itself")
    func selfDependency() {
        #expect(DependencyCycleFinder.cycle(2, dependencies: [[0, 1], [1, 1]]) == [1])
    }

    @Test("No circular dependency", arguments: [
        (4, [[0, 1], [0, 2], [1, 3], [2, 3]]),
        (3, [[Int]]()),
        (1, [[Int]]()),
        (5, [[0, 1], [1, 2], [0, 2], [3, 4], [2, 4], [0, 4]]),
        (3, [[0, 1], [0, 1], [1, 2]]),
        (4, [[1, 0], [2, 0], [3, 0], [2, 1], [3, 2]]),
    ])
    func noCycle(modules: Int, dependencies: [[Int]]) {
        #expect(DependencyCycleFinder.cycle(modules, dependencies: dependencies) == [])
    }

    @Test("A chain of 100,000 modules, closed into a loop or not")
    func longChain() {
        // A recursive DFS would go 100,000 calls deep, far past a test thread's stack
        let count = 100_000
        let chain = (0..<(count - 1)).map { [$0, $0 + 1] }
        #expect(DependencyCycleFinder.cycle(count, dependencies: chain).isEmpty, "a plain chain has no cycle")
        let loop = chain + [[count - 1, 0]]
        expectCycle(DependencyCycleFinder.cycle(count, dependencies: loop), modules: count, dependencies: loop)
    }

    @Test("A big acyclic graph, then one dependency that closes a loop")
    func bigGraph() {
        let count = 100_000
        var dependencies: [[Int]] = []
        for module in 0..<count {
            for step in [1, 2, 7] where module + step < count {
                dependencies.append([module, module + step])
            }
        }
        #expect(DependencyCycleFinder.cycle(count, dependencies: dependencies).isEmpty, "this graph has no cycle")
        let looped = dependencies + [[99_990, 50_000]]
        expectCycle(DependencyCycleFinder.cycle(count, dependencies: looped), modules: count, dependencies: looped)
    }
}
