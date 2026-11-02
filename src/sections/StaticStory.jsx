import { Suspense } from 'react';
import { motionValue } from 'framer-motion';
import Hero from './Hero';
import Journey from './Journey';
import ProjectPanel from './ProjectPanel';
import Phone from '../components/device/Phone';
import { SCENES } from '../components/device/scenes';
import { projects } from '../data/projects';

const FINISHED = motionValue(1);

// With reduced motion there is no pinning: every scene sits in its finished state, one after another
const StaticStory = () => (
    <>
        <Hero ready showPhone />
        <Journey />
        <section id="work" className="px-5 py-20 sm:px-10 lg:px-[5vw]">
            <p className="mb-3 font-mono text-sm text-swift">The work</p>
            <h2 className="mb-14 font-display text-[clamp(2.4rem,5vw,4.5rem)] font-semibold leading-none tracking-tight">Eight apps.</h2>
            <div className="space-y-20">
                {projects.map((project) => {
                    const Scene = SCENES[project.id];
                    return (
                        <article key={project.id} className="grid items-center gap-8 lg:grid-cols-[minmax(0,1fr)_340px]">
                            <div><ProjectPanel project={project} /></div>
                            <div className="mx-auto h-[600px] w-full max-w-[340px]">
                                <Phone>
                                    <Suspense fallback={<div className="absolute inset-0 bg-surface" />}>
                                        <Scene p={FINISHED} />
                                    </Suspense>
                                </Phone>
                            </div>
                        </article>
                    );
                })}
            </div>
        </section>
    </>
);

export default StaticStory;
