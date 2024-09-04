// config.js
const settings = {
    title: 'Keybindings',
    discordLink: 'https://discord.gg/RBRrUmK7hA',
    audioScr: '../assets/audio/noncopyright.mp3',
    icons: {
        iconFilter: true,
        logo: '../assets/branding/logo_alpha.png',
        download: '../assets/images/downloading.svg',
        setting: '../assets/images/settings.svg',
        filter: {
            invert: '82%',
            sepia: '72%',
            saturate: '800%',
            hueRotation: '117deg',
            brightness: '400%',
            contrast: '105%',
        }
    },
    loading: {
        loadingBarBackgound: '#00ffd5',
        loadingBarColor: '#0c9469',
    },
};

const slidesData = [
    {
        imageSrc: '../assets/images/1.png',
        headingText: 'You can add/remove items, vehicles, jobs & gangs through the shared folder.',
        captionText: 'Photo captured by: Markyoo#8068'
    },
    {
        imageSrc: '../assets/images/2.png',
        headingText: 'Adding additional player data can be achieved by modifying the qb-core player.lua file.',
        captionText: 'Photo captured by: ihyajb#9723'
    },
    {
        imageSrc: '../assets/images/3.png',
        headingText: 'All server-specific adjustments can be made in the config.lua files throughout the build.',
        captionText: 'Photo captured by: FLAPZ[INACTIV]#9925',
        isActive: true
    },
    {
        imageSrc: '../assets/images/4.png',
        headingText: 'For additional support please join our community at discord.gg/qbcore',
        captionText: 'Photo captured by: Robinerino#1312'
    }
];

const keybindsData = [
    {
        keybinds: [
            { image: "../assets/keybinds/TAB.svg", text: "TAB", small: true},
            { image: "../assets/keybinds/Tilde.svg", text: "Tilde" },
            { image: "../assets/keybinds/M.svg", text: "M" },
            { image: "../assets/keybinds/B.svg", text: "B" },
            { image: "../assets/keybinds/LALT.svg", text: "LALT", small: true },
            { image: "../assets/keybinds/F1.svg", text: "F1" },
            { image: "../assets/keybinds/I.svg", text: "I" },
            { image: "../assets/keybinds/LALT.svg", text: "LALT", small: true },
        ]
    },
    {
        keybinds: [
            { image: "../assets/keybinds/L.svg", text: "L" },
            { image: "../assets/keybinds/G.svg", text: "G" },
            { image: "../assets/keybinds/B.svg", text: "B" },
            { image: "../assets/keybinds/HOME.svg", text: "HOME", small: true },
            { image: "../assets/keybinds/Z.svg", text: "Z" },
            { image: "../assets/keybinds/X.svg", text: "X" },
            { image: "../assets/keybinds/NUM.svg", text: "NUM", small: true },
            { image: "../assets/keybinds/Y.svg", text: "Y" },
        ]
    }
];

// Wait for the DOM to be fully loaded
document.addEventListener('DOMContentLoaded', () => {
    const { icons, loading, discordLink, audioScr } = settings;
    const { logo, download, setting, iconFilter, filter } = icons;
    const { loadingBarBackgound, loadingBarColor } = loading;

    // Batch DOM updates
    const elementsToUpdate = [
        { id: 'discord', property: 'href', value: discordLink },
        { id: 'audio', property: 'src', value: audioScr },
        { id: 'logoImg', property: 'src', value: logo },
        { id: 'downloading', property: 'src', value: download },
        { id: 'settings', property: 'src', value: setting }
    ];

    elementsToUpdate.forEach(({ id, property, value }) => {
        const element = document.getElementById(id);
        if (element) element[property] = value;
    });

    if (iconFilter) {
        const settingsElement = document.getElementById('settings');
        const downloadingElement = document.getElementById('downloading');

        if (settingsElement) {
            settingsElement.style.filter = `invert(${filter.invert}) sepia(${filter.sepia}) saturate(${filter.saturate}) hue-rotate(${filter.hueRotation}) brightness(${filter.brightness}) contrast(${filter.contrast})`;
        }

        if (downloadingElement) {
            downloadingElement.style.filter = `invert(${filter.invert}) sepia(${filter.sepia}) saturate(${filter.saturate}) hue-rotate(${filter.hueRotation}) brightness(${filter.brightness}) contrast(${filter.contrast})`;
        }
    }

    // Correctly set background colors
    const loadbar = document.getElementById('loadbar');
    const thingy = document.getElementById('thingy');
    if (loadbar) loadbar.style.backgroundColor = loadingBarBackgound;
    if (thingy) thingy.style.backgroundColor = loadingBarColor;
});

export { settings, slidesData, keybindsData };