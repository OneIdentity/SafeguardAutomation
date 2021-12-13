# Web Application login for SPS
Only for demo use.

Built with AutoIT v3

Tested with Chrome v96 and SPS 6.11 on Windows Server 2016.

Make sure you build the exe using the Aut2exe tool to ensure the included files are packaged too in the exe.

Download the latest browser driver and copy it into the webdriver folder
- For Chrome: https://chromedriver.chromium.org/
- For Firefox: https://github.com/mozilla/geckodriver/releases
- For Edge: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
Check the desired driver settings in the Setup* functions at the end of the file.
Read the driver specific guidelines for further details, for example the option of saving the password is turned off in the chromedriver.

Known issues:
- It is not handled if the launcher received wrong password from the credential store.


## Support

One Identity open source projects are supported through [One Identity GitHub issues](https://github.com/OneIdentity/SafeguardAutoIt/issues) and the [One Identity Community](https://www.oneidentity.com/community/). This includes all scripts, plugins, SDKs, modules, code snippets or other solutions. For assistance with any One Identity GitHub project, please raise a new Issue on the [One Identity GitHub project](https://github.com/OneIdentity/SafeguardAutoIt/issues) page. You may also visit the [One Identity Community](https://www.oneidentity.com/community/) to ask questions.  Requests for assistance made through official One Identity Support will be referred back to GitHub and the One Identity Community forums where those requests can benefit all users.
