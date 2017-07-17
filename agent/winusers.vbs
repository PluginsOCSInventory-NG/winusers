'---------------------------------------------------------- 
' Liste des utilisateurs
' Auteur : ' J.C.BELLAMY Â© 2000 
' Adaptation pour OCS : Guillaume PRIOU
'----------------------------------------------------------
Dim network, computer, Item 
Set network = Wscript.CreateObject("WScript.Network") 
computer=network.ComputerName 

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

On Error Resume Next
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & computer & "\root\cimv2") 
 
Set colItems = objWMIService.ExecQuery _ 
    ("Select * from Win32_UserAccount Where LocalAccount = True") 
    
For Each objItem in colItems
   wscript.echo _
   "<WINUSERS>"en(str)      currentChar = mid(str,k, 1)
      o = InStr(accent, currentChar)
      If o > 0 Then
         result = result & mid(noaccent,o,1)
      Else
         result = result & currentChar
      End If
   Next
   StripAccents = result
End Function

On Error Resume Next
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & computer & "\root\cimv2") 
 
Set colItems = objWMIService.ExecQuery _ 
    ("Select * from Win32_UserAccount Where LocalAccount = True") 
    
For Each objItem in colItems
   wscript.echo _
"<WINUSERS>" & VbCrLf &_
"<NAME>" & StripAccents(objItem.Name) & "</NAME>" & VbCrLf &_
"<TYPE>Local user</TYPE>" & VbCrLf &_
"<DESCRIPTION>" & StripAccents(objItem.Description)  & "</DESCRIPTION>" & VbCrLf &_
"<DISABLED>" & objItem.Disabled  & "</DISABLED>" & VbCrLf &_
"<SID>" & objItem.SID  & "</SID>" & VbCrLf &_
   "</WINUSERS>"
next

On Error Resume Next
Set objWinNT = GetObject("WinNT://./Administrateurs,group") ' get members of the local admin group
For Each Item In objWinNT.Members
    wscript.echo _
"<WINUSERS>" & VbCrLf &_
"<NAME>" & StripAccents(Item.Name) & "</NAME>" & VbCrLf &_
"<TYPE>Admin user</TYPE>" & VbCrLf &_
"<DESCRIPTION>" & StripAccents(Item.Description)  & "</DESCRIPTION>" & VbCrLf &_
"<DISABLED>" & Item.Disabled  & "</DISABLED>" & VbCrLf &_
"<SID>" & Item.SID  & "</SID>" & VbCrLf &_
"</WINUSERS>"
Next
