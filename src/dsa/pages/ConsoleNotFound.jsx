import { Compass } from 'lucide-react';
import { useCourse } from '../course/context.js';
import { useConsoleMeta } from '../ui/hooks.js';
import { ButtonLink, EmptyState } from '../ui/primitives.jsx';

const ConsoleNotFound = () => {
    const { links } = useCourse();
    useConsoleMeta('Not found');
    return (
        <div className="mx-auto max-w-xl pt-10">
            <EmptyState icon={Compass} title="Nothing lives here">That link doesn’t match a lesson, problem or page in the console.</EmptyState>
            <div className="mt-6 flex justify-center"><ButtonLink to={links.today}>Back to today</ButtonLink></div>
        </div>
    );
};

export default ConsoleNotFound;
