import { useEffect, useRef, useState } from 'react';

// Scenes are drawn on a fixed 300 × 640 screen, and the whole device scales to fit its container
const BEZEL = 10;
const DEVICE_WIDTH = 300 + BEZEL * 2;
const DEVICE_HEIGHT = 640 + BEZEL * 2;

const Phone = ({ children, className = '' }) => {
    const containerRef = useRef(null);
    const [scale, setScale] = useState(0);

    useEffect(() => {
        const container = containerRef.current;
        const observer = new ResizeObserver(() => {
            setScale(Math.min(container.clientWidth / DEVICE_WIDTH, container.clientHeight / DEVICE_HEIGHT));
        });
        observer.observe(container);
        return () => observer.disconnect();
    }, []);

    return (
        <div ref={containerRef} className={`flex h-full w-full items-center justify-center ${className}`}>
            <div className="relative shrink-0" style={{ width: DEVICE_WIDTH * scale, height: DEVICE_HEIGHT * scale }}>
                <div
                    className="absolute left-0 top-0 origin-top-left rounded-[3.3rem] border border-white/15 bg-gradient-to-br from-[#3a3d45] via-[#1b1d22] to-[#2b2e35] shadow-[0_40px_120px_-20px_rgba(0,0,0,0.9)]"
                    style={{ width: DEVICE_WIDTH, height: DEVICE_HEIGHT, padding: BEZEL, transform: `scale(${scale})` }}
                >
                    <div className="phone-ui phone-screen relative h-full w-full overflow-hidden rounded-[2.65rem] bg-black text-white">
                        {children}
                        <div
                            data-island
                            aria-hidden="true"
                            className="absolute left-1/2 top-2.5 z-50 h-[28px] w-[92px] -translate-x-1/2 rounded-full bg-black"
                        />
                    </div>
                </div>
            </div>
        </div>
    );
};

export default Phone;
