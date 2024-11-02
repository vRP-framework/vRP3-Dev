
function createFormElement(element) {
  const formGroup = document.createElement('div');
  formGroup.className = 'form-group';
  
  if (element.type === 'fieldset') {
    const fieldset = document.createElement('fieldset');
    const legend = document.createElement('legend');
    legend.textContent = element.legend;
    fieldset.appendChild(legend);
    
    element.children.forEach(child => {
      const label = document.createElement('label');
      const input = document.createElement('input');
      input.type = child.type;
      input.name = child.name;
      input.value = child.value;
      input.required = child.required || false;
      label.appendChild(input);
      label.appendChild(document.createTextNode(child.label));
      fieldset.appendChild(label);
    });
    
    formGroup.appendChild(fieldset);
  } else {
    const label = document.createElement('label');
    label.setAttribute('for', element.id);
    label.textContent = element.label;

    const input = document.createElement('input');
    input.type = element.type;
    input.id = element.id;
    input.name = element.name;
    input.placeholder = element.placeholder;
    input.value = element.value || '';
    input.min = element.min || '';
    input.max = element.max || '';
    input.step = element.step || '';
    input.required = element.required || false;

    formGroup.appendChild(label);
    formGroup.appendChild(input);
  }
  
  return formGroup;
}

function renderForm() {
  const form = document.getElementById('dynamic-form');
  
  CONFIG.formElements.forEach(element => {
    const formElement = createFormElement(element);
    form.insertBefore(formElement, form.querySelector('button'));
  });
}

window.addEventListener('submit', (event) => {  
  event.preventDefault(); // Prevent the form from submitting
  
  const form = event.target;
  const formData = new FormData(form);
  const data = Object.fromEntries(formData.entries());
  
  // Simulate adding a new character to charData based on form input
  const newCharacter = {
    name: data.name + ' ' + data.lastname || 'Unnamed',
    age: data.age || 0,
    gender: data.gender || 'Not Specified',
    job: 'Unemployed',  // Default job
    rank: 'None',       // Default rank
    cash: 0,            // Default cash
    bank: 0,            // Default bank
    phone: 'Not Provided',
    registration: data.registration || 'N/A'
  };

  // Add the new character to the charData array
  charData.push(newCharacter);

  // Clear the form fields after submission
  form.reset();

  deselect();

  post(CONFIG.newChar, newCharacter)
});

// Expose the function to the global scope
window.renderForm = renderForm;