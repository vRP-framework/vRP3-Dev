window.addEventListener('DOMContentLoaded', () => {
  // Define the onSelect callback
  function CharSelect(name, info) {
    // Find the character data by info
    const character = charData.find(c => c.registration === info);
    renderInfo(character || {}); // Render character info or empty object if not found
  }

  // Initialize functions if they exist on the window object
  function initializeRendering() {
    const renderFunctions = {
      renderForm: window.renderForm,
      renderInfo: window.renderInfo,
      renderCharacters: window.renderCharacters
    };

    // Call each render function if it exists
    if (typeof renderFunctions.renderForm === 'function') renderFunctions.renderForm();
    if (typeof renderFunctions.renderInfo === 'function') renderFunctions.renderInfo(charData);
    if (typeof renderFunctions.renderCharacters === 'function') {
      renderFunctions.renderCharacters(charData, CharSelect);
    } else {
      console.error('renderCharacters function is not available.');
    }
  }

  initializeRendering();
});

// Reusable function to toggle element display
function toggleDisplay(element, displayStyle) {  
  if (element) element.style.display = displayStyle;
}

function deselect() {
  // Hide actions container
  const register = document.getElementById('register');
  const actionsContainer = document.querySelector('.actions');
  const characters = document.querySelectorAll('.character');
  const locActions = document.querySelector('.loc_actions');
  const locations = document.querySelectorAll('.location');
  const form = document.getElementById('dynamic-form');

  // Hide elements if they exist
  if (actionsContainer) toggleDisplay(actionsContainer, 'none');
  if (locActions) toggleDisplay(locActions, 'none');
  if (register) toggleDisplay(register, 'none');

  // Remove 'selected' class from characters and locations
  characters.forEach(el => el.classList.remove('selected'));
  locations.forEach(el => el.classList.remove('selected'));

  // Reset the form if it exists
  if (form) form.reset();

  // Post to the desChar endpoint
  post(window.CONFIG.desChar, {});
}

// Add click event listener to deselect character when clicking outside
document.addEventListener('click', (event) => {
  const register = document.getElementById('register');
  const clickedElement = event.target;
  const actionsContainer = document.querySelector('.actions');
  const locActions = document.querySelector('.loc_actions');
  const delChar = document.getElementById('delete');
  const selChar = document.getElementById('select');
  const spawn = document.getElementById('spawn');
  const popup = document.querySelector('.pop-up');
  const popup_btn = document.getElementById('accept');  


  // Action handling based on clicked element
  switch (clickedElement) {
    case delChar:
      handleDelete();
      break;
    case selChar:
      handleSelect();
      break;
    case spawn:
      handleLocationSelect();
      break;
    case popup_btn:
      toggleDisplay(popup, 'none');
      break;
  }

  // Check if click is outside specified areas
  if (!clickedElement.closest('.character') &&
      !clickedElement.closest('.location') &&
      !clickedElement.closest('.no-char') &&
      !clickedElement.closest('#register')) {
    
    // Store the references in an array
    const elementsToHide = [actionsContainer, locActions, register];

    // Hide or reset elements if they exist
    elementsToHide.forEach(element => {
      if (element) {
        deselect(); // Call the deselect function if the element exists
        renderInfo({}); // Clear the info container
      }
    });

  }
});

// Example update function to re-render the character list and selected character info
function update() {
  // Re-render the character list
  renderCharacters(charData, function(selectedName) {
    const selectedCharacter = charData.find(char => char.name === selectedName);
    renderInfo(selectedCharacter || {});
  });
}

let charData = [];
let locData = [];

window.addEventListener('message', (event) => {
  const { type, charData: newCharData, locData: newLocData } = event.data;
  const body = document.querySelector('body');
  const characterSelect = document.getElementById('characterSelect');
  const characterInfo = document.getElementById('characterInfo');
  const characterSpawn = document.getElementById('characterSpawn');

  switch (type) {
    case 'open':
      toggleDisplay(body, 'block');
      toggleDisplay(characterSelect, 'block');
      toggleDisplay(characterInfo, 'block');
      toggleDisplay(characterSpawn, 'none');
      break;

    case 'close':
      toggleDisplay(body, 'none');
      break;

    case 'charData':
      charData = Array.isArray(newCharData) ? newCharData : [newCharData];
      const displayedCharacters = charData.slice(0, window.CONFIG.MAX_ENTRIES);

      renderCharacters(displayedCharacters, (name, info) => {
        const character = charData.find(c => c.registration === info);
        renderInfo(character || {});
      });
      break;

    case 'locData':
      toggleDisplay(characterSelect, 'none');
      toggleDisplay(characterInfo, 'none');

      setTimeout(() => {
        toggleDisplay(characterSpawn, 'flex');
      }, 1000); // Wait for 2000 milliseconds (2 seconds)

      locData = Array.isArray(newLocData) ? newLocData : [newLocData];
      renderLocations(locData);
      break;

    default:
      console.error('No data received.');
  }
});

function post(url, data) {
  var xhr = new XMLHttpRequest();
  xhr.open("POST", url, true);
  xhr.setRequestHeader("Content-Type", "application/json");
  
  // Convert data object to JSON string
  var jsonData = JSON.stringify(data);

  xhr.onreadystatechange = function () {
    if (xhr.readyState === XMLHttpRequest.DONE) {
        if (xhr.status === 200) {
            var responseData = JSON.parse(xhr.responseText);
            console.log("Character created successfully:", responseData);
        } else {
            console.log("Failed to create character:", xhr.status, xhr.statusText);
        }
    }
  };

  xhr.send(jsonData);
}

// Expose the funtions/arrays to the global scope
window.charData = charData;
window.locData = locData;

window.update = update;
window.post = post;
window.deselect = deselect;