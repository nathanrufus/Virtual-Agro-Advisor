# agroAdvisor

A Jac client-side application with React support.

## Project Structure

```
agroAdvisor/
├── jac.toml              # Project configuration
├── main.jac              # Main application entry
├── components/           # Reusable components
│   └── Button.cl.jac     # Example Jac component
├── assets/               # Static assets (images, fonts, etc.)
└── build/                # Build output (generated)
```

## Getting Started

Start the development server:

```bash
jac start main.jac
```

## Components

Create Jac components in `components/` as `.cl.jac` files and import them:

```jac
cl import from .components.Button { Button }
```

## Adding Dependencies

Add npm packages with the --cl flag:

```bash
jac add --cl react-router-dom
```


pip install requests sentence-transformers chromadb

[KAMIS] Command: python scripts/kamis_search_downloader.py --crop maize --market kiambu, kenya --days 30

python scripts/rag_search_chroma.py \
"stunted growth" \
maize \
kiambu


python3 scripts/chroma_server.py
