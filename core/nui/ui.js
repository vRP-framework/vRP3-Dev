export class UIManager {
	constructor() {
		this.uis = {}; // Stores UI elements by ID
		this.createGlobalStyles(); // Inject core styles
	}

	/**
	 * Allows users to add external CSS files dynamically.
	 * @param {string[]} stylesheets - Array of CSS file paths.
	 */
	loadCustomStyles(stylesheets) {
		stylesheets.forEach((sheet) => {
			if (!document.querySelector(`link[href="${sheet}"]`)) {
				const link = document.createElement("link");
				link.rel = "stylesheet";
				link.href = sheet;
				document.head.appendChild(link);
			}
		});
	}

	/**
	 * Creates a new UI dynamically.
	 * @param {string} id - The unique ID of the UI.
	 * @param {Function} renderFunction - A function returning inner HTML.
	 * @param {string} [customStyle] - Optional custom styles for this UI.
	 */
	createUI(id, renderFunction, customStyle = "") {
		if (this.uis[id]) return console.warn(`UI with ID '${id}' already exists.`);

		const uiContainer = document.createElement("div");
		uiContainer.id = id;
		uiContainer.className = "hidden";
		uiContainer.innerHTML = renderFunction();

		if (customStyle) {
			uiContainer.style.cssText += customStyle;
		}

		document.body.appendChild(uiContainer);
		this.uis[id] = uiContainer;

		// // Auto-close button detection
		// const closeBtn = uiContainer.querySelector(".close-btn");
		// if (closeBtn) {
		// 	closeBtn.addEventListener("click", () => {
		// 		this.hideUI(id);
		// 		fetchNui(`hide${id}`);
		// 	});
		// }

		// Ensure UI is hidden initially
		this.hideUI(id);
	}

	/**
	 * Shows a UI.
	 * @param {string} id - The UI ID.
	 */
	showUI(id) {
		if (this.uis[id]) {
			console.log(`Showing UI: ${id}`);
			this.uis[id].classList.remove("hidden");
		} else {
			console.warn(`UI with ID '${id}' not found.`);
		}
	}

	/**
	 * Hides a UI.
	 * @param {string} id - The UI ID.
	 */
	hideUI(id) {
		if (this.uis[id]) {
			this.uis[id].classList.add("hidden");
		}
	}

	/**
	 * Deletes a UI from the DOM.
	 * @param {string} id - The UI ID.
	 */
	removeUI(id) {
		if (this.uis[id]) {
			this.uis[id].remove();
			delete this.uis[id];
		}
	}


	/**
	 * Updates the text content of an element by ID.
	 * @param {string} elementId - The ID of the element to update.
	 * @param {string} newText - The new text content to set.
	 */
	updateText(elementId, newText) {
		const element = document.getElementById(elementId);
		if (element) {
			element.textContent = newText;
		} else {
			console.warn(`Element with ID '${elementId}' not found.`);
		}
	}

	/**
	 * Injects global CSS styles for base UI layout.
	 */
	createGlobalStyles() {
		if (document.getElementById("global-styles")) return;

		const style = document.createElement("style");
		style.id = "global-styles";
		style.innerHTML = `
			.hidden { display: none !important; }
		`;
		document.head.appendChild(style);
	}
}


//////


/**
 * Binds a button to trigger an action or an NUI callback.
 * @param {string} buttonId - The ID of the button.
 * @param {string | null} nuiEvent - The NUI event to send (or null for local actions).
 * @param {Object} [data={}] - Optional data to send with the event.
 * @param {Function} [callback] - Optional function to execute after sending the event.
 */
export function createButton(buttonId, nuiEvent = null, data = {}, callback) {
	const button = document.getElementById(buttonId);
	if (!button) {
		console.warn(`Button with ID '${buttonId}' not found.`);
		return;
	}

	button.addEventListener("click", () => {
		if (nuiEvent) {
			// Send to FiveM client
			fetchNui(nuiEvent, data).then((response) => {
				if (callback) callback(response);
			});
		} else if (callback) {
			// Execute local UI-only action
			callback();
		}
	});
}


// nui.js - Utility functions for FiveM NUI interactions

/**
 * Listens for NUI events from the client.
 * @param {string} eventName - The name of the NUI event.
 * @param {Function} callback - Function to execute when the event is received.
 */
export function useNuiEvent(eventName, callback) {
	window.addEventListener("message", (event) => {
		if (event.data.action === eventName) {
			callback(event.data);
		}
	});
}

/**
 * Sends a callback to the FiveM client (fetchNUI event).
 * @param {string} eventName - The event name.
 * @param {Object} data - The data to send.
 * @returns {Promise<any>} - Resolves with the response from the client.
 */
export function fetchNui(eventName, data = {}) {
	return fetch(`https://${GetParentResourceName()}/${eventName}`, {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify(data),
	})
		.then((res) => res.json())
		.catch((err) => console.error(`NUI Fetch Error (${eventName}):`, err));
}
