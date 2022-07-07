<?php

/**
 * This function is called on installation and is used to create database schema for the plugin
 */
function extension_install_winusers()
{
    $commonObject = new ExtensionCommon;

    // Drop table first
    $commonObject -> sqlQuery("DROP TABLE `winusers`;");

    $commonObject -> sqlQuery(
        "CREATE TABLE `winusers` (
            `ID` INT(11) NOT NULL AUTO_INCREMENT,
            `HARDWARE_ID` INT(11) NOT NULL,
            `NAME` VARCHAR(255) DEFAULT NULL,
            `TYPE` VARCHAR(255) DEFAULT NULL,
            `SIZE` VARCHAR(255) DEFAULT '0',
            `LASTLOGON` VARCHAR(255) DEFAULT NULL,
            `DESCRIPTION` VARCHAR(255) DEFAULT NULL,
            `STATUS` VARCHAR(255) DEFAULT NULL,
            `USERMAYCHANGEPWD` VARCHAR(255) DEFAULT NULL,
            `PASSWORDEXPIRES` VARCHAR(255) DEFAULT NULL,
            `SID` VARCHAR(255) DEFAULT NULL,
            `USERCONNECTION` VARCHAR(255) DEFAULT NULL,
            `NUMBERREMOTECONNECTION` VARCHAR(255) DEFAULT NULL,
            `IPREMOTE` VARCHAR(255) DEFAULT NULL,
            PRIMARY KEY  (`ID`,`HARDWARE_ID`)
        ) ENGINE=InnoDB ;"
    );
}

/**
 * This function is called on removal and is used to destroy database schema for the plugin
 */
function extension_delete_winusers()
{
    $commonObject = new ExtensionCommon;
    $commonObject -> sqlQuery("DROP TABLE `winusers`;");
}

/**
 * This function is called on plugin upgrade
 */
function extension_upgrade_winusers()
{

}
