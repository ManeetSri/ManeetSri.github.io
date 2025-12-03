import React from 'react';
import { motion } from 'framer-motion';

const Skills = () => {
    const skills = [
        { name: 'Swift / SwiftUI', level: 95, color: 'from-lavender to-lavender-deep' },
        { name: 'UIKit & iOS Internals', level: 90, color: 'from-lavender to-[#f973c7]' },
        { name: 'System Design & Architecture', level: 88, color: 'from-[#f973c7] to-lavender-deep' },
        { name: 'Backend & Cloud Integration', level: 85, color: 'from-lavender to-[#38bdf8]' },
    ];

    return (
        <section id="skills" className="max-w-7xl mx-auto px-4 sm:px-6 pb-18 py-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">Skills & Expertise</h2>
                <p className="text-sm text-slate-300 mb-8">Specialized in building complex, high-performance mobile ecosystems.</p>

                <div className="grid md:grid-cols-2 gap-10">

                    {/* Progress Skills */}
                    <div className="glass-card rounded-3xl p-6">
                        <h3 className="text-sm font-semibold text-lavender-light mb-5">Core Competencies</h3>

                        {skills.map((skill) => (
                            <div key={skill.name} className="mb-5 last:mb-0">
                                <div className="flex justify-between text-sm mb-1">
                                    <span className="text-slate-100">{skill.name}</span>
                                    <span className="text-slate-400">Advanced</span>
                                </div>
                                <div className="h-2 rounded-full bg-slate-800 overflow-hidden">
                                    <motion.div
                                        initial={{ width: 0 }}
                                        whileInView={{ width: `${skill.level}%` }}
                                        viewport={{ once: true }}
                                        transition={{ duration: 1.2, ease: "easeOut" }}
                                        className={`h-2 rounded-full bg-gradient-to-r ${skill.color}`}
                                    />
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Descriptive Skills */}
                    <div className="grid gap-6">
                        <motion.div
                            whileHover={{ y: -5 }}
                            className="glass-card rounded-2xl p-6"
                        >
                            <h3 className="text-sm font-semibold text-lavender-light mb-3">Domain Expertise</h3>
                            <ul className="text-sm text-slate-200 space-y-2">
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>E-commerce & Payments:</strong> Secure checkout flows, loyalty systems, and complex product catalogs.</span>
                                </li>
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>Maps & Logistics:</strong> Real-time ride tracking, route optimization, and geolocation services.</span>
                                </li>
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>AI & Media:</strong> AI-driven matching algorithms, video processing, and smart interfaces.</span>
                                </li>
                            </ul>
                        </motion.div>

                        <motion.div
                            whileHover={{ y: -5 }}
                            className="glass-card rounded-2xl p-6"
                        >
                            <h3 className="text-sm font-semibold text-lavender-light mb-3">Advanced Engineering</h3>
                            <ul className="text-sm text-slate-200 space-y-2">
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>Complex Interactions:</strong> Custom gesture-driven UIs (swipe flows) and smooth animations.</span>
                                </li>
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>Real-time Systems:</strong> WebSocket integration for chat, live updates, and sync.</span>
                                </li>
                                <li className="flex gap-2">
                                    <span className="text-lavender">•</span>
                                    <span><strong>App Store Optimization:</strong> Managing full lifecycles for high-traffic apps.</span>
                                </li>
                            </ul>
                        </motion.div>
                    </div>

                </div>
            </motion.div>
        </section>
    );
};

export default Skills;
