'---------------------------------------------------------- 
' Liste des utilisateurs 
' Auteur : ' J.C.BELLAMY © 2000 
' Adaptation pour OCS : Guillaume PRIOU
'----------------------------------------------------------
Dim network, computer, Item 
Set network = Wscript.CreateObject("WScript.Network") 
computer=network.ComputerName 

On Error Resume Next
Set objWMIService = GetObject("winmgmts:" _ 
    & "{impersonationLevel=impersonate}!\\" & computer & "\root\cimv2") 
 
Set colItems = objWMIService.ExecQuery _ 
    ("Select * from Win32_UserAccount Where LocalAccount = True") 
    
For Each objItem in colItems
   wscript.echo "<WINUSERS>"
   wscript.echo "<NAME>" & objItem.Name & "</NAME>"
   wscript.echo "<TYPE>Local user</TYPE>"
   wscript.echo "<DESCRIPTION>" & objItem.Description  & "</DESCRIPTION>"
   wscript.echo "<DISABLED>" & objItem.Disabled  & "</DISABLED>"
   wscript.echo "<SID>" & objItem.SID  & "</SID>"
   wscript.echo "</WINUSERS>"
next

On Error Resume Next
Set objWinNT = GetObject("WinNT://./Administrateurs,group") ' get members of the local admin group
For Each Item In objWinNT.Members
    wscript.echo "<WINUSERS>"
    wscript.echo "<NAME>" & Item.Name & "</NAME>"
    wscript.echo "<TYPE>Admin user</TYPE>"
    wscript.echo "<DESCRIPTION>" & Item.Description  & "</DESCRIPTION>"
    wscript.echo "<DISABLED>" & Item.Disabled  & "</DISABLED>"
    wscript.echo "<SID>" & Item.SID  & "</SID>"
    wscript.echo "</WINUSERS>"
Next

