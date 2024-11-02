function renderLocations(locations, onSelect) {
  const locationsContainer = document.querySelector('.locations');
  const maxEntries = 5; // Fixed to 5 locations

  if (locationsContainer) {
    locationsContainer.innerHTML = ''; // Clear existing content

    // Convert locations object to an array and limit to maxEntries
    const displayedLocations = Object.values(locations).slice(0, maxEntries);

    displayedLocations.forEach(location => {
      const locationDiv = document.createElement('div');

      locationDiv.className = 'location';
      locationDiv.textContent = `${location.label}`;

       // Set custom attribute `data-name` to hold the location name
       locationDiv.setAttribute('data-name', location.name);

      // Add click event to select the location
      locationDiv.addEventListener('click', (event) => {
        event.stopPropagation(); // Prevent click event from bubbling up

        // Deselect all locations
        document.querySelectorAll('.location').forEach(el => el.classList.remove('selected'));

        // Select the clicked location
        locationDiv.classList.add('selected');

        post(CONFIG.selLoc, location)

        // Show actions container
        const actionsContainer = document.querySelector('.loc_actions');
        if (actionsContainer) {
          actionsContainer.style.display = 'flex'; // Show actions
        }

        // Invoke the onSelect callback
        if (typeof onSelect === 'function') {
          onSelect(location.name, location.registration);
        }
      });

      locationsContainer.appendChild(locationDiv);
    });
  } else {
    console.error('Locations container element not found.');
  }
}

// Handle location selection
function handleLocationSelect() {
  const selectedLocationElement = document.querySelector('.location.selected'); // Updated to .location.selected to match your render function
  if (selectedLocationElement) {
    const label = selectedLocationElement.textContent;
    
    // Find location in locData based on label
    const location = locData.find(loc => loc.label === label);

    if (location) {    
      // Log the coordinates specifically
      //console.log('Coordinates:', JSON.stringify(location.coords, null, 2));

      post(CONFIG.playLoc, location.coords); 
    } else {
      console.log('No matching location found for label:', label);
    }
  } else {
    showPopup('No location selected to use.');
  }
}


// Expose the function to the global scope
window.renderLocations = renderLocations;

window.handleLocationSelect = handleLocationSelect;