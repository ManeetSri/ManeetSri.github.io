import React from 'react';
import Navbar from './components/Navbar';
import Hero from './sections/Hero';
import Skills from './sections/Skills';
import Apps from './sections/Apps';
import Experience from './sections/Experience';
import Projects from './sections/Projects';
import Blogs from './sections/Blogs';
import Contact from './sections/Contact';

function App() {
  return (
    <div className="bg-[#1d1b26] min-h-screen text-slate-50 selection:bg-lavender selection:text-white">
      <Navbar />
      <main>
        <Hero />
        <Skills />
        {/* <Apps /> */}
        <Blogs />
        <Experience />
        <Projects />
      </main>
      <Contact />
    </div>
  );
}

export default App;
