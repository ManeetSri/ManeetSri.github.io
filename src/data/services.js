// What I can build, drawn from the work in projects.js and career.js.
// Used by the Services section and by the crawlable HTML generated in seo-plugin.js.
export const services = [
    {
        id: 'ios',
        title: 'iOS App Development',
        body: 'Native iPhone apps in Swift, SwiftUI and UIKit, built to last and ready for the App Store.',
        platform: 'ios',
        features: ['push', 'data'],
    },
    {
        id: 'cross-platform',
        title: 'iOS & Android Apps with React Native',
        body: 'One React Native codebase for both platforms, when you need to reach iPhone and Android users together.',
        platform: 'both',
        features: ['push', 'firebase'],
    },
    {
        id: 'projects',
        title: 'End-to-End Project Development',
        body: 'From first idea to shipped product: architecture, build, integrations and release.',
        platform: 'ios',
        features: ['push', 'firebase', 'payments', 'data'],
    },
    {
        id: 'mobility',
        title: 'Ride-Hailing & Logistics Apps',
        body: 'User and driver apps with maps, routing, payments and real-time updates.',
        platform: 'ios',
        features: ['maps', 'realtime', 'payments', 'push'],
    },
    {
        id: 'commerce',
        title: 'E-commerce & Subscription Apps',
        body: 'Product catalogs, secure checkout, order tracking, loyalty, in-app purchases and subscriptions.',
        platform: 'ios',
        features: ['payments', 'purchases', 'push', 'firebase'],
    },
    {
        id: 'release',
        title: 'App Store Release & Support',
        body: 'Submissions that follow App Store policies, plus fixes and improvements after launch.',
        platform: 'ios',
        features: ['purchases', 'push'],
    },
];

// `proof` lists the apps in projects.js that already use a feature
export const features = [
    { id: 'maps', label: 'Live maps', stack: 'Google Maps', proof: ['alyte'] },
    { id: 'payments', label: 'Payments', stack: 'Secure checkout', proof: ['alyte', 'best'] },
    { id: 'realtime', label: 'Real-time updates', stack: 'WebSockets', proof: ['alyte'] },
    { id: 'purchases', label: 'Subscriptions', stack: 'In-app purchases', proof: ['imperium', 'empowered'] },
    { id: 'push', label: 'Push notifications', stack: 'APNs', proof: ['alyte', 'best', 'spiritual'] },
    { id: 'firebase', label: 'Cloud backend', stack: 'Firebase', proof: ['best', 'spiritual'] },
    { id: 'data', label: 'On-device data', stack: 'Core Data', proof: [] },
    { id: 'video', label: 'Video recording', stack: 'In-app camera', proof: ['imperium'] },
];

export const platforms = [
    { id: 'ios', label: 'iPhone', stack: ['Swift', 'SwiftUI', 'UIKit'] },
    { id: 'both', label: 'iPhone + Android', stack: ['React Native', 'JavaScript'] },
];

export const faqs = [
    {
        question: 'Can I work with you on a mobile app?',
        answer: 'Yes. I enjoy working on new mobile apps and on improving existing ones. Tell me what you\'re building and we can see if it\'s a good fit.',
    },
    {
        question: 'Do you build Android apps?',
        answer: 'Yes, with React Native, so a single codebase runs on both iOS and Android. My native work is on iOS, in Swift and SwiftUI.',
    },
    {
        question: 'What kinds of apps have you worked on?',
        answer: 'Ride-hailing, retail e-commerce, school management, teen wellbeing, health, job discovery and community apps, plus an open-source Swift Package.',
    },
    {
        question: 'Can we work together from another country?',
        answer: 'Yes. I work remotely, so your location doesn\'t matter. Use the contact form or email me to get started.',
    },
];
