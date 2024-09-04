// loadingBar.js
let count = 0;
let thisCount = 0;
let audioPlay = true;
let videoPlay = false;

const audioToggle = document.getElementById("audioToggle");
const videoToggle = document.getElementById("videoToggle");
const thingy = document.querySelector(".thingy");
const audio = document.getElementById("audio");
const video = document.getElementById("video");

audioToggle.checked = audioPlay;
videoToggle.checked = videoPlay;

const handlers = {
    startInitFunctionOrder({ count: dataCount }) {
        count = dataCount;
    },

    initFunctionInvoking({ idx }) {
        updateLoadingBar(idx / count);
    },

    startDataFileEntries({ count: dataCount }) {
        count = dataCount;
    },

    performMapLoadFunction() {
        updateLoadingBar(++thisCount / count);
    },
};

function updateLoadingBar(percentage) {
    const width = percentage * 100 + "%";
    thingy.style.left = "0%";
    thingy.style.width = width;
}

function toggleDetails() {
    document.querySelector('.dwnCard').classList.toggle('active');
}

function toggleSettings() {
    document.querySelector('.setCard').classList.toggle('active');
}

function toggleAudio() {
    audioPlay ? audio.play() : audio.pause();
    audioPlay = !audioPlay;
}

function toggleVideo() {
    videoPlay = !videoPlay;
    videoPlay ? video.play() : video.pause();
}

// General event handler for messages
window.addEventListener("message", ({ data }) => {
    const handler = handlers[data.eventName];
    if (handler) handler(data);
});

// Click event listener
window.addEventListener('click', ({ target }) => {
    if (target.matches('#downloadBtn, #downloading, .closeDetails')) {
        toggleDetails();
    } 
    if (target.matches('#settingsBtn, #settings, .closeSettings')) {
        toggleSettings();
    }
});

// Toggle event listeners
audioToggle.addEventListener('change', toggleAudio);
videoToggle.addEventListener('change', toggleVideo);

toggleAudio();