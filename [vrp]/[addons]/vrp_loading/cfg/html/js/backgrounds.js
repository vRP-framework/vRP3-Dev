// backgroundSlides.js
import { slidesData, settings } from '../config.js';

const backgrounds = document.getElementById('backgrounds');
const toggle = document.getElementById("bgToggle");

let autoPlay = true;
let currentIndex = 0;
const delay = 4000; // 1000 * 4, simplified

toggle.checked = autoPlay;

function createSlide({ imageSrc, headingText, captionText, isActive = false }) {
    const slide = document.createElement('div');
    slide.className = `bg_slide ${isActive ? 'active' : ''}`;

    slide.innerHTML = `
        <img src="${imageSrc}" alt="">
        <div class="bg_content">
            <h3>${headingText}</h3>
            <p><b>${captionText}</b></p>
        </div>
    `;

    return slide;
}

function updateSlides() {
    const slides = document.querySelectorAll('#backgrounds .bg_slide');
    slides.forEach((slide, index) => {
        slide.classList.toggle('active', index === currentIndex);
    });
    currentIndex = (currentIndex + 1) % slides.length;
}

function startSlideShow() {
    if (!autoPlay) return; // Stop slideshow if autoPlay is false
    updateSlides();
    setTimeout(startSlideShow, delay);
}

slidesData.forEach(slideData => {
    backgrounds.appendChild(createSlide(slideData));
});

toggle.addEventListener('change', () => {
    autoPlay = toggle.checked;
    if (autoPlay) startSlideShow(); // Restart slideshow if autoPlay is enabled
});

startSlideShow();