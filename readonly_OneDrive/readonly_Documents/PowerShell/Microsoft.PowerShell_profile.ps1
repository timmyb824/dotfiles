################TERMINAL PROMPTS################
# for using starship
Invoke-Expression (&starship init powershell)
$ENV:STARSHIP_CONFIG = "C:\Users\timot\.config\starship\starship.toml"
################TERMINAL PROMPTS################


################ALIASES################
Set-Alias -Name "reset" -Value $profile -Description "Reset the prompt"
Set-Alias -Name "dig" -Value Resolve-DnsName -Description "Resolve DNS name similar to dig"
Set-Alias -Name "gdu" -Value gdu_windows_amd64.exe -Description "Run disk usage analyzer"
Set-Alias -Name "chez" -Value chezmoi.exe -Description "Run chezmoi"
# Set-Alias 'sudo' 'gsudo'
################ALIASES################

################FUNCTIONS################
 function runBat {
    C:\Users\timot\AppData\Local\Microsoft\WinGet\Packages\sharkdp.bat_Microsoft.Winget.Source_8wekyb3d8bbwe\bat-v0.25.0-x86_64-pc-windows-msvc\bat.exe @args --paging=never
}
Set-Alias cat runBat -Description "Run bat with paging disabled"

function cheat {
    curl @args https://cheat.sh/
}

function touch {
    set-content -Path ($args[0]) -Value ($null)
}

function Open-NanoWithConfig {
    C:\Users\timot\.config\nano\bin\nano.exe -f C:\Users\timot\.nanorc @args
}
Set-Alias nano Open-NanoWithConfig
################FUNCTIONS################

################AUTO-COMPLETIONS################
# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
################AUTO-COMPLETIONS################

################OTHER################
# For zoxide v0.8.0+
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})
################OTHER################


}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58
