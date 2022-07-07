# Function to get Admin user status
function Get-AdminUser {
	param([string] $username)
	$admingroup = Get-LocalGroupMember -SID "S-1-5-32-544" -ErrorAction SilentlyContinue
	$userType = "Local"
	
	foreach ($admin in $admingroup) {
		$name = $admin.name -split "\\"
		if($name[1] -eq $username){
			$userType = "Admin"
		}
	}
	
	return $userType
}

# Function to get user folder size
function Get-Size
{
	param([string]$pth)
	try {
		"{0:n2}" -f ((gci -path $pth -recurse -ErrorAction Ignore | measure-object -ErrorAction Stop -property length -sum).sum /1mb)
	} catch {
		"{0:n2}" -f 0
	}
}

# Function to check if is an AD user
function Check-AdUser($username) { 
    $ad_User = $null 
	try {
		$ad_User = Get-ADUser -Identity $username
		return "Domain" 
	} catch {
		return "Unknown" 
	}
}

# Function to retrieve user AD SID
function Get-AdSid
{
	param([string]$pth, [array]$profileList)
	foreach($sid in $profileList) {
		if($pth -eq $sid.ProfileImagePath) {
			return $sid.PSChildName
		}
	}

	return ""
}

#################################
#          Local User           #
#################################
$users = Get-LocalUser | Select *
$pathUsers = "C:\Users"
$allUsers = @()

$startTime = (get-date).AddDays(-15)
$logEvents = Get-Eventlog -LogName Security -after $startTime | where {$_.eventID -eq 4624}

foreach ($user in $users) {
	if($user.Name -ne $null){
	
		$userType = Get-AdminUser $user.Name
		$path = "C:\Users\"+ $user.Name
		$folderSize = Get-Size $path
		if($user.Enabled -ne "False") { $userStatus = "Disabled" } else { $userStatus = "Enabled" }
		if($userType -eq "Local") { $userType = $user.PrincipalSource }

		$numberConnexion = 0
		$workstation = ""
		$numberRemoteConnexion = 0
		$ipRemote ="" 

		foreach($userconnection in $logEvents){
			#In local logon
			if(($userconnection.ReplacementStrings[5] -eq $user.Name) -and (($userconnection.ReplacementStrings[8] -eq 2) -or ($userconnection.ReplacementStrings[8] -eq 7))){
				$numberConnexion = $numberConnexion + 1
				$workstation = $userconnection.ReplacementStrings[11]
			#In remote
			}if (($userconnection.ReplacementStrings[5] -eq $user.Name ) -and ($userconnection.ReplacementStrings[8] -eq 10)){
				$workstation = $userconnection.ReplacementStrings[11]
				$numberRemoteConnexion = $numberRemoteConnexion + 1
				$ipRemote = $userconnection.ReplacementStrings[18]
			}
		}

		$xml += "<WINUSERS>`n"
		$xml += "<NAME>"+ $user.Name +"</NAME>`n"
		$xml += "<TYPE>"+ $userType +"</TYPE>`n"
		$xml += "<SIZE>"+ $folderSize +"</SIZE>`n"
		$xml += "<LASTLOGON>"+ $user.LastLogon +"</LASTLOGON>`n"
		$xml += "<DESCRIPTION>"+ $user.Description +"</DESCRIPTION>`n"
		$xml += "<STATUS>"+ $userStatus +"</STATUS>`n"
		$xml += "<USERMAYCHANGEPWD>"+ $user.UserMayChangePassword +"</USERMAYCHANGEPWD>`n"
		$xml += "<PASSWORDEXPIRES>"+ $user.PasswordExpires +"</PASSWORDEXPIRES>`n"
		$xml += "<SID>"+ $user.SID +"</SID>`n"
		$xml += "<USERCONNECTION>"+ $numberConnexion +"</USERCONNECTION>`n"
		$xml += "<NUMBERREMOTECONNECTION>"+ $numberRemoteConnexion +"</NUMBERREMOTECONNECTION>`n"
		$xml += "<IPREMOTE>"+ $ipRemote +"</IPREMOTE>`n"
		$xml += "</WINUSERS>`n"

		$allUsers += $user.Name
	}
}

#################################
#            AD User            #
#################################
# Get computer account type connection
$Dsregcmd = New-Object PSObject ; Dsregcmd /status | Where {$_ -match ' : '} | ForEach { $Item = $_.Trim() -split '\s:\s'; $Dsregcmd | Add-Member -MemberType NoteProperty -Name $($Item[0] -replace '[:\s]','') -Value $Item[1] -EA SilentlyContinue }

$profileListPath =  @("Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*")
$profileList = Get-ItemProperty -Path $profileListPath -ErrorAction Ignore | Select ProfileImagePath, PSChildName

$tmp = Get-ChildItem -Path $pathUsers | Select "Name"
[System.Collections.ArrayList]$usersFolder = $tmp.Name

while ($usersFolder -contains "Public") {
	$usersFolder.Remove("Public")
}

$usersAd = $usersFolder | Where-Object {$allUsers -notcontains $_}

foreach ($userAd in $usersAd) {
	$path = "C:\Users\"+ $userAd

	$sid = Get-AdSid $path $profileList

	if($Dsregcmd.AzureAdJoined -eq "YES") {
		$folderSize = Get-Size $path
		$type = "AzureAD"
	}

	if($Dsregcmd.DomainJoined -eq "YES") {
		if (Get-Command Get-ADUser -errorAction SilentlyContinue) {
			$type = Check-AdUser -username $userAd
			$folderSize = Get-Size $path
		} else {
			$type = "Domain"
			$folderSize = Get-Size $path
		}
	}
	
	$xml += "<WINUSERS>`n"
	$xml += "<NAME>"+ $userAd +"</NAME>`n"
	$xml += "<TYPE>"+ $type +"</TYPE>`n"
	$xml += "<SIZE>"+ $folderSize +"</SIZE>`n"
	$xml += "<SID>"+ $sid +"</SID>`n"
	$xml += "</WINUSERS>`n"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
