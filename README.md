# Simple Backups
A personal Lua script to backup files in the same folder. It uses `os.execute()` and requires an installation of [7-Zip](http://www.7-zip.org/).

## Usage
Include the correct path to the 7-Zip executable (`7z.exe`) in `files.lua`. Include tables to describe the files to backup as follows:

```lua
files["dummy_name"] = {
	inpath = "x:/dummy/path/in/",
	outpath = "y:/dummy/path/out/",
	filenames = {
		"dummy.d",
		"dummy.txt"
	}
}
```

- The name of the table (`dummy_name`) is used for the created archive (`dummy_name-XXXXXXXXXX.7z`)
- `inpath` is the path containing the files to backup
- `outpath` is the folder where the archive will be created (the folder will be created if it doesn't exist)
- `filenames` is a table of filenames (in the `inpath` folder) to backup (nonexisting files will be skipped)

Then call the script with `.../lua.exe backup.lua dummy_name`.

## File Description
- **backup.lua** is the main script
- **files.lua** contains the path to `7z.exe` and tables including paths of files to backup

## Changes
- **1.0**: Initial release

## To-Do
- [ ] implement an easier way to create `files.lua`
- [ ] circumvent `os.execute()`
- [ ] create the archive inside the script instead of using an existing application