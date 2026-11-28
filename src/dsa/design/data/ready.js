// Every written lesson, by id, gathered from one file per module in ./ready/<module>.js. A lesson listed
// here is 'ready' (it has src/dsa/design/content/lessons/<module>/<id>.mdx); every other lesson is a stub.
// One file per module means writers working on different modules never edit the same file.
import orientation from './ready/sd-orientation.js';
import quality from './ready/sd-quality.js';
import modelling from './ready/sd-modelling.js';
import coupling from './ready/sd-coupling.js';
import solid from './ready/sd-solid.js';
import principles from './ready/sd-principles.js';
import swiftDesign from './ready/sd-swift-design.js';
import functional from './ready/sd-functional.js';
import styles from './ready/sd-styles.js';
import diagrams from './ready/sd-diagrams.js';
import creational from './ready/sd-creational.js';
import structural from './ready/sd-structural.js';
import behavioural1 from './ready/sd-behavioural-1.js';
import behavioural2 from './ready/sd-behavioural-2.js';
import resiliencePatterns from './ready/sd-resilience-patterns.js';
import refactoring from './ready/sd-refactoring.js';
import appRuntime from './ready/sd-app-runtime.js';
import uikit from './ready/sd-uikit.js';
import swiftui from './ready/sd-swiftui.js';
import state from './ready/sd-state.js';
import navigation from './ready/sd-navigation.js';
import di from './ready/sd-di.js';
import concurrency from './ready/sd-concurrency.js';
import reactive from './ready/sd-reactive.js';
import diagnostics from './ready/sd-diagnostics.js';
import archGoals from './ready/sd-arch-goals.js';
import mvc from './ready/sd-mvc.js';
import mvvm from './ready/sd-mvvm.js';
import unidirectional from './ready/sd-unidirectional.js';
import viper from './ready/sd-viper.js';
import clean from './ready/sd-clean.js';
import archEvolution from './ready/sd-arch-evolution.js';
import networking from './ready/sd-networking.js';
import networkLayer from './ready/sd-network-layer.js';
import apiDesign from './ready/sd-api-design.js';
import realtime from './ready/sd-realtime.js';
import persistence from './ready/sd-persistence.js';
import persistenceArch from './ready/sd-persistence-arch.js';
import caching from './ready/sd-caching.js';
import offlineSync from './ready/sd-offline-sync.js';
import media from './ready/sd-media.js';
import backendBasics from './ready/sd-backend-basics.js';
import estimation from './ready/sd-estimation.js';
import scaling from './ready/sd-scaling.js';
import dataAtScale from './ready/sd-data-at-scale.js';
import asyncSystems from './ready/sd-async-systems.js';
import push from './ready/sd-push.js';
import auth from './ready/sd-auth.js';
import observability from './ready/sd-observability.js';
import security from './ready/sd-security.js';
import privacy from './ready/sd-privacy.js';
import performance from './ready/sd-performance.js';
import background from './ready/sd-background.js';
import a11yL10n from './ready/sd-a11y-l10n.js';
import flags from './ready/sd-flags.js';
import analytics from './ready/sd-analytics.js';
import payments from './ready/sd-payments.js';
import onDeviceMl from './ready/sd-on-device-ml.js';
import testability from './ready/sd-testability.js';
import testing from './ready/sd-testing.js';
import release from './ready/sd-release.js';
import modularisation from './ready/sd-modularisation.js';
import designSystems from './ready/sd-design-systems.js';
import largeCodebases from './ready/sd-large-codebases.js';
import crossPlatform from './ready/sd-cross-platform.js';
import sdkDesign from './ready/sd-sdk-design.js';
import interview from './ready/sd-interview.js';
import casesSdks from './ready/sd-cases-sdks.js';
import casesSocial from './ready/sd-cases-social.js';
import casesRealtime from './ready/sd-cases-realtime.js';
import casesLocation from './ready/sd-cases-location.js';
import casesCommerce from './ready/sd-cases-commerce.js';
import casesPlatform from './ready/sd-cases-platform.js';
import mocks from './ready/sd-mocks.js';
import leadership from './ready/sd-leadership.js';
import capstones from './ready/sd-capstones.js';

export default new Set([
    ...orientation,
    ...quality,
    ...modelling,
    ...coupling,
    ...solid,
    ...principles,
    ...swiftDesign,
    ...functional,
    ...styles,
    ...diagrams,
    ...creational,
    ...structural,
    ...behavioural1,
    ...behavioural2,
    ...resiliencePatterns,
    ...refactoring,
    ...appRuntime,
    ...uikit,
    ...swiftui,
    ...state,
    ...navigation,
    ...di,
    ...concurrency,
    ...reactive,
    ...diagnostics,
    ...archGoals,
    ...mvc,
    ...mvvm,
    ...unidirectional,
    ...viper,
    ...clean,
    ...archEvolution,
    ...networking,
    ...networkLayer,
    ...apiDesign,
    ...realtime,
    ...persistence,
    ...persistenceArch,
    ...caching,
    ...offlineSync,
    ...media,
    ...backendBasics,
    ...estimation,
    ...scaling,
    ...dataAtScale,
    ...asyncSystems,
    ...push,
    ...auth,
    ...observability,
    ...security,
    ...privacy,
    ...performance,
    ...background,
    ...a11yL10n,
    ...flags,
    ...analytics,
    ...payments,
    ...onDeviceMl,
    ...testability,
    ...testing,
    ...release,
    ...modularisation,
    ...designSystems,
    ...largeCodebases,
    ...crossPlatform,
    ...sdkDesign,
    ...interview,
    ...casesSdks,
    ...casesSocial,
    ...casesRealtime,
    ...casesLocation,
    ...casesCommerce,
    ...casesPlatform,
    ...mocks,
    ...leadership,
    ...capstones,
]);
