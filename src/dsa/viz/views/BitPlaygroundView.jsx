import { useState } from 'react';

// An 8-bit playground: flip bits, see the value as decimal, hex and binary, and apply an operator.
const OPERATORS = {
    '&': (a, b) => a & b,
    '|': (a, b) => a | b,
    '^': (a, b) => a ^ b,
    '~': (a) => ~a,
    '<<': (a, b) => a << (b & 7),
    '>>': (a, b, signed) => (signed ? toSigned(a) >> (b & 7) : a >>> (b & 7)),
};

const toSigned = (bits) => (bits & 0x80 ? bits - 256 : bits);
const valueOf = (bits, signed) => (signed ? toSigned(bits) : bits);
const binary = (bits) => (bits & 0xff).toString(2).padStart(8, '0');

const BitRow = ({ label, bits, onToggle, signed }) => (
    <div className="flex flex-wrap items-center gap-3">
        <span className="w-20 shrink-0 font-mono text-xs text-muted">{label}</span>
        <div className="flex gap-1" role={onToggle ? 'group' : undefined} aria-label={onToggle ? `${label} bits` : undefined}>
            {Array.from({ length: 8 }, (_, index) => {
                const bit = 7 - index;
                const on = Boolean(bits & (1 << bit));
                const Cell = onToggle ? 'button' : 'span';
                return (
                    <Cell
                        key={bit}
                        {...(onToggle ? { type: 'button', onClick: () => onToggle(bits ^ (1 << bit)), 'aria-pressed': on, 'aria-label': `Bit ${bit}${signed && bit === 7 ? ' (sign)' : ''}` } : {})}
                        className={`flex h-10 w-9 flex-col items-center justify-center rounded-lg border font-mono text-sm ${on ? 'border-amber bg-amber/20 text-amber' : 'border-line text-muted'} ${onToggle ? 'hover:border-white/40' : ''}`}
                    >
                        {on ? 1 : 0}
                    </Cell>
                );
            })}
        </div>
        <span className="font-mono text-sm">= <span className="text-paper">{valueOf(bits, signed)}</span> <span className="text-muted">· 0x{(bits & 0xff).toString(16).toUpperCase().padStart(2, '0')}</span></span>
    </div>
);

// ```visual bitPlayground with { value: 13, operand: 6, signed: false, operator: '&' }
const BitPlaygroundView = ({ value = 13, operand = 6, signed: initialSigned = false, operator: initialOperator = '&' }) => {
    const [a, setA] = useState(value & 0xff);
    const [b, setB] = useState(operand & 0xff);
    const [signed, setSigned] = useState(initialSigned);
    const [operator, setOperator] = useState(initialOperator);
    const unary = operator === '~';
    const shift = operator === '<<' || operator === '>>';
    const result = OPERATORS[operator](a, b, signed) & 0xff;
    const type = signed ? 'Int8' : 'UInt8';
    const expression = unary ? `~a` : shift ? `a ${operator} ${b & 7}` : `a ${operator} b`;
    // A binary literal above 127 doesn't fit in an Int8, so signed values are written from their bit pattern
    const literal = (bits) => (signed ? ` = Int8(bitPattern: 0b${binary(bits)})` : `: UInt8 = 0b${binary(bits)}`);

    return (
        <figure className="my-8 overflow-hidden rounded-2xl border border-line bg-surface">
            <figcaption className="border-b border-line px-4 py-2.5 font-mono text-xs text-muted">Bit playground: click bits to flip them</figcaption>
            <div className="space-y-4 p-4 sm:p-5">
                <div className="flex flex-wrap items-center gap-3 text-sm text-muted">
                    <div role="group" aria-label="Type" className="flex rounded-full bg-white/8 p-0.5">
                        {[['UInt8', false], ['Int8', true]].map(([label, isSigned]) => (
                            <button key={label} type="button" aria-pressed={signed === isSigned} onClick={() => setSigned(isSigned)} className={`h-8 rounded-full px-3 font-mono text-xs ${signed === isSigned ? 'bg-white/15 text-paper' : 'text-muted'}`}>{label}</button>
                        ))}
                    </div>
                    <div role="group" aria-label="Operator" className="flex flex-wrap gap-1">
                        {Object.keys(OPERATORS).map((key) => (
                            <button key={key} type="button" aria-pressed={operator === key} onClick={() => setOperator(key)} className={`h-8 min-w-10 rounded-lg px-2 font-mono text-sm ${operator === key ? 'bg-amber/20 text-amber ring-1 ring-amber' : 'bg-white/[0.06] text-muted hover:text-paper'}`}>{key}</button>
                        ))}
                    </div>
                </div>
                <BitRow label="a" bits={a} onToggle={setA} signed={signed} />
                {!unary && <BitRow label={shift ? 'shift by b' : 'b'} bits={b} onToggle={setB} signed={signed} />}
                <div className="border-t border-line pt-4">
                    <BitRow label={expression} bits={result} signed={signed} />
                </div>
                <p aria-live="polite" className="rounded-xl bg-white/[0.04] px-4 py-3 font-mono text-[13px] leading-6">
                    let a{literal(a)}{!unary && <><br />let b{shift ? `: ${type} = ${b & 7}` : literal(b)}</>}<br />
                    print({expression}) <span className="text-muted">{'// '}{valueOf(result, signed)}</span>
                </p>
                {signed && <p className="text-xs leading-relaxed text-muted">Int8 uses two’s complement: the left bit is worth −128, so 0b11111111 is −1. Shifting a negative Int8 right keeps the sign bit (an arithmetic shift).</p>}
            </div>
        </figure>
    );
};

export default BitPlaygroundView;
