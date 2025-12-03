import React from 'react';
import { motion } from 'framer-motion';
import { ExternalLink, ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';

const ProjectsPage = () => {
    const projects = [
        {
            title: 'Retail E-commerce Platform',
            description: 'A comprehensive online shopping application for a major retailer. Features include a vast product catalog, advanced search and filtering, secure checkout, order tracking, and loyalty program integration. Optimized for performance and user retention.',
            tags: ['Swift', 'UIKit', 'E-commerce'],
            link: 'https://apps.apple.com/us/app/best-al-yousifi/id6444858752'
        },
        {
            title: 'School Management System (Parent App)',
            description: 'A dedicated mobile application for parents to stay connected with their child\'s education. Features include attendance tracking, homework updates, fee payments, and direct communication with teachers.',
            tags: ['Swift', 'Education', 'Management'],
            link: 'https://apps.apple.com/in/app/bluewings-parent/id1193120403'
        },
        {
            title: 'AI Job Discovery Platform',
            description: 'An innovative job search application utilizing AI for candidate matching. Features a swipe-based interface for quick applications, video introductions, calendar integration for interviews, and subscription models.',
            tags: ['SwiftUI', 'AI', 'Business'],
            link: 'https://apps.apple.com/us/app/imperium-jobs-app/id6476145521'
        },
        {
            title: 'Faith & Community Platform',
            description: 'A spiritual lifestyle app designed to build prayer habits and foster community. Users can create prayer lists, track spiritual growth, and connect with a supportive network.',
            tags: ['SwiftUI', 'Lifestyle', 'Community'],
            link: 'https://apps.apple.com/us/app/spiritual-quotient/id1616868583'
        },
        {
            title: 'Holistic Health & Wellness App',
            description: 'A wellness application focused on resetting and revitalizing health. Provides resources, tracking tools, and personalized guidance for users on their health journey.',
            tags: ['Swift', 'Health', 'Wellness'],
            link: 'https://apps.apple.com/in/app/bodyinc/id1534707316'
        },
        {
            title: 'Corporate Mobility & Ride-hailing',
            description: 'A premium urban mobility solution for corporate and individual users. Features include ride booking, real-time tracking, route optimization, and secure payment processing.',
            tags: ['Swift', 'Maps', 'Logistics'],
            link: 'https://apps.apple.com/in/app/alyte/id6745873281'
        }
    ];

    return (
        <div className="min-h-screen bg-[#1d1b26] pt-24 pb-20 px-4 sm:px-6">
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
                    {projects.map((project, index) => (
                        <motion.a
                            key={index}
                            href={project.link}
                            target="_blank"
                            rel="noopener noreferrer"
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: index * 0.1 }}
                            whileHover={{ y: -5 }}
                            className="glass-card rounded-3xl p-6 flex flex-col h-full group"
                        >
                            <h3 className="text-xl font-semibold text-slate-50 mb-3 group-hover:text-lavender-light transition-colors">
                                {project.title}
                            </h3>
                            <p className="text-sm text-slate-200 mb-6 leading-relaxed flex-grow">
                                {project.description}
                            </p>

                            <div className="mt-auto">
                                <div className="flex flex-wrap gap-2 mb-4">
                                    {project.tags.map(tag => (
                                        <span key={tag} className="pill text-[10px]">
                                            {tag}
                                        </span>
                                    ))}
                                </div>
                                <div className="pt-4 border-t border-white/5 flex items-center text-xs text-lavender-light font-medium gap-1">
                                    View on App Store <ExternalLink size={12} />
                                </div>
                            </div>
                        </motion.a>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default ProjectsPage;
