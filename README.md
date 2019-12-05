# Mounty 2

Mounty 2 is a clean rewrite of [Mounty](https://github.com/x0054/mounty) in Swift. This virsion of Mounty also concentrates on a slightly different use case, namely automating mounting Samba shares in command line on MacOS while safely storing passwords.

## Problem

Imagine you have a Samba (Windows File Server) share that you need to mount on your mac periodically, and you would like to mount the share with a command line script, but for security reasons you don't want to repeatedly type in the share password on the command line or store the password in a script.

## Solution

The standard MacOS mount command doesn't play nice with **MacOS's Keychain**, but Mounty does! And it's super simple to use in a shell script. Try it out today!

## Usage

This command will attempt to mount the share located at `smb://server/share` with credentials for user `user` and the password stored in the **MacOS Keychain** for that user inside the folder specified as `/mount/point`.

```
mounty smb://user@server/share /mount/point
```

If the Keychain doesn't have the password for the user, the OS will prompt the user to enter and save the password.

In some cases it is usefull to only attemnpt to connect to a given share if you are connected to the right WiFi network. This is especially usefull in my consulting work. To help with this Mounty takes an optional 3rd argument of `WiFi_SSID` and will only attempt the connection if the system is currently connected to the specified SSID.

```
mounty smb://user@server/share /mount/point WiFi_SSID
```

## Instalation

