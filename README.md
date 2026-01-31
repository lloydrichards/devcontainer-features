# Dev Container Features Collection

A collection of custom Dev Container Features for enhancing development environments.

## Features

| Feature | Description | Container URL |
| --- | --- | --- |
| Hello World | A simple hello world feature for devcontainers. | `ghcr.io/lloydrichards/devcontainer-features/hello-world:1` |
| Oh My Posh Theme | Install oh-my-posh and initialize zsh with a bundled theme. | `ghcr.io/lloydrichards/devcontainer-features/oh-my-posh-theme:1` |

### Usage

Add one or more features to your `devcontainer.json`:

```json
"features": {
  "ghcr.io/lloydrichards/devcontainer-features/oh-my-posh-theme:1": {}
}
```

## Development

### Structure

```txt
.
├── README.md
├── src
│   ├── hello-world
│   └── oh-my-posh-theme
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── README.md
├── test
│   ├── hello-world
│   └── oh-my-posh-theme
│       └── test.sh
└── .github
    └── workflows
        └── publish.yml
```

### Local Development

To test features locally in VS Code:

1. The Dev Containers CLI requires local features to live under `.devcontainer/`.
2. Copy or sync the feature into `.devcontainer/<feature-name>` (for example `.devcontainer/oh-my-posh-theme`).
3. Add the feature to `.devcontainer/devcontainer.json` using a relative path like `"./oh-my-posh-theme": {}`.
4. Rebuild your dev container.

If you want to keep `src/` as the source of truth, add a small sync step that mirrors `src/<feature-name>` into `.devcontainer/<feature-name>` before rebuilding.

### Publishing

Features are automatically published to OCI registry when releases are created.

## Contributing

1. Fork this repository
2. Create a new feature in `src/<feature-name>`
3. Add corresponding test in `test/<feature-name>`
4. Submit a pull request
