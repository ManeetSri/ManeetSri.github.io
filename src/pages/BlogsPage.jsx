import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, ArrowLeft, Calendar, User } from 'lucide-react';
import { Link } from 'react-router-dom';

const BlogsPage = () => {
    const [posts, setPosts] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchPosts = async () => {
            try {
                // Fetching from Medium RSS via rss2json
                const response = await fetch(
                    'https://api.rss2json.com/v1/api.json?rss_url=https://medium.com/feed/@maneetsrivastav'
                );
                const data = await response.json();
                if (data.status === 'ok') {
                    setPosts(data.items); // Display all posts
                }
            } catch (error) {
                console.error('Error fetching Medium posts:', error);
            } finally {
                setLoading(false);
            }
        };

        fetchPosts();
    }, []);

    const stripHtml = (html) => {
        const doc = new DOMParser().parseFromString(html, 'text/html');
        return doc.body.textContent || "";
    };

    const formatDate = (dateString) => {
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

    return (
        <div className="min-h-screen bg-[#1d1b26] pt-24 pb-20 px-4 sm:px-6">
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
                    <p className="text-slate-400">No articles found.</p>
                )}
            </div>
        </div>
    );
};

export default BlogsPage;
