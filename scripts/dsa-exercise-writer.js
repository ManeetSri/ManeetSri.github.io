import { existsSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Dev server only. The console's "Save to package" button posts your solution here, and it's written over the
// problem's exercise stub, so `swift test` checks it straight away. Only files that already exist in
// Sources/Exercises can be written. Other sites can't use it: the custom header means a cross-site request
// needs a CORS preflight, which Vite grants only to localhost pages, and a request whose Origin isn't this
// server itself is refused here.
// Each course's Swift package, by the name the console sends
const PACKAGES = {
    dsa: fileURLToPath(new URL('../dsa-swift/Sources/Exercises', import.meta.url)),
    design: fileURLToPath(new URL('../design-swift/Sources/Exercises', import.meta.url)),
};
const FILE = /^[a-z0-9-]+\/[A-Za-z0-9]+\.swift$/;
const MAX_BYTES = 256 * 1024;

const sameHost = (origin, host) => {
    try {
        return new URL(origin).host === host;
    } catch {
        return false;                           // "null" and other opaque origins
    }
};

export const dsaExerciseWriter = () => ({
    name: 'dsa-exercise-writer',
    apply: 'serve',
    configureServer(server) {
        server.middlewares.use('/__dsa/exercise', (request, response) => {
            const reply = (status, message) => {
                response.statusCode = status;
                response.setHeader('Content-Type', 'text/plain; charset=utf-8');
                response.end(message);
            };
            const { origin, host } = request.headers;
            if (request.method !== 'POST' || request.headers['x-dsa-exercise'] !== '1') return reply(405, 'Not allowed');
            if (origin && !sameHost(origin, host)) return reply(403, 'Not from this server');

            const chunks = [];
            let size = 0;
            request.on('data', (chunk) => {
                size += chunk.length;
                if (size > MAX_BYTES) {
                    reply(413, 'Too large');
                    request.destroy();
                } else {
                    chunks.push(chunk);
                }
            });
            request.on('end', () => {
                if (size > MAX_BYTES) return;
                let body;
                try {
                    body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
                } catch {
                    return reply(400, 'Not JSON');
                }
                const { package: name = 'dsa', file, code } = body ?? {};
                const exercises = Object.hasOwn(PACKAGES, name) ? PACKAGES[name] : null;
                if (!exercises || typeof file !== 'string' || !FILE.test(file) || typeof code !== 'string') return reply(400, 'Bad request');
                const path = join(exercises, file);
                if (!existsSync(path)) return reply(404, 'No such exercise');
                writeFileSync(path, code.endsWith('\n') ? code : `${code}\n`);
                reply(200, `Sources/Exercises/${file}`);
            });
        });
    },
    // The editor already shows what was written, so a changed exercise file doesn't reload the page
    handleHotUpdate({ file }) {
        if (Object.values(PACKAGES).some((exercises) => file.startsWith(exercises))) return [];
    },
});
