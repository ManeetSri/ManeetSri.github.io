export const countries = [
    ['Argentina', 'AR', '+54'], ['Australia', 'AU', '+61'], ['Austria', 'AT', '+43'], ['Bahrain', 'BH', '+973'],
    ['Bangladesh', 'BD', '+880'], ['Belgium', 'BE', '+32'], ['Brazil', 'BR', '+55'], ['Canada', 'CA', '+1'],
    ['Chile', 'CL', '+56'], ['China', 'CN', '+86'], ['Colombia', 'CO', '+57'], ['Denmark', 'DK', '+45'],
    ['Egypt', 'EG', '+20'], ['Finland', 'FI', '+358'], ['France', 'FR', '+33'], ['Germany', 'DE', '+49'],
    ['Greece', 'GR', '+30'], ['Hong Kong', 'HK', '+852'], ['India', 'IN', '+91'], ['Indonesia', 'ID', '+62'],
    ['Ireland', 'IE', '+353'], ['Israel', 'IL', '+972'], ['Italy', 'IT', '+39'], ['Japan', 'JP', '+81'],
    ['Kenya', 'KE', '+254'], ['Kuwait', 'KW', '+965'], ['Malaysia', 'MY', '+60'], ['Mexico', 'MX', '+52'],
    ['Nepal', 'NP', '+977'], ['Netherlands', 'NL', '+31'], ['New Zealand', 'NZ', '+64'], ['Nigeria', 'NG', '+234'],
    ['Norway', 'NO', '+47'], ['Oman', 'OM', '+968'], ['Pakistan', 'PK', '+92'], ['Philippines', 'PH', '+63'],
    ['Poland', 'PL', '+48'], ['Portugal', 'PT', '+351'], ['Qatar', 'QA', '+974'], ['Saudi Arabia', 'SA', '+966'],
    ['Singapore', 'SG', '+65'], ['South Africa', 'ZA', '+27'], ['South Korea', 'KR', '+82'], ['Spain', 'ES', '+34'],
    ['Sri Lanka', 'LK', '+94'], ['Sweden', 'SE', '+46'], ['Switzerland', 'CH', '+41'], ['Thailand', 'TH', '+66'],
    ['Turkey', 'TR', '+90'], ['United Arab Emirates', 'AE', '+971'], ['United Kingdom', 'GB', '+44'],
    ['United States', 'US', '+1'], ['Vietnam', 'VN', '+84'],
].map(([name, iso, dial]) => ({ name, iso, dial }));

// Regional indicator letters render as a flag emoji
export const flagFor = (iso) =>
    String.fromCodePoint(...[...iso].map((letter) => 0x1f1e6 + letter.charCodeAt(0) - 65));
