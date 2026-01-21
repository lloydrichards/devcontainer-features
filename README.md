# Dev Container Features Collection

A collection of custom Dev Container Features for enhancing development environments.

## Features

### Hello World

A simple hello world feature for devcontainers.

**Usage:**

```json
"features": {
    "ghcr.io/lloydrichards/devcontainer-features/hello-world:1": {}
}
```

## Development

### Structure

```txt
.
├── README.md
├── src
│   └── hello-world
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── README.md
├── test
│   └── hello-world
│       └── test.sh
└── .github
    └── workflows
        └── publish.yml
```

### Local Development

To test features locally:

1. Add the feature to your `.devcontainer/devcontainer.json`
2. Use relative path: `"./hello-world": {}`
3. Rebuild your dev container

### Publishing

Features are automatically published to OCI registry when releases are created.

## Contributing

1. Fork this repository
2. Create a new feature in `src/<feature-name>`
3. Add corresponding test in `test/<feature-name>`
4. Submit a pull request
