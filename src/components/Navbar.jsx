import React, { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';

const Navbar = () => {
    const [isOpen, setIsOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);

    useEffect(() => {
        const handleScroll = () => {
            setScrolled(window.scrollY > 20);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const navLinks = [
        { name: 'Skills', href: '#skills' },
        { name: 'Blogs', href: '#blogs' },
        { name: 'Projects', href: '#projects' },
        { name: 'Experience', href: '#timeline' },
        { name: 'Contact', href: '#contact' },
    ];

    return (
        <motion.header
            initial={{ y: -100 }}
            animate={{ y: 0 }}
            transition={{ duration: 0.5 }}
            className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled ? 'bg-[#1a1823]/85 backdrop-blur-md border-b border-white/10 shadow-lg' : 'bg-transparent'
                }`}
        >
            <div className="max-w-7xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between">
                {/* Branding */}
                <div className="flex items-center gap-3">
                    <div className="h-9 w-9 rounded-2xl bg-gradient-to-br from-lavender to-lavender-deep text-white flex items-center justify-center text-sm font-semibold shadow-lg">
                        MS
                    </div>
                    <div className="flex flex-col">
                        <span className="text-sm font-semibold text-slate-50">Maneet Srivastav</span>
                        <span className="text-[11px] text-slate-300">Mobile Application Engineer</span>
                    </div>
                </div>

                {/* Desktop Nav */}
                <nav className="hidden md:flex items-center gap-6 text-sm text-slate-200">
                    {navLinks.map((link) => (
                        <a
                            key={link.name}
                            href={link.href}
                            className="hover:text-lavender-light transition-colors duration-200"
                        >
                            {link.name}
                        </a>
                    ))}
                </nav>

                {/* Mobile Menu Button */}
                <button
                    onClick={() => setIsOpen(!isOpen)}
                    className="md:hidden text-slate-200 hover:text-white focus:outline-none"
                >
                    {isOpen ? <X size={28} /> : <Menu size={28} />}
                </button>
            </div>

            {/* Mobile Nav */}
            <AnimatePresence>
                {isOpen && (
                    <motion.nav
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="md:hidden bg-[#1d1b26]/95 backdrop-blur-xl border-t border-white/10 overflow-hidden"
                    >
                        <div className="px-6 py-4 flex flex-col gap-4">
                            {navLinks.map((link) => (
                                <a
                                    key={link.name}
                                    href={link.href}
                                    onClick={() => setIsOpen(false)}
                                    className="text-slate-200 text-base hover:text-lavender-light transition-colors"
                                >
                                    {link.name}
                                </a>
                            ))}
                        </div>
                    </motion.nav>
                )}
            </AnimatePresence>
        </motion.header>
    );
};

export default Navbar;
