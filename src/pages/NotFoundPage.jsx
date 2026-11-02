import React from 'react';
import { ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useDocumentTitle } from '../hooks/useDocumentTitle';

const NotFoundPage = () => {
    useDocumentTitle('Page not found – Maneet Srivastav');

    return (
        <main className="min-h-screen flex items-center justify-center px-4 sm:px-6 text-center">
            <div>
                <p className="text-xs tracking-[0.28em] uppercase text-lavender-light mb-3 font-medium">404</p>
                <h1 className="text-4xl font-bold text-slate-50 mb-4">Page not found</h1>
                <p className="text-slate-300 mb-8">This page doesn't exist or may have moved.</p>
                <Link to="/" className="inline-flex items-center text-lavender-light hover:text-white transition-colors">
                    <ArrowLeft size={20} className="mr-2" />
                    Back to Home
                </Link>
            </div>
        </main>
    );
};

export default NotFoundPage;
