import { Route, Routes } from 'react-router-dom';
import './dsa.css';
import AuthGate from './auth/AuthGate.jsx';
import Shell from './ui/Shell.jsx';
import { useConsoleMeta } from './ui/hooks.js';
import TodayPage from './pages/TodayPage.jsx';
import PathPage from './pages/PathPage.jsx';
import LessonPage from './pages/LessonPage.jsx';
import PracticePage from './pages/PracticePage.jsx';
import ProblemPage from './pages/ProblemPage.jsx';
import ReviewPage from './pages/ReviewPage.jsx';
import ProgressPage from './pages/ProgressPage.jsx';
import NotesPage from './pages/NotesPage.jsx';
import SettingsPage from './pages/SettingsPage.jsx';
import OnboardingPage from './pages/OnboardingPage.jsx';
import CheckpointPage from './pages/CheckpointPage.jsx';
import SheetsPage from './pages/SheetsPage.jsx';
import MockPage from './pages/MockPage.jsx';
import ConsoleNotFound from './pages/ConsoleNotFound.jsx';

// The private DSA-in-Swift learning console. Not linked from the portfolio, never indexed, and
// behind a passphrase. Everything it needs loads in its own chunks.
const DsaApp = () => {
    useConsoleMeta();
    return (
        <AuthGate>
            <Shell>
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
            </Shell>
        </AuthGate>
    );
};

export default DsaApp;
