# pwsh-github-action-tools

Supporting tools for implementing GitHub Actions in PowerShell

---

[![GitHub Workflow - CI](https://github.com/ebekker/pwsh-github-action-tools/workflows/CI/badge.svg)](https://github.com/ebekker/pwsh-github-action-tools/actions?workflow=CI)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/GitHubActions?label=release%20%28PSGallery%29)](https://www.powershellgallery.com/packages/GitHubActions)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/ebekker/pwsh-github-action-tools)](https://github.com/ebekker/pwsh-github-action-tools/releases/latest/download/GitHubActions.zip)
[![docs for GitHubActions](https://img.shields.io/badge/docs-GitHubActions-blueviolet)](docs/GitHubActions/README.md)
[![MyGet (with prereleases)](https://img.shields.io/myget/pwsh-github-action-tools/vpre/GitHubActions?label=pre-release%20%28MyGet%29)](https://www.myget.org/feed/pwsh-github-action-tools/package/nuget/GitHubActions)

---

## `GitHubActions` PowerShell Module

This PowerShell module can be used to interact with the environment during the run of a
GitHub Actions Workflow.

It is based on the specification for [Workflow commands for GitHub Actions](
    https://docs.github.com/en/actions/reference/workflow-commands-for-github-actions)
and is an adaptation of the [JavaScript interface](
    https://github.com/actions/toolkit/tree/a6e72497764b1cf53192eb720f551d7f0db3a4b4/packages/core/src)
from the [GitHub Actions Toolkit](https://github.com/actions/toolkit).

Checkout the [documentation](./docs/GitHubActions/README.md) for the module cmdlets.
