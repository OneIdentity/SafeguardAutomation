# SafeguardAutomation
Automation tools for building solutions with One Identity Safeguard

## Support

One Identity open source projects are supported through [One Identity GitHub issues](https://github.com/OneIdentity/SafeguardAutoIt/issues) and the [One Identity Community](https://www.oneidentity.com/community/). This includes all scripts, plugins, SDKs, modules, code snippets or other solutions. For assistance with any One Identity GitHub project, please raise a new Issue on the [One Identity GitHub project](https://github.com/OneIdentity/SafeguardAutoIt/issues) page. You may also visit the [One Identity Community](https://www.oneidentity.com/community/) to ask questions.  Requests for assistance made through official One Identity Support will be referred back to GitHub and the One Identity Community forums where those requests can benefit all users.

## About the SafeguardAutomation repository

The purpose of this repository is to share automation examples and supplementary documentation to help you build solutions for your PAM use cases with Safeguard.  The examples and documentation are organized by category, and each category subdirectory of the repository includes another README.md containing additional details.  Most of the content in this repository is related to Safeguard sessions and custom credential injection scenarios.

### [RDP Applications](RDP%20Applications)

Safeguard uses protocol proxy technology to manage and record privileged access to critical systems and sensitive data.  Safeguard supports many different platforms for credential management and a wide variety of protocols for session access, but not every protocol provides an acceptable audit experience.  This is because some protocols, such those in use for database access or web application access, do not provide a continuous session connection.  Most database drivers make a separate TCP connection for each command, and a web application session is made up of many separate, asynchronous HTTP requests.  The resulting portocol recordings do not lend themselves to a movie-like playback, and an auditor or incident investigator will not be able to see exactly what the end user saw depending on how the client rendered the session.

RDP applications can be used to provide movie-like playback for any system, any protocol, or any application by recording the end user's interaction with a remote published application over remote desktop protocol.  Safeguard includes a special remote application launching mechanism that allows secure privileged credential injection.  This repository includes examples and documentation for configuring these applications.

:arrow_forward: [More details...](RDP%20Applications)

### [Terminal Pattern Files](Terminal%20Pattern%20Files)

Safeguard has the ability to launch and record terminal access to mainframes, midrange computers, and minis via Telnet, TN3270, and TN5250 protocols.  TN3270 and TN5250 sessions start with basic Telnet which then transform into a 3270 or 5250 connection after specific options and control characters are sent to establish the appropriate data streams.  Often, the login experience is presented as a form which may prompt for username, password, and potentially, other information.  [Safeguard Custom Platforms](https://github.com/OneIdentity/SafeguardCustomPlatform) can be created to handle credential management for these scenarios, but Safeguard also needs customization for credential injection.

This section of the repository contains a plugin and template pattern files that are necessary to establish these connections and securely inject privileged credentials.

:arrow_forward: [More details...](Terminal%20Pattern%20Files)

## Additional Information

Safeguard is an extremely flexible PAM solution with fully-featured REST APIs and plugin frameworks.  The [One Identity GitHub organization](https://github.com/OneIdentity) contains many repositories to help you get the most of Safeguard.

- [Safeguard API Tutorial](https://github.com/OneIdentity/safeguard-api-tutorial)
- [Safeguard Custom Platform](https://github.com/OneIdentity/SafeguardCustomPlatform)

SDKs:

- [.NET](https://github.com/OneIdentity/SafeguardDotNet)
- [Java](https://github.com/OneIdentity/SafeguardJava)
- [Python](https://github.com/OneIdentity/PySafeguard)
- [JavaScript](https://github.com/OneIdentity/safeguard.js)

Scripting:

- [Powershell](https://github.com/OneIdentity/safeguard-ps)
- [Bash](https://github.com/OneIdentity/safeguard-bash)
- [Ansible](https://github.com/OneIdentity/safeguard-ansible)

Session Plugin Resources:

- [Plugin SDK](https://github.com/OneIdentity/safeguard-sessions-plugin-sdk)
- [AA Skeleton](https://github.com/OneIdentity/safeguard-sessions-plugin-skeleton-aa)
- [List of Plugins](https://github.com/topics/oi-sps-plugin)
