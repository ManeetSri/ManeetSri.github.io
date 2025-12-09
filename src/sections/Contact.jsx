import React from 'react';
import { Mail, Github, Linkedin, FileText, Send } from 'lucide-react';
import { motion } from 'framer-motion';

const Contact = () => {
    const [formData, setFormData] = React.useState({
        name: '',
        email: '',
        message: ''
    });
    const [status, setStatus] = React.useState('');
    const [focusedField, setFocusedField] = React.useState(null);

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
        <section id="contact" className="relative py-20 overflow-hidden">
            {/* Background Gradients */}
            <div className="absolute top-0 right-0 w-96 h-96 bg-lavender/5 rounded-full blur-[100px] -translate-y-1/2 translate-x-1/2" />
            <div className="absolute bottom-0 left-0 w-96 h-96 bg-blue-500/5 rounded-full blur-[100px] translate-y-1/2 -translate-x-1/2" />

            <div className="max-w-7xl mx-auto px-4 sm:px-6 relative z-10">
                <motion.div
                    initial={{ opacity: 0, y: 20 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.6 }}
                    className="grid md:grid-cols-[1fr,1.5fr] gap-12 lg:gap-20 items-start"
                >
                    {/* Left Column - Contact Info */}
                    <div className="space-y-8 pt-4">
                        <motion.div
                            initial={{ opacity: 0, x: -20 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            viewport={{ once: true }}
                            transition={{ duration: 0.6, delay: 0.2 }}
                        >
                            <h2 className="text-4xl md:text-5xl font-bold text-slate-50 mb-6 bg-clip-text text-transparent bg-gradient-to-r from-white to-slate-400">
                                Let’s connect
                            </h2>
                            <p className="text-base text-slate-300 leading-relaxed mb-8 max-w-md">
                                Open to roles and collaborations around mobility, logistics, ecommerce and
                                user-centric mobile products. Happy to talk architecture, performance and product trade-offs.
                            </p>
                        </motion.div>

                        <div className="space-y-4">
                            {[
                                { icon: Mail, label: 'Email', value: 'srivastavmaneet@gmail.com', href: 'mailto:srivastavmaneet@gmail.com', color: 'hover:text-red-400' },
                                { icon: Github, label: 'GitHub', value: 'github.com/ManeetSri', href: 'https://github.com/ManeetSri', color: 'hover:text-slate-100' },
                                { icon: Linkedin, label: 'LinkedIn', value: '/in/maneet-srivastav', href: 'https://www.linkedin.com/in/maneet-srivastav-1499a1196/', color: 'hover:text-blue-400' },
                                { icon: FileText, label: 'Blog', value: '@maneetsrivastav', href: 'https://medium.com/@maneetsrivastav', color: 'hover:text-green-400' }
                            ].map((item, index) => (
                                <motion.a
                                    key={item.label}
                                    href={item.href}
                                    target={item.label !== 'Email' ? "_blank" : undefined}
                                    rel="noreferrer"
                                    initial={{ opacity: 0, x: -20 }}
                                    whileInView={{ opacity: 1, x: 0 }}
                                    viewport={{ once: true }}
                                    transition={{ duration: 0.4, delay: 0.3 + (index * 0.1) }}
                                    className={`flex items-center gap-4 p-4 rounded-xl bg-white/5 border border-white/5 hover:border-white/10 hover:bg-white/10 transition-all group ${item.color}`}
                                >
                                    <div className="p-2.5 rounded-lg bg-white/5 group-hover:bg-white/10 transition-colors">
                                        <item.icon size={20} className="text-slate-400 group-hover:text-white transition-colors" />
                                    </div>
                                    <div>
                                        <span className="text-xs text-slate-500 block mb-0.5">{item.label}</span>
                                        <span className="text-sm font-medium text-slate-200 group-hover:text-white transition-colors">{item.value}</span>
                                    </div>
                                </motion.a>
                            ))}
                        </div>
                    </div>

                    {/* Right Column - Form */}
                    <motion.div
                        initial={{ opacity: 0, x: 20 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ duration: 0.6, delay: 0.4 }}
                        className="relative"
                    >
                        {/* Glow effect behind form */}
                        <div className="absolute inset-0 bg-gradient-to-r from-lavender/10 to-blue-500/10 rounded-3xl blur-2xl -z-10" />

                        <div className="bg-[#161320]/80 backdrop-blur-xl rounded-3xl p-6 md:p-10 border border-white/10 shadow-2xl">
                            <form
                                onSubmit={handleSubmit}
                                name="contact"
                                data-netlify="true"
                                className="space-y-6"
                            >
                                <input type="hidden" name="form-name" value="contact" />

                                <div className="grid md:grid-cols-2 gap-6">
                                    {['name', 'email'].map((field) => (
                                        <div key={field} className="space-y-2">
                                            <label htmlFor={field} className="text-sm font-medium text-slate-400 uppercase tracking-wider text-[11px] ml-1">
                                                {field}
                                            </label>
                                            <div className="relative">
                                                <input
                                                    type={field === 'email' ? 'email' : 'text'}
                                                    id={field}
                                                    name={field}
                                                    required
                                                    value={formData[field]}
                                                    onChange={handleChange}
                                                    onFocus={() => setFocusedField(field)}
                                                    onBlur={() => setFocusedField(null)}
                                                    className={`w-full bg-[#0a0a0f]/50 border rounded-xl px-5 py-3 text-slate-100 text-sm focus:outline-none transition-all duration-300 ${focusedField === field
                                                            ? 'border-lavender-light/50 ring-1 ring-lavender-light/50 shadow-[0_0_15px_rgba(200,180,255,0.1)]'
                                                            : 'border-white/10 hover:border-white/20'
                                                        }`}
                                                    placeholder={field === 'name' ? "John Doe" : "john@example.com"}
                                                />
                                            </div>
                                        </div>
                                    ))}
                                </div>

                                <div className="space-y-2">
                                    <label htmlFor="message" className="text-sm font-medium text-slate-400 uppercase tracking-wider text-[11px] ml-1">
                                        Message
                                    </label>
                                    <div className="relative">
                                        <textarea
                                            id="message"
                                            name="message"
                                            required
                                            rows="5"
                                            value={formData.message}
                                            onChange={handleChange}
                                            onFocus={() => setFocusedField('message')}
                                            onBlur={() => setFocusedField(null)}
                                            className={`w-full bg-[#0a0a0f]/50 border rounded-xl px-5 py-3 text-slate-100 text-sm focus:outline-none transition-all duration-300 resize-none ${focusedField === 'message'
                                                    ? 'border-lavender-light/50 ring-1 ring-lavender-light/50 shadow-[0_0_15px_rgba(200,180,255,0.1)]'
                                                    : 'border-white/10 hover:border-white/20'
                                                }`}
                                            placeholder="Tell me about your project..."
                                        ></textarea>
                                    </div>
                                </div>

                                <motion.button
                                    whileHover={{ scale: 1.02, boxShadow: "0 0 20px rgba(167, 139, 250, 0.3)" }}
                                    whileTap={{ scale: 0.98 }}
                                    type="submit"
                                    disabled={status === 'sending'}
                                    className="w-full bg-gradient-to-r from-lavender to-lavender-light text-[#161320] font-bold py-4 rounded-xl transition-all duration-300 disabled:opacity-70 disabled:cursor-not-allowed flex items-center justify-center gap-3 group relative overflow-hidden"
                                >
                                    <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300" />
                                    <span className="relative z-10">{status === 'sending' ? 'Sending...' : 'Send Message'}</span>
                                    {!status && <Send size={18} className="relative z-10 group-hover:translate-x-1 group-hover:-translate-y-1 transition-transform" />}
                                </motion.button>

                                {status === 'success' && (
                                    <motion.div
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        className="text-green-400 text-sm text-center bg-green-500/10 py-3 rounded-xl border border-green-500/20 flex items-center justify-center gap-2"
                                    >
                                        <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse" />
                                        Message sent! I'll be in touch soon.
                                    </motion.div>
                                )}
                                {status === 'error' && (
                                    <motion.div
                                        initial={{ opacity: 0, y: 10 }}
                                        animate={{ opacity: 1, y: 0 }}
                                        className="text-red-400 text-sm text-center bg-red-500/10 py-3 rounded-xl border border-red-500/20"
                                    >
                                        Something went wrong. Please try again.
                                    </motion.div>
                                )}
                            </form>
                        </div>
                    </motion.div>
                </motion.div>

                <motion.p
                    initial={{ opacity: 0 }}
                    whileInView={{ opacity: 1 }}
                    transition={{ delay: 0.8 }}
                    className="mt-20 text-[11px] text-slate-500 text-center border-t border-white/5 pt-8"
                >
                    © 2025 · Designed & built by <span className="text-slate-300 font-medium">Maneet Srivastav</span>
                </motion.p>
            </div>
        </section>
    );
};

export default Contact;
