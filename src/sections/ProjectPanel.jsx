import { useState } from 'react';
import { Check, Copy, ExternalLink, Github, Globe } from 'lucide-react';
import AppIcon from '../components/device/AppIcon';
import { track } from '../analytics';

const linkClass = 'inline-flex h-10 items-center gap-1.5 rounded-full border border-line bg-white/5 px-3.5 text-sm font-medium transition-colors hover:bg-white/10';

const CopySnippet = ({ snippet }) => {
    const [copied, setCopied] = useState(false);

    const copy = async () => {
        try {
            await navigator.clipboard.writeText(snippet);
            track('snippet_copy');
            setCopied(true);
            setTimeout(() => setCopied(false), 1800);
        } catch {
            setCopied(false);
        }
    };

    return (
        <div className="mt-3 flex max-w-xl items-center gap-2 rounded-xl border border-line bg-surface py-1 pl-3 pr-1">
            <code className="min-w-0 flex-1 truncate font-mono text-xs text-muted">{snippet}</code>
            <button type="button" onClick={copy} aria-label="Copy Swift Package snippet" className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg hover:bg-white/10">
                {copied ? <Check size={16} className="text-[#30D158]" aria-hidden="true" /> : <Copy size={16} aria-hidden="true" />}
            </button>
            <span role="status" className="sr-only">{copied ? 'Copied' : ''}</span>
        </div>
    );
};

const ProjectPanel = ({ project }) => {
    const isGithub = project.link?.includes('github.com');

    return (
        <>
            <div className="flex items-center gap-3 lg:block">
                <span className="hidden lg:mb-5 lg:block"><AppIcon project={project} size={68} /></span>
                <span className="lg:hidden"><AppIcon project={project} size={44} /></span>
                <div className="min-w-0">
                    <p className="truncate font-mono text-xs lg:mb-2 lg:text-sm" style={{ color: project.tint }}>{project.category}</p>
                    <h3 className="truncate font-display text-[clamp(1.2rem,6vw,1.5rem)] font-semibold tracking-tight lg:whitespace-normal lg:text-5xl">{project.title}</h3>
                </div>
            </div>

            <p className="mt-2 text-sm leading-snug text-paper/85 lg:hidden">{project.summary}</p>
            <p className="mt-4 hidden max-w-xl text-lg leading-relaxed text-paper/85 lg:block">{project.description}</p>

            {project.stat && <p className="mt-2 font-mono text-xs text-[#30D158] lg:mt-4 lg:text-sm">{project.stat}</p>}
            <p className="mt-3 hidden font-mono text-sm text-muted lg:block">
                {project.tags.join(' · ')}{project.builtAt && ` · Built at ${project.builtAt}`}
            </p>

            {project.snippet && <div className="hidden sm:block"><CopySnippet snippet={project.snippet} /></div>}

            <div className="mt-3 flex flex-wrap items-center gap-2 lg:mt-5">
                {project.link && (
                    <a href={project.link} target="_blank" rel="noopener noreferrer" data-event="app_link_click" data-event-app={project.id} data-event-destination={isGithub ? 'github' : 'app_store'} className={linkClass}>
                        {isGithub ? <><Github size={15} aria-hidden="true" /> GitHub</> : <><ExternalLink size={15} aria-hidden="true" /> App Store</>}
                    </a>
                )}
                {project.website && (
                    <a href={project.website} target="_blank" rel="noopener noreferrer" data-event="app_link_click" data-event-app={project.id} data-event-destination="website" className={linkClass}>
                        <Globe size={15} aria-hidden="true" /> Website
                    </a>
                )}
            </div>

            {!project.interactive && (
                <p className="mt-3 hidden text-xs text-muted lg:block">Phone view is an illustrative recreation with sample data, not a screenshot.</p>
            )}
        </>
    );
};

export default ProjectPanel;
