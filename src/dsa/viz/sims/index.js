// Simulators (cache, retry, rate limiter, hash ring, estimator): small programs a lesson configures in
// YAML and the learner steps through or plays with. Each name has a schema the build runs on the lesson's
// YAML, which returns true or a readable problem. The views are in views.js, so the build (which imports this
// file through names.js) never pulls in React components. Node-safe.
// src/dsa/design/content/AUTHORING.sims.md documents the props.
import { cacheSimSchema } from './cacheSim.js';
import { estimatorSchema } from './estimator.js';
import { hashRingSchema } from './hashRing.js';
import { rateLimiterSchema } from './rateLimiter.js';
import { retrySchema } from './retry.js';

export const SIM_SCHEMAS = {
    cacheSim: cacheSimSchema,
    retry: retrySchema,
    rateLimiter: rateLimiterSchema,
    hashRing: hashRingSchema,
    estimator: estimatorSchema,
};

export const SIM_NAMES = Object.keys(SIM_SCHEMAS);
