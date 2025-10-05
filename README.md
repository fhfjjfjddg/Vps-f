# Secure RDP Access with GitHub Actions

This repository contains a GitHub Actions workflow that provisions a Windows virtual machine and provides secure remote access to it via RDP (Remote Desktop Protocol) over a Tailscale VPN. It is designed for developers who need a sandboxed Windows environment for testing, development, or debugging.

## Purpose

The primary goal of this workflow is to create a fully configured and secure Windows environment that is accessible from anywhere. By leveraging GitHub Actions and Tailscale, it automates the setup of a temporary Windows machine, complete with essential development tools and secure connectivity. This avoids the need for a dedicated physical machine and ensures a clean environment for every run.

## Features

The workflow performs the following automated steps:

- **Configures RDP**: Enables Remote Desktop on the runner and configures firewall rules to allow access.
- **Installs Essential Tools**:
  - **BlueStacks**: For running Android applications.
  - **WSL (Windows Subsystem for Linux)**: With the Ubuntu distribution installed by default.
  - **Up-to-date Browsers**: Ensures the latest versions of Google Chrome and Microsoft Edge are installed.
- **System Upgrades**: Uses `winget` to upgrade all possible system applications to their latest versions.
- **Secure Access**:
  - Creates a temporary user with a strong, randomly generated password.
  - Uses **Tailscale** to create a secure VPN connection, so the RDP port is not exposed to the public internet.
- **Persistent Connection**: The workflow job remains active for up to 6 hours, allowing ample time for remote work.

## Setup

To use this workflow, you need to configure a Tailscale authentication key as a GitHub secret.

1.  **Get a Tailscale Account**: If you don't have one, sign up at [Tailscale.com](https://tailscale.com).
2.  **Generate an Auth Key**:
    - Go to the **Keys** section of your Tailscale admin console.
    - Generate a new auth key. It's recommended to make it **reusable** and **ephemeral** so that the machine automatically cleans itself up from your Tailnet after it goes offline.
    - Copy the generated key (it will look like `tskey-auth-...`).
3.  **Add the Key to GitHub Secrets**:
    - In your GitHub repository, go to `Settings` > `Secrets and variables` > `Actions`.
    - Click `New repository secret`.
    - Name the secret `TAILSCALE_AUTH_KEY`.
    - Paste the auth key you generated.

## Usage

1.  **Run the Workflow**:
    - Go to the **Actions** tab in your repository.
    - Select the **RDP** workflow.
    - Click **Run workflow** and confirm by clicking the green button.

2.  **Get Connection Details**:
    - Once the workflow starts, click on the running job to view the logs.
    - Wait for the **Maintain Connection** step to begin.
    - The logs will display the Tailscale IP address and the RDP credentials (username and password).

    ```
    === RDP ACCESS ===
    Address: 100.x.x.x
    Username: RDP
    Password: User: RDP | Password: <your-generated-password>
    ==================
    ```

3.  **Connect via RDP**:
    - Open your favorite RDP client (e.g., Microsoft Remote Desktop).
    - Use the Tailscale IP address as the computer name.
    - Enter `RDP` as the username and the generated password to connect.

## Security Considerations

- **Secret Management**: Your `TAILSCALE_AUTH_KEY` is a sensitive secret. Treat it like a password. Using it as a GitHub secret is the recommended approach.
- **Ephemeral Machines**: The runner is destroyed at the end of the workflow run. This is a security benefit, as no data persists by default.
- **Tailscale Network**: RDP access is restricted to your private Tailscale network, which is significantly more secure than exposing port 3389 to the public internet.
- **Random Passwords**: A new, strong password is generated for the RDP user on every run, reducing the risk of unauthorized access.