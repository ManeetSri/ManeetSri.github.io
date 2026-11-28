import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct GrowthTermOrderTests {
    typealias Term = GrowthTermOrder.Term

    static let one = Term()
    static let logN = Term(logPower: 1)
    static let n = Term(power: 1)
    static let nLogN = Term(power: 1, logPower: 1)
    static let nSquared = Term(power: 2)
    static let twoToN = Term(base: 2)

    @Test("The examples")
    func examples() {
        #expect(GrowthTermOrder.relation(Self.n, Self.nSquared) == .littleO)
        #expect(GrowthTermOrder.relation(Term(coefficient: 3, power: 1), Self.n) == .theta)
        #expect(GrowthTermOrder.relation(Term(logPower: 3), Self.n) == .littleO)
        #expect(GrowthTermOrder.relation(Term(power: 10), Self.twoToN) == .littleO)
        #expect(GrowthTermOrder.relation(Term(base: 3), Term(base: 2, power: 5)) == .littleOmega)
        #expect(GrowthTermOrder.relation(Self.one, Term(coefficient: 500)) == .theta)
    }

    @Test("Coefficients never change the answer", arguments: [1, 2, 1_000, 1_000_000_000])
    func coefficientsIgnored(coefficient: Int) {
        #expect(GrowthTermOrder.relation(Term(coefficient: coefficient, power: 1), Self.nSquared) == .littleO)
        #expect(GrowthTermOrder.relation(Term(coefficient: coefficient, power: 2), Self.nSquared) == .theta)
        #expect(GrowthTermOrder.relation(Self.n, Term(coefficient: coefficient, logPower: 50)) == .littleOmega)
    }

    @Test("Each part outranks the ones after it")
    func partsInOrder() {
        // a power of n beats any power of log n
        #expect(GrowthTermOrder.relation(Term(logPower: 100), Term(power: 1)) == .littleO)
        // an exponential beats any power of n and log n
        #expect(GrowthTermOrder.relation(Term(power: 100, logPower: 100), Term(base: 2)) == .littleO)
        #expect(GrowthTermOrder.relation(Term(base: 2, power: 100), Term(base: 3)) == .littleO)
        // equal bases and powers: the log power decides
        #expect(GrowthTermOrder.relation(Term(base: 2, power: 3, logPower: 2), Term(base: 2, power: 3, logPower: 1)) == .littleOmega)
        #expect(GrowthTermOrder.relation(Term(base: 5, power: 4, logPower: 3), Term(coefficient: 7, base: 5, power: 4, logPower: 3)) == .theta)
    }

    @Test("f is o(g) exactly when g is ω(f)")
    func symmetry() {
        let terms = [Self.one, Self.logN, Self.n, Self.nLogN, Self.nSquared, Self.twoToN,
                     Term(coefficient: 9, power: 1), Term(base: 3, logPower: 2), Term(logPower: 4)]
        for f in terms {
            for g in terms {
                let forwards = GrowthTermOrder.relation(f, g)
                let backwards = GrowthTermOrder.relation(g, f)
                switch forwards {
                case .littleO: #expect(backwards == .littleOmega)
                case .littleOmega: #expect(backwards == .littleO)
                case .theta: #expect(backwards == .theta)
                }
            }
            #expect(GrowthTermOrder.relation(f, f) == .theta, "nothing is o of itself")
        }
    }

    @Test("The ladder from the examples")
    func ladderExample() {
        let input = [Self.nSquared, Self.logN, Self.twoToN, Self.nLogN, Self.one, Self.n]
        #expect(GrowthTermOrder.ladder(input) == [Self.one, Self.logN, Self.n, Self.nLogN, Self.nSquared, Self.twoToN])
    }

    @Test("Equal-growth terms keep their order")
    func ladderTies() {
        let threeN = Term(coefficient: 3, power: 1)
        let sevenN = Term(coefficient: 7, power: 1)
        let input = [Self.nSquared, threeN, Self.one, Self.n, sevenN, Term(coefficient: 2)]
        let expected = [Self.one, Term(coefficient: 2), threeN, Self.n, sevenN, Self.nSquared]
        #expect(GrowthTermOrder.ladder(input) == expected)
    }

    @Test("Empty and single-term ladders")
    func ladderSmall() {
        #expect(GrowthTermOrder.ladder([]) == [])
        #expect(GrowthTermOrder.ladder([Self.twoToN]) == [Self.twoToN])
    }

    @Test("A long ladder comes out in growth order, ties in input order")
    func ladderLong() {
        var input: [Term] = []
        for i in 0..<2_000 {
            input.append(Term(coefficient: i + 1, base: 1 + i % 3, power: (i * 7) % 5, logPower: (i * 11) % 4))
        }
        let result = GrowthTermOrder.ladder(input)
        #expect(result.count == input.count)
        var inOrder = true
        for (earlier, later) in zip(result, result.dropFirst()) {
            switch GrowthTermOrder.relation(earlier, later) {
            case .littleOmega: inOrder = false
            case .theta: if earlier.coefficient > later.coefficient { inOrder = false }   // coefficients rise with the index
            case .littleO: break
            }
        }
        #expect(inOrder)
    }
}
