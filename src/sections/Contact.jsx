import React from 'react';
import { Mail, Github, Linkedin, FileText } from 'lucide-react';

const Contact = () => {
    return (
        <section id="contact" className="border-t border-white/10 bg-[#161320]/95">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
                <div className="grid md:grid-cols-[2fr,1.3fr] gap-8 items-start">
                    <div>
                        <h2 className="text-3xl font-semibold text-slate-50 mb-3">Let’s connect</h2>
                        <p className="text-sm text-slate-300 mb-6 max-w-xl leading-relaxed">
                            Open to roles and collaborations around mobility, logistics, ecommerce and
                            user-centric mobile products. Happy to talk architecture, performance and product trade-offs.
                        </p>
                    </div>

                    <div className="space-y-3 text-sm text-slate-100">
                        <a href="mailto:srivastavmaneet@gmail.com" className="flex items-center gap-3 hover:text-lavender-light transition-colors group">
                            <Mail size={18} className="text-slate-400 group-hover:text-lavender-light" />
                            <span>Email: <span className="font-medium">srivastavmaneet@gmail.com</span></span>
                        </a>

                        <a href="https://github.com/ManeetSri" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group">
                            <Github size={18} className="text-slate-400 group-hover:text-lavender-light" />
                            <span>GitHub: <span className="font-medium">github.com/ManeetSri</span></span>
                        </a>

                        <a href="https://www.linkedin.com/in/maneet-srivastav-1499a1196/" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group">
                            <Linkedin size={18} className="text-slate-400 group-hover:text-lavender-light" />
                            <span>LinkedIn: <span className="font-medium">/in/maneet-srivastav-1499a1196</span></span>
                        </a>

                        <a href="https://medium.com/@maneetsrivastav" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group">
                            <FileText size={18} className="text-slate-400 group-hover:text-lavender-light" />
                            <span>Blog: <span className="font-medium">@maneetsrivastav</span></span>
                        </a>
                    </div>
                </div>

                <p className="mt-12 text-[11px] text-slate-400 border-t border-white/5 pt-8">
                    © 2025 · Designed & built by <span className="text-lavender-light font-medium">Maneet Srivastav</span>
                </p>
            </div>
        </section>
    );
};

export default Contact;
