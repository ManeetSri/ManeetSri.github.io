import React from 'react';
import { motion } from 'framer-motion';
import SpotlightCard from '../components/SpotlightCard';

const Skills = () => {
    const skillGroups = [
        { name: 'Languages', items: ['Swift', 'JavaScript'] },
        { name: 'UI Frameworks', items: ['SwiftUI', 'UIKit', 'React Native'] },
        { name: 'Architecture', items: ['MVVM', 'MVC', 'Dependency Injection'] },
        { name: 'Data & Backend', items: ['Core Data', 'Firebase', 'MongoDB', 'APNs', 'Alamofire'] },
        { name: 'Tools', items: ['Xcode', 'Instruments', 'Swift Package Manager', 'CocoaPods', 'VS Code'] },
    ];

    return (
        <section id="skills" className="max-w-7xl mx-auto px-4 sm:px-6 pb-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">Skills & Expertise</h2>
                <p className="text-sm text-slate-300 mb-8">Specialized in building complex, high-performance mobile ecosystems.</p>

                <div className="grid md:grid-cols-2 gap-6 md:gap-10">

                    {/* Grouped Skills */}
                    <SpotlightCard className="rounded-3xl p-6">
                        <h3 className="text-sm font-semibold text-lavender-light mb-5">Core Competencies</h3>

                        {skillGroups.map((group) => (
                            <div key={group.name} className="mb-5 last:mb-0">
                                <p className="text-sm text-slate-100 mb-2">{group.name}</p>
                                <div className="flex flex-wrap gap-2">
                                    {group.items.map((item) => (
                                        <span key={item} className="pill">{item}</span>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </SpotlightCard>

                    <div className="grid gap-6">
                        <SpotlightCard
                            whileHover={{ y: -5 }}
                            className="rounded-2xl p-6"
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
                                    <span><strong>AI & Media:</strong> Interfaces for AI-based job matching and in-app video resume recording.</span>
                                </li>
                            </ul>
                        </SpotlightCard>

                        <SpotlightCard
                            whileHover={{ y: -5 }}
                            className="rounded-2xl p-6"
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
                                    <span><strong>App Store Delivery:</strong> Taking apps through submission and release, in line with App Store policies.</span>
                                </li>
                            </ul>
                        </SpotlightCard>
                    </div>

                </div>
            </motion.div>
        </section>
    );
};

export default Skills;
