$ScriptVersion = "2.1.1"

# Header start
$OS = "Unknown OS"
if ($IsWindows) {
    $OS = "Windows"
} elseif ($IsMacOS) {
    $OS = "Mac OS"
} elseif ($IsLinux) {
    $OS = "Linux" + $Env:OS
}

# MSVC is C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/MSVC/14.30.30705/bin/Hostx64/x64/cl
# Clang is C:/Program Files/Microsoft Visual Studio/2022/Community/VC/Tools/Llvm/x64/bin/clang++.exe

$PreviousColor = 'White'
$Host.UI.RawUI.ForegroundColor = $PreviousColor

function Write-Green {
    $Host.UI.RawUI.ForegroundColor = 'Green'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Yellow {
    $Host.UI.RawUI.ForegroundColor = 'Yellow'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Red {
    $Host.UI.RawUI.ForegroundColor = 'Red'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Purple {
    $Host.UI.RawUI.ForegroundColor = 'DarkMagenta'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Magenta {
    $Host.UI.RawUI.ForegroundColor = 'Magenta'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-White {
    $Host.UI.RawUI.ForegroundColor = 'White'
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Black {
    $Host.UI.RawUI.ForegroundColor = "Black"
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Cyan {
    $Host.UI.RawUI.ForegroundColor = "Cyan"
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

function Write-Blue {
    $Host.UI.RawUI.ForegroundColor = "Blue"
    Write-Output $args
    $Host.UI.RawUI.ForegroundColor = $PreviousColor # Restore the previous foreground color    
}

# Unused values under here
# $IncludePath = "C:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/"

# Header end

# Arguments check
$oargs = $args

function Get-Parameter([String]$param) {
    $value = ""
    for ($id = 0; $id -lt $oargs.Length; $id = $id + 1) {
        $itemraw = $oargs[$id]
        $item = $itemraw.ToString() # Make sure item is a string
        if ($item.StartsWith("-") -or $item.StartsWith("/")) {
            if($item.StartsWith("--")) {
                $item = $item.Substring(2)
            } else {
                $item = $item.Substring(1)
            }

            if ($item.Contains("=")) {
                $temp = $item.Split("=")
                $prefix = $temp[0]
                if ($prefix -eq $param) {
                    $value = $temp[1]
                }
            }

            if ($id + 1 -lt $oargs.Length -and $item.Contains(":")) {
                    #if ($oargs[$id + 1].ToString().StartsWith(":")) {
                    
                    $temp = $item.Split(":")
                    $prefix = $temp[0]
                    if ($prefix -eq $param) {
                        return $oargs[$id + 1].ToString()
                    }
            #}
            } elseif ($item.Contains(":")) {
                $temp = $item.Split(":")
                $prefix = $temp[0]
                if ($prefix -eq $param) {
                    $value = $temp[1]
                }
            }
        }
    }
    return $value
}

$PSMinVersion = 7
$PSVersion = $PSVersionTable.PSVersion.Major
if($PSVersionTable.PSVersion.Major -lt 6) {
    $PSVersionFull = $PSVersionTable.PSVersion.Major.ToString() + "." + $PSVersionTable.PSVersion.Minor.ToString() + "." + $PSVersionTable.PSVersion.Revision.ToString()
} else {
    $PSVersionFull = $PSVersionTable.PSVersion.Major.ToString() + "." + $PSVersionTable.PSVersion.Minor.ToString() + "." + $PSVersionTable.PSVersion.Patch.ToString()
}

$Location = Get-Location
$LocationPath = $Location.Path

try {
    if ($PSVersion -lt $PSMinVersion) {
        Write-Red "You are using PowerShell version $PSVersionFull, which is not officially supported by this script, using PowerShell 7"
        Write-Blue "Running PowerShell 7 to execute script..."
        $InvocationName = $MyInvocation.MyCommand.Name
        $PowerShell7Exists = Test-Path "C:\Program Files\powershell\7\"
        if ($PowerShell7Exists -eq $False) {
            if($IsWindows -and [System.Environment]::OSVersion.Version.Major -ge 10) {
                Write-Red "PowerShell 7 not found"
                Write-Blue "Installing PowerShell 7 using WinGet"
                Winget install Microsoft.PowerShell
            } elseif ($IsWindows) {
                Write-Red "Unable to install PowerShell since you don't have WinGet"
            } elseif($IsLinux) {
                Write-Red "WARNING: Unable to automatically install PowerShell 7 on linux, please install it to continue"
            }
        }
        try {
            pwsh.exe -Command "./$InvocationName $args" 
            Write-Green 'Run "pwsh" to use PowerShell 7'
            exit
        } catch {
            Write-Red "PowerShell 7 doesn't seem to be installed, please install it at https://aka.ms/PSWindows to use this"
            exit
        }
    }


    Write-Green "Lmaxplay C# build script $ScriptVersion" 'Licensed under the MIT License' 'Copyright 2022 Lmaxplay' ""

    # TODO Possibly re-add this as an argument?
    # Write-Cyan "Running on PowerShell version $PSVersionFull" ""

    Write-Cyan 'Running compiler...'

    $Compiler = Get-Parameter "compiler"
    if($Compiler -eq "") {
        $Compiler = "0"
    }
    Write-Magenta $CompilerParam
    $Action

    $CompilerTimer = [Diagnostics.Stopwatch]::StartNew()
    
    dotnet build "./EXTLIBSharp.csproj" -nologo

    $CompilerTimer.Stop()
    $CompileTime = $CompilerTimer.Elapsed
    Write-Cyan "Compile took $CompileTime"

    $CompileOut = $LASTEXITCODE
    if($CompileOut -ne 0) {
        Write-Red "exited with error code $CompileOut"
    } else {
        Write-Cyan "Compile completed succesfully"
    }
    Write-White ""
    Set-Location $LocationPath

} catch {
    Write-Cyan "An error occured"
    Write-Red $Error
    $Error.Clear()
    Set-Location $LocationPath
}