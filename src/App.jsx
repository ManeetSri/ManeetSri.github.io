import { Suspense, lazy, useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { MotionConfig, useReducedMotion } from 'framer-motion';
import ErrorBoundary from './components/ErrorBoundary';
import ScrollToTop from './components/ScrollToTop';
import ScrollProgress from './components/ScrollProgress';
import TabBar from './components/TabBar';
import FeedbackSheet from './components/FeedbackSheet';
import AnalyticsTracker from './components/AnalyticsTracker';
import CookieBanner from './components/CookieBanner';
import BuildLoader from './components/BuildLoader';
import { shouldPlayLoader } from './components/loaderSession';
import Stage from './sections/Stage';
import StaticStory from './sections/StaticStory';
import Instruments from './sections/Instruments';
import Services from './sections/Services';
import Learning from './sections/Learning';
import Notes from './sections/Notes';
import Contact from './sections/Contact';
import NotFoundPage from './pages/NotFoundPage';
import { usePageMeta } from './hooks/usePageMeta';
import { isPrivatePath } from './utils/privatePaths';

// Secondary pages load when first visited, keeping the home page's bundle small
const BlogsPage = lazy(() => import('./pages/BlogsPage'));
const PrivacyPage = lazy(() => import('./pages/PrivacyPage'));
const BuildPage = lazy(() => import('./pages/BuildPage'));
const ConsoleApp = lazy(() => import('./dsa/ConsoleApp'));
const CourseRoutes = lazy(() => import('./dsa/ConsoleApp').then((module) => ({ default: module.CourseRoutes })));

// The game page and the private learning console are their own focused spaces, without the portfolio's navigation
const PortfolioChrome = () => {
  const { pathname } = useLocation();
  if (pathname === '/build' || isPrivatePath(pathname)) return null;

  return (
    <>
      <ScrollProgress />
      <TabBar />
      <FeedbackSheet />
    </>
  );
};

// The learning console never runs analytics, so it has nothing to ask consent for
const SiteCookieBanner = () => {
  const { pathname } = useLocation();
  return isPrivatePath(pathname) ? null : <CookieBanner />;
};

const Home = () => {
  usePageMeta({
    title: 'iOS & Android App Developer | Maneet Srivastav',
    description: 'Mobile app developer building iOS and Android apps with Swift, SwiftUI and React Native. 4+ years shipping ride-hailing, retail and education apps.',
    path: '/',
  });

  const { hash } = useLocation();
  const reduceMotion = useReducedMotion();
  const [loading, setLoading] = useState(() => shouldPlayLoader(hash));
  const [ready, setReady] = useState(!loading);

  return (
    <>
      {loading && <BuildLoader onReady={() => setReady(true)} onDone={() => setLoading(false)} />}
      <main>
        {reduceMotion ? <StaticStory /> : <Stage ready={ready} />}
        <Instruments />
        <Services />
        <Learning />
        <Notes />
        <Contact />
      </main>
    </>
  );
};

function App() {
  return (
    <MotionConfig reducedMotion="user">
      <Router>
        <ScrollToTop />
        <AnalyticsTracker />
        <ErrorBoundary>
          <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/projects" element={<Navigate to="/#work" replace />} />
          <Route path="/blogs" element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><BlogsPage /></Suspense>} />
          <Route path="/privacy" element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><PrivacyPage /></Suspense>} />
          <Route path="/build" element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><BuildPage /></Suspense>} />
          {/* The private console: one gate and store, with a set of routes per course */}
          <Route element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><ConsoleApp /></Suspense>}>
            <Route path="/dsa/*" element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><CourseRoutes course="dsa" /></Suspense>} />
            <Route path="/design/*" element={<Suspense fallback={<div className="min-h-svh bg-ink" />}><CourseRoutes course="design" /></Suspense>} />
          </Route>
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
        </ErrorBoundary>
        <PortfolioChrome />
        <SiteCookieBanner />
      </Router>
    </MotionConfig>
  );
}

export default App;
