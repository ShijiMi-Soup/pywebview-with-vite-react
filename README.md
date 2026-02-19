# Pywebview with Vite React

This is a  simple boilerplate to help you start with _pywebview_, Vite, and React.
Stack is based on pywebview, React, Vite bundler, pyinstaller (Windows/Linux) and py2app (macOS).

## Requirements
- Python 3
- Node

## Tutorials

- English: https://medium.com/@takahiro.zt899/creating-a-desktop-app-with-pywebview-vite-and-react-7785db86490f
- Japanese: https://qiita.com/ShijiMi-Soup/items/1f5e2b542884ca4a279f

## Initialization

### Mac OS

```shell
npm run init
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Windows

```shell
npm run init
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

### Linux

- Linux support is not provided but you can mimic the [original boiller plate](https://github.com/r0x0r/pywebview-react-boilerplate)

## Run in dev mode

### Frontend only (without pywebview)

```shell
npm run dev
```

This starts the Vite dev server on `http://localhost:5173`. Useful for rapid frontend development, but pywebview APIs won't be available.

### Full app with hot reload (recommended for development)

**Terminal 1 - Start Vite dev server:**
```shell
npm run dev
```

**Terminal 2 - Start Python backend in dev mode:**
```shell
npm run dev:backend
```

The Python backend will load the frontend from the Vite dev server (`http://localhost:5173`), enabling:
- ✨ **Hot Module Replacement (HMR)** - Changes appear instantly without full page reload
- 🔄 **React Fast Refresh** - Component state is preserved during updates
- 🚀 **Instant feedback** - No need to rebuild or restart the app

### Production mode (no hot reload)

```shell
npm run start
```

This builds the frontend and runs the backend with static files (traditional mode, no hot reload).

## Build

```shell
npm run build
```

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](./LICENSE) file for more details.

### Third-Party Code

This project includes code from a project by Roman, used under the BSD 3-Clause License. See the [LICENSE-Roman](./LICENSE-Roman) file for more details.
