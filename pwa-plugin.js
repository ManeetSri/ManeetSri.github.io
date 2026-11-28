import { createHash } from 'node:crypto';
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { CONSOLE_BASES } from './src/utils/privatePaths.js';

const isShellLink = (tag) => /\brel=["'](?:stylesheet|modulepreload)["']/.test(tag);

export const pwa = () => {
    let root;
    let outDir;

    return {
        name: 'portfolio-pwa',
        apply: 'build',
        configResolved(config) {
            root = config.root;
            outDir = resolve(root, config.build.outDir);
        },
        writeBundle(_, bundle) {
            const html = readFileSync(join(outDir, 'index.html'), 'utf8');
            const worker = readFileSync(new URL('./scripts/service-worker.js', import.meta.url), 'utf8');
            const shell = new Set(['/index.html']);

            const addAsset = (name) => {
                const file = bundle[name];
                if (!file || shell.has(`/${name}`)) return;
                shell.add(`/${name}`);
                if (file.type === 'chunk') file.imports.forEach(addAsset);
            };

            for (const tag of html.match(/<(?:script|link)\b[^>]+>/g) ?? []) {
                if (!tag.startsWith('<script') && !isShellLink(tag)) continue;
                const asset = tag.match(/\b(?:src|href)=["']\/(assets\/[^"']+)["']/);
                if (asset) addAsset(asset[1]);
            }

            for (const [name, file] of Object.entries(bundle)) {
                const isScene = file.type === 'chunk' && file.facadeModuleId?.startsWith(`${root}/src/scenes/`);
                const isDefaultFont = /-latin-wght-normal-[^/]+\.woff2$/.test(name);
                if (isScene || isDefaultFont) addAsset(name);
            }

            const projectAssets = readdirSync(join(root, 'public/assets/apps')).filter((name) => name.endsWith('.jpg')).sort();
            const publicAssets = [
                '/manifest.webmanifest',
                '/icons/favicon-phone-16.png',
                '/icons/favicon-phone-32.png',
                ...projectAssets.map((name) => `/assets/apps/${name}`),
            ];
            const version = createHash('sha256').update(html).update(worker).update(JSON.stringify([...shell, CONSOLE_BASES]));
            for (const path of publicAssets) version.update(path).update(readFileSync(join(root, 'public', path.slice(1))));

            const code = worker
                .replace("'__BUILD_VERSION__'", JSON.stringify(version.digest('hex').slice(0, 16)))
                .replace('/* __SHELL_FILES__ */ []', JSON.stringify([...shell, ...publicAssets]))
                .replace('/* __CONSOLE_BASES__ */ []', JSON.stringify(CONSOLE_BASES));
            // writeBundle runs after Rollup has written the final, transformed HTML.
            writeFileSync(join(outDir, 'sw.js'), code);
        },
    };
};
