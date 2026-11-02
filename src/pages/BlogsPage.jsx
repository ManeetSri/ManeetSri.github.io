import { ArrowLeft, ExternalLink } from 'lucide-react';
import { Link } from 'react-router-dom';
import Articles from '../components/Articles';
import { MEDIUM_PROFILE_URL } from '../hooks/useMediumPosts';
import { usePageMeta } from '../hooks/usePageMeta';

const BlogsPage = () => {
    usePageMeta({
        title: 'iOS & Mobile App Development Articles | Maneet Srivastav',
        description: 'Articles on iOS and mobile app development: SwiftUI, Core Data, MVVM architecture, debugging and developer tools, from a working mobile engineer.',
        path: '/blogs',
    });

    return (
        <main className="min-h-svh px-5 pb-28 pt-16 sm:px-10 lg:px-[5vw]">
            <Link to="/" className="mb-8 inline-flex items-center gap-2 text-amber hover:underline">
                <ArrowLeft size={18} aria-hidden="true" /> Back to Home
            </Link>
            <h1 className="mb-10 font-display text-[clamp(2.6rem,6vw,5rem)] font-semibold leading-none tracking-tight">The full log.</h1>
            <Articles />
            {/* The feed only returns the 10 newest posts, so older ones live on Medium */}
            <a href={MEDIUM_PROFILE_URL} target="_blank" rel="noopener noreferrer" className="mt-6 inline-flex items-center gap-2 font-medium text-amber hover:underline">
                See every article on Medium <ExternalLink size={16} aria-hidden="true" />
            </a>
        </main>
    );
};

export default BlogsPage;
