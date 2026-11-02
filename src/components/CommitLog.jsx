import { useState } from 'react';
import { AnimatePresence, motion } from 'framer-motion';
import { ChevronDown, ExternalLink } from 'lucide-react';
import { useMediumPosts, stripHtml, formatDate, MEDIUM_PROFILE_URL } from '../hooks/useMediumPosts';

// Medium's guid ends in the post's id, which makes a genuine short hash
const shortHash = (guid = '') => guid.split('/').pop().slice(0, 7);

const Commit = ({ post, isHead }) => {
    const [open, setOpen] = useState(false);
    const startHere = post.title.includes('ViewModel Initialized');

    return (
        <li className="border-b border-line last:border-b-0">
            <button
                type="button"
                onClick={() => setOpen(!open)}
                aria-expanded={open}
                className="flex w-full items-start gap-3 px-4 py-3.5 text-left transition-colors hover:bg-raised sm:px-5"
            >
                <span className="mt-0.5 shrink-0 font-mono text-sm text-amber">{shortHash(post.guid)}</span>
                <span className="min-w-0 flex-1">
                    <span className="mr-2 font-medium">{post.title}</span>
                    {isHead && <span className="mr-2 whitespace-nowrap font-mono text-xs text-[#30D158]">(HEAD)</span>}
                    {startHere && <span className="whitespace-nowrap font-mono text-xs text-swift">start here</span>}
                    <span className="mt-1 block font-mono text-xs text-muted">{formatDate(post.pubDate)}</span>
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
                        <div className="px-4 pb-4 sm:px-5">
                            <p className="mb-3 line-clamp-4 text-sm leading-relaxed text-muted">{stripHtml(post.description)}</p>
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
        </li>
    );
};

const CommitLog = ({ limit }) => {
    const { posts, loading } = useMediumPosts();
    const visible = limit ? posts.slice(0, limit) : posts;

    return (
        <div className="overflow-hidden rounded-2xl border border-line bg-surface">
            <p className="border-b border-line px-4 py-3 font-mono text-sm text-muted sm:px-5">
                <span className="text-swift">$</span> git log --author=maneet
            </p>
            {loading && <p className="px-4 py-6 font-mono text-sm text-muted sm:px-5">Fetching origin…</p>}
            {!loading && posts.length === 0 && (
                <p className="px-4 py-6 text-sm text-muted sm:px-5">
                    The articles couldn't be loaded right now.{' '}
                    <a href={MEDIUM_PROFILE_URL} target="_blank" rel="noopener noreferrer" className="text-amber underline">
                        Read them on Medium
                    </a>.
                </p>
            )}
            <ul>
                {visible.map((post, index) => (
                    <Commit key={post.guid} post={post} isHead={index === 0} />
                ))}
            </ul>
        </div>
    );
};

export default CommitLog;
