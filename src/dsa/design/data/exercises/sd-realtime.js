// Design exercises and architecture reviews for D35 · Real-time communication
export default [
    {
        id: 'sd-review-realtime-scores-socket',
        kind: 'critique',
        title: 'Review: a live-scores socket client',
        difficulty: 'medium',
        patterns: ['realtime', 'networking', 'concurrency'],
        lessons: ['sd-rt-websockets', 'sd-rt-reconnection', 'sd-rt-battery-radio'],
        minutes: 25,
        lists: [],
        summary: 'A URLSessionWebSocketTask client with no heartbeat, a tight reconnect loop, main-thread decoding and a history that never stops growing: find why scores freeze and connections multiply.',
    },
    {
        id: 'sd-design-realtime-live-scores',
        kind: 'design',
        title: 'Live score updates for 5 million fans',
        difficulty: 'hard',
        patterns: ['realtime', 'scaling', 'push'],
        lessons: ['sd-rt-push-vs-pull', 'sd-rt-polling', 'sd-rt-sse', 'sd-rt-ordering-delivery'],
        minutes: 45,
        template: 'system',
        mock: true,
        lists: [],
        summary: 'Get goals to 5 million concurrent fans within two seconds without ever showing a score twice or backwards, and keep them informed when the app is closed.',
    },
];
