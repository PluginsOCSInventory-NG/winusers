function Get-AdminUser {
	param([string] $username)
	$admingroup = Get-LocalGroupMember -SID "S-1-5-32-544"
	$userType = "Local"
	
	foreach ($admin in $admingroup) {
		$name = $admin.name -split "\\"
		if($name[1] -eq $username){
			$userType = "Admin"
		}
	}
	
	return $userType
}

function Get-Size
{
	param([string]$pth)
	try {
		"{0:n2}" -f ((gci -path $pth -recurse -ErrorAction Ignore | measure-object -ErrorAction Stop -property length -sum).sum /1mb)
	} catch {
		"{0:n2}" -f 0
	}
}

function Check-AdUser($username) { 
    $ad_User = $null 
    $ad_User = Get-ADUser -Identity $username 
    if($ad_User -ne $null) { 
        return "Domain user" 
    } else { 
        return "Local user" 
    }
}

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
		$xml += "<USERCONNEXION>"+ $numberConnexion +"</USERCONNEXION>`n"
		$xml += "<NUMBERREMOTECONNEXION>"+ $numberRemoteConnexion +"</NUMBERREMOTECONNEXION>`n"
		$xml += "<IPREMOTE>"+ $ipRemote +"</IPREMOTE>`n"
		$xml += "</WINUSERS>`n"

		$allUsers += $user.Name
	}
}

$tmp = Get-ChildItem -Path $pathUsers | Select "Name"
[System.Collections.ArrayList]$usersFolder = $tmp.Name

while ($usersFolder -contains "Public") {
	$usersFolder.Remove("Public")
}

$usersAd = $usersFolder | Where-Object {$allUsers -notcontains $_}

foreach ($userAd in $usersAd) {
	$path = "C:\Users\"+ $userAd
	if (Get-Command Get-ADUser -errorAction SilentlyContinue) {
		$type = Check-AdUser -username $userAd 
		$folderSize ='0'
	} else {
		$folderSize = Get-Size
		$type = "Domain"
	}
	
	$xml += "<WINUSERS>`n"
	$xml += "<NAME>"+ $userAd +"</NAME>`n"
	$xml += "<TYPE>"+ $type +"</TYPE>`n"
	$xml += "<SIZE>"+ $folderSize +"</SIZE>`n"
	$xml += "</WINUSERS>`n"
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
