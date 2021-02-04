function Get-AdminUser {
	param([string] $username)
	$admingroup = Get-LocalGroupMember -Group "Administrators"
	$userType = "Local user"
	
	foreach ($admin in $admingroup) {
		$name = $admin.name -split "\\"
		if($name[1] -eq $username){
			$userType = "Admin user"
		}
	}
	
	return $userType
}

function Get-Size
{
	param([string]$pth)
	"{0:n2}" -f ((gci -path $pth -recurse | measure-object -property length -sum).sum /1mb)
}


$users = Get-LocalUser | Select *

foreach ($user in $users) {
	if($user.Name -ne $null){
	
		$userType = Get-AdminUser $user.Name
		$path = "C:\Users\"+ $user.Name
		$folderSize = Get-Size $path
		if($user.Enabled -ne "False") { $userStatus = "Disabled" } else { $userStatus = "Enabled" }
	
		$xml += "<WINUSERS>"
		$xml += "<NAME>"+ $user.Name +"</NAME>"
		$xml += "<TYPE>"+ $userType +"</TYPE>"
		$xml += "<SIZE>"+ $folderSize +"</SIZE>"
		$xml += "<LASTLOGON>"+ $user.LastLogon +"</LASTLOGON>"
		$xml += "<DESCRIPTION>"+ $user.Description +"</DESCRIPTION>"
		$xml += "<STATUS>"+ $userStatus +"</STATUS>"
		$xml += "<USERMAYCHANGEPWD>"+ $user.UserMayChangePassword +"</USERMAYCHANGEPWD>"
		$xml += "<PASSWORDEXPIRES>"+ $user.PasswordExpires +"</PASSWORDEXPIRES>"
		$xml += "<SID>"+ $user.SID +"</SID>"
		$xml += "</WINUSERS>"
	}
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
