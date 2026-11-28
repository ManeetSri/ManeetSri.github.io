// What a design rubric measures. Every rubric criterion names one skill; a design's score for a skill is
// its weakest criterion for that skill, and Progress shows the latest score for each.
export const SKILLS = {
    requirements: 'Requirements & scope',
    estimation: 'Estimation',
    architecture: 'High-level architecture',
    client: 'Client architecture',
    api: 'API design',
    data: 'Data & storage',
    offline: 'Offline & failure',
    performance: 'Performance',
    security: 'Security & privacy',
    testing: 'Testing',
    tradeoffs: 'Trade-offs',
    communication: 'Communication',
};

// The rubric for a timed mock design interview, scored 1–4 like the DSA mock
export const MOCK_CRITERIA = [
    { id: 'requirements', label: 'Requirements and scope', skill: 'requirements', detail: 'Asked the questions that change the design, and agreed what’s in and out' },
    { id: 'architecture', label: 'High-level architecture', skill: 'architecture', detail: 'A clear picture of the parts on device and server, and how data flows' },
    { id: 'client', label: 'Client architecture', skill: 'client', detail: 'Layers, state, dependencies and navigation that would hold up in a real app' },
    { id: 'apidata', label: 'API and data model', skill: 'data', detail: 'Sensible endpoints or messages, entities, storage and caching' },
    { id: 'deepdive', label: 'Deep dive', skill: 'architecture', detail: 'Went deep on the hardest part instead of staying shallow everywhere' },
    { id: 'tradeoffs', label: 'Trade-offs', skill: 'tradeoffs', detail: 'Named alternatives and said why one won' },
    { id: 'failure', label: 'Failure, offline and edge cases', skill: 'offline', detail: 'Bad networks, retries, conflicts, security and privacy' },
    { id: 'communication', label: 'Communication and time', skill: 'communication', detail: 'Drove the conversation, explained clearly and used the time well' },
];
