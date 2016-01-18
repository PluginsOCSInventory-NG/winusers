<?php
function plugin_version_winusers()
{
return array('name' => 'winusers',
'version' => '1.0',
'author'=> 'Guillaume PRIOU, Gilles DUBOIS',
'license' => 'GPLv2',
'verMinOcs' => '2.2');
}

function plugin_init_winusers()
{
$object = new plugins;
$object -> add_cd_entry("winusers","other");

$object -> sql_query("CREATE TABLE `winusers` (`ID` INT(11) NOT NULL AUTO_INCREMENT,`HARDWARE_ID` INT(11) NOT NULL,
 `NAME` VARCHAR(255) DEFAULT NULL, PRIMARY KEY  (`ID`,`HARDWARE_ID`)) ENGINE=InnoDB;");

}

function plugin_delete_winusers()
{
$object = new plugins;
$object -> del_cd_entry("winusers");

$object -> sql_query("DROP TABLE `winusers`;");

}

?>
