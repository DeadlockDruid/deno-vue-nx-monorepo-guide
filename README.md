# Guide to Setting Up an NX Monorepo with Deno and Vue Apps

### Setup NX Workspace

1. Initialize the workspace
   Create a simple NX workspace with basic JS/TS support:

```bash
yarn create nx-workspace@latest --packageManager yarn
```

2. Update package.json

Ensure the root package.json includes the following configuration:

```
{
  "name": "@deno-vue/source",
  "version": "0.0.0",
  "license": "MIT",
  "private": true,
  "devDependencies": {
    "@nx/js": "20.3.0",
    "prettier": "^2.6.2",
    "typescript": "~5.6.2",
    "nx": "20.3.0"
  },
  "workspaces": [
    "apps/**",
    "libs/**",
    "packages/**"
  ],
  "packageManager": "yarn@4.6.0"
}
```

3. Create apps and libs folders

Follow NX conventions by creating the following directories:

```
mkdir apps libs
```

### Creating Deno Apps

1. Generate Deno projects using Hono

Since NX doesn’t have a generator for Deno apps, manually create them by moving into the apps/backend directory first:

```
mkdir apps/backend
cd apps/backend
deno run -A npm:create-hono@latest
```

2. Set up apps/backend/deno.json

Create a shared deno.json file in apps/backend/:

```
{
  "workspace": ["./deno-app-1", "./deno-app-2"],
  "importMap": "./shared_import_map.json",
  "tasks": {
    "lint": "deno lint",
    "fmt": "deno fmt"
  }
}
```

- workspace: Lists the Deno projects to share configurations.
- importMap: Defines shared libraries for all Deno apps.
- tasks: Common Deno tasks (e.g., linting, formatting) across all projects.

3. Add project.json for each Deno app

Manually configure each Deno app with project.json. Example for deno-app-1:

```
{
  "$schema": "../../../node_modules/nx/schemas/project-schema.json",
  "name": "deno-app-1",
  "projectType": "application",
  "sourceRoot": "apps/backend/deno-app-1",
  "targets": {
    "serve": {
      "executor": "nx:run-commands",
      "options": {
        "command": "deno task start",
        "cwd": "{projectRoot}"
      }
    },
    "lint": {
      "executor": "nx:run-commands",
      "options": {
        "command": "deno lint --config {projectRoot}/deno.json"
      },
      "inputs": ["default"],
      "cache": true
    },
    "compile": {
      "executor": "nx:run-commands",
      "options": {
        "command": "deno compile --config {projectRoot}/deno.json --output {projectRoot}/dist/deno-app-1 {projectRoot}/main.ts"
      },
      "outputs": ["{projectRoot}/dist"],
      "inputs": ["production", "^production"],
      "cache": true
    },
    "test": {
      "executor": "nx:run-commands",
      "options": {
        "command": "deno test --config {projectRoot}/deno.json --coverage={projectRoot}/coverage/ --permit-no-files"
      },
      "inputs": ["default"],
      "cache": true
    },
    "deploy": {
      "executor": "nx:run-commands",
      "options": {
        "command": "bash {projectRoot}/scripts/deploy-app.sh"
      },
      "dependsOn": ["compile"],
      "inputs": ["production"]
    }
  },
  "tags": ["scope:backend", "type:deno"]
}
```

Explanation of Keys:

- targets: Defines various actions (e.g., serve, lint, compile) for the app.
- serve: Runs the Deno server using the start task defined in deno.json.
- lint: Lints the code using Deno’s built-in linter.
- compile: Compiles the Deno app into a standalone binary.
- test: Runs tests with coverage reports.
- deploy: Executes a deployment script after compiling the app.
- tags: Used to categorize the project (e.g., backend, Deno).

---

### Adding Vue Apps

1. Add Vue generator plugin

Install the Vue plugin for NX:

`yarn nx add @nx/vue`

2. Generate a Vue app

Create a Vue app under apps/frontend/:

`yarn nx g @nx/vue:app apps/frontend/vue-app-1`

3. Ensure path aliases

Add path aliases to vite.config.ts for shared libraries:

```
resolve: {
  alias: {
    '@shared': path.resolve(__dirname, '../../../libs/shared')
  }
}
```

---

### Code Sharing via Libraries

1. Generate shared library for Zod schemas

Use NX to create a library for shared Zod schemas:

`yarn nx generate @nx/js:library users --directory=libs/shared/zod-schemas`

2. Update imports for Deno compatibility

Ensure exports in index.ts have .ts extensions for Deno compatibility:

`export * from './lib/users.ts';`

3. Add shared library paths in tsconfig.base.json

Update tsconfig.base.json to include paths for shared libraries:

```
"paths": {
  "@shared/*": ["libs/shared/*"]
}
```

---

### Configuring NX for Efficient Builds

1. Configure .nxignore

Ignore irrelevant files to speed up builds by adding them to .nxignore:

```
**/.vscode
```

2. Update nx.json with default ignored inputs

Add "default" ignored inputs to nx.json:

```
"!{projectRoot}/scripts/**/*",
"!{projectRoot}/**/*.md",
"!{projectRoot}/**/*.{png,jpg,jpeg,gif,svg,ico,json,txt}",
"!{projectRoot}/.editorconfig",
"!{projectRoot}/.prettierrc",
"!{projectRoot}/.prettierignore",
"!{projectRoot}/.vscode/**/*",
"!{projectRoot}/coverage/**/*",
"!{projectRoot}/**/*.log",
"!{projectRoot}/.cache/**/*",
"!{projectRoot}/dist/**/*",
"!{projectRoot}/build/**/*"
```

3. Run NX affected commands

Use the following command to lint, build, test, and compile only affected projects:

```
yarn nx affected --targets=lint,build,test,compile
```

4. Run NX Affected Deploy commands after linting & testing:

```
yarn nx affected --targets=deploy
```

### Summary

## This guide walks through setting up an NX monorepo with Deno and Vue apps. It includes manually configuring Deno apps, generating Vue apps, sharing code via NX libraries, and optimizing builds using NX’s powerful affected commands.
