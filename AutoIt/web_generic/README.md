# Web Application login for arbitrary web applications
Only for demo use.

See guidance for usage in the au3 script and the executable itself under Releases.

Built with AutoIT v3

Make sure you build the exe using the Aut2exe tool to ensure the included files are packaged too in the exe.

See wiki for using the Webdriver in AutoIT at https://www.autoitscript.com/wiki/WebDriver

Download the latest browser driver and copy it into the webdriver folder
- For Chrome: https://chromedriver.chromium.org/
- For Firefox: https://github.com/mozilla/geckodriver/releases
- For Edge: https://developer.microsoft.com/en-us/microsoft-edge/tools/webdriver/
Check the desired driver settings in the Setup* functions at the end of the file.
Read the driver specific guidelines for further details, for example the option of saving the password is turned off in the chromedriver.

The used .au3 sources for the webdriver may become outdated, you can look them up at their original repository if needed. See reference at https://www.autoitscript.com/wiki/WebDriver#Requirements

Known issues:
- It is not handled if the launcher received wrong password from the credential store.


## Support

One Identity open source projects are supported through [One Identity GitHub issues](https://github.com/OneIdentity/SafeguardAutoIt/issues) and the [One Identity Community](https://www.oneidentity.com/community/). This includes all scripts, plugins, SDKs, modules, code snippets or other solutions. For assistance with any One Identity GitHub project, please raise a new Issue on the [One Identity GitHub project](https://github.com/OneIdentity/SafeguardAutoIt/issues) page. You may also visit the [One Identity Community](https://www.oneidentity.com/community/) to ask questions.  Requests for assistance made through official One Identity Support will be referred back to GitHub and the One Identity Community forums where those requests can benefit all users.
