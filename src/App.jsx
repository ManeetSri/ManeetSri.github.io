import { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { MotionConfig, useReducedMotion } from 'framer-motion';
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
import Notes from './sections/Notes';
import Contact from './sections/Contact';
import BlogsPage from './pages/BlogsPage';
import NotFoundPage from './pages/NotFoundPage';
import { usePageMeta } from './hooks/usePageMeta';

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
        <ScrollProgress />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/projects" element={<Navigate to="/#work" replace />} />
          <Route path="/blogs" element={<BlogsPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
        <TabBar />
        <FeedbackSheet />
        <CookieBanner />
      </Router>
    </MotionConfig>
  );
}

export default App;
