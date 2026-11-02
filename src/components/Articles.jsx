import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ArrowUpRight, ChevronDown, ExternalLink } from 'lucide-react';
import { useMediumPosts, formatDate, MEDIUM_PROFILE_URL } from '../hooks/useMediumPosts';

const Meta = ({ post }) => (
    <span className="font-mono text-xs text-muted">{formatDate(post.pubDate)} · {post.readMinutes} min read</span>
);

const Tags = ({ tags }) => (
    <span className="flex flex-wrap gap-1.5">
        {tags.map((tag) => (
            <span key={tag} className="rounded-full border border-line px-2 py-0.5 font-mono text-xs text-muted">{tag}</span>
        ))}
    </span>
);

const FeaturedPost = ({ post }) => (
    <motion.a
        href={post.link}
        target="_blank"
        rel="noopener noreferrer"
        initial={{ opacity: 0, y: 24 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true, margin: '-8% 0px' }}
        transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="group flex flex-col overflow-hidden rounded-2xl border border-line bg-surface transition-colors hover:border-swift/60"
    >
        <div className="relative aspect-[16/9] overflow-hidden bg-raised">
            {post.cover && (
                <img
                    src={post.cover}
                    alt=""
                    loading="lazy"
                    className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105 motion-reduce:transition-none motion-reduce:group-hover:scale-100"
                />
            )}
            <span className="swift-gradient absolute left-3 top-3 rounded-full px-3 py-1 font-mono text-xs font-semibold text-ink">Start here</span>
        </div>
        <div className="flex flex-1 flex-col gap-3 p-5 sm:p-6">
            <Meta post={post} />
            <h3 className="font-display text-2xl font-semibold leading-tight tracking-tight sm:text-3xl">{post.title}</h3>
            <p className="line-clamp-3 leading-relaxed text-muted">{post.excerpt}</p>
            <Tags tags={post.tags} />
            <span className="mt-auto inline-flex items-center gap-1.5 pt-2 font-medium text-amber">
                Read on Medium <ArrowUpRight size={17} aria-hidden="true" className="transition-transform group-hover:-translate-y-0.5 group-hover:translate-x-0.5" />
            </span>
        </div>
    </motion.a>
);

const Commit = ({ post, index, isHead }) => {
    const [open, setOpen] = useState(false);

    return (
        <motion.li
            initial={{ opacity: 0, x: 18 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: '-5% 0px' }}
            transition={{ duration: 0.45, delay: Math.min(index, 5) * 0.06 }}
            className="border-b border-line last:border-b-0"
        >
            <button
                type="button"
                onClick={() => setOpen(!open)}
                aria-expanded={open}
                className="flex w-full items-start gap-3 px-4 py-4 text-left transition-colors hover:bg-raised sm:px-5"
            >
                <span className="mt-0.5 shrink-0 font-mono text-sm text-amber">{post.hash}</span>
                <span className="min-w-0 flex-1">
                    <span className="mr-2 font-medium leading-snug">{post.title}</span>
                    {isHead && <span className="whitespace-nowrap font-mono text-xs text-[#30D158]">(HEAD)</span>}
                    <span className="mt-1.5 block"><Meta post={post} /></span>
                </span>
                <ChevronDown
                    size={18}
                    aria-hidden="true"
                    className={`mt-0.5 shrink-0 text-muted transition-transform ${open ? 'rotate-180' : ''}`}
                />
            </button>
            <AnimatePresence initial={false}>
                {open && (
                    <motion.div
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.25 }}
                        className="overflow-hidden"
                    >
                        <div className="space-y-3 px-4 pb-5 sm:px-5">
                            <p className="line-clamp-4 text-sm leading-relaxed text-muted">{post.excerpt}</p>
                            <Tags tags={post.tags} />
                            <a
                                href={post.link}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="inline-flex items-center gap-1.5 text-sm font-medium text-amber hover:underline"
                            >
                                Read on Medium <ExternalLink size={14} aria-hidden="true" />
                            </a>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </motion.li>
    );
};

// One post in the spotlight, with the rest as a commit log beside it
const Articles = ({ limit }) => {
    const { posts, loading } = useMediumPosts();
    const featured = posts.find((post) => post.title.includes('ViewModel Initialized')) ?? posts[0];
    const rest = posts.filter((post) => post !== featured);
    const log = limit ? rest.slice(0, limit) : rest;

    if (!loading && posts.length === 0) {
        return (
            <p className="rounded-2xl border border-line bg-surface p-6 text-muted">
                The articles couldn't be loaded right now.{' '}
                <a href={MEDIUM_PROFILE_URL} target="_blank" rel="noopener noreferrer" className="text-amber underline">
                    Read them on Medium
                </a>.
            </p>
        );
    }

    return (
        <div className="grid items-start gap-6 lg:grid-cols-[minmax(0,5fr)_minmax(0,6fr)]">
            {featured ? <FeaturedPost post={featured} /> : <div className="aspect-[16/9] rounded-2xl border border-line bg-surface" />}

            <div className="overflow-hidden rounded-2xl border border-line bg-surface">
                <p className="flex items-center justify-between gap-3 border-b border-line px-4 py-3 font-mono text-sm text-muted sm:px-5">
                    <span><span className="text-swift">$</span> git log --author=maneet</span>
                    {posts.length > 0 && <span className="whitespace-nowrap text-xs">{posts.length} commits</span>}
                </p>
                {loading && <p className="px-4 py-6 font-mono text-sm text-muted sm:px-5">Fetching origin…</p>}
                <ul>
                    {log.map((post, index) => (
                        <Commit key={post.guid} post={post} index={index} isHead={post === posts[0]} />
                    ))}
                </ul>
            </div>
        </div>
    );
};

export default Articles;
