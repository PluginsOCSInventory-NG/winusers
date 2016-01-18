'---------------------------------------------------------- 
' Liste des utilisateurs 
' Auteur : ' J.C.BELLAMY © 2000 
' Adaptation pour OCS : Guillaume PRIOU
'----------------------------------------------------------
Dim network, computer, SAM, Item 
Set network = Wscript.CreateObject("WScript.Network") 
computer=network.ComputerName 
 
set SAM=GetObject("WinNT://" & computer & ",computer") 
for each Item in SAM 
   Classe=Item.Class 
   If Classe = "User" then 
      wscript.echo "<WINUSERS>"
      wscript.echo "<NAME>" & Item.name & "</NAME>"
      wscript.echo "</WINUSERS>"
   End if 
next
