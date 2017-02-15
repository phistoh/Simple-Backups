-- checks if a given file exists
function file_exists(name)
	-- open the file
	local file=io.open(name, "r")
	if file == nil then
		-- file doesn't exist
		return false
	else
		-- file exists: close it and return true
		io.close(file)
		return true
	end
end

-- checks if a given path exists
function path_exists(path)
	if os.execute("cd \"" .. path .. "\" >nul 2>nul")  == nil then
		-- path doesn't exist
		return false
	else
		-- path exists
		return true
	end
end

-- creates an compressed archive using 7z
-- parameters: path to 7z.exe, input file (or concatenated string of input files), name for output
function create_archive(zip, infiles, outfile)	
	-- create filename (including timestamp)
	archive_file = outfile .. "-" .. os.time() .. ".7z"
	
	-- create archive
	-- extra quote around the whole command because Windows-CMD removes the first and last quotation mark
	os.execute("\"\"" .. zip .. "\" a " .. archive_file .. " " .. infiles .. "\"")
	
	io.write("\n")
end


-----------
-- "Main"
-----------
-- load table of files
dofile("files.lua")

-- check if any argument was given
if arg[1] == nil then
	io.write("Usage: lua backup.lua name_of_table")
	return
end

-- check if the given table exists
if files[arg[1]] == nil then
	io.write(arg[1] .. " is not defined in files.lua")
	return
end

-- get copy of table and in/outpath
local table_of_files = files[arg[1]]
local inpath = table_of_files["inpath"]
local outpath = table_of_files["outpath"]

-- check if paths exist
-- 7z.exe
	if file_exists(path_of_7z) == false then
		io.write("7z.exe not found.\n")
		return false
	end

-- input
if path_exists(inpath) == false then
	io.write("The path \""..inpath.."\" is not valid\n")
	return
end

-- output
if path_exists(outpath) == false then
	io.write("The path \""..outpath.."\" does not exist.\nShould it be created? (y/n) ")
	-- get user input
	local create_path = io.read()
	if create_path == "y" then
		-- create folder
		os.execute("md \"" .. outpath .. "\"")
	else
		-- exit
		return
	end
end

-- start timer
io.write("Copying started...\n")
local start = os.time()

-- init empty string and number
input_string = ""
file_count = 0

-- iterate over table of inputfiles
for k,current_file in pairs(table_of_files["filenames"]) do
	-- check if file exists
	if file_exists(inpath .. current_file) == true then
		-- concatenate string and increase file_count
		input_string = input_string .. " \"" .. inpath .. current_file .. "\""
		file_count = file_count + 1
	else
		io.write(current_file .. " not found. Will be skipped.\n")
	end
end

-- input_string starts with a space -> remove it
input_string = string.sub(input_string, 2)

-- create the archive (if there were files to compress)
if file_count > 0 then
	create_archive(path_of_7z, input_string, outpath .. arg[1])
end

-- stop timer
local elapsedTime = os.difftime(os.time(), start)
io.write(string.format("%d File(s) copied in %.1f seconds.", file_count, elapsedTime))