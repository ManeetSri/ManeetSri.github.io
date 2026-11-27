import { Hammer } from 'lucide-react';
import { useConsoleMeta } from '../ui/hooks.js';
import { ButtonLink, EmptyState, PageHeader } from '../ui/primitives.jsx';

// Screens that are planned but arrive in a later delivery phase
const PLANNED = {
    sheets: { title: 'Cheat sheets', phase: 5, detail: 'Big-O tables for every structure, the Swift collection API, a pattern-recognition flowchart, code templates and a glossary.' },
    mock: { title: 'Mock interview', phase: 10, detail: 'A random problem from topics you’ve mastered, a 45-minute timer, no hints, and a rubric to score yourself afterwards.' },
    checkpoint: { title: 'Checkpoint test', phase: 3, detail: 'A mixed test at the end of each module. Score 80% or more to mark it mastered, or to test out of a module you already know.' },
};

const ComingSoon = ({ screen }) => {
    const { title, phase, detail } = PLANNED[screen];
    useConsoleMeta(title);
    return (
        <div className="mx-auto max-w-2xl">
            <PageHeader eyebrow={`Arrives in phase ${phase}`} title={title} />
            <EmptyState icon={Hammer} title="On the roadmap">{detail}</EmptyState>
            <div className="mt-6 flex justify-center gap-2">
                <ButtonLink to="/dsa">Back to today</ButtonLink>
            </div>
        </div>
    );
};

export default ComingSoon;
