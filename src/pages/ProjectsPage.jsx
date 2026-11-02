import React from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, ArrowLeft, Github } from 'lucide-react';
import { Link } from 'react-router-dom';
import { projects } from '../data/projects';
import { useDocumentTitle } from '../hooks/useDocumentTitle';

const ProjectsPage = () => {
    useDocumentTitle('Projects – Maneet Srivastav');

    return (
        <div className="min-h-screen pt-24 pb-20 px-4 sm:px-6">
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
                        All Projects
                    </motion.h1>
                    <motion.p
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="text-slate-300 max-w-2xl"
                    >
                        A collection of mobile applications I've engineered, ranging from e-commerce and logistics to education and community platforms.
                    </motion.p>
                </div>

                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                    {projects.map((project, index) => {
                        const Card = project.link ? motion.a : motion.div;
                        const linkProps = project.link
                            ? { href: project.link, target: '_blank', rel: 'noopener noreferrer' }
                            : {};

                        return (
                            <Card
                                key={project.title}
                                {...linkProps}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                transition={{ delay: index * 0.1 }}
                                whileHover={{ y: -5 }}
                                className="glass-card rounded-3xl p-6 flex flex-col h-full group"
                            >
                                <p className="text-xs text-lavender-light mb-1">{project.category}</p>
                                <h3 className="text-xl font-semibold text-slate-50 mb-3 group-hover:text-lavender-light transition-colors">
                                    {project.title}
                                </h3>
                                <p className="text-sm text-slate-200 mb-6 leading-relaxed flex-grow">
                                    {project.description}
                                </p>

                                <div className="mt-auto">
                                    <div className="flex flex-wrap gap-2 mb-4">
                                        {project.tags.map(tag => (
                                            <span key={tag} className="pill">
                                                {tag}
                                            </span>
                                        ))}
                                    </div>
                                    {project.link && (
                                        <div className="pt-4 border-t border-white/5 flex items-center text-xs text-lavender-light font-medium gap-1">
                                            {project.link.includes('github.com') ? (
                                                <>View on GitHub <Github size={12} /></>
                                            ) : (
                                                <>View on App Store <ExternalLink size={12} /></>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </Card>
                        );
                    })}
                </div>
            </div>
        </div>
    );
};

export default ProjectsPage;
