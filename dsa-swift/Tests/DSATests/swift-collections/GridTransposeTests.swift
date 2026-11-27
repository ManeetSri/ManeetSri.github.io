import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GridTransposeTests {
    @Test("Transposes a square grid")
    func square() {
        #expect(GridTranspose.transpose([[1, 2], [3, 4]]) == [[1, 3], [2, 4]])
        #expect(GridTranspose.transpose([[1, 2, 3], [4, 5, 6], [7, 8, 9]]) == [[1, 4, 7], [2, 5, 8], [3, 6, 9]])
    }

    @Test("Swaps the shape of a rectangular grid")
    func rectangle() {
        #expect(GridTranspose.transpose([[1, 2, 3], [4, 5, 6]]) == [[1, 4], [2, 5], [3, 6]])
        #expect(GridTranspose.transpose([[1, 4], [2, 5], [3, 6]]) == [[1, 2, 3], [4, 5, 6]])
    }

    @Test("Turns a single row into a single column and back")
    func singleRowOrColumn() {
        #expect(GridTranspose.transpose([[7, 8, 9]]) == [[7], [8], [9]])
        #expect(GridTranspose.transpose([[7], [8], [9]]) == [[7, 8, 9]])
        #expect(GridTranspose.transpose([[5]]) == [[5]])
    }

    @Test("Returns [] when there are no rows or no columns")
    func empty() {
        #expect(GridTranspose.transpose([]) == [])
        #expect(GridTranspose.transpose([[], []]) == [])
    }

    @Test("Transposing twice gives back the original")
    func twice() {
        let grid = (0..<30).map { r in (0..<50).map { c in r * 100 - c } }
        let flipped = GridTranspose.transpose(grid)
        #expect(flipped.count == 50)
        #expect(flipped.allSatisfy { $0.count == 30 })
        #expect(GridTranspose.transpose(flipped) == grid)
    }
}
