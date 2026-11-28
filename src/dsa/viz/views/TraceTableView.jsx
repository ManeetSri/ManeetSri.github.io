import { useMemo } from 'react';
import Player from '../Player.jsx';
import { traceFrames, traceProgram } from '../algorithms/traceTable.js';

// ```visual traceTable with { program: sum | largest | reverseDigits | gcd, input: { … } }
const TraceTableView = ({ program = 'sum', input = {} }) => {
    const { title, code, columns } = traceProgram(program);
    const inputKey = JSON.stringify(input);
    const frames = useMemo(() => traceFrames(program, JSON.parse(inputKey)), [program, inputKey]);

    return (
        <Player frames={frames} code={code} title={`Trace table: ${title.toLowerCase()}`}>
            {(frame) => (
                <div className="space-y-4">
                    <div className="flex flex-wrap gap-2" aria-label="Variables">
                        {Object.entries(frame.vars).map(([name, value]) => (
                            <span key={name} className="rounded-lg border border-line bg-white/[0.04] px-3 py-1.5 font-mono text-sm">
                                <span className="text-muted">{name}</span> <span className="text-amber">{String(value)}</span>
                            </span>
                        ))}
                    </div>
                    <div className="overflow-x-auto rounded-xl border border-line">
                        <table className="w-full text-left font-mono text-sm">
                            <thead className="bg-white/[0.04] text-xs text-muted">
                                <tr>
                                    <th className="px-3 py-2 font-medium">pass</th>
                                    {columns.map((column) => <th key={column} className="px-3 py-2 font-medium">{column}</th>)}
                                </tr>
                            </thead>
                            <tbody>
                                {frame.rows.length === 0 && (
                                    <tr><td colSpan={columns.length + 1} className="px-3 py-3 text-xs text-muted">Rows appear as the loop runs.</td></tr>
                                )}
                                {frame.rows.map((row, index) => (
                                    <tr key={index} className={`border-t border-line ${frame.newRow && index === frame.rows.length - 1 ? 'bg-amber/10' : ''}`}>
                                        <td className="px-3 py-2 text-muted">{index + 1}</td>
                                        {columns.map((column) => <td key={column} className="px-3 py-2">{String(row[column])}</td>)}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                </div>
            )}
        </Player>
    );
};

export default TraceTableView;
