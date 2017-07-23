'---------------------------------------------------------- 
' Liste des utilisateurs 
' Auteur : ' J.C.BELLAMY © 2000 
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
   wscript.echo "<WINUSERS>"
   wscript.echo "<NAME>" & StripAccents(objItem.Name) & "</NAME>"
   wscript.echo "<TYPE>Local user</TYPE>"
   wscript.echo "<DESCRIPTION>" & StripAccents(objItem.Description)  & "</DESCRIPTION>"
   wscript.echo "<DISABLED>" & objItem.Disabled  & "</DISABLED>"
   wscript.echo "<SID>" & objItem.SID  & "</SID>"
   wscript.echo "</WINUSERS>"
next

On Error Resume Next
Set objWinNT = GetObject("WinNT://./Administrateurs,group") ' get members of the local admin group
For Each Item In objWinNT.Members
    wscript.echo "<WINUSERS>"
    wscript.echo "<NAME>" & StripAccents(Item.Name) & "</NAME>"
    wscript.echo "<TYPE>Admin user</TYPE>"
    wscript.echo "<DESCRIPTION>" & StripAccents(Item.Description)  & "</DESCRIPTION>"
    wscript.echo "<DISABLED>" & Item.Disabled  & "</DISABLED>"
    wscript.echo "<SID>" & Item.SID  & "</SID>"
    wscript.echo "</WINUSERS>"
Next

