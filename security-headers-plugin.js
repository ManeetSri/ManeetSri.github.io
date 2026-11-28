import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { CONSOLE_BASES } from './src/utils/privatePaths.js';

// Everything the site is allowed to load or talk to. A new third-party service has to be added here.
const SOURCES = {
    scripts: ['https://www.googletagmanager.com'],
    images: [
        'https://cdn-images-1.medium.com',
        'https://*.google-analytics.com',
        'https://*.googletagmanager.com',
        'https://*.g.doubleclick.net',
        'https://*.google.com',
    ],
    connections: [
        'https://api.rss2json.com',
        'https://*.google-analytics.com',
        'https://*.analytics.google.com',
        'https://*.googletagmanager.com',
        'https://*.g.doubleclick.net',
        'https://*.google.com',
        'https://firebase.googleapis.com',
        'https://firebaseinstallations.googleapis.com',
        'https://firebaseremoteconfig.googleapis.com',
        'https://firebaselogging-pa.googleapis.com',
        'https://ingesteer.services-prod.nsvcs.net',
        // Sign-in and progress sync for the private learning console
        'https://identitytoolkit.googleapis.com',
        'https://securetoken.googleapis.com',
        'https://firestore.googleapis.com',
    ],
};

// The learning console and its code chunks are never indexed. These blocks only add a header:
// repeating the CSP here would make Netlify join two policies into one header.
const PRIVATE_PATHS = [...CONSOLE_BASES.flatMap((base) => [base, `${base}/*`]), '/assets/dsa/*'];

const hashesOf = (html, pattern) => [...html.matchAll(pattern)]
    .map((match) => `'sha256-${createHash('sha256').update(match[1]).digest('base64')}'`);

const contentSecurityPolicy = (html) => {
    // Inline blocks are allowed by exact hash, so only the ones in this build can ever run.
    // JSON-LD isn't executable, so it doesn't need one.
    const inlineScripts = hashesOf(html, /<script(?![^>]*\bsrc=)(?![^>]*application\/ld\+json)[^>]*>([\s\S]*?)<\/script>/g);
    const inlineStyles = hashesOf(html, /<style[^>]*>([\s\S]*?)<\/style>/g);

    return [
        "default-src 'self'",
        `script-src 'self' ${[...inlineScripts, ...SOURCES.scripts].join(' ')}`,
        "worker-src 'self'",
        `style-src 'self' ${inlineStyles.join(' ')}`,
        `img-src 'self' ${SOURCES.images.join(' ')}`,
        "font-src 'self'",
        `connect-src 'self' ${SOURCES.connections.join(' ')}`,
        "object-src 'none'",
        "frame-src 'none'",
        "base-uri 'self'",
        "form-action 'self'",
        "frame-ancestors 'none'",
        'upgrade-insecure-requests',
    ].join('; ');
};

const headersFile = (html) => `/*
  Content-Security-Policy: ${contentSecurityPolicy(html)}
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Permissions-Policy: accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), browsing-topics=()
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Resource-Policy: same-site
/assets/*
  Cache-Control: public, max-age=31536000, immutable
/sw.js
  Cache-Control: no-cache
/manifest.webmanifest
  Cache-Control: no-cache
${PRIVATE_PATHS.map((path) => `${path}\n  X-Robots-Tag: noindex, nofollow, noarchive\n`).join('')}`;

// Writes Netlify's _headers file after the build, because the hashes depend on the final HTML.
// Everything under /assets has a content hash in its name, so browsers can keep it for a year.
export const securityHeaders = () => {
    let outDir = 'dist';

    return {
        name: 'security-headers',
        apply: 'build',
        configResolved: (config) => {
            outDir = config.build.outDir;
        },
        closeBundle: () => {
            const html = readFileSync(join(outDir, 'index.html'), 'utf8');
            writeFileSync(join(outDir, '_headers'), headersFile(html));
        },
    };
};
