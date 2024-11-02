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

function deselect() {
  // Hide actions container
  const registerElement = document.getElementById('register');
  const actionsContainer = document.querySelector('.actions');
  const characters = document.querySelectorAll('.character');
  const form = document.getElementById('dynamic-form');
  
  actionsContainer.style.display = 'none'; // Hide actions
  registerElement.style.display = 'none'; // Hide register
  characters.forEach(el => el.classList.remove('selected'));
  form.reset(); // Clear the form fields
}

// Example update function to re-render the character list and selected character info
function update(data) {
  // Re-render the character list
  renderCharacters(data, function(selectedName) {
    const selectedCharacter = data.find(char => char.name === selectedName);
    renderInfo(selectedCharacter || {});
  });
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

window.update = update;
window.post = post;
window.deselect = deselect;
window.renderInfo = renderInfo;