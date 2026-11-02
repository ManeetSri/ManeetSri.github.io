import { ArrowLeft } from 'lucide-react';
import { Link } from 'react-router-dom';
import { openCookieSettings } from '../analytics/consent';
import { usePageMeta } from '../hooks/usePageMeta';

const CONTACT_EMAIL = 'srivastavmaneet@gmail.com';
const LAST_UPDATED = '2 November 2026';

const Section = ({ title, children }) => (
    <section className="mt-10">
        <h2 className="mb-3 font-display text-2xl font-semibold tracking-tight">{title}</h2>
        <div className="space-y-3 leading-relaxed text-paper/85">{children}</div>
    </section>
);

const Bullets = ({ items }) => (
    <ul className="list-disc space-y-2 pl-5 marker:text-muted">
        {items.map((item) => <li key={item}>{item}</li>)}
    </ul>
);

const PrivacyPage = () => {
    usePageMeta({
        title: 'Privacy Policy | Maneet Srivastav',
        description: 'What this portfolio collects, why, who it is shared with, and how to change your cookie choices.',
        path: '/privacy',
    });

    return (
        <main className="min-h-svh px-5 pb-28 pt-16 sm:px-10">
            <div className="mx-auto max-w-3xl">
                <Link to="/" className="mb-8 inline-flex min-h-11 items-center gap-2 text-amber hover:underline">
                    <ArrowLeft size={18} aria-hidden="true" /> Back to Home
                </Link>
                <h1 className="font-display text-[clamp(2.6rem,6vw,4.5rem)] font-semibold leading-none tracking-tight">Privacy Policy</h1>
                <p className="mt-4 font-mono text-sm text-muted">Last updated {LAST_UPDATED}</p>
                <p className="mt-6 text-lg leading-relaxed text-paper/85">
                    This is the personal portfolio of Maneet Srivastav. This page explains what the site collects, why, and the choices you have.
                    Questions are welcome at <a href={`mailto:${CONTACT_EMAIL}`} className="text-amber underline">{CONTACT_EMAIL}</a>.
                </p>

                <Section title="Your cookie choices">
                    <p>
                        Analytics and advertising cookies are off until you accept them. You can reject them, and the site works the same either way.
                        You can change your choice at any time. If you withdraw consent, the Google cookies this site set in your browser are removed.
                    </p>
                    <button
                        type="button"
                        onClick={openCookieSettings}
                        className="inline-flex h-11 items-center rounded-full bg-white/10 px-5 text-sm font-semibold transition-colors hover:bg-white/15"
                    >
                        Open cookie settings
                    </button>
                    <p>If your browser sends a Global Privacy Control signal, the site treats that as a "no" and doesn't ask.</p>
                </Section>

                <Section title="Information you choose to send">
                    <Bullets items={[
                        'Contact form: your name, email address and message.',
                        'Feedback form: your star rating, and any comment or email address you add.',
                    ]} />
                    <p>
                        These are used to read and reply to you. They're processed and stored by Netlify, which hosts this site.
                        The "Ship your app" game runs in your browser, and what you enter is only sent if you choose to send it through the contact form.
                    </p>
                </Section>

                <Section title="If you accept analytics">
                    <p>The site uses Google Analytics and Firebase, both provided by Google, to understand how it's used and how well it performs:</p>
                    <Bullets items={[
                        'Pages and sections viewed, how far you scroll and how long you stay.',
                        'What you interact with, such as apps opened, demos played, links clicked and forms sent.',
                        'Approximate location, device, browser, screen type and how you arrived at the site, as reported by Google Analytics.',
                        'Page load speed and technical errors.',
                    ]} />
                    <p>
                        What you type into forms and search boxes isn't included in these measurements. Forms only report things like whether they were sent,
                        the star rating, and whether a comment or email was included.
                    </p>
                </Section>

                <Section title="If you accept advertising">
                    <p>
                        Google's advertising features are also turned on, including Google Signals and ad personalization. Google may use this data to measure ads
                        and to personalize them across its services. This site doesn't display ads. Accepting advertising also turns on analytics, because they share the same system.
                    </p>
                    <p>
                        Google explains its use of this data at{' '}
                        <a href="https://policies.google.com/technologies/partner-sites" target="_blank" rel="noopener noreferrer" className="text-amber underline">how Google uses information from sites that use its services</a>.
                    </p>
                </Section>

                <Section title="Cookies and browser storage">
                    <Bullets items={[
                        'Google Analytics cookies (names beginning with _ga), only if you accept.',
                        'Browser storage for your cookie choice, which is kept for 12 months, and for whether the feedback prompt has been shown. These stay on your device.',
                    ]} />
                </Section>

                <Section title="Other services the site connects to">
                    <p>Loading some content means your browser connects to these services, which can see your IP address and browser details, as with any website:</p>
                    <Bullets items={[
                        'Netlify, which hosts the site.',
                        'rss2json and Medium, which provide the article list and cover images.',
                    ]} />
                    <p>Links to the App Store, GitHub, LinkedIn and Medium take you to those services, which have their own privacy policies.</p>
                </Section>

                <Section title="How long data is kept">
                    <p>
                        Messages and feedback are kept for as long as needed to respond and follow up, and you can ask for them to be deleted.
                        Analytics data is kept according to the retention period set in Google Analytics.
                    </p>
                </Section>

                <Section title="Your rights">
                    <p>
                        Depending on where you live, you may have the right to access, correct or delete your personal data, to object to its use, and to withdraw consent.
                        To ask, email <a href={`mailto:${CONTACT_EMAIL}`} className="text-amber underline">{CONTACT_EMAIL}</a>.
                        You may also be able to complain to your local data protection authority.
                    </p>
                </Section>

                <Section title="Children">
                    <p>This site isn't directed at children and isn't intended to collect their personal data.</p>
                </Section>

                <Section title="Changes">
                    <p>If this policy changes, the updated version will appear here with a new date.</p>
                </Section>
            </div>
        </main>
    );
};

export default PrivacyPage;
