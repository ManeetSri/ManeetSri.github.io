import { Component } from 'react';
import { RotateCcw } from 'lucide-react';
import { track } from '../analytics';

// A crash anywhere, or a page file that fails to download after a new deploy, shows this
// instead of a blank screen. Technical details stay out of the page.
class ErrorBoundary extends Component {
    state = { hasError: false };

    static getDerivedStateFromError() {
        return { hasError: true };
    }

    componentDidCatch(error) {
        console.error(error);
        track('exception', { description: String(error?.message), fatal: true });
    }

    render() {
        if (!this.state.hasError) return this.props.children;
        const offline = !navigator.onLine;

        return (
            <main className="flex min-h-svh items-center justify-center px-5 text-center">
                <div>
                    <h1 className="mb-4 font-display text-5xl font-semibold tracking-tight sm:text-6xl">
                        {offline ? 'This page is unavailable offline.' : 'Something went wrong.'}
                    </h1>
                    <p className="mb-8 text-lg text-muted">{offline ? 'Reconnect and reload to open this page.' : 'Reloading usually fixes it.'}</p>
                    <button
                        type="button"
                        onClick={() => window.location.reload()}
                        className="swift-gradient inline-flex h-12 items-center gap-2 rounded-full px-6 font-semibold text-ink"
                    >
                        <RotateCcw size={18} aria-hidden="true" /> Reload page
                    </button>
                    <a href="/" className="mx-auto mt-5 block w-fit text-sm text-muted hover:text-paper">Back to portfolio</a>
                </div>
            </main>
        );
    }
}

export default ErrorBoundary;
