import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';

const Projects = () => {
    const featuredProjects = [
        {
            title: 'Retail E-commerce Platform',
            description: 'A comprehensive online shopping application with advanced catalog, search, and loyalty integration.',
            tags: ['Swift', 'UIKit', 'E-commerce']
        },
        {
            title: 'AI Job Discovery Platform',
            description: 'Innovative job search app using AI matching, video intros, and smart scheduling.',
            tags: ['SwiftUI', 'AI', 'Business']
        },
        {
            title: 'Corporate Mobility Solution',
            description: 'Premium ride-hailing app for corporate users with real-time tracking and route optimization.',
            tags: ['Swift', 'Maps', 'Logistics']
        },
        {
            title: 'Faith & Community Platform',
            description: 'Spiritual lifestyle app for building prayer habits and connecting with community.',
            tags: ['SwiftUI', 'Lifestyle', 'Community']
        }
    ];

    return (
        <section id="projects" className="max-w-7xl mx-auto px-4 sm:px-6 pb-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <div className="mb-10">
                    <h2 className="text-3xl font-semibold text-slate-50 mb-2">Highlighted projects</h2>
                    <p className="text-sm text-slate-300">A few products that represent my work.</p>
                </div>

                <div className="grid lg:grid-cols-2 gap-8">
                    {featuredProjects.map((project, index) => (
                        <motion.article
                            key={index}
                            initial={{ opacity: 0, y: 20 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            whileHover={{ y: -5 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.5, delay: index * 0.1 }}
                            className="glass-card rounded-3xl p-6"
                        >
                            <h3 className="text-slate-50 font-semibold mb-2">{project.title}</h3>
                            <p className="text-sm text-slate-200 mb-3 leading-relaxed">
                                {project.description}
                            </p>
                            <div className="flex flex-wrap gap-2 text-[11px] text-slate-100">
                                {project.tags.map(tag => (
                                    <span key={tag} className="pill">{tag}</span>
                                ))}
                            </div>
                        </motion.article>
                    ))}
                </div>

                <div className="mt-8 text-center">
                    <Link
                        to="/projects"
                        className="inline-flex items-center justify-center rounded-full border border-violet-300/30 text-violet-100 text-sm px-6 py-2 bg-white/5 hover:bg-white/10 transition-colors"
                    >
                        View all projects <ArrowRight size={16} className="ml-2" />
                    </Link>
                </div>
            </motion.div>
        </section>
    );
};

export default Projects;
