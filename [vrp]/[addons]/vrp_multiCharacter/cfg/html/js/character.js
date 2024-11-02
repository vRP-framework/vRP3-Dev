function createCharacterElement(name, info, onSelect) {
  const characterDiv = document.createElement('div');
  characterDiv.className = name === "+" ? 'no-char' : 'character';

  if (name === "+") {
    characterDiv.textContent = "+";
    characterDiv.title = "Add new character"; // Tooltip to indicate action
    characterDiv.addEventListener('click', () => {
      // Show the #register element when "+" is clicked
      const registerElement = document.getElementById('register');
      if (registerElement) {
        // Deselect all characters
        document.querySelector('.actions').style.display = 'none';
        document.querySelectorAll('.character').forEach(el => el.classList.remove('selected'));
        // Clear the info container
        renderInfo({});
        registerElement.style.display = 'block'; // Show register form
      }
    });
  } else {
    const nameDiv = document.createElement('div');
    nameDiv.className = 'name';
    nameDiv.textContent = name;

    const infoDiv = document.createElement('div');
    infoDiv.className = 'info';
    infoDiv.textContent = info;

    characterDiv.appendChild(nameDiv);
    characterDiv.appendChild(infoDiv);

    // Add an event listener for the "select" event
    characterDiv.addEventListener('click', (event) => {
      event.stopPropagation(); // Prevent click event from bubbling up to document

      // Remove 'selected' class from all characters
      document.querySelectorAll('.character').forEach(el => el.classList.remove('selected'));

      // Add 'selected' class to the clicked character
      characterDiv.classList.add('selected');

      // Show actions container
      const actionsContainer = document.querySelector('.actions');
      if (actionsContainer) {
        document.getElementById('register').style.display = 'none'; // Hide register
        actionsContainer.style.display = 'flex'; // Show actions
      }

      if (typeof onSelect === 'function') {
        onSelect(name, info);
      }
    });
  }

  return characterDiv;
}

function renderCharacters(characters, onSelect) {
  const charactersContainer = document.querySelector('.characters');
  const maxEntries = window.CONFIG.MAX_ENTRIES || 4; // Default to 4 if not defined

  if (charactersContainer) {
    charactersContainer.innerHTML = ''; // Clear existing content

    // Limit characters to the maximum entries
    const displayedCharacters = characters.slice(0, maxEntries);

    displayedCharacters.forEach(character => {
      const characterElement = createCharacterElement(character.name, character.registration, (name, info) => {
        post(CONFIG.selChar, character)
        
        // **Invoke the Original onSelect Callback**
        if (typeof onSelect === 'function') {
          onSelect(name, info);
        }
      });
      charactersContainer.appendChild(characterElement);
    });

    // Add placeholder elements for remaining slots
    const placeholdersCount = Math.max(0, maxEntries - displayedCharacters.length);
    for (let i = 0; i < placeholdersCount; i++) {
      const noCharDiv = createCharacterElement("+", "", onSelect);
      charactersContainer.appendChild(noCharDiv);
    }
  } else {
    console.error('Characters container element not found.');
  }
}

// Handle character deletion
function handleDelete() {
  // Find the selected character
  const selectedCharacterElement = document.querySelector('.character.selected');
  if (selectedCharacterElement) {
    const name = selectedCharacterElement.querySelector('.name').textContent;
    
    // Find character in charData
    const character = charData.find(char => char.name === name);

    if (character) {
      const index = charData.indexOf(character);

      // Check if the character is at index 0 and it's the only item in the list
      if (index === 0 && charData.length === 1) {
        showPopup('Cannot delete the only character in the list.');
        return; // Prevent deletion
      }

      if (index > -1) {
        charData.splice(index, 1); // Remove from charData
        post(CONFIG.delChar, character)
        update(); // Re-render the character list
      }
    }
  } else {
    /** todo: create a popup */
    showPopup('No character selected to delete.')
  }
}

// Handle character deletion
function handleSelect() {
  // Find the selected character
  const selectedCharacterElement = document.querySelector('.character.selected');
  if (selectedCharacterElement) {
    const name = selectedCharacterElement.querySelector('.name').textContent;
    
    // Find character in charData
    const character = charData.find(char => char.name === name);

    if (character) { post(CONFIG.playChar, character)  }
  } else {
    showPopup('No character selected to use.')
  }
}

// Expose the function to the global scope
window.renderCharacters = renderCharacters;

window.handleDelete = handleDelete;
window.handleSelect = handleSelect;