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
	-- >nul suppresses stdout ; 2>nul suppresses stderr
	if os.execute('cd "' .. path .. '" >nul 2>nul') == nil then
		-- path doesn't exist
		return false
	else
		-- path exists
		return true
	end
end

-- creates an compressed archive using 7z
-- parameters: folder of files to compress, name for output
function create_archive(infiles, outfile)	
	-- create filename (including timestamp)
	archive_file = outfile .. "-" .. os.time() .. ".7z"
	
	-- create archive
	-- extra quote around the whole command because Windows-CMD removes the first and last quotation mark
	-- -mx9 specifies maximum compression
	-- -sdel deletes files after including
	-- -xr!outfile-*.7z excludes all previously generated 7z files
	-- -x!_lastbackup.log exludes the logfile
	os.execute('"7za.exe a ' .. infiles .. archive_file .. ' ' .. infiles .. '*" -mx9 -sdel -xr!' .. outfile .. '-*.7z -x!_lastbackup.log >nul')
	
	io.write('\n')
end


-----------
-- "Main"
-----------

-- load table of files
dofile('files.lua')

-- check if any argument was given
if arg[1] == nil then
	io.write('Usage: lua backup.lua name_of_table')
	return
end

-- check if the given table exists
if files[arg[1]] == nil then
	io.write(arg[1] .. ' is not defined in files.lua')
	return
end

-- get copy of table and in/outpath
local table_of_files = files[arg[1]]
local inpath = table_of_files['inpath']
local outpath = table_of_files['outpath']

-- Check if the paths end with forward-slashed. If not -> add them
if string.sub(inpath, string.len(inpath)) ~= '\\' then
	inpath = inpath .. '\\'
end
if string.sub(outpath, string.len(outpath)) ~= '\\' then
	outpath = outpath .. '\\'
end

-- check if paths exist
-- 7z.exe
if file_exists('7za.exe') == false then
	io.write('7za.exe not found.\n')
	return false
end

-- input
if path_exists(inpath) == false then
	io.write('The path "'..inpath..'" is not valid\n')
	return
end

-- output
if path_exists(outpath) == false then
	io.write('The path "'..outpath..'" does not exist.\nShould it be created? (y/n) ')
	-- get user input
	local create_path = io.read()
	if create_path == 'y' then
		-- create folder
		os.execute('md "' .. outpath .. '"')
	else
		-- exit
		return
	end
end

-- start timer
io.write('Copying started...\n')
local start = os.time()

-- init empty string and number
input_string = ''
file_count = 0

-- iterate over table of inputfiles
for k,current_file in pairs(table_of_files['filenames']) do
	-- test if current_file is actually a folder
	if string.sub(current_file,-1) == '\\' then
		-- check if the folder exists
		if path_exists(inpath..current_file) == true then
			-- create the respective directory
			os.execute('md "' .. outpath..current_file .. '" >nul 2>nul')
			
			-- copy all files in subfolder recursively (robocopy)
			-- omit the trailing backslash
			os.execute('robocopy "'..string.sub(inpath..current_file,1,-2)..'" "'..string.sub(outpath..current_file,1,-2)..'" /E >nul 2>nul')
			
			-- count files in copied folder to update file counter
			for _f in io.popen('dir '.. string.sub(outpath..current_file,1,-2) ..' /b'):lines() do
				file_count = file_count + 1
			end
			
			io.write(string.gsub(current_file,'*','') .. ' copied.\n')
		else
			io.write(current_file .. ' not found. Will be skipped.\n')
		end
	else
		-- (re)initialize subdirs to take care of files in subdirectories
		subdirs = ''
		-- check if file exists
		if file_exists(inpath .. current_file) == true then
			-- increase file_count and copy file
			file_count = file_count + 1
			
			-- if the file is in a subdirectory, create the folder structure
			if string.find(current_file,'\\') ~= nil then
				-- reverse the string and find the first backslash -> its the last backslash in the original string (TODO: write extra method)
				last_position = 1 + string.len(outpath..current_file) - string.find(string.reverse(outpath..current_file),'\\')
				-- create a directory
				os.execute('md "' .. string.sub(outpath..current_file,1,last_position) .. '" >nul 2>nul')
				-- add subdirectory to outpath
				subdirs = string.sub(outpath..current_file,string.len(outpath)+1,last_position)
			end
			-- >nul suppresses stdout ; 2>nul suppresses stderr
			os.execute('copy "' .. inpath .. current_file .. '" "' .. outpath .. subdirs .. '" >nul 2>nul')
			io.write(current_file .. ' copied.\n')
		else
			io.write(current_file .. ' not found. Will be skipped.\n')
		end
	end
end

-- input_string starts with a space -> remove it
input_string = string.sub(input_string, 2)

-- create the archive (if there were files to compress)
if file_count > 0 then
	create_archive(outpath, arg[1])
end

-- create logfile which contains time of last backup
logfile = io.open(outpath.."//_lastbackup.log", "w")
logfile:write(os.date("%Y-%m-%d %H-%M-%S"))
logfile:close()

-- stop timer
local elapsedTime = os.difftime(os.time(), start)
io.write(string.format('%d File(s) copied in %.1f seconds.', file_count, elapsedTime))