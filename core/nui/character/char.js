import { UIManager, createButton, fetchNui, useNuiEvent } from "../ui.js";
const uiManager = new UIManager();
// Load custom stylesheets
uiManager.loadCustomStyles(["./character/char.css"]); // styling

const characters = []; // holds the player's characters for the UI


function renderCharacterSlots() {
	let slots = characters.map((char, index) => `
		<div class="character-slot">
			<p>${char.firstname} ${char.lastname}</p>
			<p>Age: ${char.age}</p>
			<p>Gender: ${char.gender}</p>
			<button class="select-character" data-index="${index}">Select</button>
		</div>`
	).join("");

	const emptySlots = Math.max(3 - characters.length, 0);
	for (let i = 0; i < emptySlots; i++) {
		slots += `<div class="character-slot empty-slot" id="createNewCharacter-${i}">+</div>`;
	}

	return slots;
}

function updateCharacterGrid() {
	document.getElementById('characterGrid').innerHTML = renderCharacterSlots();

	document.querySelectorAll('.empty-slot').forEach((slot) => {
		slot.addEventListener('click', () => {
			uiManager.hideUI("characterSelectionUI"); // hide the first UI(displays all characters)
			uiManager.showUI("characterCreationUI"); // show the second UI(displays the creation for new characters)
		})
	});

	document.querySelectorAll('.select-character').forEach((button) => {
		button.addEventListener('click', (event) => {
			const characterIndex = event.target.dataset.index;
			selectCharacter(characterIndex);
		})
	})
}

function selectCharacter(index) {
	const selectedCharacter = characters[index];
	fetchNui('selectCharacter', { selectedCharacter, index })
	uiManager.hideUI('characterSelectionUI')
}


// Character selection
uiManager.createUI('characterSelectionUI', () => `
	<div class="ui">
		<h1>Select Your Character</h1>
		<div id="characterGrid" class="character-grid">
			${renderCharacterSlots()}
		</div>
	</div>
`)

// Character creation
uiManager.createUI('characterCreationUI', () => `
	<div class='ui'>
		<h1>Create Character</h1>
		<input type="text" id="firstname" placeholder="First Name">
		<input type="text" id="lastname" placeholder="Last Name">
		<input type="range" id="ageSlider" min="20" max="50" value="21">
		<p>Age: <span id="ageValue">30</span></p>
		<select id="gender">
			<option value="male">Male</option>
			<option value="female">Female</option>
		</select>
		<br></br>
		<button id="submitCharacter">Create</button>
		<button id="cancelCharacter" class="close-btn">Close</button>
	</div>
`)


// Show by default
uiManager.showUI('characterSelectionUI')

// button for creating a character
createButton('submitCharacter', null, {}, () => {
	const character = {
		firstname: document.getElementById('firstname').value,
		lastname: document.getElementById('lastname').value,
		age: document.getElementById('ageSlider').value,
		gender: document.getElementById('gender').value
	};

	let slot = null;
	for (let i = 1; i <= 3; i++) {
		if (!characters[i - 1]) {
			slot = i;
			break;
		}
	}

	if (slot === null) {
		console.log('all slots are full')
		return;
	}

	characters[slot - 1] = character;
	updateCharacterGrid()
	uiManager.hideUI('characterCreationUI');
	uiManager.showUI('characterSelectionUI')

	fetchNui('saveCharacter', { slot, character })
})

createButton('cancelCharacter', null, {}, () => {
	uiManager.hideUI('characterCreationUI')
	uiManager.showUI('characterSelectionUI')
})



document.getElementById('ageSlider').addEventListener('input', (e) => {
	document.getElementById('ageValue').textContent = e.target.value;
})

// initial update
updateCharacterGrid();

useNuiEvent('loadCharacters', (data) => {
	if (data.characters) {
		characters.length = 0;

		data.characters.forEach((char, index) => {
			if (!char.firstname || !char.lastname) {
				console.log(`Character ${index} is missing first or lastname!`)
			}

			characters.push({
				firstname: char.firstname || "unknown",
				lastname: char.lastname || "unknown",
				age: char.age || 21,
				gender: char.gender || "unknown"
			})
		})


		//refresh UI with new data
		updateCharacterGrid()
	}
})