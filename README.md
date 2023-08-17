# Loto

This project is a lottery game based on french Loto past results.

https://loto.jbreynaud.com

## Project Setup

```sh
npm install
```

### Compile and Hot-Reload for Development

```sh
npm run dev
```

## Data

### Where the data came from?

The data came from official french Loto website: https://www.fdj.fr/jeux-de-tirage/loto/historique

### Import data

```bash
brew install -q wget jq vim

sh import-results.sh
```
