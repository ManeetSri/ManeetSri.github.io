import { ArrowRight } from 'lucide-react';
import { Link } from 'react-router-dom';
import Articles from '../components/Articles';

const Notes = () => (
    <section id="notes" className="relative bg-ink px-5 py-16 sm:px-10 lg:px-[5vw] lg:py-24">
        <p className="mb-3 font-mono text-sm text-swift">Notes</p>
        <h2 className="mb-10 font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Things I learned the hard way, committed to writing.</h2>
        <Articles limit={5} />
        <Link to="/blogs" className="mt-6 inline-flex items-center gap-2 font-medium text-amber hover:underline">
            View the full log <ArrowRight size={17} aria-hidden="true" />
        </Link>
    </section>
);

export default Notes;
