window.config = {
    soundVolume: 0.2, // Default sound volume
    numberFormatting: {
        pattern: /\B(?=(\d{3})+(?!\d))/g,
        separator: " ",
    },

    // Pattern for formatting prices with thousand separators
    priceFormatting: {
        // For thousand separators (e.g., 1000 -> 1 000)
        numberPattern: /\B(?=(\d{3})+(?!\d))/g,
        numberSeparator: " ",

        // For currency symbol
        // Use at the beginning: [/^(\d)/, '€$1'] for €100
        // Use at the end: [/(\d)$/, '$1€'] for 100€
        currencyPattern: /^(\d)/,
        currencyFormat: "$$$1", // Adds $ at the start (e.g., $100)
    },
};
