# Devhub Lib

## Overview

**Devhub Lib** is a core library required for all Devhub scripts. It provides essential functions and configuration options to ensure that scripts work seamlessly on your server.

## Why Do I Need It?

-   **Centralized Configuration**: Configure your framework, target system, sound system, and other essential settings in one place.
-   **Plug-and-Play for Devhub Scripts**: Once set up, all future Devhub scripts will work effortlessly without additional configuration.
-   **Open-Source & Customizable**: Modify and extend the library to fit your server's needs.

## Features

-   Support for multiple frameworks
-   Integration with various targeting and sound systems
-   Optimized performance and lightweight
-   Easy-to-update structure

## Installation

1. Download the latest version of **devhub_lib**.
2. Place it in the appropriate resource folder.
3. Ensure that it is started before any Devhub scripts in your `server.cfg`:

```cfg
    ensure your_sql_script
    ensure your_sound_script

    ensure devhub_lib

    ensure your_devhub_script
```

## Documentation

For a full guide on installation, configuration, and usage, visit the [Devhub Lib Documentation](https://docs.devhub.gg/).

## Support

For issues or feature requests, open a ticket on the [Discord](https://discord.com/invite/8uBVD36ZxD).
