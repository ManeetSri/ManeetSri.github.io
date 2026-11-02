import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { Activity, FileText, GitCommitHorizontal, History, House, LayoutGrid, MessageCircle } from 'lucide-react';
import { useLocation, useNavigate } from 'react-router-dom';

const TABS = [
    { id: 'top', name: 'Home', icon: House },
    { id: 'journey', name: 'Journey', icon: History },
    { id: 'work', name: 'Work', icon: LayoutGrid },
    { id: 'skills', name: 'Skills', icon: Activity },
    { id: 'notes', name: 'Notes', icon: GitCommitHorizontal },
    { id: 'contact', name: 'Contact', icon: MessageCircle },
];

const TabBar = () => {
    const { pathname } = useLocation();
    const navigate = useNavigate();
    const [visible, setVisible] = useState('top');
    const current = pathname === '/' ? visible : pathname === '/blogs' ? 'notes' : null;

    // The active tab is whichever section crosses the middle of the screen
    useEffect(() => {
        if (pathname !== '/') return undefined;
        const observer = new IntersectionObserver((entries) => {
            entries.forEach((entry) => {
                if (entry.isIntersecting) setVisible(entry.target.dataset.tab ?? entry.target.id);
            });
        }, { rootMargin: '-50% 0px -50% 0px' });
        [...TABS.map(({ id }) => id), 'services'].forEach((id) => {
            const section = document.getElementById(id);
            if (section) observer.observe(section);
        });
        return () => observer.disconnect();
    }, [pathname]);

    const goTo = (event, id) => {
        event.preventDefault();
        if (pathname === '/') {
            document.getElementById(id)?.scrollIntoView();
        } else {
            navigate(`/#${id}`);
        }
    };

    return (
        <nav
            aria-label="Sections"
            className="phone-ui fixed bottom-3 left-1/2 z-50 flex -translate-x-1/2 items-center gap-0.5 rounded-full border border-line bg-surface/80 p-1 shadow-2xl shadow-black/60 backdrop-blur-xl"
        >
            {TABS.map(({ id, name, icon: Icon }) => (
                <a
                    key={id}
                    href={`/#${id}`}
                    onClick={(event) => goTo(event, id)}
                    aria-label={name}
                    aria-current={current === id ? 'location' : undefined}
                    className={`relative flex h-11 min-w-10 items-center justify-center gap-1.5 rounded-full px-1.5 text-sm transition-colors min-[390px]:min-w-11 min-[390px]:px-2.5 lg:px-3.5 ${current === id ? 'text-ink' : 'text-muted hover:text-paper'}`}
                >
                    {current === id && (
                        <motion.span
                            layoutId="active-tab"
                            transition={{ type: 'spring', stiffness: 420, damping: 36 }}
                            className="absolute inset-0 rounded-full bg-paper"
                        />
                    )}
                    <Icon size={18} className="relative shrink-0" aria-hidden="true" />
                    <span className={`relative text-xs font-medium lg:inline lg:text-sm ${current === id ? 'hidden min-[375px]:inline' : 'hidden'}`}>{name}</span>
                </a>
            ))}
            <a
                href="/resume.pdf"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Resume (PDF)"
                className="swift-gradient ml-0.5 flex h-11 min-w-10 items-center justify-center gap-1.5 rounded-full px-1.5 text-sm font-semibold text-ink min-[390px]:min-w-11 min-[390px]:px-2.5 lg:px-3.5"
            >
                <FileText size={18} className="shrink-0" aria-hidden="true" />
                <span className="hidden lg:inline">Resume</span>
            </a>
        </nav>
    );
};

export default TabBar;
