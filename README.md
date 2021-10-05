ZOOM-Checker
Extract game titles from a saved ZOOM Platform web page.

zoomcheck_dropbox_7 zoomcheck_dropbox_8

The ZOOM Platform previously had no easy way to determine what games have been recently added. 'News' page now show this.

ZOOM Checker.exe had been developed for that prior shortfall. Some features of this program remain handy.

HOW TO USE
(Part 1 - Original Method)
Go to the ZOOM Platform website.
Select the 'GAMES' tab.
Scroll the list of games until all have been shown.
Save the web page to file (i.e. Zoom Platform.html).
Start the 'ZOOM Checker.exe' program.
Go to Part 2.
(Part 1 - New Method)
(Part 1 - TAB or LOAD process) - (Optional) refers to v1.4 or newer.

Start the 'ZOOM Checker.exe' program.
(Optional) Click the dropdown combo field and select SETTINGS.
(Optional) Browse and set a save folder path on the SETTINGS window.
(Optional) Enable the save folder path usage. This also makes the READ button state available.
(Optional) Set your browser Save Dialog window title in that field (i.e Save As).
(Optional) Close the SETTINGS window.
Zoomcheck_settings.png

(Part 1 - LOAD process only)

If 'One TAB' is not enabled, then right-click the GO button and enable that option.

(Part 1 - TAB or LOAD process)

Click the GO button, to go to the ZOOM Platform 'Games' web page.
Wait until Games page has finished loading (scrollbar is best indicator of this).
(Part 1 - TAB process only)

Click the TAB button, to load the next section of games.
Wait until next section has finished loading (scrollbar is best indicator of this).
Click the TAB button again (wait & repeat) until it becomes a SAVE button.
(Part 1 - LOAD process only)

Click the LOAD button.
Wait until all game sections have finished loading (scrollbar is best indicator of this).
(Part 1 - TAB or LOAD process)

Check all sections have loaded, and manually scroll if not.
Click the SAVE button to save the web page of games to file. NOTE - Some automation is available (v1.4 or newer only).
When your browser 'Save Dialog' window appears, browse (if no automation) to set the download destination, then click 'Save'.
Go to Part 2 ... or Click the READ button (v1.4 or newer only). READ parses (processes) 'Zoom Platform.html' and displays the result.
zoomcheck_dropbox_2 zoomcheck_dropbox_6 zoomcheck_dropbox_3 zoomcheck_dropbox_8

(Part 2)
Drag & drop your saved file (Zoom Platform.html) onto the drop area of 'ZOOM Checker'.
Wait while titles are being extracted and then displayed.
zoomcheck_dropbox_4 zoomcheck_dropbox_5

zoomcheck_display

NOTES
The 'ZOOM Checker' program is a floating dropbox, that will remember its screen position when closed.

The 'ZOOM Checker' program creates two files - Games.txt and Games.ini.

Games.txt is an alphanumeric listing of all games discovered.

Games.ini is also alphanumeric for the most part, but on subsequent runs of the program any newer game titles will appear at the end. It is also a record of games that may no longer exist.

The 'ZOOM Checker' program creates a third file on subsequent runs - Oldgames.txt.

Oldgames.txt is the previous 'Games.txt' file, and can be considered a backup.

The DISPLAY button on the dropbox, opens the 'Games.ini' file in the Display Viewer, where the most recent additions at the ZOOM Platform website, will be displayed last.

zoomcheck_display_end

Date of original discovery is displayed in the third column, with any subsequent (current) check date displayed after (shown in brackets).

First row entry is the number of game titles listed. Last row entry is the number of game titles currently found versus number listed.

The date in the DATE column of the Display Viewer, is also a way of checking for games that no longer exist at the ZOOM Platform.

The 'Titles List' option opens the 'Games.txt' file in your default text file viewer (i.e. Notepad).
The 'Removed' games option opens the 'List.txt' file in your default text file viewer.
The 'Added' games option opens the 'List.txt' file in your default text file viewer.
Entries in the 'Games.txt' file will always be in complete alphanumeric order, but most recent game title additions, will have the text '(NEW)' after the name, which you can easily search for.

zoomcheck_notepad

Game titles no longer existing at the ZOOM Platform, won't appear in this file.

ZOOM Checker.exe can also be used from the command-line, so you could create a Registry right-click entry for it with HTML files if you wished, instead of using drag & drop with the floating dropbox. There are obvious benefits to using the dropbox though.
