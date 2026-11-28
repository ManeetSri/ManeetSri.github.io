// Close to Xcode's default dark theme, so code looks the way it will in Xcode.
// prism-react-renderer applies these through React's style prop, which the site's CSP allows.
export const xcodeTheme = {
    plain: { color: '#F2F0EB', backgroundColor: 'transparent' },
    styles: [
        { types: ['comment', 'prolog', 'doctype', 'cdata'], style: { color: '#7F8C98', fontStyle: 'italic' } },
        { types: ['keyword', 'boolean', 'important', 'atrule'], style: { color: '#FF7AB2', fontWeight: '600' } },
        { types: ['string', 'char', 'attr-value', 'regex'], style: { color: '#FF8170' } },
        { types: ['number'], style: { color: '#D9C97C' } },
        { types: ['class-name', 'builtin', 'constant'], style: { color: '#DABAFF' } },
        { types: ['function', 'function-definition'], style: { color: '#78C2B3' } },
        { types: ['directive', 'property', 'attribute', 'tag'], style: { color: '#FFA14F' } },
        { types: ['operator', 'punctuation'], style: { color: '#C9CBD3' } },
        { types: ['interpolation-punctuation'], style: { color: '#FF7AB2' } },
    ],
};
