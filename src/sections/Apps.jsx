import React, { useRef } from 'react';
import { motion, useScroll, useTransform } from 'framer-motion';

const Apps = () => {
    const scrollRef = useRef(null);

    const apps = [
        { id: 1, image: '/assets/1.png', alt: 'App UI 1' },
        { id: 2, image: '/assets/2.png', alt: 'App UI 2' },
        { id: 3, image: '/assets/3.png', alt: 'App UI 3' },
    ];

    return (
        <section id="apps" className="max-w-7xl mx-auto px-4 sm:px-6 pt-24 pb-20">
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
            >
                <h2 className="text-3xl font-semibold text-slate-50 mb-2">App interfaces</h2>
                <p className="text-sm text-slate-300 mb-8">Selected UI from ride-hailing, ecommerce & community products.</p>

                <div
                    ref={scrollRef}
                    className="flex gap-5 overflow-x-auto pb-6 snap-x snap-mandatory no-scrollbar"
                    style={{ scrollBehavior: 'smooth' }}
                >
                    {apps.map((app, index) => (
                        <motion.div
                            key={app.id}
                            initial={{ opacity: 0, scale: 0.9 }}
                            whileInView={{ opacity: 1, scale: 1 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.5, delay: index * 0.1 }}
                            className="min-w-[280px] sm:min-w-[320px] snap-center aspect-[9/16] rounded-[2rem] bg-black border border-slate-700 shadow-2xl overflow-hidden relative group"
                        >
                            <img
                                src={app.image}
                                alt={app.alt}
                                className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-105"
                            />
                            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                        </motion.div>
                    ))}
                </div>
            </motion.div>
        </section>
    );
};

export default Apps;
