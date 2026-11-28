// Design exercises and architecture reviews for D21 · Dependency injection
export default [
    {
        id: 'sd-review-di-hidden-locator',
        kind: 'critique',
        title: 'Review: the locator inside the models',
        difficulty: 'medium',
        patterns: ['di', 'architecture', 'testing'],
        lessons: ['sd-di-service-locator', 'sd-di-why', 'sd-di-scopes'],
        minutes: 25,
        lists: [],
        summary: 'A home-grown service locator resolved from view models and model types: find why the tab shows the last user’s orders, why previews and the widget crash, and why the tests only pass alone.',
    },
    {
        id: 'sd-design-di-singleton-migration',
        kind: 'design',
        title: 'Plan: move a 200-screen app from singletons to injection',
        difficulty: 'hard',
        patterns: ['di', 'architecture', 'modularity'],
        lessons: ['sd-di-composition-root', 'sd-di-scopes', 'sd-di-environment', 'sd-di-compile-time'],
        minutes: 35,
        template: 'migration',
        mock: false,
        lists: [],
        summary: 'Forty-six singletons, 3,100 call sites, six squads and two cross-user data leaks: plan the move to a composition root and session scopes without stopping feature work.',
    },
];
