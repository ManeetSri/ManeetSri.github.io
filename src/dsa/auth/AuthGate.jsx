import { useEffect, useMemo, useRef, useState } from 'react';
import { KeyRound, Laptop, LoaderCircle } from 'lucide-react';
import { usePageMeta } from '../../hooks/usePageMeta';
import { OWNER_EMAIL } from '../services/owner';
import { createStore, StoreContext } from '../store/store.js';
import { Button } from '../ui/primitives.jsx';

// Every screen before sign-in. The course's own title takes over once its pages render.
const Centered = ({ children }) => {
    usePageMeta({ title: 'Private console', description: 'Private learning console.', path: window.location.pathname, noindex: true });
    return (
        <main className="flex min-h-svh items-center justify-center bg-[radial-gradient(70%_50%_at_50%_0%,rgba(240,81,56,0.14),transparent_70%)] px-5">
            <div className="w-full max-w-sm">{children}</div>
        </main>
    );
};

const PassphraseScreen = ({ services, onLocal }) => {
    const [passphrase, setPassphrase] = useState('');
    const [error, setError] = useState('');
    const [busy, setBusy] = useState(false);

    const submit = async (event) => {
        event.preventDefault();
        if (!passphrase || busy) return;
        setBusy(true);
        setError('');
        try {
            await services.unlock(passphrase);
        } catch (failure) {
            setError(services.unlockErrorMessage(failure));
            setBusy(false);
        }
    };

    return (
        <Centered>
            <span className="swift-gradient mb-6 flex h-14 w-14 items-center justify-center rounded-2xl text-ink">
                <KeyRound size={26} aria-hidden="true" />
            </span>
            <h1 className="font-display text-4xl font-semibold tracking-tight">Private console</h1>
            <p className="mt-2 text-muted">Enter your passphrase to continue.</p>
            <form onSubmit={submit} className="mt-8 space-y-3">
                {/* Lets password managers match the saved passphrase to this account */}
                <input type="text" name="username" autoComplete="username" value={OWNER_EMAIL} readOnly hidden />
                <label htmlFor="dsa-passphrase" className="sr-only">Passphrase</label>
                <input
                    id="dsa-passphrase"
                    type="password"
                    name="password"
                    autoComplete="current-password"
                    autoFocus
                    value={passphrase}
                    onChange={(event) => setPassphrase(event.target.value)}
                    aria-invalid={Boolean(error)}
                    aria-describedby={error ? 'dsa-passphrase-error' : undefined}
                    placeholder="Passphrase"
                    className="h-12 w-full rounded-xl border border-line bg-surface px-4 text-base outline-none focus:border-amber"
                />
                {error && <p id="dsa-passphrase-error" role="alert" className="text-sm text-[#FF9D96]">{error}</p>}
                <Button type="submit" variant="primary" className="w-full" disabled={!passphrase || busy}>
                    {busy ? <LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> : null}
                    {busy ? 'Unlocking…' : 'Unlock'}
                </Button>
            </form>
            {import.meta.env.DEV && onLocal && (
                <Button variant="ghost" className="mt-6 w-full" onClick={onLocal}>
                    <Laptop size={18} aria-hidden="true" /> Use local data (development only)
                </Button>
            )}
        </Centered>
    );
};

const Loading = ({ label }) => (
    <Centered>
        <p className="flex items-center justify-center gap-3 text-muted" role="status">
            <LoaderCircle size={20} aria-hidden="true" className="animate-spin" /> {label}
        </p>
    </Centered>
);

// Shows the passphrase screen until the single console account is signed in, then provides a store
// synced with that account. In development, a local store can stand in without signing in.
const AuthGate = ({ children }) => {
    const [services, setServices] = useState(null);
    const [loadError, setLoadError] = useState(false);
    const [session, setSession] = useState({ state: 'checking', store: null });
    const usingLocalData = useRef(false);

    useEffect(() => {
        let cancelled = false;
        let stopWatching = () => {};
        import('../services/firebase')
            .then((module) => {
                if (cancelled) return;
                setServices(module);
                // Fetch the sync code now, while the passphrase is being typed
                const sync = module.loadSync();
                let latest = 0;
                stopWatching = module.watchUser((user) => {
                    if (usingLocalData.current) return;
                    const attempt = ++latest;
                    if (!user) {
                        setSession({ state: 'signed-out', store: null });
                        return;
                    }
                    sync.then(({ createFirestoreAdapter }) => {
                        // A later sign-in or sign-out wins over this one
                        if (cancelled || attempt !== latest || usingLocalData.current) return;
                        setSession({ state: 'signed-in', store: createStore(createFirestoreAdapter(user.uid)) });
                    }).catch(() => !cancelled && setLoadError(true));
                });
            })
            .catch(() => !cancelled && setLoadError(true));
        return () => {
            cancelled = true;
            stopWatching();
        };
    }, []);

    // Each store stops syncing when it's replaced or the console closes
    useEffect(() => () => session.store?.destroy(), [session.store]);

    const openLocalData = import.meta.env.DEV
        ? async () => {
            const { createLocalAdapter, rememberLocalMode } = await import('../store/localAdapter.js');
            rememberLocalMode(true);
            usingLocalData.current = true;
            setSession({ state: 'local', store: createStore(createLocalAdapter()) });
        }
        : null;

    // In development, a reload stays in local mode until the console is locked.
    // The whole body sits inside the DEV check so production builds drop it, local adapter included.
    useEffect(() => {
        if (import.meta.env.DEV) {
            import('../store/localAdapter.js').then(({ isLocalModeRemembered }) => {
                if (isLocalModeRemembered() && !usingLocalData.current) openLocalData();
            });
        }
    }, []); // eslint-disable-line react-hooks/exhaustive-deps -- once, on first load

    const value = useMemo(() => session.store && {
        ...session.store,
        lock: async () => {
            if (import.meta.env.DEV && usingLocalData.current) {
                usingLocalData.current = false;
                (await import('../store/localAdapter.js')).rememberLocalMode(false);
                setSession({ state: 'signed-out', store: null });
                return;
            }
            await services.lock();
        },
    }, [session.store, services]);

    if (session.store) {
        return <StoreContext.Provider value={value}>{children}</StoreContext.Provider>;
    }
    if (loadError) {
        return (
            <Centered>
                <h1 className="font-display text-3xl font-semibold tracking-tight">Couldn’t load the console</h1>
                <p className="mt-2 text-muted">Check your connection and reload the page.</p>
                {import.meta.env.DEV && openLocalData && <Button className="mt-6" onClick={openLocalData}>Use local data instead</Button>}
            </Centered>
        );
    }
    if (!services) return <Loading label="Opening your console…" />;
    if (session.state === 'checking') return <Loading label="Opening your console…" />;
    return <PassphraseScreen services={services} onLocal={openLocalData} />;
};

export default AuthGate;
