-- PSU Converter Backend (Create and Extract) - MODULE VERSION
-- This script acts as a library for the main frontend script.

local lfs = require("lfs")
local string_pack = string.pack
local string_unpack = string.unpack
local string_rep = string.rep
local string_sub = string.sub
local path_sep = "\\" -- Manually set for Windows

-- This table will hold our functions to export them as a module
local M = {}

-- Attribute constants
local MC_ATTR_NORM_FOLDER = 0x8427
local MC_ATTR_NORM_FILE = 0x8497

----------------------------------------------------
-- INTERNAL HELPER FUNCTIONS
----------------------------------------------------

local function timestamp_to_ps2time(timestamp)
    local dt = os.date("*t", timestamp)
    return string_pack('<BBBBBBH', 0, dt.sec, dt.min, dt.hour, dt.day, dt.month, dt.year)
end

local function create_psu_header(name, attr, size, ctime, mtime)
    local header_parts = {}
    header_parts[1] = string_pack('<H', attr)       -- Attr @ offset 0x00
    header_parts[2] = string_rep('\0', 2)           -- Unknown @ offset 0x02
    header_parts[3] = string_pack('<I', size)       -- Size @ offset 0x04
    header_parts[4] = timestamp_to_ps2time(ctime)   -- cTime @ offset 0x08
    header_parts[5] = string_rep('\0', 8)           -- EMS_used @ offset 0x10
    header_parts[6] = timestamp_to_ps2time(mtime)   -- mTime @ offset 0x18
    header_parts[7] = string_rep('\0', 32)          -- Gap to offset 0x40

    local name_padded = (name .. string_rep('\0', 32)):sub(1, 32)
    header_parts[8] = name_padded                   -- Name @ offset 0x40

    local header_string = table.concat(header_parts)
    return (header_string .. string_rep('\0', 512)):sub(1, 512)
end

local function read_psu_header(file_handle)
    local header_data = file_handle:read(512)
    if not header_data or #header_data < 512 then return nil end
    local header = {}
    header.size = string_unpack('<I', header_data, 5)
    header.name = header_data:sub(0x41):match("([^\0]*)")
    return header
end

----------------------------------------------------
-- PUBLIC MODULE FUNCTIONS
----------------------------------------------------

function M.convert_to_psu(source_dir, output_psu_file)
    print("--- Starting PSU Creation Process ---")
    local source_attrs = lfs.attributes(source_dir)
    if not source_attrs or source_attrs.mode ~= "directory" then
        print("Error: Source directory '" .. source_dir .. "' not found.")
        return
    end

    local file_list = {}
    for file in lfs.dir(source_dir) do
        if file ~= "." and file ~= ".." and lfs.attributes(source_dir .. path_sep .. file, "mode") == "file" then
            table.insert(file_list, file)
        end
    end
    print("Found " .. #file_list .. " files to process.")

    local folder_name = source_dir:match("([^" .. path_sep .. "]+)$")
    local main_header_size = #file_list + 2
    local folder_ctime = source_attrs.creation
    local folder_mtime = source_attrs.modification

    local psu_file, err = io.open(output_psu_file, "wb")
    if not psu_file then print("Error opening output file: " .. err); return end

    psu_file:write(create_psu_header(folder_name, MC_ATTR_NORM_FOLDER, main_header_size, folder_ctime, folder_mtime))
    psu_file:write(create_psu_header(".", MC_ATTR_NORM_FOLDER, 0, folder_ctime, folder_mtime))
    psu_file:write(create_psu_header("..", MC_ATTR_NORM_FOLDER, 0, folder_ctime, folder_mtime))
    
    for i, filename in ipairs(file_list) do
        local file_path = source_dir .. path_sep .. filename
        local file_attrs = lfs.attributes(file_path)
        print(string.format("\n  (%d/%d) Processing '%s'...", i, #file_list, filename))
        psu_file:write(create_psu_header(filename, MC_ATTR_NORM_FILE, file_attrs.size, file_attrs.creation, file_attrs.modification))
        
        local f_in, err_in = io.open(file_path, "rb")
        if not f_in then print("Error opening '" .. file_path .. "': " .. err_in); goto continue end
        psu_file:write(f_in:read("*a"))
        f_in:close()

        local padding_size = (0x400 - (file_attrs.size % 0x400)) % 0x400
        if padding_size > 0 then psu_file:write(string_rep(string.char(0xFF), padding_size)) end
        ::continue::
    end
    
    psu_file:close()
    print("\n--- All files processed. ---")
    print("\nCreation successful!")
end

function M.extract_from_psu(source_psu_file, output_dir)
    print("--- Starting PSU Extraction Process ---")
    local psu_file, err = io.open(source_psu_file, "rb")
    if not psu_file then print("Error opening source PSU file: " .. err); return end

    local main_header = read_psu_header(psu_file)
    if not main_header then print("Error: Invalid or corrupt PSU file."); psu_file:close(); return end
    
    local root_folder_path = output_dir .. path_sep .. main_header.name
    print("Creating root folder: " .. root_folder_path)
    lfs.mkdir(root_folder_path)

    read_psu_header(psu_file) -- Skip '.'
    read_psu_header(psu_file) -- Skip '..'

    local file_count = main_header.size - 2
    print("Found " .. file_count .. " files to extract...")
    for i = 1, file_count do
        local file_header = read_psu_header(psu_file)
        if not file_header then print("Error: PSU file ended unexpectedly."); break end

        if file_header.name == "" then
             print("Warning: Found an entry with no filename. Skipping.")
             if file_header.size > 0 then psu_file:read(file_header.size) end
             local padding_size = (0x400 - (file_header.size % 0x400)) % 0x400
             if padding_size > 0 then psu_file:read(padding_size) end
             goto continue
        end

        print(string.format("\n  (%d/%d) Extracting '%s'...", i, file_count, file_header.name))
        print(string.format("    - Size: %d bytes", file_header.size))

        local content = psu_file:read(file_header.size)
        if not content or #content ~= file_header.size then print("Error: Could not read file content from PSU."); break end

        local out_path = root_folder_path .. path_sep .. file_header.name
        
        local f_out, err_out = io.open(out_path, "wb")
        if not f_out then print("Error creating output file '" .. out_path .. "': " .. err_out); goto continue end
        f_out:write(content)
        f_out:close()
        print("    - File written to " .. out_path)

        local padding_size = (0x400 - (file_header.size % 0x400)) % 0x400
        if padding_size > 0 then psu_file:read(padding_size) end
        ::continue::
    end

    psu_file:close()
    print("\n--- All files extracted. ---")
    print("\nExtraction successful!")
end

-- Return the module table so other scripts can use its functions
return M