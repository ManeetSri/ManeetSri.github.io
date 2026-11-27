// A radar of mastery per part. The table under it carries the same numbers for screen readers and exact reading.
const SIZE = 300;
const CENTRE = SIZE / 2;
const RADIUS = 110;

const MasteryRadar = ({ entries }) => {
    const angle = (index) => (Math.PI * 2 * index) / entries.length - Math.PI / 2;
    const point = (index, value) => [CENTRE + Math.cos(angle(index)) * RADIUS * value, CENTRE + Math.sin(angle(index)) * RADIUS * value];
    const polygon = entries.map((entry, index) => point(index, Math.max(0.02, entry.value)).join(',')).join(' ');

    return (
        <div className="grid items-center gap-6 md:grid-cols-[300px_minmax(0,1fr)]">
            <svg viewBox={`0 0 ${SIZE} ${SIZE}`} className="mx-auto w-full max-w-[300px]" aria-hidden="true">
                {[0.25, 0.5, 0.75, 1].map((ring) => (
                    <polygon key={ring} points={entries.map((_, index) => point(index, ring).join(',')).join(' ')} fill="none" stroke="rgba(242,240,235,0.12)" />
                ))}
                {entries.map((_, index) => {
                    const [x, y] = point(index, 1);
                    return <line key={index} x1={CENTRE} y1={CENTRE} x2={x} y2={y} stroke="rgba(242,240,235,0.12)" />;
                })}
                <polygon points={polygon} fill="rgba(253,176,58,0.25)" stroke="var(--color-amber)" strokeWidth="2" />
                {entries.map((entry, index) => {
                    const [x, y] = point(index, 1.16);
                    return <text key={entry.part} x={x} y={y + 4} textAnchor="middle" fontSize="11" fontFamily="var(--font-mono)" fill="var(--color-muted)">{entry.part}</text>;
                })}
            </svg>
            <table className="w-full text-left text-sm">
                <caption className="sr-only">Mastery by part</caption>
                <thead className="font-mono text-xs text-muted">
                    <tr><th className="py-1 font-medium">Part</th><th className="py-1 font-medium">Lessons</th><th className="py-1 text-right font-medium">Mastery</th></tr>
                </thead>
                <tbody>
                    {entries.map((entry) => (
                        <tr key={entry.part} className="border-t border-line">
                            <td className="py-1.5"><span className="mr-2 font-mono text-xs text-muted">{entry.part}</span>{entry.title}</td>
                            <td className="py-1.5 font-mono text-xs text-muted">{entry.lessons.done}/{entry.lessons.total}</td>
                            <td className="py-1.5 text-right font-mono">{Math.round(entry.value * 100)}%</td>
                        </tr>
                    ))}
                </tbody>
            </table>
        </div>
    );
};

export default MasteryRadar;
