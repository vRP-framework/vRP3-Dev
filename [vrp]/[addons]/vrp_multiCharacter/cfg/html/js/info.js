function createInfoTable(data) {
  const infoDiv = document.createElement('div');
  infoDiv.className = 'info';

  const table = document.createElement('table');

  // Define the order of the fields
  const orderedFields = CONFIG.orderedFields;

  orderedFields.forEach((key) => {
    if (data.hasOwnProperty(key)) {
      const row = document.createElement('tr');

      const cell1 = document.createElement('td');
      cell1.textContent = `${key.charAt(0).toUpperCase() + key.slice(1)}:`; // Capitalize the first letter

      const cell2 = document.createElement('td');
      cell2.id = `char${key.replace(/\s+/g, '')}`; // Replace spaces in key for ID
      cell2.textContent = data[key];

      row.appendChild(cell1);
      row.appendChild(cell2);
      table.appendChild(row);
    }
  });

  infoDiv.appendChild(table);
  return infoDiv;
}


function renderInfo(data) {
  const infoContainer = document.getElementById('info-container');
  
  if (infoContainer) {
    infoContainer.innerHTML = ''; // Clear existing content

    if (Object.keys(data).length === 0) {
      // If data object is empty, show "No Character Selected" message
      const noDataMessage = document.createElement('p');
      noDataMessage.textContent = 'No Character Selected';   // Change this message as needed
      infoContainer.appendChild(noDataMessage);
    } else {
      const infoTable = createInfoTable(data);
      infoContainer.appendChild(infoTable);
    }
  } else {
    console.error('Info container element not found.');
  }
}

function showPopup(message, callback) {
  const popup = document.querySelector('.pop-up');
  const messageElement = document.getElementById("popup-message");
  
  // Set the message
  messageElement.textContent = message;
  
  // Show the popup
  popup.style.display = "flex";
  
  // Attach the callback to the OK button
  document.getElementById("accept").onclick = function() {
    popup.style.display = "none";  // Hide the popup
    if (callback) callback();      // Call the callback if provided
  };
}

// Expose the function to the global scope
window.renderInfo = renderInfo;
window.showPopup = showPopup;

// Initialize the info container with "No Character Selected" message on page load
window.addEventListener('DOMContentLoaded', () => {
  renderInfo({}); // Show "No Character Selected" initially
});
