import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, Calendar, User } from 'lucide-react';

const Blogs = () => {
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPosts = async () => {
            try {
                const response = await fetch(
                    'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@maneetsrivastav'
                );
                const data = await response.json();
                if (data.status === 'ok') {
                    setPosts(data.items.slice(0, 3)); // Display top 3 posts
                }
            } catch (error) {
                console.error('Error fetching Medium posts:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchPosts();
    }, []);

    // Helper to strip HTML tags for preview text
    const stripHtml = (html) => {
        const doc = new DOMParser().parseFromString(html, 'text/html');
        return doc.body.textContent || "";
    };

    // Helper to format date
    const formatDate = (dateString) => {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

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
                    <div className="grid md:grid-cols-3 gap-6">
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
                                className="glass-card rounded-3xl p-6 flex flex-col h-full group"
                            >
                                <div className="mb-4">
                                    <h3 className="text-lg font-semibold text-slate-50 mb-2 line-clamp-2 group-hover:text-lavender-light transition-colors">
                                        {post.title}
                                    </h3>
                                    <div className="flex items-center gap-4 text-[11px] text-slate-400 mb-3">
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
                    <p className="text-slate-400 text-sm">No articles found at the moment.</p>
                )}

                <div className="mt-8 text-center">
                    <a
                        href="https://medium.com/@maneetsrivastav"
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex items-center justify-center rounded-full border border-violet-300/30 text-violet-100 text-sm px-6 py-2 bg-white/5 hover:bg-white/10 transition-colors"
                    >
                        View all articles
                    </a>
                </div>
            </motion.div>
        </section>
    );
};

export default Blogs;
