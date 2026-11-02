import React from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, ArrowLeft, Calendar, User } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useMediumPosts, stripHtml, formatDate, MEDIUM_PROFILE_URL } from '../hooks/useMediumPosts';
import { useDocumentTitle } from '../hooks/useDocumentTitle';

const BlogsPage = () => {
    useDocumentTitle('Articles – Maneet Srivastav');
    const { posts, loading } = useMediumPosts();

    return (
        <div className="min-h-screen pt-24 pb-20 px-4 sm:px-6">
            <div className="max-w-7xl mx-auto">
                <div className="mb-12">
                    <Link to="/" className="inline-flex items-center text-lavender-light hover:text-white transition-colors mb-6">
                        <ArrowLeft size={20} className="mr-2" />
                        Back to Home
                    </Link>
                    <motion.h1
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-4xl font-bold text-slate-50 mb-4"
                    >
                        All Articles
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-slate-300 max-w-2xl"
                    >
                        Thoughts, tutorials, and insights on mobile engineering, architecture, and technology.
                    </motion.p>
                </div>

                {loading ? (
                    <div className="flex justify-center py-20">
                        <div className="w-10 h-10 border-4 border-lavender border-t-transparent rounded-full animate-spin"></div>
                    </div>
                ) : (
                    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                        {posts.map((post, index) => (
                            <motion.a
                                key={index}
                                href={post.link}
                                target="_blank"
                                rel="noopener noreferrer"
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: index * 0.1 }}
                                whileHover={{ y: -5 }}
                                className="glass-card rounded-3xl p-5 md:p-6 flex flex-col h-full group overflow-hidden"
                            >
                                <div className="mb-4">
                                    <h3 className="text-lg font-semibold text-slate-50 mb-2 line-clamp-2 group-hover:text-lavender-light transition-colors">
                                        {post.title}
                                    </h3>
                                    <div className="flex items-center gap-4 text-xs text-slate-400 mb-3">
                                        <span className="flex items-center gap-1">
                                            <Calendar size={12} />
                                            {formatDate(post.pubDate)}
                                        </span>
                                        <span className="flex items-center gap-1">
                                            <User size={12} />
                                            {post.author}
                                        </span>
                                    </div>
                                    <p className="text-sm text-slate-200 line-clamp-4 leading-relaxed">
                                        {stripHtml(post.description)}
                                    </p>
                                </div>

                                <div className="mt-auto pt-4 border-t border-white/5 flex items-center text-xs text-lavender-light font-medium gap-1">
                                    Read on Medium <ExternalLink size={12} />
                                </div>
                            </motion.a>
                        ))}
                    </div>
                )}

                {!loading && posts.length === 0 && (
                    <p className="text-slate-400">Articles couldn't be loaded right now.</p>
                )}

                {/* The feed only returns the 10 newest posts, so older ones live on Medium */}
                {!loading && (
                    <div className="mt-10 text-center">
                        <a
                            href={MEDIUM_PROFILE_URL}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex items-center justify-center rounded-full border border-violet-300/30 text-violet-100 text-sm px-6 py-2 bg-white/5 hover:bg-white/10 transition-colors"
                        >
                            See every article on Medium <ExternalLink size={16} className="ml-2" />
                        </a>
                    </div>
                )}
            </div>
        </div>
    );
};

export default BlogsPage;
