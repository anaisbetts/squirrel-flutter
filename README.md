# Squirrel.Windows for Flutter 

This package creates desktop installers for Windows 7+ as well as implements auto-update, via Squirrel.Windows, an installer technology used originally as part of the Atom text editor and now deployed on millions of machines via projects such as Slack, Discord, GitHub Desktop, as well as hundreds of other projects.

## Getting Started (alpha) 
Run the following command, it will tell you what to do next (put an extra block in your pubspec.yaml).

```sh
flutter pub run squirrel:installer_windows
```

Now take that folder that it generates and upload that to Cloudfront / Fastly / any static CDN. Bingo bongo, you're done!

## How do I update? (alpha) 

This is WIP, but the extremely lazy answer is, run this command on startup via Process.run:

```sh
$WHATEVER_FOLDER_MY_EXECUTABLE_IS_IN/../Update.exe --update https://wherever-i-put-my-update-folder
```
`
Before this package reaches 1.0, it will have a proper API to do this!

## Where can I read more, because this README is extremely lacking in content! (I know) 

Read the [Squirrel documentation](https://github.com/Squirrel/Squirrel.Windows/blob/develop/docs/readme.md) - note that some of the names in this package have been clarified / simplified vs. what they are called in Squirrel.Windows, read installer_windows.dart in this package to see how things map.
