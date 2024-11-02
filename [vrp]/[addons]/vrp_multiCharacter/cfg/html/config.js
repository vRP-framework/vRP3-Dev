const CONFIG = {
  MAX_ENTRIES: 5, // Set the maximum number of entries you want

  newChar: 'https://vrp_multiCharacter/createNewCharacter', // set post location for new character
  delChar: 'https://vrp_multiCharacter/deleteCharacter', // set post location for new character
  selChar: 'https://vrp_multiCharacter/selectCharacter', // set post location for select character
  selLoc: 'https://vrp_multiCharacter/selectLocation', // set post location for select location
  desChar: 'https://vrp_multiCharacter/deselectCharacter', // set post location for deselect character
  playChar: 'https://vrp_multiCharacter/playCharacter', // set post location for play character
  playLoc: 'https://vrp_multiCharacter/playLocation', // set post location for play location

  orderedFields: [
    'name', 
    'age', 
    'gender', 
    'job',
    'rank', 
    'cash', 
    'bank', 
    'phone', 
    'registration'
  ],

  formElements: [
    {
      type: 'text',
      id: 'name',
      name: 'name',
      placeholder: 'First Name',
      label: 'First Name'+ ':',
      required: true
    },
    {
      type: 'text',
      id: 'lastname',
      name: 'lastname',
      placeholder: 'Last Name',
      label: 'Last Name'+ ':',
      required: true
    },
    {
      type: 'fieldset',
      legend: 'Gender' + ':',
      children: [
        {
          type: 'radio',
          name: 'gender',
          value: 'male',
          label: 'Male'
        },
        {
          type: 'radio',
          name: 'gender',
          value: 'female',
          label: 'Female'
        }
      ]
    },
    {
      type: 'number',
      id: 'age',
      name: 'age',
      min: 15,
      max: 70,
      step: 1,
      value: 21,
      placeholder: 'Age',
      label: 'Age'+ ':',
      required: true
    }
  ]
};

// Expose the CONFIG object to the global scope
window.CONFIG = CONFIG;