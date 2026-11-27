// Each visualiser loads only when a lesson shows it. Names must match viz/names.js.
export const VISUALS = {
    binarySearch: () => import('./views/BinarySearchView.jsx'),
    recursionTree: () => import('./views/RecursionTreeView.jsx'),
    traceTable: () => import('./views/TraceTableView.jsx'),
    growthChart: () => import('./views/GrowthChartView.jsx'),
    bitPlayground: () => import('./views/BitPlaygroundView.jsx'),
    arrayTrace: () => import('./views/ArrayTraceView.jsx'),
    linkedList: () => import('./views/LinkedListView.jsx'),
    stackQueue: () => import('./views/StackQueueView.jsx'),
    hashTable: () => import('./views/HashTableView.jsx'),
};
