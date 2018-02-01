'----------------------------------------------------------
' Plugin for OCS Inventory NG 2.x
' Script : Users list
' Version : 2.20
' Date : 01/02/2018
' Authors : J.C. BELLAMY © 2000 and Stéphane PAUTREL (acb78.com)
' OCS adaptation  :	Guillaume PRIOU
'----------------------------------------------------------
' OS checked [X] on	32b	64b	(Professionnal edition)
'	Windows XP		[X]
'	Windows Vista	[X]	[X]
'	Windows 7		[X]	[X]
'	Windows 8.1		[X]	[X]	
'	Windows 10		[X]	[X]
'	Windows 2k8R2		[X]
'	Windows 2k12R2		[X]
'	Windows 2k16		[X]
' ---------------------------------------------------------
' NOTE : No checked on Windows 8
' ---------------------------------------------------------
On Error Resume Next

Dim Network, objFSO, Computer, objWMIService
Dim colItems, objItem, colAdmGroup, UserType, UserStatus, objAdm
Dim accent, noaccent, currentChar, result, k, o

Set objFSO = Wscript.CreateObject("Scripting.FileSystemObject")
Set Network = Wscript.CreateObject("WScript.Network")
Computer=Network.ComputerName

Function StripAccents(str)
	accent   = "ÈÉÊËÛÙÏÎÀÂÔÖÇèéêëûùïîàâôöç"
	noaccent = "EEEEUUIIAAOOCeeeeuuiiaaooc"
	currentChar = ""
	result = ""
	k = 0
	o = 0
	For k = 1 To len(str)
		currentChar = mid(str,k, 1)
		o = InStr(accent, currentChar)
		If o > 0 Then
			result = result & mid(noaccent,o,1)
		Else
			result = result & currentChar
		End If
	Next
	StripAccents = result
End Function

Function IfAdmin(str)
	Set colAdmGroup = GetObject("WinNT://./Administrateurs") ' get members of the local admin group
	UserType = "Local user"
	For Each objAdm In colAdmGroup.Members
		If objAdm.Name = objItem.Name Then
			UserType = "Local admin"
		End If
	Next
End Function

Function getFolderSize(folderName)	
    On Error Resume Next
    size = 0
    hasSubfolders = False
    Set folder = objFSO.GetFolder(folderName)
    Err.Clear
    size = folder.Size

    If Err.Number <> 0 then   
        For Each subfolder in folder.SubFolders
            size = size + getFolderSize(subfolder.Path)
            hasSubfolders = True
        Next

        If not hasSubfolders then
            size = folder.Size
        End If
    End If

    getFolderSize = size

    Set folder = Nothing        
End Function

Set objWMIService = GetObject("winmgmts:root\cimv2")

Set colItems = objWMIService.ExecQuery _
	("Select * from Win32_UserAccount Where LocalAccount = True")

For Each objItem in colItems
	IfAdmin(objItem.Name)
	UserStatus = objItem.Disabled
	If objItem.Disabled = "False" Or objItem.Disabled = "Faux" Then UserStatus = "Actif"	' or Enabled in your native language
	If objItem.Disabled = "True" Or objItem.Disabled = "Vrai" Then UserStatus = "Inactif"	' or Disabled in your native language
	Set objFolder = objFSO.GetFolder("C:\Users\" & objItem.Name & "")
	
	dtmLastLogin = "NC"	' Default text (for ex. Never connected)
	On Error Resume Next
	Set objUser = GetObject("WinNT://./" & objItem.Name & ",user")
	dtmLastLogin = objUser.LastLogin
	
	Wscript.echo _
		"<WINUSERS>" & VbCrLf &_
		"<NAME>" & StripAccents(objItem.Name) & "</NAME>" & VbCrLf &_
		"<TYPE>" & UserType & "</TYPE>" & VbCrLf &_
		"<SIZE>" & round(getFolderSize(objFolder)/(1024*1024),0) & "</SIZE>" & VbCrLf &_
		"<LASTLOGON>" & dtmLastLogin & "</LASTLOGON>" & VbCrLf &_
		"<DESCRIPTION>" & StripAccents(objItem.Description)  & "</DESCRIPTION>" & VbCrLf &_
		"<STATUS>" & UserStatus  & "</STATUS>" & VbCrLf &_
		"<SID>" & objItem.SID  & "</SID>" & VbCrLf &_
		"</WINUSERS>"
	Set objFolder = Nothing
Next