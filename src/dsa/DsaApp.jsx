import { lazy, Suspense } from 'react';
import { Route, Routes } from 'react-router-dom';
import { LoaderCircle } from 'lucide-react';
import './dsa.css';
import AuthGate from './auth/AuthGate.jsx';
import Shell from './ui/Shell.jsx';
import { useConsoleMeta } from './ui/hooks.js';
import TodayPage from './pages/TodayPage.jsx';

// Today is where the console opens, so it ships with the shell. Every other page loads when it's
// first visited: lessons and problems bring the MDX renderer and syntax highlighting with them.
const PathPage = lazy(() => import('./pages/PathPage.jsx'));
const LessonPage = lazy(() => import('./pages/LessonPage.jsx'));
const PracticePage = lazy(() => import('./pages/PracticePage.jsx'));
const ProblemPage = lazy(() => import('./pages/ProblemPage.jsx'));
const ReviewPage = lazy(() => import('./pages/ReviewPage.jsx'));
const ProgressPage = lazy(() => import('./pages/ProgressPage.jsx'));
const NotesPage = lazy(() => import('./pages/NotesPage.jsx'));
const SettingsPage = lazy(() => import('./pages/SettingsPage.jsx'));
const OnboardingPage = lazy(() => import('./pages/OnboardingPage.jsx'));
const CheckpointPage = lazy(() => import('./pages/CheckpointPage.jsx'));
const SheetsPage = lazy(() => import('./pages/SheetsPage.jsx'));
const MockPage = lazy(() => import('./pages/MockPage.jsx'));
const ConsoleNotFound = lazy(() => import('./pages/ConsoleNotFound.jsx'));

const PageLoading = () => (
    <p className="flex items-center gap-2 py-10 text-muted" role="status">
        <LoaderCircle size={18} aria-hidden="true" className="animate-spin" /> Loading…
    </p>
);

// The private DSA-in-Swift learning console. Not linked from the portfolio, never indexed, and
// behind a passphrase. Everything it needs loads in its own chunks.
const DsaApp = () => {
    useConsoleMeta();
    return (
        <AuthGate>
            <Shell>
                <Suspense fallback={<PageLoading />}>
                    <Routes>
                        <Route index element={<TodayPage />} />
                        <Route path="path" element={<PathPage />} />
                        <Route path="learn/:lessonId" element={<LessonPage />} />
                        <Route path="practice" element={<PracticePage />} />
                        <Route path="practice/:problemId" element={<ProblemPage />} />
                        <Route path="review" element={<ReviewPage />} />
                        <Route path="progress" element={<ProgressPage />} />
                        <Route path="notes" element={<NotesPage />} />
                        <Route path="settings" element={<SettingsPage />} />
                        <Route path="sheets" element={<SheetsPage />} />
                        <Route path="sheets/:sheetId" element={<SheetsPage />} />
                        <Route path="mock" element={<MockPage />} />
                        <Route path="checkpoint/:moduleId" element={<CheckpointPage />} />
                        <Route path="start" element={<OnboardingPage />} />
                        <Route path="*" element={<ConsoleNotFound />} />
                    </Routes>
                </Suspense>
            </Shell>
        </AuthGate>
    );
};

export default DsaApp;
