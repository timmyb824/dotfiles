---
name: security-check-remediate
description: >-
  Run dx security-check and interactively remediate findings. Auto-fixes
  simple errors (.npmrc, Dockerfile issues) and guides analysis of npm
  install script warnings with package reputation research and remediation
  choices.
---

# Remediate security-check findings

Run `dx security-check`, fix simple errors in place, and guide the user through complex decisions (npm install script warnings). Remediation is not done until `dx security-check` passes with no errors and all warnings are addressed.

## Workflow

1. **Run `dx security-check`** via Bash. The command exits non-zero on errors; warnings print in yellow but do not fail the command. Capture all output.
2. **Categorize findings** from the output:
   - **Simple errors** (auto-fixable): `.npmrc` issues, Dockerfile rule violations. See [Simple error remediation](#simple-error-remediation).
   - **Install script warnings** (need analysis): lines starting with `WARNING:` that mention `hasInstallScript` or `ignore-scripts=true`. See [npm install script analysis](#npm-install-script-analysis).
3. **Fix simple errors first** using the table in [Simple error remediation](#simple-error-remediation). Present each fix to the user and offer to apply it. After applying fixes, re-run `dx security-check` to confirm they are resolved before proceeding.
4. **Analyze install script warnings** using parallel sub-agents. See [npm install script analysis](#npm-install-script-analysis).
5. **Present findings and remediate** one package at a time. See [npm install script remediation](#npm-install-script-remediation).
6. **Final verification** — re-run `dx security-check` to confirm clean output.

## Simple error remediation

Each error message from `dx security-check` contains the exact fix. Apply the fix described in the error output. Common patterns:

| Error pattern                                          | Fix                                                                                                                                                     |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Missing .npmrc file in {dir}`                         | Create `{dir}/.npmrc` with: `ignore-scripts=true` on line 1, `registry="https://artifactory.tools.simplisafe.com/artifactory/api/npm/npmjs/"` on line 2 |
| `Missing 'ignore-scripts=true'`                        | Append `ignore-scripts=true` to the `.npmrc` file mentioned in the error                                                                                |
| `Missing the Artifactory registry override`            | Append `registry="https://artifactory.tools.simplisafe.com/artifactory/api/npm/npmjs/"` to the `.npmrc` file                                            |
| `Uses 'npm install' instead of 'npm ci'`               | In the Dockerfile at the cited line, replace `npm install` (or `npm i`) with `npm ci`                                                                   |
| `Runs npm without first copying .npmrc`                | In the Dockerfile, insert `COPY .npmrc ./` before the cited line                                                                                        |
| `Global npm install without --userconfig flag`         | Append `--userconfig .npmrc` to the npm install command at the cited line                                                                               |
| `Direct npm install of {pkg} without a pinned version` | Ask the user for the correct exact version to pin (e.g. `pkg@1.2.3`); this cannot be fully auto-fixed                                                   |

After applying all simple fixes, re-run `dx security-check`. If new errors appear, fix those too. Only proceed to install script analysis after all errors are resolved.

## Install script analysis

This section applies to **all package managers** (npm, yarn v1, yarn v2+). The analysis process is the same; only the remediation actions differ per package manager (see the mapping table below).

**Before researching any package**, check the known findings below. If a package appears in the cache, use those findings directly — do not launch a sub-agent for it. Only launch sub-agents for packages **not** found in the cache.

### Known install script findings

!`cat "${CLAUDE_SKILL_DIR}/known-install-scripts.md" 2>/dev/null || echo "No cached findings available."`

For each **uncached** package, launch a sub-agent (using the Agent tool) to research it. Launch all sub-agents **in a single message** so they run in parallel. Each sub-agent should:

1. **Check package reputation** — use WebSearch to look up the package on npmjs.com. Report: publisher/maintainer, weekly download count, last publish date, and any known supply-chain security incidents.
2. **Find the install script** — read `node_modules/{package}/package.json` and look at the `scripts.install`, `scripts.preinstall`, and `scripts.postinstall` fields. If `node_modules/` does not exist, install dependencies first (npm: `npm ci --ignore-scripts`, yarn v1: `yarn install --frozen-lockfile --ignore-scripts`, yarn v2+: `yarn install --immutable`).
3. **Read the script implementation** — follow the script entry point (e.g. `node install.js`) and read the actual script file in the package's directory. Summarize what it does in 2-3 sentences.
4. **Assess necessity** — is the script required for the package to function at runtime, or is it a development/build-time convenience? Common examples:
   - `esbuild`, `@esbuild/*`: downloads a platform-specific native binary (**required**)
   - `protobufjs`: runs a version scheme postinstall check (**usually not required**)
   - `core-js`: prints a donation/support banner (**not required**)
   - `husky`: sets up git hooks (**not required in CI/containers**)

5. **Assess applicability to target environments** - If allowed to run, this install script can be run either inside a Linux Docker container at build time, OR on a developer laptop (usually MacOS).
6. **Assess applicability to this project** - Are the features enabled by this install script used in this project?

Each sub-agent should return a structured summary: package name, what the script does, risk assessment, and a recommendation (likely needed / likely not needed).

## Install script remediation

After all sub-agents complete, present their findings to the user **one package at a time**. For each package:

1. **Show the findings**: package name, what the install script does, reputation summary, and the sub-agent's recommendation.
2. **Offer a choice** using `AskUserQuestion`:
   - **Option 1: "Not required"** — the install script is unnecessary for this application. Follow [Ignoring a package's install scripts](#ignoring-a-packages-install-scripts).
   - **Option 2: "Needed — generate manual invocation"** — the install script is required. Follow the appropriate section for the package manager.

### PM-to-action mapping

Use this table to translate a "Needed" or "Not needed" finding into the right action for the project's package manager:

| Finding        | npm                                                                                                                                                                                  | yarn v2+                                                    | yarn v1                                                                                                                                                                                |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Needed**     | Add `npm rebuild <pkg> --ignore-scripts=false` to `npm_install_scripts.sh`, update Dockerfile, create `dx install` command, add to `vulnerabilities.npm.ignoreInstallScriptWarnings` | Add `"built": true` to `dependenciesMeta` in `package.json` | Add `npm rebuild <pkg> --ignore-scripts=false` to `yarn_install_scripts.sh`, update Dockerfile, create `dx install` command, add to `vulnerabilities.yarn.ignoreInstallScriptWarnings` |
| **Not needed** | Add to `vulnerabilities.npm.ignoreInstallScriptWarnings`                                                                                                                             | Add to `vulnerabilities.yarn.ignoreInstallScriptWarnings`   | Add to `vulnerabilities.yarn.ignoreInstallScriptWarnings`                                                                                                                              |

### Ignoring a package's install scripts

1. Read the dex config file at `dex/config/project.yaml`.
2. Determine which app section to modify. If the project has multiple apps (check the `apps:` keys), ask the user which app the package belongs to. Most projects use `main`.
3. Add the package name to `apps.{id}.vulnerabilities.npm.ignoreInstallScriptWarnings`. If the `vulnerabilities`, `npm`, or `ignoreInstallScriptWarnings` keys do not exist yet, create the full path. Example result:

```yaml
apps:
  main:
    vulnerabilities:
      npm:
        ignoreInstallScriptWarnings:
          - esbuild
```

### Manual install script invocations

1. Identify the directory containing the `package-lock.json` that triggered the warning.
2. At the same level as that `package-lock.json`, create or append to a file named `npm_install_scripts.sh`.
3. If creating the file, start with:

```sh
#!/bin/sh
set -e
```

4. For each package that needs a manual invocation, add a line:

   ```sh
   # {package-name}: {brief description}
   npm rebuild {package-name} --ignore-scripts=false
   ```

   `npm rebuild` re-runs the package's install/postinstall scripts against the already-installed `node_modules/` tree. The `--ignore-scripts=false` flag overrides the global `.npmrc` `ignore-scripts=true` setting for just this invocation. This is preferred over manually `cd`-ing into `node_modules/` because `npm rebuild` handles lifecycle environment variables (`INIT_CWD`, `npm_config_user_agent`), uses npm's bundled `node-gyp` (avoiding PATH issues in Alpine/Docker), and doesn't require knowing the exact script command.

5. Make the file executable: `chmod +x npm_install_scripts.sh`.

**Example** of a complete `npm_install_scripts.sh`:

```sh
#!/bin/sh
set -e

# esbuild: installs platform-specific native binary
npm rebuild esbuild --ignore-scripts=false

# unix-dgram: compiles native C++ addon via node-gyp
npm rebuild unix-dgram --ignore-scripts=false
```

6. **Update Dockerfiles** — find all Dockerfiles that COPY the corresponding `package.json` and run `npm ci` (these are the same Dockerfiles that `dx security-check` validates). In each one, add a `COPY` and `RUN` directive for `npm_install_scripts.sh` immediately **after** the `RUN npm ci` line:

```dockerfile
RUN npm ci
COPY npm_install_scripts.sh ./
RUN sh npm_install_scripts.sh
```

If the Dockerfile uses a multi-stage build, add these lines in every stage that runs `npm ci` and needs the install scripts. The `COPY` must come after `npm ci` because the scripts operate on the installed `node_modules/` tree.

7. **Create or update `dex/commands/install.ts`** — this is a dex project-defined command so that `dx install` becomes the single entry point for a safe, reproducible dependency install. If `dex/commands/install.ts` already exists, add the `npm_install_scripts.sh` invocation after the existing `npm ci` call. If it does not exist, create it as a new project-defined command. Use the dex shell API (`$` tagged template) and `printer` for output — see the [project-defined commands docs](https://dex.docs.simplisafe.com/docs/commands/project-defined-commands/).

   **dex CWD behavior:** dex commands always execute from the project root, even when invoked from a subdirectory. If the `package.json` (and `package-lock.json`) that triggered the security-check warning lives in a subdirectory (e.g. `src/`, `lambda/`), you must call `process.chdir('<subdir>')` **before** any `npm ci/install` or `sh npm_install_scripts.sh` call. Failure to do so will cause npm to error with "No package.json found."

   Example for a project with two npm subprojects (`src/` and `lambda/`):

```typescript title="dex/commands/install.ts"
import { printer, $, cicd } from "@simplidevops/dex";

export async function command() {
  printer.header("Installing dependencies");

  const originalCwd = process.cwd();
  try {
    // dex always runs from project root — chdir to each subproject before npm
    process.chdir("src");
    await $`npm ${cicd.isCurrentEnvironment ? "ci" : "install"}`;
    await $`sh npm_install_scripts.sh`;

    process.chdir(originalCwd);
    process.chdir("lambda");
    await $`npm ${cicd.isCurrentEnvironment ? "ci" : "install"}`;
    await $`sh npm_install_scripts.sh`;
  } finally {
    process.chdir(originalCwd);
  }

  printer.successFooter("Install completed successfully");
}
```

`sh npm_install_scripts.sh` runs relative to the `chdir`'d directory. If a subproject has no `npm_install_scripts.sh`, omit that line for that subproject.

If a package only needs rebuilding on a specific OS (e.g. `fsevents` is macOS-only), you can inline the rebuild directly instead of adding it to `npm_install_scripts.sh`:

```typescript
// fsevents: macOS-only; npm skips it on Linux due to os:darwin restriction
await $`npm rebuild fsevents --ignore-scripts=false`;
```

Consult the `working-with-dex` skill and existing commands in `dex/commands/` for the exact patterns used in this project (e.g. whether `cicd.isCurrentEnvironment` is used to switch between `npm ci` and `npm install`).

Run `dx install` to validate it works.

8. After creating the script, updating Dockerfiles, and creating the install command, also add the package to `ignoreInstallScriptWarnings` in the dex config (following the steps in [Ignoring a package's install scripts](#ignoring-a-packages-install-scripts)) so the warning is suppressed in future runs.

## Yarn v2+ remediation

Yarn v2+ (Berry) projects use `.yarnrc.yml` instead of `.npmrc`. The remediation patterns are similar to npm but with yarn-specific directives.

### Missing or incomplete `.yarnrc.yml`

Create or update `.yarnrc.yml` with the required security directives:

```yaml
enableScripts: false
npmRegistryServer: "https://artifactory.tools.simplisafe.com/artifactory/api/npm/npmjs/"
```

### Dockerfile fixes for yarn v2+

| Error                                   | Fix                                               |
| --------------------------------------- | ------------------------------------------------- |
| `yarn install` without `--immutable`    | Change to `yarn install --immutable`              |
| `.yarnrc.yml` not copied before install | Add `COPY .yarnrc.yml ./` before the install line |
| `yarn.lock` not copied before install   | Add `COPY yarn.lock ./` before the install line   |

### Packages with build script warnings (yarn)

For each package flagged with a build script warning, there are two remediation paths:

#### If the build script IS needed (e.g. esbuild, native addons)

Yarn v2+ has a **built-in per-package mechanism**. Add `dependenciesMeta` to `package.json`:

```json
{
  "dependenciesMeta": {
    "esbuild": {
      "built": true
    }
  }
}
```

When `enableScripts: false` is set globally, `"built": true` tells yarn to still run that specific package's install scripts. No shell scripts or Dockerfile changes are needed.

#### If the build script is NOT needed (e.g. donation banners, telemetry)

Add the package to `vulnerabilities.yarn.ignoreInstallScriptWarnings` in the dex config (typically `dex/config/project.yaml`) to suppress the warning:

```yaml
apps:
  main:
    vulnerabilities:
      yarn:
        ignoreInstallScriptWarnings:
          - "@nestjs/core"
          - protobufjs
          - "@scarf/scarf"
```

This tells `dx security-check` that you've reviewed the package and its build script is not needed — without adding `"built": true` to `dependenciesMeta` (which would actually run the script).

## Yarn v1 remediation

Yarn v1 (Classic) projects use `.npmrc` for security settings (same as npm). The project-level remediation is identical to npm; the Dockerfile patterns differ.

### Missing or incomplete `.npmrc` (yarn v1)

Create or update `.npmrc` with the required security directives (same as npm):

```
ignore-scripts=true
registry=https://artifactory.tools.simplisafe.com/artifactory/api/npm/npmjs/
```

### Dockerfile fixes for yarn v1

| Error                                      | Fix                                             |
| ------------------------------------------ | ----------------------------------------------- |
| `yarn install` without `--frozen-lockfile` | Change to `yarn install --frozen-lockfile`      |
| `.npmrc` not copied before install         | Add `COPY .npmrc ./` before the install line    |
| `yarn.lock` not copied before install      | Add `COPY yarn.lock ./` before the install line |

### Manual install script invocations (yarn v1)

Yarn v1 has no per-package `dependenciesMeta` mechanism. Use the same `npm rebuild` shell script approach as npm — `npm rebuild` works on yarn v1 projects because it operates directly on the `node_modules/` tree.

1. Create `yarn_install_scripts.sh` at the same level as `yarn.lock`:

```sh
#!/bin/sh
set -e

# esbuild: installs platform-specific native binary
npm rebuild esbuild --ignore-scripts=false

# unix-dgram: compiles native C++ addon via node-gyp
npm rebuild unix-dgram --ignore-scripts=false
```

2. Make executable: `chmod +x yarn_install_scripts.sh`

3. Update Dockerfiles — add after the `yarn install --frozen-lockfile` line:

```dockerfile
RUN yarn install --frozen-lockfile
COPY yarn_install_scripts.sh ./
RUN sh yarn_install_scripts.sh
```

4. Create or update `dex/commands/install.ts` to include the script invocation:

```typescript title="dex/commands/install.ts"
import { printer, $ } from "@simplidevops/dex";

export async function command() {
  printer.header("Installing dependencies");

  await $`yarn install --frozen-lockfile`;
  await $`sh yarn_install_scripts.sh`;

  printer.successFooter("Install completed successfully");
}
```

5. Add the package to `vulnerabilities.yarn.ignoreInstallScriptWarnings` in the dex config.

## Anti-patterns

- Blindly ignoring all install script warnings without researching what the scripts do.
- Running install scripts from packages with low reputation or known supply-chain issues.
- Forgetting to re-run `dx security-check` after applying fixes.
- Modifying the wrong app's config section in multi-app repos.
- Creating `npm_install_scripts.sh` without reading and understanding the actual script implementation.
- Using `npm_install_scripts.sh` for yarn projects — use `dependenciesMeta` instead.
- Forgetting to `process.chdir('<subdir>')` in `dex/commands/install.ts` when `package.json` is not at the project root — dex always runs from the project root, so npm will fail to find `package.json` without an explicit directory change.
- Declaring success without a final clean `dx security-check` run.
