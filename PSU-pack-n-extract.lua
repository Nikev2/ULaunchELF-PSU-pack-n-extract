-- Frontend for the PSU Converter. Handles user interaction and calls the backend.

-- Load the backend script and our dialog handler module.
local backend = require("psu_converter")
local dialog_handler = require("dialog_handler")

--- Runs a command and captures its standard output.
local function capture_output(command)
    local lines = {}
    local file = io.popen(command)
    if not file then return nil end
    for line in file:lines() do
        print("  [PowerShell Output]: " .. line)
        table.insert(lines, line)
    end
    file:close()
    local output = table.concat(lines, "\n")
    return output:match("^%s*(.-)%s*$")
end

--- Shows a dialog by executing the embedded PowerShell script via a temporary file.
-- @param mode (string) The dialog mode to show (e.g., 'MainMenu', 'SelectFolder').
local function show_dialog(mode)
    -- *** THIS IS THE FINAL, CORRECTED LOGIC ***

    -- 1. Define a name for our temporary PowerShell script file.
    local temp_script_filename = "_temp_dialog.ps1"

    -- 2. Write the PowerShell script content from our module to this temporary file.
    local temp_file, err = io.open(temp_script_filename, "w")
    if not temp_file then
        print("Error: Could not create temporary script file: " .. (err or "unknown error"))
        return
    end
    temp_file:write(dialog_handler.script_content)
    temp_file:close()

    -- 3. Build the command to execute the temporary file with the correct mode.
    local command = string.format(
        "powershell -ExecutionPolicy Bypass -File %s -Mode %s",
        temp_script_filename,
        mode
    )

    -- 4. Execute the command and capture the output.
    local result = capture_output(command)

    -- 5. Clean up by deleting the temporary script file.
    os.remove(temp_script_filename)

    return result
end

-- --- Workflow for creating a .psu file. ---
local function run_create_workflow()
    print("\nOpening folder selector to choose the RAW save folder...")
    local source_path = show_dialog("SelectFolder")

    if not source_path or source_path == "" then
        print("\nOperation canceled: No source folder selected.")
        return
    end
    print("Source Folder Confirmed: " .. source_path)

    print("\nOpening file saver to choose the destination .psu file...")
    local dest_path = show_dialog("SaveFile")

    if not dest_path or dest_path == "" then
        print("\nOperation canceled: No destination file selected.")
        return
    end
    print("Destination File Confirmed: " .. dest_path)

    return "create", source_path, dest_path
end

-- --- Workflow for extracting a .psu file. ---
local function run_extract_workflow()
    print("\nOpening file selector to choose the .psu file to extract...")
    local source_path = show_dialog("OpenFile")

    if not source_path or source_path == "" then
        print("\nOperation canceled: No source file selected.")
        return
    end
    print("Source File Confirmed: " .. source_path)

    print("\nOpening folder selector for the destination folder...")
    local dest_path = show_dialog("SelectFolder")

    if not dest_path or dest_path == "" then
        print("\nOperation canceled: No destination folder selected.")
        return
    end
    print("Destination Folder Confirmed: " .. dest_path)

    return "extract", source_path, dest_path
end

-- --- Main Script Execution ---
print("--- PS2 Save Create/Extract Utility ---")
local mode = show_dialog("MainMenu")

local operation, source, destination

if mode == "Create" then
    operation, source, destination = run_create_workflow()
elseif mode == "Extract" then
    operation, source, destination = run_extract_workflow()
else
    print("\nOperation canceled by user.")
end

-- If an operation was chosen and paths were provided, call the backend.
if operation and source and destination then
    print("\nPaths selected. Starting process...")
    print("-------------------------------------------")
    
    if operation == "create" then
        backend.convert_to_psu(source, destination)
    elseif operation == "extract" then
        backend.extract_from_psu(source, destination)
    end
    
    print("-------------------------------------------")
    print("Process finished.")
    print("\nConsole will close in 5 seconds... (Close the window to skip)")
    os.execute("timeout /t 5 /nobreak > nul")
end
