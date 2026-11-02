import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';

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
    ],
};

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
`;

// Writes Netlify's _headers file after the build, because the hashes depend on the final HTML
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
