################
# Code is delivered "AS IS". Any issues encountered can be reported on Github and contributors will make a best effort to resolve them.
################
#
# Update browser driver to the latest stable release
# It does not check what browser version is installed, it just downloads the latest stable driver
# If there is no driver file on the specified path, the script also downloads the latest stable one and copies it to the specified path
#
#########
# USAGE:
# Configure the desired driver path below at VARIABLES per each browser type, then then run the script in PowerShell for the specified browser type
# .\browser_driver_update.ps1 <chrome|edge|firefox>


param(
    [Parameter(Mandatory=$true)]
    [string] $browser
)


#########
# VARIABLES
#
# Platform can be: win32, win64
$platform="win64"
#
# Configure the path for the driver
# The running user must have RW permissions in the folder
# If the file already exits, the script will compare its version to the latest available driver and overwrite the existing one if a newer one is available
# You can define multiple path, one per browser type, and the script will update the one given as argument
switch ($browser) {
    "chrome" {
        $driverpath="C:\<YOUR-PATH-HERE>\chromedriver.exe"
    }

    "edge" {
        $driverpath="C:\<YOUR-PATH-HERE>\msedgedriver.exe"
    }

    "firefox" {
        $driverpath="C:\<YOUR-PATH-HERE>\geckodriver.exe"
    }

    default {
        Write-Error "Browser parameter must either be 'chrome', 'edge', or 'firefox'"
        exit 1
    }
}

$driverFolder = Split-Path -Parent $driverPath


#########
# FUNCTIONS

function getDriverVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string] $browser
    )

    Switch ($browser) {
        "chrome" {
            try {
                return Invoke-Expression "& '$driverpath' --version"
            }
            catch {
                return "Can't identify driver version, maybe a wrong file path is given? Let's just download the latest stable driver"
            }
        }

        "edge" {
            try {
                return Invoke-Expression "& '$driverpath' --version"
            }
            catch {
                return "Can't identify driver version, maybe a wrong file path is given? Let's just download the latest stable driver"
            }

        }

        "firefox" {
            try {
                return $(Invoke-Expression "& '$driverpath' --version")[0]
            }
            catch {
                return "Can't identify driver version, maybe a wrong file path is given? Let's just download the latest stable driver"
            }
        }

        
    }
}

#function getBrowserVersion {
#    param (
#        [Parameter(Mandatory=$true)]
#        [string] $browser
#    )

#    Switch ($browser) {
#        "chrome" {
#            $installed = gwmi cim_datafile -Filter {Name='C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'}
#            return $installed.Version
#        }

#        "edge" {
            #TODO
#        }

#        "firefox" {
            #TODO
#        }

        
#    }
#}

function getLatestStableDriverVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string] $browser
    )

    Switch ($browser) {
        "chrome" {
            return Invoke-RestMethod -Uri "https://googlechromelabs.github.io/chrome-for-testing/LATEST_RELEASE_STABLE" -Method Get
        }
        "edge" {
            $latestStableVersionFile = $driverFolder + "\msedgedriver_LATEST_STABLE.txt"
            Invoke-RestMethod -Uri "https://msedgedriver.azureedge.net/LATEST_STABLE" -Method Get -OutFile $latestStableVersionFile
            $stableVersion = Get-Content -Path $latestStableVersionFile -TotalCount 1
            Remove-Item -Force -Path $latestStableVersionFile
            return $stableVersion
        }

        "firefox" {
            $latestGecko = Invoke-RestMethod -Uri "https://api.github.com/repos/mozilla/geckodriver/releases/latest" -Method Get
            return $latestGecko.name
        }

       
    }

}

function getDownloadUrl {
    param (
        [Parameter(Mandatory=$true)]
        [string] $browser,
        [Parameter(Mandatory=$true)]
        [string] $version
    )

    Switch ($browser) {
        "chrome" {
        
            $uri = "https://googlechromelabs.github.io/chrome-for-testing/"+$version+".json"
            $downloads = Invoke-RestMethod -Uri $uri -Method Get
            foreach ($_ in $downloads.downloads.chromedriver) {
                if ($_.platform -eq $platform) {
                    return $_.url
                }
            }
            Write-Error "Download URL not found for platform:"$platform
            exit 1 
        }

        "edge" {
            return "https://msedgedriver.azureedge.net/" + $version + "/edgedriver_" + $platform + ".zip"
        }

        "firefox" {
            return "https://github.com/mozilla/geckodriver/releases/download/v" + $version + "/geckodriver-v" + $version + "-" + $platform + ".zip"
        }

        
    }

}

function updateDriver {
    param (
        [Parameter(Mandatory=$true)]
        [string] $browser,
        [Parameter(Mandatory=$true)]
        [string] $url
    )

    
    Switch ($browser) {
        "chrome" {
            $driverFileName = "chromedriver.exe"        
            $zipPath = $driverFolder + "\chromedriver_tmp.zip"
        }

        "edge" {
            $driverFileName = "msedgedriver.exe"        
            $zipPath = $driverFolder + "\msedgedriver_tmp.zip"
        }

        "firefox" {
            $driverFileName = "geckodriver.exe"        
            $zipPath = $driverFolder + "\geckodriver_tmp.zip"
        }

        

        
    }

    try {
        Invoke-RestMethod -Uri $url -Method Get -OutFile $zipPath
    } catch {
        Write-Error "An error occured while downloading the driver package"
        exit 1
    }
            
    try {

        # Load compression methods
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        # Open zip file for reading
        $driverZip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        # Copy selected items to the target directory
        $driverZip.Entries |
            ForEach-Object -Process {
                if ($_.Name -eq $driverFileName) {
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $driverPath , $true)
                 }
            }
        $driverZip.Dispose()
        Remove-Item -Force -Path $zipPath


    } catch {
        Write-Error "An error occured while extracting the driver from the zip file"
        exit 1
    }

}

function trimDriverVersion {
    param (
        [Parameter(Mandatory=$true)]
        [string] $browser,
        [Parameter(Mandatory=$true)]
        [string] $version
    )

    Switch ($browser) {
        "chrome" {
            return $version.Substring(13)

        }

        "edge" {
            return $version.Substring(25)
        }

        "firefox" {
            return $version.Substring(12)
        }
    }
}

#########
# SCRIPT

$driverversion=getDriverVersion($browser)
Write-Host "Installed driver:"$driverversion



$latestStableDriver=getLatestStableDriverVersion($browser)
Write-Host "Latest stable driver:"$latestStableDriver

# String comparison does not work, let's trim $driverVersion
$driverVersion = trimDriverVersion -browser $browser -version $driverVersion

if ($driverversion.StartsWith($latestStableDriver)) {
    Write-Host "Installed driver matches latest stable driver. Do nothing"
    exit 0
} else {
    $downloadUrl = getDownloadUrl -browser $browser -version $latestStableDriver
    updateDriver -browser $browser -url $downloadUrl
}

$newDriverVersion = getDriverVersion($browser)
Write-Host "New driver installed:"$newDriverVersion




