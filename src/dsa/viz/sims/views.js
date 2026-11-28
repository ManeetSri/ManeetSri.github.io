// Each simulator's view, loaded the first time a lesson shows it (names match SIM_NAMES in index.js)
export const SIM_VISUALS = {
    cacheSim: () => import('./views/CacheSimView.jsx'),
    retry: () => import('./views/RetryView.jsx'),
    rateLimiter: () => import('./views/RateLimiterView.jsx'),
    hashRing: () => import('./views/HashRingView.jsx'),
    estimator: () => import('./views/EstimatorView.jsx'),
};
