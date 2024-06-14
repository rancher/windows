# Setting Up Repositories

This document is a guide on known steps for setting up new Rancher repositories that contain one or more of the following:

1. User / Developer Docs

2. Application Code / Scripts (Go, Bash, PowerShell, .NET)

3. Docker Images

4. Helm Charts

If your repository does not need one of the above, skip that section.

## Minimum Requirements

On creating a Rancher repository, there are a couple of files that should always exist:

1. [`README.md`](../../README.md)

2. [`LICENSE`](../../LICENSE)

3. [`CODEOWNERS`](../../CODEOWNERS)

4. [`MAINTAINERS.md`](../../MAINTAINERS.md)

5. [`CODE_OF_CONDUCT.md`](../../CODE_OF_CONDUCT.md)

6. [`CONTRIBUTING.md`](../../CONTRIBUTING.md): make sure you replace references to `rancher/windows` to match your repository

7. `SECURITY.md`

8. [`.gitignore`](../../.gitignore): make sure it ignores `.DS_STORE`, `*.swp`, `.vscode`, and `.idea` at minimum

9. [`.gitattributes`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/.gitattributes)

10. [`.github/ISSUE_TEMPLATE/bug_report.md`](../../.github/ISSUE_TEMPLATE/bug_report.md): modify this to your repository's needs

11. [`.github/ISSUE_TEMPLATE/feature_request.md`](../../.github/ISSUE_TEMPLATE/feature_request.md): modify this to your repository's needs

12. [`.github/workflows/label_opened_issues.yml`](../../.github/workflows/label-opened-issues.yml): update the label from `team/area2` to your team's label on GitHub

13. [`.github/workflows/stale.yml`](../../.github/workflows/stale.yml)

> **Note**: You will need to ensure this repository has a `GITHUB_TOKEN` secret for the `label-opened-issues.yml` workflow to work.

### Setting up build targets

It's typical for most Rancher repositories to include a [`Makefile`](https://www.gnu.org/software/make/) that identifies build targets for developers to use (`make prepare`, `make build`, `make ci`, etc.).

This `Makefile` typically contains targets that point into the (Bash) `scripts/` directory, i.e.

```text
TARGETS := $(shell ls scripts)
```

`make lint` is equivalent to running `./scripts/lint`.

### Setting up cross-platform build targets

