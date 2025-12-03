import React from 'react';
import { motion } from 'framer-motion';

const Projects = () => {
    const projects = [
        {
            title: '🛒 Best Al-Yousif — E-commerce platform',
            description: 'Kuwait-based retail app with 10,000+ products, advanced discovery, multi-payment support and loyalty mechanics like vouchers, flash deals and cashback.',
            tags: ['Swift', 'SwiftUI', 'Firebase']
        },
        {
            title: '💼 Imperium Jobs — AI job platform',
            description: 'AI-powered job discovery with swipe-based matching, video introductions, calendar integration and subscription-based swipe limits.',
            tags: ['SwiftUI', 'Firebase']
        },
        {
            title: '🚖 Prominence Services & Prompt Driver',
            description: 'Dual app suite — limousine booking for customers and driver app for chauffeurs, with routes, schedules, earnings and real-time notifications.',
            tags: ['SwiftUI', 'Firebase']
        },
        {
            title: '🙏 Spiritual Quotient — Prayer & fellowship',
            description: 'Faith-focused platform that helps users create and track prayers, consume spiritual content and connect with supportive communities.',
            tags: ['SwiftUI', 'Firebase']
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
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">Highlighted projects</h2>
                <p className="text-sm text-slate-300 mb-10">A few products that represent my work.</p>

                <div className="grid lg:grid-cols-2 gap-8">
                    {projects.map((project, index) => (
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
            </motion.div>
        </section>
    );
};

export default Projects;
