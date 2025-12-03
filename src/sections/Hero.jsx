import React, { useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';

const Hero = () => {
    const ref = useRef(null);
    const { scrollY } = useScroll();
    const y1 = useTransform(scrollY, [0, 500], [0, 100]);
    const y2 = useTransform(scrollY, [0, 500], [0, -100]);

    return (
        <section ref={ref} className="relative overflow-hidden min-h-screen flex items-center pt-20">
            {/* Parallax Blobs */}
            <div className="pointer-events-none absolute inset-0 -z-10 opacity-70">
                <motion.div
                    style={{ y: y1 }}
                    className="absolute -top-32 -left-16 w-80 h-80 rounded-full bg-lavender blur-3xl"
                />
                <motion.div
                    style={{ y: y2 }}
                    className="absolute -bottom-40 right-0 w-96 h-96 rounded-full bg-[#5b3bd9] blur-[110px] opacity-80"
                />
                <div className="absolute top-24 right-1/3 w-72 h-72 rounded-full bg-[#ff7fd7] blur-[120px] opacity-75" />
            </div>

            <div className="max-w-7xl mx-auto px-4 sm:px-6 py-20 w-full">
                <div className="grid md:grid-cols-2 gap-12 items-center">

                    {/* Left Content */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.8, ease: "easeOut" }}
                    >
                        <p className="text-[11px] tracking-[0.28em] uppercase text-lavender-light mb-3 font-medium">
                            iOS · Swift · SwiftUI · React Native
                        </p>

                        <h1 className="text-4xl sm:text-5xl font-semibold tracking-tight text-slate-50 mb-4 leading-tight">
                            Building scalable, elegant & reliable mobile applications.
                        </h1>

                        <p className="text-[15px] text-slate-200 leading-relaxed mb-7 max-w-xl">
                            I’m <span className="font-semibold text-white">Maneet Srivastav</span>, currently{' '}
                            <span className="font-semibold text-white">
                                Assistant Manager – IT (Mobile Applications) at Mahindra Logistics
                            </span>.
                            I design and ship production-grade iOS apps using Swift, SwiftUI, UIKit, React Native and Firebase,
                            with a strong focus on architecture, performance and user experience.
                        </p>

                        <div className="flex flex-wrap gap-3 mb-6">
                            <a
                                href="https://github.com/ManeetSri"
                                target="_blank"
                                rel="noreferrer"
                                className="inline-flex items-center justify-center rounded-full bg-white text-slate-900 text-sm font-medium px-5 py-2.5 shadow-md hover:bg-slate-100 transition-colors"
                            >
                                View GitHub
                            </a>
                            <a
                                href="#contact"
                                className="inline-flex items-center justify-center rounded-full border border-violet-300/60 text-violet-50 text-sm px-5 py-2.5 bg-white/5 hover:bg-white/10 transition-colors"
                            >
                                Contact Me
                            </a>
                        </div>

                        <div className="flex flex-wrap gap-2">
                            {['Swift · SwiftUI · UIKit', 'Ride-hailing & Logistics', 'E-commerce & Platforms'].map((tag) => (
                                <span key={tag} className="pill">
                                    {tag}
                                </span>
                            ))}
                        </div>
                    </motion.div>

                    {/* Right Card */}
                    <motion.div
                        initial={{ opacity: 0, x: 30 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
                        className="flex justify-center md:justify-end"
                    >
                        <div className="glass-card rounded-3xl p-6 w-full max-w-md transform transition-all hover:scale-[1.02]">
                            <p className="text-[11px] font-semibold tracking-[0.25em] uppercase text-slate-300 mb-4">
                                Snapshot
                            </p>
                            <div className="space-y-4 text-sm text-slate-100">
                                <div className="flex justify-between gap-4">
                                    <span className="text-slate-300">Current Role</span>
                                    <span className="font-semibold text-right text-white">
                                        Assistant Manager – IT<br />Mahindra Logistics
                                    </span>
                                </div>
                                <div className="flex justify-between">
                                    <span className="text-slate-300">Experience</span>
                                    <span className="font-semibold text-white">3+ years</span>
                                </div>
                                <div className="flex justify-between gap-4">
                                    <span className="text-slate-300">Focus</span>
                                    <span className="font-semibold text-right text-white">
                                        iOS Apps · Architecture<br />Mobility & Logistics
                                    </span>
                                </div>
                            </div>
                            <p className="mt-5 pt-4 border-t border-violet-300/40 text-[11px] text-slate-300">
                                Previously at Singsys, JamTech & Synclovis — delivering multi-domain mobile apps and mentoring junior engineers.
                            </p>
                        </div>
                    </motion.div>

                </div>
            </div>
        </section>
    );
};

export default Hero;
