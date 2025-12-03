import React from 'react';
import { motion } from 'framer-motion';

const Experience = () => {
    const experiences = [
        {
            role: 'Assistant Manager – IT (Specialist – Mobile Application)',
            company: 'Mahindra Logistics',
            period: 'Sept 2025 – Present · Gurugram',
            description: 'Building and optimizing enterprise mobility apps using Swift, Core Data and MVC-based architectures. Focused on scalable workflows for logistics & operations teams.',
            color: 'from-lavender to-lavender-deep'
        },
        {
            role: 'Software Engineer',
            company: 'Singsys',
            period: 'May 2024 – May 2025 · Lucknow',
            description: 'Delivered multi-domain apps using Swift, SwiftUI & React Native. Architected and shipped a complete ride-hailing ecosystem (user & driver apps) with maps, routing, payments and real-time updates.',
            color: 'bg-lavender-deep'
        },
        {
            role: 'Associate iOS Developer',
            company: 'JamTech Technologies',
            period: 'Dec 2023 – May 2024 · Lucknow',
            description: 'Developed a job-board iOS app with video resume recording, swipe-based discovery and in-app purchase flows.',
            color: 'bg-[#7dd3fc]'
        },
        {
            role: 'Software Engineer',
            company: 'Synclovis Systems',
            period: 'Nov 2022 – Nov 2023 · Bengaluru',
            description: 'Started my iOS journey with SwiftUI & UIKit, working on e-commerce features and school management flows, building strong foundations in architecture and delivery.',
            color: 'bg-[#22c1ee]'
        }
    ];

    return (
        <section id="timeline" className="max-w-7xl mx-auto px-4 sm:px-6 pb-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">Experience</h2>
                <p className="text-sm text-slate-300 mb-8">Roles that shaped how I think about product & engineering.</p>

                <div className="relative border-l-2 border-indigo-200/20 ml-3 pl-8 md:ml-6 md:pl-10 space-y-12">
                    {experiences.map((exp, index) => (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -20 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.5, delay: index * 0.1 }}
                            className="relative"
                        >
                            <div className={`absolute -left-[2.65rem] top-1.5 h-3.5 w-3.5 rounded-full border-[3px] border-black/30 outline outline-4 outline-lavender/15 ${exp.color.includes('gradient') ? `bg-gradient-to-br ${exp.color}` : exp.color}`} />

                            <p className="text-[11px] uppercase tracking-wide text-slate-400 mb-1 pt-1">
                                {exp.period}
                            </p>
                            <h3 className="text-sm sm:text-base font-semibold text-slate-50">
                                {exp.role} <span className="text-slate-400">·</span> {exp.company}
                            </h3>
                            <p className="text-sm text-slate-200 mt-2 max-w-2xl leading-relaxed">
                                {exp.description}
                            </p>
                        </motion.div>
                    ))}
                </div>
            </motion.div>
        </section>
    );
};

export default Experience;
