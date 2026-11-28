// Design exercises and architecture reviews for D20 · Navigation & routing
export default [
    {
        id: 'sd-review-navigation-pushy-screens',
        kind: 'critique',
        title: 'Review: screens that push each other',
        difficulty: 'medium',
        patterns: ['navigation', 'architecture', 'security'],
        lessons: ['sd-nav-uikit-containers', 'sd-nav-coordinators-uikit', 'sd-nav-routers'],
        minutes: 30,
        summary: 'View controllers that build and push each other, reach into the tab bar by index, and parse deep links in two places that already disagree.',
    },
    {
        id: 'sd-design-navigation-shop-routing',
        kind: 'design',
        title: 'Routing for a tabbed shopping app',
        difficulty: 'hard',
        patterns: ['navigation', 'architecture', 'push'],
        lessons: ['sd-nav-split-view', 'sd-nav-deep-links', 'sd-nav-entry-points', 'sd-nav-restoration'],
        minutes: 45,
        template: 'feature',
        mock: true,
        lists: [],
        summary: 'Every way into a four-tab shop, from tracked email links and notifications to widgets and restoration, through one route and one router.',
    },
];
