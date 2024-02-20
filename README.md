# SSH Tunneling App

![Application Logo](logo.png)

## Description

The SSH Tunneling application is a simple yet powerful utility for establishing secure remote connections using the SSH protocol. It allows users to create SSH tunnels to secure and route network traffic through remote servers.

The application is developed in Swift for macOS, providing a user-friendly interface for configuring and managing SSH tunnels with ease.

> Since [version 0.3.0](https://github.com/julianitow/SSHTunnelApp/releases/tag/v0.3.0), SwiftNIO SSH is available to use at config (0.3.0 only accepts password authentication, keys will be implemented soon). It resolve some issues that can happen when using passwords without NIO usage.

## Features

- Create both local and remote SSH tunnels.
- Manage SSH keys for secure authentication. (TBD)
- Advanced tunnel configuration settings, including local and remote ports.
- Profile management for easy configuration and tunnel reuse. (TBD)
- Real-time status visualization of active tunnels.

## Installation

1. Download the latest version of the application from [releases](https://github.com/julianitow/SSHTunnelApp/releases).
2. Extract app from downloaded zip file to applications folder. 
3. Drag and drop the application into the Applications folder.
4. Go to the security settings in MacOS and click "open" (needed for now)

## Usage

1. Launch the application from the Applications folder.
2. Create a new SSH tunnel profile by specifying the configuration details.
3. Activate the tunnel by clicking the "Connect" button.
4. Monitor the tunnel's status in the list of active tunnels.

## Development

If you wish to contribute to the development of this application, follow these steps:

Clone the repository: git clone https://github.com/julianitow/SSHTunnelApp
Open the project in Xcode.
Develop new features or enhance existing ones.
Submit a pull request with your changes.