If you are creating a repository that needs to run on Windows, typically we replace `make` with [`mage`](https://github.com/magefile/mage), since it allows us to encode our scripts in Go (which is cross-platform).

If you are using mage, see the [`magefiles/magefiles.go`](https://github.com/rancher/wins/blob/main/magefiles/magefile.go) on the `rancher/wins` repository for an example on how to set this up.

### Verifying

Once you have made the above changes, your new repository should look as follows:

```markdown
.github/
    ISSUE_TEMPLATE/
        bug_report.md
        feature_request.md
    workflows/
        label_opened_issues.yml
        stale.yml
.gitattributes
.gitignore
CODEOWNERS
CODE_OF_CONDUCT.md
CONTRIBUTING.md
LICENSE
MAINTAINERS.md
README.md
SECURITY.md
Makefile # or `mage.go` or `magefiles/*`
```

## User / Developer Docs

Once you have created the boilerplate files, it's a good idea to start by creating a [`docs/README.md`](../README.md) that points to a couple of other docs targeted to different audiences of your repository.

> **Note**: A good example of a repository with these kinds of docs is [`rancher/helm-project-operator`](https://github.com/rancher/helm-project-operator).

### Reference Docs

Here are some good examples of docs you should write.

#### `getting_started.md`

A doc for first-time users or new developers. This should be a short document with clear, step-by-step instructions on how to get started running the **final product** of your repository.

If your repository ships Helm chart(s), it should tell a user how to install that chart on a Kubernetes cluster locally (i.e. the helm command) and how to install it on Rancher's Apps & Marketplace.

If your repository ships Docker image(s), it should tell a user how to run the Docker image locally (i.e. the docker command).

If your repository ships application(s) (i.e. Go binary), it should tell a user what commands they can run on it.

If your repository ships a library (i.e. Go modules), it should tell a user how to run the tests.

#### `developing.md`

A doc for new or experienced developers. This should be a mechanical document that gives clear, step-by-step instructions on how to make changes at **every** level and test them.

If your repository ships a library (i.e. Go modules), it should tell a user how to run the tests.

If your repository ships application(s) (i.e. Go binary), it should tell a user how to build the application (ideally provide the one-liner they need to run).

If your repository ships Docker image(s), it should tell a user how to build the Docker image (once you have built the application) locally and push it to your own Docker registry (ideally provide the one-liner they need to run).

If your repository ships Helm chart(s), it should tell a user how to provide overrides to the Helm chart with your custom image(s).

#### `design.md`

A doc for experienced developers and advanced users. This should be a lengthy reference guide.

This is the document where you talk in detail about software design, purpose, and implementation details.

A great example of such a doc is the one on [`k3s-io/kine`](https://github.com/k3s-io/kine/blob/master/docs/flow.md).

### Adding CI

It's generally a good idea to add some form of linting to your repository for docs.

In this repository, we use three linting solutions:

1. [`markdownlint`](https://github.com/DavidAnson/markdownlint): checks for basic formatting inconsistencies in Markdown files. Make sure you add [.markdownlint.json](../../.markdownlint.json).

2. [`write-good`](https://github.com/btford/write-good): checks for readability issues, such as using passive voice

3. [`spellchecker`](https://github.com/tbroadley/spellchecker-cli): checks for spelling mistakes. See [`.spellcheckerrc.yaml`](../../.spellcheckerrc.yaml) and [`.spellchecker.dict.txt`](../../.spellchecker.dict.txt) for example configuration

> **Note**: For a quick setup, use `markdownlint` and `write-good` since they require the least customization.

To copy this setup, copy [scripts/lint](../../scripts/lint) and modify it accordingly for your repository (e.g. add more excluded `markdown_files`, remove `charts_dirs`, remove `terraform_dirs`, etc.).

Once you set everything else up, make sure you create a `.github/workflows/lint_docs.yml` file to set up a GitHub Actions Workflow and test it:

```yaml
name: Lint Docs

on:
  push:
    branches:
    - main
    paths:
    - '**/*.md'
  pull_request:
    branches:
    - main
    paths:
    - '**/*.md'

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: actions/setup-node@v3

    - name: Install dependencies
      run: |
        npm install -g markdownlint-cli
        npm install -g write-good
        # Uncomment this if you would like to use spellchecker-cli
        # npm install -g spellchecker-cli

    - name: Run custom lint script
      run: ./scripts/lint
```

### Verifying

Once you have finished these steps, you should see the following added files and/or directories:

```markdown
.github/
    workflows/
        lint_docs.yml
docs/
    getting_started.md
    design.md
    developing.md
    # other *.md files
    README.md
scripts/
    lint
```

## Application Code / Scripts

Your application code / scripts should belong to the canonical set of directories depending on which language you are using.

If you are using Bash for build scripts, it should be in the `scripts/` directory.

If you are using PowerShell for build scripts, it should be in the `scripts/windows` directory.

If you are developing PowerShell modules / scripts or .NET code, it should be in the `src/` directory.

When in doubt, look for other Rancher repositories that have similar contents and replicate their directory structure.

### Go Code

Since the majority of applications developed in Rancher will involve Go code, there are specific patterns we follow with new repositories.

To start, make sure you create a `go.mod` by running `go mod init rancher/<repo-name>`. Always use `rancher/` as the prefix on initialization to avoid renames on imports when you move it to an official Rancher repository.

#### Go Modules

The majority of your code (i.e. your Go modules) should belong in the `pkg/` directory. If you are creating a Go library, like [`rancher/permissions`](https://github.com/rancher/permissions), no other directory should contain Go code.

#### `main.go`

If you are shipping a tool or CLI Binary (i.e. `system-agent`, `wins`, `fleet`, etc.), the canonical tool we use for setting up the CLI is [`rancher/wrangler-cli`](https://github.com/rancher/wrangler-cli). This wraps [`spf13/cobra`](https://github.com/spf13/cobra), a popular library for creating CLI applications, in a clean and readable way.

> **Note**: A good example of a repository that uses `rancher/wrangler-cli` in a single `main.go` is [`rancher/helm-locker`](https://github.com/rancher/helm-locker/blob/main/main.go).

If the CLI tool you are building does not use sub-commands (e.g. `helm-locker <args>`), you can place the `rancher/wrangler-cli` logic directly in a `main.go`.

If the CLI tool you are building uses sub-commands (e.g. `wins cli prc run <args>`), it's typical to place your `main.go` in a `cmd/main.go` with `cmd/<subcommand>/*.go` containing the logic for executing the sub-commands.

If you are building multiple CLI tools, it's typical to place each tool's `main.go` under `cmd/<tool>/main.go` instead.

> **Note**: A good example of a repository that organizes sub-commands in `cmd/` is [`rancher/Rancher-Plugin-gMSA`](https://github.com/rancher/Rancher-Plugin-gMSA/tree/main/cmd).

It's also typical for us to define [`pkg/version/version.go`](https://github.com/rancher/helm-locker/blob/main/pkg/version/version.go) for tools / CLI binaries to report their version.

This module contains a simple `FriendlyVersion` function that takes in the hard-coded `Version` and `GitCommit`, which is typically overridden on `go build` by specifying the following `LINKFLAGS` in a `scripts/build` file:

```bash
REPO="<repo>"

mkdir -p bin
if [ "$(uname)" = "Linux" ]; then
    OTHER_LINKFLAGS="-extldflags -static -s"
fi
LINKFLAGS="-X github.com/rancher/$REPO/pkg/version.Version=$VERSION"
LINKFLAGS="-X github.com/rancher/$REPO/pkg/version.GitCommit=$COMMIT $LINKFLAGS"
CGO_ENABLED=0 go build -ldflags "$LINKFLAGS $OTHER_LINKFLAGS" -o bin/$REPO
```

#### Generated code

If you are generating code (which is common for controllers written in Go), define a [`generate.go`](https://github.com/rancher/helm-locker/blob/main/generate.go) file at the repository root that runs your `go generate` commands.

This is generally accompanied by a [`scripts/validate-ci`](https://github.com/rancher/helm-locker/blob/main/scripts/validate-ci) target that runs `go generate` and then enforces that Git is clean.

Common directories that get auto-generated like this include:

1. [`crds/`](https://github.com/rancher/helm-locker/tree/main/crds)

2. [`pkg/generated/`](https://github.com/rancher/helm-locker/tree/main/pkg/generated)

3. Some of the files in [`./pkg/apis`](https://github.com/rancher/helm-locker/tree/main/pkg/apis) that start with `zz_generated`

Typically, we place `go generate` logic in a single module at [`pkg/codegen/`](https://github.com/rancher/helm-locker/tree/main/pkg/codegen).

Some useful wrangler packages that are using in code generation for Kubernetes clusters include:

1. [`cleanup`](https://github.com/rancher/wrangler/blob/master/pkg/cleanup): removes `zz_generated` files from a directory

2. [`crd`](https://github.com/rancher/wrangler/tree/master/pkg/crd): provides a utility to batch create CRDs when provided a `*rest.Config` to a Kubernetes cluster (one of the first steps a controller takes on initialization) as well as contains utilities that convert those same structs into YAML objects placed in the `crd/` directory

3. [`yaml`](https://github.com/rancher/wrangler/tree/master/pkg/yaml): makes it easy to export objects as YAML, for CRD export

4. [`controller-gen`](https://github.com/rancher/wrangler/tree/master/pkg/controller-gen): actually generates boilerplate controller code from each struct provided. The actual struct should be in [`pkg/apis/<group>.cattle.io/<version>/*.go`](https://github.com/rancher/helm-locker/blob/main/pkg/apis/helm.cattle.io/v1alpha1/release.go), as long as each struct embeds `metav1.TypeMeta` and `metav1.ObjectMeta`.

#### Controller code

Discussing how to actually set up a controller is out-of-scope for this document; however, here are some typical reserved directories we use for controllers:

1. `pkg/apis/<group>.cattle.io/<version>/*.go`: contains Go structs that embed `metav1.TypeMeta` and `metav1.ObjectMeta`, which makes it a Kubernetes resource

2. `pkg/apis/<group>.cattle.io/<version>/docs.go`: contains boilerplate code with comments for `go generate` to parse.

3. `pkg/crd`: contains code for exporting CRDs as YAML (used by `pkg/codegen`) as well as code to batch install CRDs

Within `pkg/controllers`, there's typically a [`pkg/controllers/controller.go`](https://github.com/rancher/helm-locker/blob/main/pkg/controllers/controller.go) that handles all of the boilerplate logic, such as defining an `appContext` (which contains all controllers and clients created from a `SharedControllerFactory`) and registering handlers on controllers.

Each handler's `OnChange` logic should be in `pkg/controllers/<handler>/controller.go`.

### Adding Tests

Similarly, your application code / scripts should have testing set up in a way that is canonical to the language used.

If you are using Go, make sure you have `_test.go` files so you can run `go test`.

If you are using PowerShell, try to incorporate [Pester](https://pester.dev/docs/quick-start) tests, if applicable, under `*.Tests.ps1`.

### Adding Build Targets

Once you have finished adding your Go code, here are some basic build targets you should consider adding :

1. [`test`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/test): A script that runs `go test`, `Invoke-Pester`, etc.

2. [`generate-coverage`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/generate-coverage): A script that runs `go test` with coverage and outputs an HTML file. Intended for users to directly use.

3. [`validate`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/validate): runs `go fmt` and [golangci-lint](https://github.com/golangci/golangci-lint). Make sure you also create [`.golangci.json`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/.golangci.json) in your repository root if you do this.

If you are building a tool / CLI Binary:

1. [`version`](https://github.com/rancher/helm-locker/blob/main/scripts/version): calculates the right values for `GIT_TAG` and `COMMIT` to pass in to the build script.

2. [`build`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/build): A script that runs `go build` or any cross-platform build steps. You can also add `build-net` for .NET applications, but keep it as a separate file since you may not want to run it on Linux machines. Make sure you invoke `version` to inject in the right version values on build.

If you are generating code:

1. [validate-ci](https://github.com/rancher/helm-locker/blob/main/scripts/validate-ci): runs `go generate` and ensures that Git is not dirty after

You may also want to consider adding the following meta-targets:

1. [`default`](https://github.com/rancher/helm-locker/blob/main/scripts/default): The default build target that runs `build` and `test`

2. [`ci`](https://github.com/rancher/helm-locker/blob/main/scripts/ci): The default build target for GitHub Actions. Should run `build` (if you are using it), `test`, `validate`, and `validate-ci` (if you are using it)

### Adding CI

Assuming that any repository that has application code will also have docs, you can modify the [above GitHub Action](#adding-ci) to add a dependency on `golangci-lint` and execute `bash ./scripts/ci`.

If you do this, rename the file `.github/workflows/ci.yml`.

If you are developing a tool or CLI binary, you will also need to add a [`.github/workflows/release.yml`](https://github.com/rancher/wins/blob/main/.github/workflows/release.yaml) to handle creating the GitHub release using `gh release create`.

Make sure this GitHub workflow passes in the necessary environment variables to ensure that the `version` script provides the right output for the image you cut.

## Docker Images

Any Docker image and the relevant code mounted onto it (i.e. scripts) should exist in the `package/` directory.

Use the smallest possible base image in your `Dockerfile`, typically `registry.suse.com/bci/bci-micro` or `mcr.microsoft.com/windows/nanoserver`.

> **Note**: Ensure that the base image that you use at least has sufficient tooling to allow you to debug issues in production after you ship it.
>
> If not, you can use [`leodotcloud/swiss-army-knife`](https://github.com/leodotcloud/swiss-army-knife).

### Adding Build Targets

In addition to the build targets mentioned [above](#adding-build-targets), once you have finished adding your Dockerfile(s), here are some basic build targets you should consider adding:

1. [`package`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/package): A script that runs `docker build` to build all images based on the `IMAGE` provided by `version`

2. [`publish`](https://github.com/rancher/Rancher-Plugin-gMSA/blob/main/scripts/publish): A script that runs `ORG=$ORG REPO=$REPO docker push $ORG/$REPO:$TAG` to push generated images. Developers should export customized environment values for `$ORG` and `$REPO` on running this script to avoid pushing straight to the official DockerHub.

You will need to modify [`version`](https://github.com/rancher/helm-locker/blob/main/scripts/version) to calculate the right `IMAGE` based on environment variables.

You may also want to consider updating the `default` target to include `package` and the `ci` target to include `publish` (if you plan to publish images for every merged commit).

### Adding CI

If you followed the steps to set up a `.github/workflows/ci.yml` in the previous section, you will need to update your `.github/workflows/release.yml` to also publish the image and manifests.

## Helm Charts

All Helm chart(s) should exist within the `charts/` directory.

> **Note**: The exception to this rule are the repositories that use [`rancher/charts-build-scripts`](https://github.com/rancher/charts-build-scripts), like [`rancher/prometheus-federator`](https://github.com/rancher/prometheus-federator).
>
> Discussing how or why to set up a `rancher/charts-build-scripts` repository is out-of-scope for this document, but the canonical directories / files we use for those directories are:
>
> 1. `packages/`: contains each chart "package" we maintain
>
> 2. `configuration.yaml`: configures `charts-build-scripts` itself
>
> 3. `assets/` and `index.yaml`: defines a Helm [repository](https://helm.sh/docs/topics/chart_repository/)
>
> 4. `CNAME` / `_config.yml`: for hosting on GitHub Pages
>
> 5. `scripts/charts-build-scripts/`: for running scripts related to charts-build-scripts, like pulling scripts or removing assets. Typically, these scripts are directly linked as target(s) on the `Makefile`.

### Adding CI

After your `ci.yaml` builds the Docker images you intend to test using this Helm chart, you can use [`AbsaOSS/k3d-action`](https://github.com/AbsaOSS/k3d-action) to create a [k3d](https://k3d.io/) cluster.

> **Note**: If you are developing a Helm chart that deploys on a Windows cluster with Windows components, there is no way for you to add CI at a Helm chart level today.
>
> This is because it is impossible to create a mixed OS Kubernetes cluster within a single GitHub runner (Linux or Windows) using k3d today.

You can then test if a simple `helm install` works. Make sure your `helm install` provides values that override the default Helm chart values (which should point to the official Rancher repository) to point at your locally built image.

Once that's done, it's up to you how much more testing you want to do (i.e. `helm uninstall`, `helm upgrade`, making sure workloads are up, proxying service endpoints to probe them, ensuring resources exist, etc.).

An example of a repository that has set up such CI is [`rancher/helm-project-oprator`](https://github.com/rancher/helm-project-operator/blob/main/.github/workflows/e2e-ci.yaml).

### After Release

After your first release, make sure that your Helm charts find a place in the correct release branch(es) on [`rancher/charts`](https://github.com/rancher/charts) to release them to all Rancher users.
