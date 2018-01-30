# Simple Backups
A personal Lua script to backup files in the same folder. It uses `os.execute()` to copy files and comes with the command line version of [7-Zip](http://www.7-zip.org/). 7-Zip is licensed under [GNU LGPL](http://www.gnu.org/).

## Usage
Include tables in `files.lua` to describe the files to backup as follows:

```lua
files["dummy_name"] = {
	inpath = "x:\\dummy\\path\\in",
	outpath = "y:\\dummy\\path\\out",
	filenames = {
		"dummy.d",
		"dummy.txt",
		"subfolder\\dummy.f",
		"subfolder2\\"
	}
}
```

- The name of the table (`dummy_name`) is used for the created archive (`dummy_name-XXXXXXXXXX.7z`)
- `inpath` is the path containing the files to backup
- `outpath` is the folder where the archive will be created (the folder will be created if it doesn't exist)
- `filenames` is a table of filenames (in the `inpath` folder) to backup (nonexisting files will be skipped) (files in subfolders are allowed)

Then call the script with `.../lua.exe backup.lua dummy_name`.

Another method is to set up the batch file. Include the location of `backup.lua` there. Then you can also call the script by using the batch file: `backup.bat dummy_name`

## File Description
- **backup.lua** is the main script
- **files.lua** contains tables including paths of files to backup
- **backup.bat** is a batch script which calls backup.lua
- **7za.exe**, **7za.dll** and **7zxa.dll** are the standalone files of 7-Zip

## Changes
- **1.3**: Script is now able to copy whole subfolders instead of only specific files
- **1.2**: Included handling of files in subfolders of `inpath`
- **1.1**: Now includes 7-Zip (licensed under [GNU LGPL](http://www.gnu.org/))
- **1.0**: Initial release

## To-Do
- [ ] implement an easier way to create `files.lua`
- [ ] circumvent `os.execute()`
- [ ] create the archive inside the script instead of using an existing application