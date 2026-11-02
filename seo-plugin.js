import { career } from './src/data/career.js';
import { projects } from './src/data/projects.js';
import { faqs, services } from './src/data/services.js';

const SITE_URL = 'https://maneet-srivastav.netlify.app/';
const PROFILES = [
    'https://github.com/ManeetSri',
    'https://www.linkedin.com/in/maneet-srivastav-1499a1196/',
    'https://medium.com/@maneetsrivastav',
];

const escapeHtml = (text) => text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

const list = (items, render) => `<ul>${items.map((item) => `<li>${render(item)}</li>`).join('')}</ul>`;

// The site's content as plain HTML, for crawlers that don't run JavaScript.
// React replaces it on load, so people and crawlers get the same information.
const renderContent = () => `<div id="seo-content">
    <h1>Maneet Srivastav: iOS &amp; Android app developer</h1>
    <p>Mobile app developer shipping production iOS and Android apps with Swift, SwiftUI, UIKit and React Native. Open to mobile app development and project work.</p>
    <p><a href="/build">Ship your app: a mobile app building game</a> · <a href="/privacy">Privacy Policy</a> · <a href="/resume.pdf">Resume (PDF)</a> · <a href="mailto:srivastavmaneet@gmail.com">Email</a> · ${PROFILES.map((url) => `<a href="${url}">${new URL(url).hostname.replace('www.', '')}</a>`).join(' · ')}</p>
    <h2>Mobile app development services</h2>
    ${list(services, (service) => `<strong>${escapeHtml(service.title)}</strong>: ${escapeHtml(service.body)}`)}
    <h2>Apps I've worked on</h2>
    ${list(projects, (project) => `${project.link ? `<a href="${project.link}">${escapeHtml(project.title)}</a>` : escapeHtml(project.title)}: ${escapeHtml(project.category)}. ${escapeHtml(project.description)}`)}
    <h2>Experience</h2>
    ${list(career, (role) => `<strong>${escapeHtml(role.company)}</strong>, ${escapeHtml(role.role)} (${escapeHtml(role.period)}). ${escapeHtml(role.notes.join(' '))}`)}
    <h2>Frequently asked questions</h2>
    ${faqs.map((faq) => `<h3>${escapeHtml(faq.question)}</h3><p>${escapeHtml(faq.answer)}</p>`).join('')}
  </div>`;

const structuredData = () => JSON.stringify({
    '@context': 'https://schema.org',
    '@graph': [
        {
            '@type': 'WebSite',
            '@id': `${SITE_URL}#website`,
            url: SITE_URL,
            name: 'Maneet Srivastav',
        },
        {
            '@type': 'Person',
            '@id': `${SITE_URL}#person`,
            name: 'Maneet Srivastav',
            jobTitle: 'Mobile App Developer',
            url: SITE_URL,
            email: 'mailto:srivastavmaneet@gmail.com',
            image: `${SITE_URL}assets/og-image.png`,
            sameAs: PROFILES,
            knowsAbout: ['iOS app development', 'Android app development', 'Mobile app development', 'Swift', 'SwiftUI', 'UIKit', 'React Native', 'Firebase'],
        },
        {
            '@type': 'ProfessionalService',
            '@id': `${SITE_URL}#service`,
            name: 'Maneet Srivastav – Mobile App Development',
            url: SITE_URL,
            image: `${SITE_URL}assets/og-image.png`,
            founder: { '@id': `${SITE_URL}#person` },
            address: { '@type': 'PostalAddress', addressCountry: 'IN' },
            areaServed: 'Worldwide',
            knowsLanguage: 'en',
            hasOfferCatalog: {
                '@type': 'OfferCatalog',
                name: 'Mobile app development services',
                itemListElement: services.map((service) => ({
                    '@type': 'Offer',
                    itemOffered: { '@type': 'Service', name: service.title, description: service.body },
                })),
            },
        },
        {
            '@type': 'FAQPage',
            mainEntity: faqs.map((faq) => ({
                '@type': 'Question',
                name: faq.question,
                acceptedAnswer: { '@type': 'Answer', text: faq.answer },
            })),
        },
    ],
});

export const seoContent = () => ({
    name: 'seo-content',
    transformIndexHtml: (html) => html
        .replace('<!--seo-content-->', renderContent)
        .replace('<!--seo-jsonld-->', () => `<script type="application/ld+json">${structuredData().replace(/</g, '\\u003c')}</script>`),
});
