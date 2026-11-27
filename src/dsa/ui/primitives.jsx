import { Link } from 'react-router-dom';

const BUTTON_VARIANTS = {
    primary: 'swift-gradient font-semibold text-ink hover:brightness-110',
    secondary: 'bg-white/8 font-medium text-paper hover:bg-white/12',
    ghost: 'font-medium text-muted hover:bg-white/8 hover:text-paper',
    success: 'bg-[#30D158] font-semibold text-ink hover:brightness-110',
};

const BUTTON_SIZES = {
    sm: 'h-9 px-3.5 text-sm',
    md: 'h-11 px-5',
};

const buttonClasses = (variant, size, className) => `inline-flex items-center justify-center gap-2 rounded-full transition disabled:cursor-not-allowed disabled:opacity-40 ${BUTTON_VARIANTS[variant]} ${BUTTON_SIZES[size]} ${className}`;

export const Button = ({ variant = 'secondary', size = 'md', className = '', type = 'button', ...props }) => (
    <button type={type} className={buttonClasses(variant, size, className)} {...props} />
);

export const ButtonLink = ({ variant = 'secondary', size = 'md', className = '', ...props }) => (
    <Link className={buttonClasses(variant, size, className)} {...props} />
);

const CHIP_TONES = {
    neutral: 'bg-white/8 text-muted',
    swift: 'bg-swift/15 text-swift',
    amber: 'bg-amber/15 text-amber',
    green: 'bg-[#30D158]/15 text-[#30D158]',
    red: 'bg-[#FF9D96]/15 text-[#FF9D96]',
};

export const Chip = ({ tone = 'neutral', className = '', children }) => (
    <span className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 font-mono text-xs ${CHIP_TONES[tone]} ${className}`}>{children}</span>
);

export const Card = ({ as: Tag = 'section', className = '', children, ...props }) => (
    <Tag className={`rounded-2xl border border-line bg-surface ${className}`} {...props}>{children}</Tag>
);

export const ProgressBar = ({ value, label, className = '' }) => (
    <div
        role="progressbar"
        aria-label={label}
        aria-valuemin={0}
        aria-valuemax={100}
        aria-valuenow={Math.round(value * 100)}
        className={`h-1.5 overflow-hidden rounded-full bg-white/10 ${className}`}
    >
        <div className="swift-gradient h-full origin-left rounded-full transition-transform duration-500" style={{ transform: `scaleX(${Math.min(1, Math.max(0, value))})` }} />
    </div>
);

// A small donut, used for module and daily progress
export const ProgressRing = ({ value, size = 28, stroke = 3, label, children }) => {
    const radius = (size - stroke) / 2;
    const circumference = 2 * Math.PI * radius;
    const done = value >= 1;
    return (
        <span className="relative inline-flex shrink-0 items-center justify-center" style={{ width: size, height: size }} role={label ? 'img' : undefined} aria-label={label} aria-hidden={label ? undefined : true}>
            <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="-rotate-90">
                <circle cx={size / 2} cy={size / 2} r={radius} fill="none" stroke="currentColor" strokeWidth={stroke} className="text-white/10" />
                <circle
                    cx={size / 2}
                    cy={size / 2}
                    r={radius}
                    fill="none"
                    strokeWidth={stroke}
                    strokeLinecap="round"
                    strokeDasharray={circumference}
                    strokeDashoffset={circumference * (1 - Math.min(1, value))}
                    className={done ? 'stroke-[#30D158]' : 'stroke-amber'}
                />
            </svg>
            {children && <span className="absolute inset-0 flex items-center justify-center">{children}</span>}
        </span>
    );
};

export const PageHeader = ({ eyebrow, title, children }) => (
    <header className="mb-8">
        {eyebrow && <p className="mb-2 font-mono text-sm text-swift">{eyebrow}</p>}
        <h1 className="font-display text-[clamp(2rem,5vw,3.25rem)] font-semibold leading-[1.05] tracking-tight">{title}</h1>
        {children && <div className="mt-3 max-w-2xl leading-relaxed text-muted">{children}</div>}
    </header>
);

export const Kbd = ({ children }) => (
    <kbd className="rounded-md border border-line bg-white/5 px-1.5 py-0.5 font-mono text-[11px] text-muted">{children}</kbd>
);

export const EmptyState = ({ icon: Icon, title, children }) => (
    <div className="rounded-2xl border border-dashed border-line px-6 py-10 text-center">
        {Icon && <Icon size={28} aria-hidden="true" className="mx-auto mb-3 text-muted" />}
        <p className="font-semibold">{title}</p>
        {children && <div className="mx-auto mt-2 max-w-md text-sm leading-relaxed text-muted">{children}</div>}
    </div>
);
