// The structured answer for each kind of design exercise. An exercise names its template in the registry
// (and may leave sections out with `omit` in its ```workspace block); its model answer has one
// <ModelAnswer section="…"> per section, in this order.
//
// Each section: { id, title, prompt (what to cover), rows (height of the answer box) }

const section = (id, title, prompt, rows = 6) => ({ id, title, prompt, rows });

export const TEMPLATES = {
    // A whole feature or app, as in a mobile system design interview
    feature: {
        label: 'Feature design',
        minutes: 45,
        sections: [
            section('requirements', 'Requirements and scope', 'Clarifying questions, functional and non-functional requirements, what’s out of scope.', 5),
            section('estimates', 'Estimates', 'Users, requests, payload and storage sizes: the numbers that shape the design.', 4),
            section('architecture', 'High-level design', 'The main parts on the device and the server, and how data flows between them.', 7),
            section('client', 'Client architecture', 'Layers, modules, state, navigation, dependencies: how the app is put together.', 7),
            section('api', 'API', 'Endpoints or messages, request and response shapes, pagination, errors, versioning.', 6),
            section('data', 'Data model and storage', 'Entities, where each lives (memory, disk, server), caching and invalidation.', 6),
            section('deepdive', 'Deep dives', 'The two or three hardest parts, worked through in detail.', 8),
            section('failure', 'Failure, offline and edge cases', 'Bad networks, offline use, retries, conflicts, partial failure, security and privacy.', 6),
            section('tradeoffs', 'Trade-offs and evolution', 'What you chose over what, why, and how the design changes as it grows.', 5),
        ],
    },
    // One component or SDK: an image loader, a networking layer, a feature-flag client
    component: {
        label: 'Component design',
        minutes: 35,
        sections: [
            section('requirements', 'Requirements and scope', 'Who calls it, what it must do, and the constraints (threads, memory, platforms).', 5),
            section('api', 'Public API', 'The types and methods callers use, with a short usage example.', 7),
            section('internals', 'Internals', 'The parts inside and how a call flows through them.', 8),
            section('concurrency', 'Concurrency and state', 'Which state exists, who owns it, and how it stays safe across threads or actors.', 6),
            section('failure', 'Failure and edge cases', 'Errors, cancellation, limits, misuse.', 5),
            section('testing', 'Testing', 'How you’d test it, and the seams that make it testable.', 4),
            section('tradeoffs', 'Trade-offs', 'Alternatives you rejected and why.', 4),
        ],
    },
    // Changing an existing design: a migration, a refactor, a new architecture for an old app
    migration: {
        label: 'Migration plan',
        minutes: 35,
        sections: [
            section('current', 'Where things stand', 'The current design and what’s wrong with it, as concretely as you can.', 6),
            section('target', 'Target design', 'Where you want to end up, and why.', 6),
            section('steps', 'Steps', 'An order of small, shippable steps, each leaving the app working.', 8),
            section('risks', 'Risks and safety nets', 'What could go wrong, how you’d notice, how you’d roll back.', 5),
            section('measure', 'How you’d know it worked', 'Signals and metrics before and after.', 4),
        ],
    },
    // An architecture review of code or a design
    critique: {
        label: 'Architecture review',
        minutes: 25,
        sections: [
            section('problems', 'Problems you found', 'Each problem, where it is, and why it matters. Most serious first.', 9),
            section('plan', 'How you’d fix it', 'The refactor or redesign, in steps.', 7),
            section('tests', 'Tests and safety nets', 'What you’d test before and after changing it.', 4),
        ],
    },
};

export const templateSections = (templateId, omit = []) => (TEMPLATES[templateId]?.sections ?? []).filter((item) => !omit.includes(item.id));
