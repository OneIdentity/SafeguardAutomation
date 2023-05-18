# RDP Application Web Browser Tutorial

:arrow_forward: *Reading the [Background](https://github.com/OneIdentity/SafeguardAutomation/tree/master/RDP%20Applications#background) section of the main RDP Applications page will provide context for this tutorial.*

:arrow_forward: *Reading the [RDP Application Configuration Tutorial](https://github.com/OneIdentity/SafeguardAutomation/tree/master/RDP%20Applications/Tutorial) page will provide additional information when configuring a remote application to launch a web browser.*

The purpose of this page is to help you learn how to use a Go script to launch and record a web browser application session.

## Requirements

- [Remote Application Publisher](https://github.com/OneIdentity/RemoteApplicationPublisher)
- [Remoteapp-launcher](https://support.oneidentity.com/one-identity-safeguard-for-privileged-sessions/)
- [Git](https://git-scm.com/download/win)
- [Go](https://go.dev/doc/install)
- [Chrome Web Browser](https://www.google.com/chrome/)
- [Chromedp](https://github.com/chromedp/chromedp)

## 1. Install Git, Go and Chromedp

Injecting credentials into a web page requires an additional utility. This utility depends on the chromedp screen scrapping plugin which is wrapped by a Go script. The Go script needs to be built into an executible that takes the remote application injectible parameters on its commandline, finds the appropriate fields on a web pages and injects the values.

- Install Git, Go and Chromedp on a work machine that is used to build the utility. [NOTE] If you see an error about not being able to find the go mod, use the following instructions:

  ```First make sure that your GO111MODULE value is set to "auto". You can check it from: "go env" if it is not set to "auto", run: "go env -w GO111MODULE=auto"  go to your work directory in terminal and run: "go mod init 'generic_proj'" and "go mod tidy". Then set GO111MODULE to "off" again. Run: "go env -w GO111MODULE=off".```

## 2. Clone the SafeguardAutomation repository

Use the Git utility to clone the [SafeguardAutomation](https://github.com/OneIdentity/SafeguardAutomation) repository to your local build machine. If you are seeing the error that was mentioned above when installing chromedp, you will need to clone the repository in order to get the project code that is mentioned in the solution.

## 3. Build and install generic.exe utility

- Build the generic.go utility by invoking ```go build generic.go``` from the same folder that contains the Go scripts.
- Copy the ```generic.exe``` utility to the remote application host. The utility can be copied to any folder.

## 4. Publish the remote application for launching a web browser

- Install the ```Remote Application Publisher``` on the remote application jump host if it hasn't been installed already.
- Install the Chrome browser on the remote application jump host if it hasn't been installed already.
- Open the ```Remote Application Publisher``` and publish a new remote application by clicking on the plus button.
  - Enter the following values into the ```Application Properties``` dialog:
    - ```Name``` - SPSWebUI
    - ```Full Name``` - SPS Web UI Chrome
    - Enable the ```Use One Identity Launcher``` checkbox.
    - ```Command Line Parameters``` - --cmd c:\apps\generic.exe --args "-url https://{Target.AssetNetworkAddress} -account {username} -password {password} -account-selector #local-username -password-selector #local-password -submit-selector button.flat.primary -insecure" --enable-debug
  - Click the ```Save``` button
- If you need to inject the credentials into a web page other than the SPS Web UI, you will need to find the CSS-Selectors for appropriate fields on login web page. These CSS-Selectors need to be entered into the command line for the ```-account-selector```, ```-password-selector``` and ```-submit-selector```.  See the example command line above. This article explains how to [find the CSS-Selectors using the Chrome Developer Tools](https://stackoverflow.com/questions/4500572/how-can-i-get-the-css-selector-in-chrome).

## 5. Configure the SPS appliance asset and the RDP application access request policy in SPP

- Ensure that the Windows jump host has been added to SPP as an asset.
- Ensure that an account with rights to launch a remote application has been associated with the jump host asset.
- Create an ```SPS Appliance``` asset in SPP with accounts.
- Create an ```Entitlement``` and ```Access Request Policy```.
- On the ```General``` tab of the ```Access Request Policy```, select the ```Policy Type``` as ```Session``` and the ```Session Type``` as ```RDP Application```.
- On the ```Security``` tab of the ```Access Request Policy```, set the following values:
  - Ensure that an ```SPS Connection Policy``` has been selected. If no selectable policies appear in the dropdown list, ensure that an SPS appliance has been joined to SPP.
  - Browse and select an ```RDP Host Asset``` (jump host asset).
  - Browse and select the associated ```RDP Host Asset Account``` (jump host account).
  - Go to the ```Remote Application Publisher``` on the jump host, select and right-click on the ```Full Name``` of the published ```SPSWebUI``` remote application. Select ```Copy to Clipboard```.
  - Paste the ```Full Name``` into the ```Application Display Name``` field.
  - Go to the Remote Application Publisher on the jump host, select and right-click on the ```Program Path``` of the published ```SPSWebUI``` remote application. Select ```Copy to Clipboard```.
  - Paste the ```Program Path``` into the ```Application Alias``` field.
- On the ```Scope``` tab of the ```Access Request Policy```, add the account that is associated with the SPS appliance asset.

## 6. Launch the SPS web UI as a remote application

In this step we will launch the SPS web UI in a browser as a remote application.

- Select ```Access Requests``` / ```My Requests``` on the main page of SPP.
- Click on the ```New Request``` button.
- Search for and select the ```SPS Appliance``` asset with access type ```RDP Application``` and click Next.
- Set any other parameters and click ```Submit Request```.
- Click on the ```Start RDP Session``` (if [SCALUS](https://github.com/OneIdentity/SCALUS) has been installed and configured) or ```Download RDP``` file.
- If the RDP file was downloaded, navigate to the file and double click it.
- This should launch a web browser as a remote application. The browser should automatically load the SPS web IU and inject the approriate login credentials.
