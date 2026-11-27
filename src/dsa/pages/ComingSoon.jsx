import { Hammer } from 'lucide-react';
import { useConsoleMeta } from '../ui/hooks.js';
import { ButtonLink, EmptyState, PageHeader } from '../ui/primitives.jsx';

// Screens that are planned but arrive in a later delivery phase
const PLANNED = {
    mock: { title: 'Mock interview', phase: 10, detail: 'A random problem from topics you’ve mastered, a 45-minute timer, no hints, and a rubric to score yourself afterwards.' },
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
