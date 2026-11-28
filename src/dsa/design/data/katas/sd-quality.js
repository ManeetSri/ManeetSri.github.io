// Katas for D01 · Quality attributes & trade-offs
export default [
    {
        id: 'sd-kata-quality-decision-matrix',
        kind: 'problem',
        title: 'Weighted decision matrix',
        difficulty: 'easy',
        patterns: ['principles', 'architecture'],
        lessons: ['sd-quality-decisions'],
        swiftTest: 'QualityDecisionMatrixTests',
        lists: [],
        minutes: 25,
    },
    {
        id: 'sd-kata-quality-budget-gate',
        kind: 'problem',
        title: 'Performance budget gate',
        difficulty: 'medium',
        patterns: ['performance', 'testing', 'release'],
        lessons: ['sd-quality-measuring', 'sd-quality-performance', 'sd-quality-reliability'],
        swiftTest: 'QualityBudgetGateTests',
        lists: [],
        minutes: 30,
    },
];
