# ULaunchELF-PSU-pack-n-extract
A small software used to pack/extract psu files like you would in U/WlaunchELF on PC.
<br />
<br />
<br />
<br />

Download here: https://github.com/Nikev2/ULaunchELF-PSU-pack-n-extract/releases/

## Why does this exist? Couldn't you just use existing tools?

I made this tool because I was tired of having to use U_Launch_ELF to constantly transfer saves between pcsx2 (using mymc) and my regular FAT PS2 via a USB drive. There were no tools to help me, even the py_psu wasn't enough for me.

Since I love to geek out, I wanted to make it a little less tedious way of transferring saves between the emulator and the console. All you do is start the program, click the option you want to do yada yada yada more details at the bottom.

## Features

-   Extract `.psu` files into raw memory card saves (aka Folder like BASUS-298298 (made that up) )
    
-   Packing Raw memory card saves into a `.psu` file.
    

## Installation Requirements

-   Windows 7 or newer. May work on wine due to its simplicity, but the PowerShell might be tricky.
    
-   PowerShell 2.0 or newer (included by default in Windows 7 and up).
    
-   .NET Framework 2.0 or newer (included by default in all modern Windows versions).
    
-   LUA 5.4 or higher (for source code users)
    

## Installation Guide

-   **Using the EXE:** Extract the contents of  anywhere you want and run the EXE file.
    
-   **From the source (Note building not available yet):**
    
    -   Download the source code
        
    -   run `cd ULaunchELF-PSU-pack-n-extract`
        
    -   run `lua run_converter.lua` to use it
        

## Usage:

 - Click the `PSU-pack-n-extract.exe` file
 - A Dialog box should come up saying "what do you want to do?" with options.
 - Notes: 
	 - that the tutorial here splits depending on the option you want
	 -  if your using ftp it won't work in ftp directories, you must drag it to a folder in windows
	 - do not get weirded by the `.psu` file not having a notepad icon, it doesn't need to. I just tinkered with mine.

 
 - ## Create (Folder to .psu)
	 - Click on the create option
	 - It will open a file/folder selection window, Your **game save** is in a folder like in the image below. Select that folder and click "Open" sometimes you need to click it twice.
	 ![enter image description here](https://i.imgur.com/sggzW6f.png)
	- It will then open up another file selection window, this time asking where you want to save the file. Do that and then click the confirmation (aka the save or open file button)
	- If its done properly the console window will say `Console will close in 5 seconds... (Close the window to skip)`
	- Your done! If you want you can test to see if its being read properly use mymc. This is what the file looks like if you didn't name it![](https://i.imgur.com/MYYc4r3.png)
	- Heres my GTA SA psu save in ps2 save builder![enter image description here](https://i.imgur.com/TRm3e38.png)
	
 - ## Extract (.psu to Folder)
	 - Click the "Extract" option 
	 - When file selection comes up select the `.psu` file. A psu file looks like this ![](https://i.imgur.com/MYYc4r3.png)
	 - At the next file selection pop-up select the folder or directory you want your save in, I recommend downloads since its easy to acess.
	 - If the console window outputs ``Console will close in 5 seconds... (Close the window to skip)`` then it was sucessfull
	 - Your done now put that in your ps2 memory card via FTP this is what the program was made for note you still need to use UlaunchELF in order to start the ftp stuff
	 - Folder should look like this with numbers the game and more numbers. like this![enter image description here](https://i.imgur.com/sggzW6f.png)

  
