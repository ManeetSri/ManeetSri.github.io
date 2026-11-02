import { ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import { usePageMeta } from '../hooks/usePageMeta';

const NotFoundPage = () => {
    usePageMeta({
        title: 'Page not found | Maneet Srivastav',
        description: 'This page does not exist.',
        path: '/',
        noindex: true,
    });

    return (
        <main className="flex min-h-svh items-center justify-center px-5 pb-20 text-center">
            <div>
                <p className="mb-4 font-mono text-sm text-[#FF9D96]">error: no such route (404)</p>
                <h1 className="mb-4 font-display text-5xl font-semibold tracking-tight sm:text-7xl">Build failed.</h1>
                <p className="mb-8 text-lg text-muted">This page doesn't exist or may have moved.</p>
                <Link to="/" className="inline-flex items-center gap-2 text-amber hover:underline">
                    <ArrowLeft size={18} aria-hidden="true" /> Back to Home
                </Link>
            </div>
        </main>
    );
};

export default NotFoundPage;
