import React from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, ArrowRight, Calendar, User } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useMediumPosts, stripHtml, formatDate, MEDIUM_PROFILE_URL } from '../hooks/useMediumPosts';

const Blogs = () => {
    const { posts: allPosts, loading } = useMediumPosts();
    const posts = allPosts.slice(0, 3); // Display top 3 posts

    return (
        <section id="blogs" className="max-w-7xl mx-auto px-4 sm:px-6 pb-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">Latest Articles</h2>
                <p className="text-sm text-slate-300 mb-10">Thoughts on mobile engineering and tech.</p>

                {loading ? (
                    <div className="flex justify-center py-10">
                        <div className="w-8 h-8 border-4 border-lavender border-t-transparent rounded-full animate-spin"></div>
                    </div>
                ) : (
                    <div className="grid md:grid-cols-3 gap-6 md:gap-8">
                        {posts.map((post, index) => (
                            <motion.a
                                key={index}
                                href={post.link}
                                target="_blank"
                                rel="noopener noreferrer"
                                initial={{ opacity: 0, y: 20 }}
                                whileInView={{ opacity: 1, y: 0 }}
                                whileHover={{ y: -5 }}
                                viewport={{ once: true }}
                                transition={{ duration: 0.5, delay: index * 0.1 }}
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
                                    <p className="text-sm text-slate-200 line-clamp-3 leading-relaxed">
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
                    <p className="text-slate-400 text-sm">
                        Articles couldn't be loaded right now.{' '}
                        <a href={MEDIUM_PROFILE_URL} target="_blank" rel="noopener noreferrer" className="text-lavender-light underline hover:text-white">
                            Read them on Medium
                        </a>.
                    </p>
                )}

                <div className="mt-8 text-center">
                    <Link
                        to="/blogs"
                        className="inline-flex items-center justify-center rounded-full border border-violet-300/30 text-violet-100 text-sm px-6 py-2 bg-white/5 hover:bg-white/10 transition-colors"
                    >
                        View all articles <ArrowRight size={16} className="ml-2" />
                    </Link>
                </div>
            </motion.div>
        </section>
    );
};

export default Blogs;
