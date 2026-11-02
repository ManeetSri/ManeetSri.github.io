import { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { MotionConfig, useReducedMotion } from 'framer-motion';
import ScrollToTop from './components/ScrollToTop';
import ScrollProgress from './components/ScrollProgress';
import TabBar from './components/TabBar';
import BuildLoader from './components/BuildLoader';
import { shouldPlayLoader } from './components/loaderSession';
import Stage from './sections/Stage';
import StaticStory from './sections/StaticStory';
import Instruments from './sections/Instruments';
import Notes from './sections/Notes';
import Contact from './sections/Contact';
import BlogsPage from './pages/BlogsPage';
import NotFoundPage from './pages/NotFoundPage';
import { useDocumentTitle } from './hooks/useDocumentTitle';

const Home = () => {
  useDocumentTitle('Maneet Srivastav – iOS & Mobile Application Engineer');

  const { hash } = useLocation();
  const reduceMotion = useReducedMotion();
  const [loading, setLoading] = useState(() => shouldPlayLoader(hash));

  return (
    <>
      {loading && <BuildLoader onDone={() => setLoading(false)} />}
      <main>
        {reduceMotion ? <StaticStory /> : <Stage ready={!loading} />}
        <Instruments />
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
        <ScrollProgress />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/projects" element={<Navigate to="/#work" replace />} />
          <Route path="/blogs" element={<BlogsPage />} />
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
        <TabBar />
      </Router>
    </MotionConfig>
  );
}

export default App;
