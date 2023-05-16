# RDP Application Configuration Tutorial

:arrow_forward: *Reading the [Background](https://github.com/OneIdentity/SafeguardAutomation/tree/master/RDP%20Applications#background) section of the main RDP Applications page will provide context for this tutorial.*

The purpose of this page is to help you learn how to publish an RDP application for use with Safeguard's RDP application auto-login feature.

## 1. Configure a remote application jump host

There are several different types of jumps host that can be configured to work with RDP Applications. In this tutorial we will use a Windows 10/11 OS as the jump host. The advantage to using a Windows 10/11 OS is that it is easy to configure and use to launch remote applications. The disadvantage is that Windows 10/11 OS is restricted to a single RDP connection at a time. For a more robust solution, you should consider using a Windows Server configured with RDS services and CALS which supports either per-user or per-device licensing. For more information, see [Deploying Remote Desktop Services](https://getanadmin.com/windowsserver/deploying-remote-desktop-services-on-windows-server-2019/) and [RDS CALS](https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-install-cals)

- Go to the following page and follow the instructions for enabling ```Remote Desktop Services``` on a Windows 10/11 OS.
- Add local user accounts or Active Directory user accounts if the Windows 10/11 host is joined to a domain.
- Make sure that each new user account is a member of the ```Remote Desktop Users``` group.
- Set the following Windows registry entry:
  - Add and disable ```HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\fEnableRemoteFXAdvancedRemoteApp``` = 0 (REG_DWORD)

## 2. Install the Safeguard Remote Application Launcher

The ```OI-SG-RemoteApp-Launcher``` must be installed on each Windows jump host that will be used to launch remote applications. The launcher is a small command line application that is capable of establishing a communication channel between the remote application to be launched and the SPP/SPS appliances that are used to inject the credentials and record the remote application session. Once installed, the launcher program will not appear in the start menu. The launcher can only be invoked by configuring it as a published remote application. More information about how to configure the launcher will be discussed in a later step.

- The installer for the ```OI-SG-RemoteApp-Launcher``` can be downloaded from the [One Identity software download site](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/) for the latest version of SPS.
- The launcher is a command line tool whose parameters identify the remote application to be launched. The following describes the parameters that can be used. Example:

```--cmd "C:\Program Files\DBeaver\dbeaver.exe" --args "-con user={username}|password={password}|host=localhost|driver=MariaDB|database=nation|name={asset}|connect=true" --enable-debug```

- ```--cmd``` - Full path to the remote application.
- ```--args``` - Command line parameter for the remote application.
- ```--enable-debug``` - Enable debug logging. The debug log will be located in the folder: ```C:\Users\<user>\AppData\Roaming\OneIdentity\OI-SG-RemoteApp-Launcher```
- Injectable values - When the remote application is launched using the remote application launcher, it provides several values than can be injected into the command line of the remote application. In the example above, the parameters for the DBeaver database client contains several values enclosed in braces. Any of the following values can be injected by specifying the key in the parameter list:
  - ```{asset}``` - Name of the remote application asset as it appears in SPP.
  - ```{username}``` - User/account name associated with the asset.
  - ```{password}``` - Password associated with the user account.
  - ```{Target.TotpCodes}``` - JSON string which lists all of the totp codes and expirations.
  - ```{Target.AccountPassword}``` - Password associated with the user account. See ```{password}```.
  - ```{Target.AccountName}``` - User/account name associated with the asset. See ```{username}```.
  - ```{Target.AccountDomainName}``` - Domain name associated with the account.
  - ```{Target.AssetName}``` - Name of the remote application asset as it appears in SPP. See ```{asset}```.
  - ```{Target.AssetNetworkAddress}``` - Network address associated with the asset. [NOTE] A remote application asset network address can be set to a URL so that the URL can be injected into a browser to record a browser session.
  - ```{RdpHost.AccountName}``` - Jump host account name.
  - ```{RdpHost.AccountPassword}``` - Jump host account password.
  - ```{RdpHost.AssetName}``` - Jump host asset name.
  - ```{RdpHost.AssetNetworkAddress}``` - Jump host network address.
  - ```{RdpHost.ApplicationName}``` - Remote application name as it appears in the SPP entitlement access policy.
  - ```{RdpHost.ApplicationProgram}``` - Remote application program name as it appears in the SPP entitlement access policy.

## 3. Install the target client program

The remote application launcher can be used to launch any application that is available on the jump host. For this tutorial we will use a general purpose database client called DBeaver. DBeaver will be configured as the client for a MariaDB database.

- Install the [MariaDB database](https://go.mariadb.com/download-mariadb-server-community108.html) with sample data.
- Install the [DBeaver](https://dbeaver.io/download/) database client.
- Configure a [database connection](https://dbeaver.com/2022/03/03/how-to-create-database-connection-in-dbeaver/).

## 4. Install the Remote Application Publisher

The [Remote Application Publisher](https://github.com/OneIdentity/RemoteApplicationPublisher) should be install on the Windows 10/11 jump host. It is a simple Windows desktop application that adds and manages specific registry entries which Windows uses to identify applications which can be launched remotely.

- See the Remote Application Publisher open source project for more information about how to publish remote applications.
- When publishing a remote application, make sure to check the ```Use One Identity Launcher``` checkbox on the ```Application Properties``` dialog. By checking the checkbox, the Remote Application Publisher will automatically configure the remote application to use the One Identity launcher that was installed previously.
- [NOTE] If you are publishing the remote application on a Windows Server which has been configured for Remote Desktop Services (RDS), Server Manager can be used to publish remote applications as well.

## 5. Publish a remote application

The easiest way to publish a remote application is to use the [Remote Application Publisher](https://github.com/OneIdentity/RemoteApplicationPublisher). The Remote Application Publisher can be used on any Windows OS to publish an existing application as a remote application. If you are publishing a remote application on a Windows server with RDS CALS installed, the Server Manager application provides an alternate way to [publish remote applications](https://learn.microsoft.com/en-us/windows-server/remote/remote-desktop-services/rds-create-collection).

- In this example, the DBeaver database client can be published as a remote application.
- In the Remote Application Publisher click the plus button to create publish a new remote application. Select the DBeaver application.
- On the ```Application Properties``` dialog, make sure the check the ```Use One Identity Launcher``` checkbox.
- Add the [command line parameters](https://dbeaver.com/docs/wiki/Command-Line/) for DBeaver in the ```--args``` parameter of the launcher on the ```Application Properties``` dialog. See the example above.

## 6. Configure SPP access policy

- Ensure that the Windows jump host has been added to SPP as an asset.
- Ensure that an account with rights to launch a remote application has been associated with the jump host asset.
- Create a MySQL asset in SPP with accounts.
- Create an ```Entitlement``` and ```Access Request Policy```.
- On the ```General``` tab of the ```Access Request Policy```, select the ```Policy Type``` as ```Session``` and the ```Session Type``` as ```RDP Application```.
- On the ```Security``` tab of the ```Access Request Policy```, set the following values:
  - Ensure that an ```SPS Connection Policy``` has been selected. If no selectable policies appear in the dropdown list, ensure that an SPS appliance has been joined to SPP.
  - Browse and select an ```RDP Host Asset``` (jump host asset).
  - Browse and select the associated ```RDP Host Asset Account``` (jump host account).
  - Go to the ```Remote Application Publisher``` on the jump host, select and right-click on the ```Full Name``` of the published remote application. Select ```Copy to Clipboard```.
  - Paste the ```Full Name``` into the ```Application Display Name``` field.
  - Go to the Remote Application Publisher on the jump host, select and right-click on the ```Program Path``` of the published remote application. Select ```Copy to Clipboard```.
  - Paste the ```Program Path``` into the ```Application Alias``` field.
- On the ```Scope``` tab of the ```Access Request Policy```, add the account that is associated with the MySQL asset.

## 7. End-to-end testing

In this step we will launch the remote application by creating a access request.

- Select ```Access Requests``` / ```My Requests``` on the main page of SPP.
- Click on the ```New Request``` button.
- Search for and select the ```MySQL``` asset with access type ```RDP Application``` and click Next.
- Set any other parameters and click ```Submit Request```.
- Click on the ```Start RDP Session``` (if [SCALUS](https://github.com/OneIdentity/SCALUS) has been installed and configured) or ```Download RDP``` file.
- If the RDP file was downloaded, navigate to the file and double click it.
- This should launch the session which should appear as a application on the Windows client desktop.
