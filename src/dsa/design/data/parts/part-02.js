// Part II: Design patterns (D10–D15). The classic catalogue taught through Swift and Apple's own
// frameworks, then the concurrency and resilience patterns apps need, and finally the smells and
// refactorings that move real code towards (or away from) them.
//
// A lesson is ['id', 'Title', { options }]. Options default to the module's level and tracks, and
// 20 minutes. Lesson ids are permanent: progress is stored against them.

export default [
    {
        id: 'sd-creational', code: 'D10', part: 2, title: 'Creational patterns', level: 'intermediate', tracks: ['core'], requires: ['sd-solid', 'sd-swift-design'],
        summary: 'Ways to create objects without hard-wiring their types: factories, builders, prototypes, singletons and their testable alternatives, pools and lazy initialisation.',
        lessons: [
            ['sd-creational-patterns-intro', 'What design patterns are, and the creational family', { minutes: 15 }],
            ['sd-creational-static-factories', 'Static factories and convenience initialisers', { minutes: 15 }],
            ['sd-creational-factory-method', 'Factory method'],
            ['sd-creational-abstract-factory', 'Abstract factory: families of related objects'],
            ['sd-creational-builder', 'Builder, fluent APIs and result builders', { minutes: 25 }],
            ['sd-creational-prototype', 'Prototype: NSCopying and value copies'],
            ['sd-creational-singleton', "Singleton and Apple's shared instances"],
            ['sd-creational-singleton-alternatives', 'Why to avoid singletons, and testable alternatives', { minutes: 25 }],
            ['sd-creational-object-pools', 'Object pools and reuse, from cells to formatters'],
            ['sd-creational-lazy', 'Lazy initialisation', { minutes: 15 }],
        ],
    },
    {
        id: 'sd-structural', code: 'D11', part: 2, title: 'Structural patterns', level: 'intermediate', tracks: ['core'], requires: ['sd-creational'],
        summary: 'Composing types into larger structures: adapters, facades, decorators, proxies and composites, plus bridge, flyweight and enum namespaces.',
        lessons: [
            ['sd-structural-adapter', 'Adapter: wrapping SDKs and legacy code'],
            ['sd-structural-facade', 'Facade: one simple front for a subsystem', { minutes: 15 }],
            ['sd-structural-decorator', 'Decorator: logging and caching by wrapping', { minutes: 25 }],
            ['sd-structural-swiftui-modifiers', 'SwiftUI view modifiers as decorators', { minutes: 15, tracks: ['ios'] }],
            ['sd-structural-proxy', 'Proxy: virtual, remote, protection and NSProxy', { minutes: 25 }],
            ['sd-structural-wrappers-compared', 'Adapter, decorator, proxy and facade compared', { minutes: 15 }],
            ['sd-structural-composite', 'Composite: view hierarchies and menus'],
            ['sd-structural-bridge', 'Bridge: separating abstraction from implementation'],
            ['sd-structural-flyweight', 'Flyweight: sharing state across many objects', { minutes: 15 }],
            ['sd-structural-enum-namespaces', 'Namespacing with caseless enums', { minutes: 10 }],
        ],
    },
    {
        id: 'sd-behavioural-1', code: 'D12', part: 2, title: 'Behavioural patterns I', level: 'intermediate', tracks: ['core'], requires: ['sd-structural'],
        summary: 'How objects talk to each other: observers in every Apple flavour, delegates, target–action, callbacks, the responder chain, chains of responsibility, commands, strategies and template methods.',
        lessons: [
            ['sd-behavioural-observer', 'Observer and NotificationCenter'],
            ['sd-behavioural-kvo-combine-observation', 'Observers in KVO, Combine and Observation', { minutes: 25 }],
            ['sd-behavioural-delegate', 'Delegate and data source'],
            ['sd-behavioural-target-action', 'Target–action', { minutes: 15, tracks: ['ios'] }],
            ['sd-behavioural-closure-callbacks', 'Closure callbacks, and choosing a callback style'],
            ['sd-behavioural-responder-chain', 'The responder chain', { minutes: 15, tracks: ['ios'] }],
            ['sd-behavioural-chain-of-responsibility', 'Chain of responsibility: interceptors and middleware', { minutes: 25 }],
            ['sd-behavioural-command', 'Command and UndoManager', { minutes: 25 }],
            ['sd-behavioural-strategy', 'Strategy: swappable algorithms'],
            ['sd-behavioural-template-method', 'Template method and hook methods', { minutes: 15 }],
        ],
    },
    {
        id: 'sd-behavioural-2', code: 'D13', part: 2, title: 'Behavioural patterns II', level: 'intermediate', tracks: ['core'], requires: ['sd-behavioural-1', 'sd-functional'],
        summary: 'State machines, mediators, mementos, iterators, visitors, interpreters, null objects and specifications, with a first look at event sourcing.',
        lessons: [
            ['sd-behavioural-state', 'State: enum state machines', { minutes: 25 }],
            ['sd-behavioural-mediator', 'Mediator: coordinators as mediators'],
            ['sd-behavioural-memento', 'Memento: snapshots and state restoration'],
            ['sd-behavioural-iterator', 'Iterator: Sequence and AsyncSequence'],
            ['sd-behavioural-visitor', 'Visitor: double dispatch vs switching on enums', { level: 'advanced' }],
            ['sd-behavioural-interpreter', 'Interpreter: mini DSLs and route grammars', { minutes: 25, level: 'advanced' }],
            ['sd-behavioural-null-object', 'Null object: safe do-nothing defaults', { minutes: 10 }],
            ['sd-behavioural-specification', 'Specification: composable business rules', { minutes: 15 }],
            ['sd-behavioural-event-sourcing', 'Event sourcing: a preview', { minutes: 15, level: 'advanced' }],
            ['sd-behavioural-choosing', 'Choosing a behavioural pattern', { minutes: 15 }],
        ],
    },
    {
        id: 'sd-resilience-patterns', code: 'D14', part: 2, title: 'Concurrency & resilience patterns', level: 'advanced', tracks: ['core'], requires: ['sd-behavioural-2', 'sd-swift-design'],
        summary: 'Patterns for concurrent work, for shaping traffic from the client, and for surviving slow or failing dependencies.',
        lessons: [
            ['sd-resilience-producer-consumer', 'Producer–consumer and work queues', { level: 'intermediate' }],
            ['sd-resilience-actor-model', 'The actor model as a design pattern'],
            ['sd-resilience-futures-async', 'Futures and promises vs async/await'],
            ['sd-resilience-async-streams', 'Async sequences and streams'],
            ['sd-resilience-debounce-throttle', 'Debounce, throttle and coalesce', { level: 'intermediate' }],
            ['sd-resilience-single-flight', 'Single-flight request de-duplication'],
            ['sd-resilience-rate-limiting', 'Client-side rate limiting'],
            ['sd-resilience-retry-backoff', 'Retry with exponential backoff and jitter', { minutes: 25 }],
            ['sd-resilience-circuit-breaker', 'Circuit breakers and bulkheads', { minutes: 25 }],
            ['sd-resilience-timeouts-cancellation', 'Timeouts, deadlines and cancellation propagation', { minutes: 25 }],
        ],
    },
    {
        id: 'sd-refactoring', code: 'D15', part: 2, title: 'Anti-patterns & refactoring', level: 'intermediate', tracks: ['core'], requires: ['sd-coupling', 'sd-solid', 'sd-behavioural-1'],
        summary: 'Recognising the smells that rot iOS codebases, protecting behaviour with characterisation tests, and the refactorings that fix them safely.',
        lessons: [
            ['sd-refactoring-smells-guide', 'Smells and anti-patterns: a field guide', { minutes: 15 }],
            ['sd-refactoring-massive-vc', 'Massive View Controller and god objects'],
            ['sd-refactoring-global-state', 'Singleton abuse, global state and service locators'],
            ['sd-refactoring-change-smells', 'Feature envy, shotgun surgery and divergent change'],
            ['sd-refactoring-abstraction-smells', 'Leaky abstractions and speculative generality'],
            ['sd-refactoring-api-smells', 'Callback pyramids and stringly-typed APIs'],
            ['sd-refactoring-characterisation-tests', 'Refactoring safely: characterisation tests and small steps', { minutes: 25 }],
            ['sd-refactoring-extract-child-vc', 'Extract child view controller', { tracks: ['ios'] }],
            ['sd-refactoring-extract-protocol', 'Extract protocol and introduce parameter object'],
            ['sd-refactoring-replace-conditional', 'Replace conditional with polymorphism'],
        ],
    },
];
