import React from 'react';
import { motion } from 'framer-motion';

const Skills = () => {
    const skills = [
        { name: 'Swift / SwiftUI', level: 92, color: 'from-lavender to-lavender-deep' },
        { name: 'UIKit & iOS ecosystem', level: 88, color: 'from-lavender to-[#f973c7]' },
        { name: 'Architecture (MVC · MVVM)', level: 90, color: 'from-[#f973c7] to-lavender-deep' },
        { name: 'Firebase & realtime backends', level: 85, color: 'from-lavender to-[#38bdf8]' },
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
                <p className="text-sm text-slate-300 mb-8">A blend of mobile engineering, architecture & problem solving.</p>

                <div className="grid md:grid-cols-2 gap-10">

                    {/* Progress Skills */}
                    <div className="glass-card rounded-3xl p-6">
                        <h3 className="text-sm font-semibold text-lavender-light mb-5">Core technical skills</h3>

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
                            <h3 className="text-sm font-semibold text-lavender-light mb-3">Mobile engineering</h3>
                            <ul className="text-sm text-slate-200 space-y-1.5">
                                <li>• End-to-end feature ownership from idea to App Store.</li>
                                <li>• MapKit, geolocation & live ride tracking flows.</li>
                                <li>• Push notifications, deep links & background tasks.</li>
                                <li>• Clean, testable, modular codebases.</li>
                                <li>• In-app purchases & subscription journeys.</li>
                            </ul>
                        </motion.div>

                        <motion.div
                            whileHover={{ y: -5 }}
                            className="glass-card rounded-2xl p-6"
                        >
                            <h3 className="text-sm font-semibold text-lavender-light mb-3">Cloud & tools</h3>
                            <ul className="text-sm text-slate-200 space-y-1.5">
                                <li>• Firebase (Firestore, Auth, Realtime DB).</li>
                                <li>• MongoDB, REST APIs & integration patterns.</li>
                                <li>• Xcode, GitHub, Postman, Android Studio.</li>
                                <li>• Debugging, profiling & performance tuning.</li>
                            </ul>
                        </motion.div>
                    </div>

                </div>
            </motion.div>
        </section>
    );
};

export default Skills;
