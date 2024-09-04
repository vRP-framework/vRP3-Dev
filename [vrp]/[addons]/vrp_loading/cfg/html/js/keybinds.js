// carousel.js
import { settings, keybindsData } from '../config.js';

const delay = 4000; // 1000 * 4 simplified
let currentSlide = 0;
let autoPlayTimer;

function createCarouselSlide(keybinds) {
    return `
        <div class="carousel-slide">
            <div class="keybinds">
                ${keybinds.map(({ image, text, small }) => `
                    <div class="keybind ${small ? 'small' : ''}">
                        <img class="keybind-img" src="${image}" alt="${text}">
                        <h5 class="keybind-text">${text}</h5>
                    </div>
                `).join('')}
            </div>
        </div>
    `;
}

function renderCarousel() {
    const section = document.getElementById('keybindings');
    section.innerHTML = `<h1>${settings.title}</h1>` + section.innerHTML;

    const container = document.getElementById('carousel-container');
    const carousel = document.createElement('div');
    carousel.className = 'carousel';

    const slidesContainer = document.createElement('div');
    slidesContainer.className = 'carousel-slides';
    slidesContainer.innerHTML = keybindsData.map(data => createCarouselSlide(data.keybinds)).join('');

    carousel.appendChild(slidesContainer);
    carousel.innerHTML += `
        <button class="carousel-control prev">&#10094;</button>
        <button class="carousel-control next">&#10095;</button>
    `;

    container.appendChild(carousel);

    container.addEventListener('click', handleCarouselControls);
}

function handleCarouselControls(event) {
    if (event.target.matches('.prev')) prevSlide();
    if (event.target.matches('.next')) nextSlide();
}

function showSlide(index) {
    const slides = document.querySelector('.carousel-slides');
    const totalSlides = document.querySelectorAll('.carousel-slide').length;

    currentSlide = (index + totalSlides) % totalSlides;
    slides.style.transform = `translateX(${-currentSlide * 100}%)`;
    resetAutoPlay();
}

function nextSlide() {
    showSlide(currentSlide + 1);
}

function prevSlide() {
    showSlide(currentSlide - 1);
}

function resetAutoPlay() {
    clearInterval(autoPlayTimer);
    autoPlayTimer = setInterval(nextSlide, delay);
}

document.addEventListener('DOMContentLoaded', () => {
    autoPlayTimer = setInterval(nextSlide, delay / 2);
    renderCarousel();
});