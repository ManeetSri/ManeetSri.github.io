import React from 'react';
import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { ArrowRight, ExternalLink, Github } from 'lucide-react';
import SpotlightCard from '../components/SpotlightCard';
import { projects } from '../data/projects';

const Projects = () => {
    const featuredProjects = projects.filter((project) => project.featured);

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

                <div className="grid lg:grid-cols-2 gap-6 lg:gap-8">
                    {featuredProjects.map((project, index) => (
                        <SpotlightCard
                            key={project.title}
                            as={motion.a}
                            href={project.link}
                            target="_blank"
                            rel="noopener noreferrer"
                            initial={{ opacity: 0, y: 20 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            whileHover={{ y: -5 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.5, delay: index * 0.1 }}
                            className="block rounded-3xl p-6 group"
                        >
                            <p className="text-xs text-lavender-light mb-1">{project.category}</p>
                            <h3 className="text-slate-50 font-semibold mb-2 group-hover:text-lavender-light transition-colors">{project.title}</h3>
                            <p className="text-sm text-slate-200 mb-3 leading-relaxed">
                                {project.summary}
                            </p>
                            <div className="flex flex-wrap gap-2 text-xs text-slate-100 mb-4">
                                {project.tags.map(tag => (
                                    <span key={tag} className="pill">{tag}</span>
                                ))}
                            </div>
                            <div className="flex items-center text-xs text-lavender-light font-medium gap-1">
                                {project.link.includes('github.com') ? (
                                    <>View on GitHub <Github size={12} /></>
                                ) : (
                                    <>View on App Store <ExternalLink size={12} /></>
                                )}
                            </div>
                        </SpotlightCard>
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
