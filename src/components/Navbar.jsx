import React, { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { Link, useLocation, useNavigate } from 'react-router-dom';

const Navbar = () => {
    const [isOpen, setIsOpen] = useState(false);
    const [scrolled, setScrolled] = useState(false);
    const location = useLocation();
    const navigate = useNavigate();

    useEffect(() => {
        const handleScroll = () => {
            setScrolled(window.scrollY > 20);
        };
        window.addEventListener('scroll', handleScroll);
        return () => window.removeEventListener('scroll', handleScroll);
    }, []);

    const handleNavClick = (e, href) => {
        setIsOpen(false);
        if (href.startsWith('#')) {
            e.preventDefault();

            const scrollToElement = () => {
                const element = document.querySelector(href);
                if (element) {
                    const offsetTop = element.offsetTop - 80; // Adjust for fixed header height
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                }
            };

            if (location.pathname !== '/') {
                navigate('/');
                setTimeout(scrollToElement, 300);
            } else {
                // Small delay to allow mobile menu to close smoothly before scrolling starts
                setTimeout(scrollToElement, 300);
            }
        }
    };

    const navLinks = [
        { name: 'Skills', href: '#skills' },
        { name: 'Blogs', href: '/blogs' },
        { name: 'Experience', href: '#timeline' },
        { name: 'Projects', href: '/projects' },
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
                <Link to="/" className="flex items-center gap-3">
                    <div className="h-9 w-9 rounded-2xl bg-gradient-to-br from-lavender to-lavender-deep text-white flex items-center justify-center text-sm font-semibold shadow-lg">
                        MS
                    </div>
                    <div className="flex flex-col">
                        <span className="text-sm font-semibold text-slate-50">Maneet Srivastav</span>
                        <span className="text-[11px] text-slate-300">Mobile Application Engineer</span>
                    </div>
                </Link>

                {/* Desktop Nav */}
                <nav className="hidden md:flex items-center gap-8">
                    <div className="flex items-center gap-6 text-sm text-slate-200">
                        {navLinks.map((link) => (
                            link.href.startsWith('#') ? (
                                <a
                                    key={link.name}
                                    href={link.href}
                                    onClick={(e) => handleNavClick(e, link.href)}
                                    className="hover:text-lavender-light transition-colors duration-200 cursor-pointer"
                                >
                                    {link.name}
                                </a>
                            ) : (
                                <Link
                                    key={link.name}
                                    to={link.href}
                                    className="hover:text-lavender-light transition-colors duration-200"
                                >
                                    {link.name}
                                </Link>
                            )
                        ))}
                    </div>

                    <a
                        href="#contact"
                        onClick={(e) => handleNavClick(e, '#contact')}
                        className="px-5 py-2.5 rounded-full bg-gradient-to-r from-lavender to-lavender-deep text-white text-sm font-medium hover:shadow-[0_0_20px_rgba(180,151,255,0.3)] transition-all duration-300 hover:scale-105"
                    >
                        Get in Touch
                    </a>
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
                        transition={{ duration: 0.3, ease: "easeInOut" }}
                        className="md:hidden bg-[#161320] border-b border-white/10 shadow-2xl overflow-hidden relative"
                    >
                        {/* Decorative gradient line */}
                        <div className="absolute top-0 left-0 right-0 h-[1px] bg-gradient-to-r from-transparent via-lavender/50 to-transparent" />

                        <div className="px-6 py-8 flex flex-col gap-6">
                            {navLinks.map((link, index) => (
                                <motion.div
                                    key={link.name}
                                    initial={{ x: -20, opacity: 0 }}
                                    animate={{ x: 0, opacity: 1 }}
                                    transition={{ delay: 0.1 + (index * 0.1) }}
                                >
                                    {link.href.startsWith('#') ? (
                                        <a
                                            href={link.href}
                                            onClick={(e) => handleNavClick(e, link.href)}
                                            className="text-slate-300 text-lg font-medium hover:text-white transition-colors cursor-pointer block p-2 hover:bg-white/5 rounded-xl"
                                        >
                                            {link.name}
                                        </a>
                                    ) : (
                                        <Link
                                            to={link.href}
                                            onClick={() => setIsOpen(false)}
                                            className="text-slate-300 text-lg font-medium hover:text-white transition-colors block p-2 hover:bg-white/5 rounded-xl"
                                        >
                                            {link.name}
                                        </Link>
                                    )}
                                </motion.div>
                            ))}
                            <motion.div
                                initial={{ y: 20, opacity: 0 }}
                                animate={{ y: 0, opacity: 1 }}
                                transition={{ delay: 0.5 }}
                                className="pt-4"
                            >
                                <a
                                    href="#contact"
                                    onClick={(e) => handleNavClick(e, '#contact')}
                                    className="block w-full py-4 rounded-xl bg-gradient-to-r from-lavender to-lavender-deep text-white text-base font-bold text-center shadow-lg shadow-lavender/20 active:scale-95 transition-all"
                                >
                                    Get in Touch
                                </a>
                            </motion.div>
                        </div>
                    </motion.nav>
                )}
            </AnimatePresence>
        </motion.header>
    );
};

export default Navbar;
