import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { MotionConfig } from 'framer-motion';
import Navbar from './components/Navbar';
import ScrollToTop from './components/ScrollToTop';
import Hero from './sections/Hero';
import Skills from './sections/Skills';
import Experience from './sections/Experience';
import Projects from './sections/Projects';
import Blogs from './sections/Blogs';
import Contact from './sections/Contact';
import ProjectsPage from './pages/ProjectsPage';
import BlogsPage from './pages/BlogsPage';
import NotFoundPage from './pages/NotFoundPage';
import { useDocumentTitle } from './hooks/useDocumentTitle';

const Home = () => {
  useDocumentTitle('Maneet Srivastav – Mobile Application Engineer');

  return (
    <main>
      <Hero />
      <Experience />
      <Projects />
      <Skills />
      <Blogs />
      <Contact />
    </main>
  );
};

function App() {
  return (
    <MotionConfig reducedMotion="user">
      <Router>
        <ScrollToTop />
        <div className="min-h-screen text-slate-50 selection:bg-lavender selection:text-white">
          <Navbar />
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/projects" element={<ProjectsPage />} />
            <Route path="/blogs" element={<BlogsPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Routes>
        </div>
      </Router>
    </MotionConfig>
  );
}

export default App;
