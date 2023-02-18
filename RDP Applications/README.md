# SafeguardAutomation : RDP Applications

## Resources

| Resource | Description |
| --- | --- |
| [Publisher](https://github.com/OneIdentity/RemoteApplicationPublisher) | Remote Application Publisher for publishing your configuration. |
| [Launcher](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions) | Required component that must be published to securely launch and inject credentials into target applications. |
| [AutoIt](AutoIt) | Sample AutoIT scripts and examples for injecting passwords into Windows forms and web applications. |
| [Go chromedp](Go%20chromedp) | chromedp is a library in Go for automating browsers.  It can be used to automate credential injections in web forms. |
| [Deprecated Publisher](Deprecated%20Publisher) | Before the [Publisher](https://github.com/OneIdentity/RemoteApplicationPublisher), this tool was used to create published RDP applications to launch with the One Identity Safeguard remote application [Launcher](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions). |
| [SCALUS]() | After completing approval workflow, there are two ways for the end user to start an SPP-initiated RDP application session: 1) download the RDP file from Safeguard, 2) click the launch button to invoke a custom URL via Session Client Application Launch Uri System (SCALUS). |

*Try out the [RDP application tutorial](Tutorial).*


## Background

The RDP Applications solution consists of multiple components working together to provide seamless privileged access to published RDP applications.  The solution may be configured to require approvals via SPP access request workflow and credential injection for both the RDP connection and the published RDP application.  The end users requests session access and starts the session in the normal way, but only the requested remote application appears on the screen rather than a full remote desktop session.

![RdpAppArchDiagram](Images/RdpAppArchDiagram.png)

## Components

| Component | Description |
| --- | --- |
| **SPP** | Safeguard for Privileged Passwords appliance used for RDP Application policy definition, access request workflow, and privileged credential vaulting. |
| **SPS** | Safeguard for Privileged Sessions appliance used for session proxy and credential injection. |
| **Jump Host** | Windows server (or desktop**) used to configure the published RDP application and hosts the RDP session connection. |
| **Target Server** | Any server that hosts the target application; in the diagram this is a server with a database installed, but it could be a server with an application server or could even be a cloud target. The important thing to note is that the critical application does not have to be installed on the Jump Host. |
| **Launcher** | One Identity Safeguard remote application [Launcher](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions) (OI-SG-RemoteApp-Launcher.exe); this is an installable component downloadable from the One Identity support site.  This component is published as the RDP application, because it can communicate securely with SPS to retrieve the application credential and use it to launch the target application. |
| **Client** | The client used to access the target application; in the diagram this is a database client such as SQL Server Management Studio, DBeaver, or MySQL Workbench.  This client is invoked by the [Launcher](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions) and the application credentials are passed via the command line.  There are many application clients that do not support credentials from the command line.  In these cases, AutoIt and other technologies can be used to populate forms and submit credentials.  Much of the content of this section is dedicated to samples and documentation for how this may be accomplished. |
| **Publisher** | The Remote Application Publisher component is not depicted in the diagram.  It is an [open source project](https://github.com/OneIdentity/RemoteApplicationPublisher) that facilitates the RDP application configuration necessary to publish the Launcher and required command line as a published RDP application on Windows.  This configuration can be created manually or using Microsoft's tools, but the Publisher component |