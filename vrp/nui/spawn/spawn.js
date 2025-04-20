import { UIManager, createButton, fetchNui, useNuiEvent } from "../ui.js";
const uiManager = new UIManager();
// Load custom stylesheets
uiManager.loadCustomStyles(["./spawn/spawn.css"]); // styling

let selectedLocation = null;

useNuiEvent('spawnMenu', (data) => {


	const locations = Object.keys(data.spawns).map((key) => ({
		id: data.spawns[key].id,
		name: key, // display name e.g "Harmony" or "LS Air Port"
		spawnData: data.spawns[key] // stores full spawn data
	}))

	uiManager.createUI('spawnMenu', () => `
		<div class="container">
			<div class="title">Select Location</div>
			<div class="subtitle">Choose between the following locations</div>
			<div class="location-list">
				${locations.map(location => `
					<button id="${location.id}" class="location-item">
						<i class="fas fa-map-marker-alt"></i>
						${location.name}
						<span class="arrow">▶️</span>
					</button>
					`).join("")}
				</div>
			</div>
		</div>
	`)

	uiManager.showUI('spawnMenu')

	locations.forEach(location => {
		createButton(location.id, "selectLocation", { location: location.name }, () => {
			selectedLocation = location.spawnData; // save the selected spawn data
			uiManager.showUI('spawnBtn') // show the spawn button when selected
		})
	})
})


////////

uiManager.createUI('spawnBtn', () => `
	<div class='spawnBtn' id='spawnbtn'>Spawn Here</div>
`)

createButton('spawnbtn', null, {}, () => {
	fetchNui('spawnHere', selectedLocation)
	uiManager.hideUI('spawnBtn')
	uiManager.hideUI('spawnMenu')
})
