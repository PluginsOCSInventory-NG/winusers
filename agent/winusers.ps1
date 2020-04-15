function Get-AdminUser {
	param([string] $username)
	$admingroup = Get-LocalGroupMember -Group "Administrateurs"
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
		$xml += "</WINUSERS>`n"
	}
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::WriteLine($xml)
