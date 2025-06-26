-- This module contains the PowerShell script for creating native Windows dialogs.
-- Embedding it here allows the final application to be a single .exe file.

local M = {}

-- The entire PowerShell script is stored in this multi-line string.
-- Lua's [[...]] syntax is perfect for this, as it handles quotes and newlines.
M.script_content = [[
    # This PowerShell script block is executed by the main Lua application.
    param (
        [string]$Mode # The parameter decides which dialog to show.
    )

    # Add the .NET assembly needed for Windows Forms.
    Add-Type -AssemblyName System.Windows.Forms

    # Use a switch statement to show the correct dialog based on the -Mode.
    switch ($Mode) {
        'MainMenu' {
            $form = New-Object System.Windows.Forms.Form
            $form.Text = 'PSU Converter'; $form.Size = New-Object System.Drawing.Size(320,140); $form.StartPosition = 'CenterScreen'; $form.FormBorderStyle = 'FixedDialog'; $form.MaximizeBox = $false; $form.MinimizeBox = $false
            $label = New-Object System.Windows.Forms.Label; $label.Text = 'What would you like to do?'; $label.Location = New-Object System.Drawing.Point(20,20); $label.AutoSize = $true; $label.Font = New-Object System.Drawing.Font("Segoe UI", 10); $form.Controls.Add($label)
            $createButton = New-Object System.Windows.Forms.Button; $createButton.Location = New-Object System.Drawing.Point(20,50); $createButton.Size = New-Object System.Drawing.Size(80,30); $createButton.Text = 'Create'; $createButton.DialogResult = 'Yes'; $form.Controls.Add($createButton)
            $extractButton = New-Object System.Windows.Forms.Button; $extractButton.Location = New-Object System.Drawing.Point(110,50); $extractButton.Size = New-Object System.Drawing.Size(80,30); $extractButton.Text = 'Extract'; $extractButton.DialogResult = 'No'; $form.Controls.Add($extractButton)
            $cancelButton = New-Object System.Windows.Forms.Button; $cancelButton.Location = New-Object System.Drawing.Point(200,50); $cancelButton.Size = New-Object System.Drawing.Size(80,30); $cancelButton.Text = 'Cancel'; $cancelButton.DialogResult = 'Cancel'; $form.Controls.Add($cancelButton)
            $result = $form.ShowDialog()
            if ($result -eq 'Yes') { Write-Host "Create" }
            if ($result -eq 'No') { Write-Host "Extract" }
        }
        'SelectFolder' {
            $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Title = "Select a Folder"; $dialog.FileName = "Folder Selection"; $dialog.ValidateNames = $false; $dialog.CheckFileExists = $false; $dialog.AddExtension = $false
            if ($dialog.ShowDialog() -eq "OK") { Write-Host ([System.IO.Path]::GetDirectoryName($dialog.FileName)) }
        }
        'SaveFile' {
            $dialog = New-Object System.Windows.Forms.SaveFileDialog; $dialog.Title = "Save PSU File As..."; $dialog.Filter = "uLaunchELF MC (*.psu)|*.psu"; $dialog.DefaultExt = "psu"
$dialog.FileName = "Save"
            if ($dialog.ShowDialog() -eq "OK") { Write-Host $dialog.FileName }
        }
        'OpenFile' {
            $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Title = "Select .psu File to Extract"; $dialog.Filter = "uLaunchELF MC (*.psu)|*.psu"; $dialog.CheckFileExists = $true
            if ($dialog.ShowDialog() -eq "OK") { Write-Host $dialog.FileName }
        }
    }
]]

return M
