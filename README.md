# Secure RDP GitHub Action

This repository contains a GitHub Actions workflow (`Main.yml`) that sets up a secure Remote Desktop Protocol (RDP) session on a Windows runner. The project has been refactored to treat the PowerShell logic as a first-class codebase, with a full suite of Pester unit tests to ensure its quality and correctness.

## Project Structure

- **`.github/workflows/`**: Contains the GitHub Actions workflows.
  - `Main.yml`: The main workflow that orchestrates the RDP setup by executing the PowerShell scripts. It is responsible for the sequence of operations and passing data between steps.
  - `run-tests.yml`: A CI workflow that automatically runs the Pester test suite on every push and pull request to ensure the integrity of the PowerShell logic.
- **`scripts/`**: Contains all the PowerShell logic, extracted into modular, single-purpose scripts. Each script corresponds to a step in the `Main.yml` workflow.
- **`tests/`**: Contains the Pester unit tests for every PowerShell script in the `scripts/` directory, ensuring 100% of the refactored code is covered by tests.

## Features

- **Automated RDP Configuration**: Enables RDP and configures firewall rules automatically.
- **Development Environment Setup**: Installs and upgrades essential tools like Google Chrome, Microsoft Edge, WSL (with Ubuntu), and BlueStacks.
- **Secure Connectivity**: Creates a secure RDP user and establishes a connection using Tailscale.
- **Robust Testing**: A comprehensive Pester unit test suite provides coverage for the core PowerShell logic, ensuring the reliability and stability of the workflow.

## Testing and Validation

This repository uses **Pester**, the de-facto standard testing framework for PowerShell, to provide unit test coverage for the scripts in the `scripts/` directory.

### Continuous Integration

The Pester test suite is run automatically on every push and pull request that affects the `scripts/` or `tests/` directories, as defined in the `run-tests.yml` workflow. The build will fail if any of the tests do not pass, ensuring that the codebase remains in a healthy and reliable state.

### Local Testing

You can (and should) run the Pester test suite locally before pushing any changes. This provides a fast feedback loop for development.

#### 1. Prerequisites

You will need a Windows environment with PowerShell.

#### 2. Installation

First, install the Pester testing framework from the PowerShell Gallery. Open a PowerShell terminal as an administrator and run:

```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

#### 3. Running the Tests

Once Pester is installed, navigate to the root of the repository in a PowerShell terminal and run the following command:

```powershell
Invoke-Pester -Script ./tests
```

This command will discover and execute all test files (ending in `*.Tests.ps1`) in the `tests` directory and report the results. A successful run will show all tests passing, confirming that your changes have not introduced any regressions.