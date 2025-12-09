import React from 'react';
import { Mail, Github, Linkedin, FileText } from 'lucide-react';

const Contact = () => {
    const [formData, setFormData] = React.useState({
        name: '',
        email: '',
        message: ''
    });
    const [status, setStatus] = React.useState('');

    const handleChange = (e) => {
        setFormData({
            ...formData,
            [e.target.name]: e.target.value
        });
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        setStatus('sending');

        const encode = (data) => {
            return Object.keys(data)
                .map(key => encodeURIComponent(key) + "=" + encodeURIComponent(data[key]))
                .join("&");
        };

        fetch("/", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: encode({ "form-name": "contact", ...formData })
        })
            .then(() => {
                setStatus('success');
                setFormData({ name: '', email: '', message: '' });
                setTimeout(() => setStatus(''), 3000);
            })
            .catch(error => {
                console.error('Error:', error);
                setStatus('error');
            });
    };

    return (
        <section id="contact" className="border-t border-white/10 bg-[#161320]/95">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 py-12">
                <div className="grid md:grid-cols-[1fr,1.5fr] gap-12 items-start">
                    {/* Left Column - Contact Info */}
                    <div className="space-y-8">
                        <div>
                            <h2 className="text-3xl font-semibold text-slate-50 mb-3">Let’s connect</h2>
                            <p className="text-sm text-slate-300 leading-relaxed">
                                Open to roles and collaborations around mobility, logistics, ecommerce and
                                user-centric mobile products. Happy to talk architecture, performance and product trade-offs.
                            </p>
                        </div>

                        <div className="space-y-4 text-sm text-slate-100">
                            <a href="mailto:srivastavmaneet@gmail.com" className="flex items-center gap-3 hover:text-lavender-light transition-colors group p-2 hover:bg-white/5 rounded-lg -ml-2">
                                <Mail size={18} className="text-slate-400 group-hover:text-lavender-light" />
                                <span>Email: <span className="font-medium">srivastavmaneet@gmail.com</span></span>
                            </a>

                            <a href="https://github.com/ManeetSri" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group p-2 hover:bg-white/5 rounded-lg -ml-2">
                                <Github size={18} className="text-slate-400 group-hover:text-lavender-light" />
                                <span>GitHub: <span className="font-medium">github.com/ManeetSri</span></span>
                            </a>

                            <a href="https://www.linkedin.com/in/maneet-srivastav-1499a1196/" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group p-2 hover:bg-white/5 rounded-lg -ml-2">
                                <Linkedin size={18} className="text-slate-400 group-hover:text-lavender-light" />
                                <span>LinkedIn: <span className="font-medium">/in/maneet-srivastav-1499a1196</span></span>
                            </a>

                            <a href="https://medium.com/@maneetsrivastav" target="_blank" rel="noreferrer" className="flex items-center gap-3 hover:text-lavender-light transition-colors group p-2 hover:bg-white/5 rounded-lg -ml-2">
                                <FileText size={18} className="text-slate-400 group-hover:text-lavender-light" />
                                <span>Blog: <span className="font-medium">@maneetsrivastav</span></span>
                            </a>
                        </div>
                    </div>

                    {/* Right Column - Form */}
                    <div className="bg-white/5 rounded-2xl p-6 md:p-8 backdrop-blur-sm border border-white/10">
                        <form
                            onSubmit={handleSubmit}
                            name="contact"
                            data-netlify="true"
                            className="space-y-5"
                        >
                            <input type="hidden" name="form-name" value="contact" />

                            <div className="grid md:grid-cols-2 gap-5">
                                <div className="space-y-2">
                                    <label htmlFor="name" className="text-sm font-medium text-slate-300">Name</label>
                                    <input
                                        type="text"
                                        id="name"
                                        name="name"
                                        required
                                        value={formData.name}
                                        onChange={handleChange}
                                        className="w-full bg-[#161320]/50 border border-white/10 rounded-lg px-4 py-2.5 text-slate-100 text-sm focus:outline-none focus:border-lavender-light/50 focus:ring-1 focus:ring-lavender-light/50 transition-all placeholder:text-slate-500"
                                        placeholder="Your name"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <label htmlFor="email" className="text-sm font-medium text-slate-300">Email</label>
                                    <input
                                        type="email"
                                        id="email"
                                        name="email"
                                        required
                                        value={formData.email}
                                        onChange={handleChange}
                                        className="w-full bg-[#161320]/50 border border-white/10 rounded-lg px-4 py-2.5 text-slate-100 text-sm focus:outline-none focus:border-lavender-light/50 focus:ring-1 focus:ring-lavender-light/50 transition-all placeholder:text-slate-500"
                                        placeholder="your@email.com"
                                    />
                                </div>
                            </div>

                            <div className="space-y-2">
                                <label htmlFor="message" className="text-sm font-medium text-slate-300">Message</label>
                                <textarea
                                    id="message"
                                    name="message"
                                    required
                                    rows="4"
                                    value={formData.message}
                                    onChange={handleChange}
                                    className="w-full bg-[#161320]/50 border border-white/10 rounded-lg px-4 py-2.5 text-slate-100 text-sm focus:outline-none focus:border-lavender-light/50 focus:ring-1 focus:ring-lavender-light/50 transition-all placeholder:text-slate-500 resize-none"
                                    placeholder="How can I help you?"
                                ></textarea>
                            </div>

                            <button
                                type="submit"
                                disabled={status === 'sending'}
                                className="w-full bg-lavender hover:bg-lavender-light text-[#161320] font-medium py-2.5 rounded-lg transition-all duration-300 disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                            >
                                {status === 'sending' ? 'Sending...' : 'Send Message'}
                            </button>

                            {status === 'success' && (
                                <p className="text-green-400 text-sm text-center bg-green-400/10 py-2 rounded-lg border border-green-400/20">
                                    Message sent successfully! I'll get back to you soon.
                                </p>
                            )}
                            {status === 'error' && (
                                <p className="text-red-400 text-sm text-center bg-red-400/10 py-2 rounded-lg border border-red-400/20">
                                    Something went wrong. Please try again later.
                                </p>
                            )}
                        </form>
                    </div>
                </div>

                <p className="mt-16 text-[11px] text-slate-400 border-t border-white/5 pt-8 text-center sm:text-left">
                    © 2025 · Designed & built by <span className="text-lavender-light font-medium">Maneet Srivastav</span>
                </p>
            </div>
        </section>
    );
};

export default Contact;
