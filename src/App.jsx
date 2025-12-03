import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Hero from './sections/Hero';
import Skills from './sections/Skills';
import Apps from './sections/Apps';
import Experience from './sections/Experience';
import Projects from './sections/Projects';
import Blogs from './sections/Blogs';
import Contact from './sections/Contact';
import ProjectsPage from './pages/ProjectsPage';
import BlogsPage from './pages/BlogsPage';

function App() {
  return (
    <Router>
      <div className="bg-[#1d1b26] min-h-screen text-slate-50 selection:bg-lavender selection:text-white">
        <Navbar />
        <Routes>
          <Route path="/" element={
            <main>
              <Hero />
              <Skills />
              {/* <Apps /> */}
              <Blogs />
              <Experience />
              <Projects />
              <Contact />
            </main>
          } />
          <Route path="/projects" element={<ProjectsPage />} />
          <Route path="/blogs" element={<BlogsPage />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
