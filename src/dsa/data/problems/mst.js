// Problems for the mst module. Fields are described in ../problems.js.
export default [
    {
        id: 'cheapest-cable-network',
        title: 'The cheapest cable network',
        difficulty: 'medium',
        patterns: ['union-find', 'greedy', 'sorting'],
        lessons: ['mst-kruskal', 'mst-problems'],
        swiftTest: 'CheapestCableNetworkTests',
        lists: ['patterns150'],
        minutes: 30,
    },
    {
        id: 'connect-every-point',
        title: 'Connect every point',
        difficulty: 'medium',
        patterns: ['greedy', 'heap'],
        lessons: ['mst-prim', 'mst-problems'],
        swiftTest: 'PointConnectorTests',
        lists: ['core75'],
        minutes: 35,
    },
    {
        id: 'critical-and-optional-links',
        title: 'Critical and optional links',
        difficulty: 'hard',
        patterns: ['union-find', 'greedy', 'sorting'],
        lessons: ['mst-definition', 'mst-problems'],
        swiftTest: 'MSTEdgeRolesTests',
        lists: ['patterns150'],
        minutes: 50,
    },
];
