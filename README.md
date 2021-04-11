# ZOOM-Checker
Extract game titles from a saved ZOOM Platform web page.

![zoomcheck_dropbox_1](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_dropbox_1.png?raw=true)

The ZOOM Platform currently has no easy way to determine what games have been recently added.

ZOOM Checker.exe has been developed for that shortfall.

# HOW TO USE
(Original Method - Part 1)
1. Go to the ZOOM Platform website.
2. Select the 'GAMES' tab.
3. Scroll the list of games until all have been shown.
4. Save the web page to file (i.e. Zoom Platform.html).
5. Start the 'ZOOM Checker.exe' program.

(New Method - Part 1)
1. Start the 'ZOOM Checker.exe' program.
2. Click the GO button, to go to the ZOOM Platform 'Games' web page.
3. Wait until Games page has finished loading (scrollbar is the best indicator of this).
4. Click the TAB button, to load the next section of games.
5. Wait until next section has finished loading (scrollbar is the best indicator of this).
6. Click the TAB button again (wait & repeat) until it becomes a SAVE button.
7. Check all sections have loaded, and manually scroll if not.
8. Click the SAVE button to save the web page of games to file.

![zoomcheck_dropbox_2](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_dropbox_2.png?raw=true)
![zoomcheck_dropbox_3](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_dropbox_3.png?raw=true)

(Part 2)
1. Drag & drop your saved file (Zoom Platform.html) onto the drop area of 'ZOOM Checker'.
2. Wait while titles are being extracted and then displayed.

![zoomcheck_display](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_display.png?raw=true)

# NOTES
The 'ZOOM Checker' program is a floating dropbox, that will remember its screen position when closed.

The 'ZOOM Checker' program creates two files - Games.txt and Games.ini.

Games.txt is an alphanumeric listing of all games discovered.

Games.ini is also alphanumeric for the most part, but on subsequent runs of the program any newer game titles will appear at the end. It is also a record of games that may no longer exist.

The 'ZOOM Checker' program creates a third file on subsequent runs - Oldgames.txt.

Oldgames.txt is the previous 'Games.txt' file, and can be considered a backup.

The DISPLAY button on the dropbox, opens the 'Games.ini' file in the Display Viewer, where the most recent additions at the ZOOM Platform website, will be displayed last.

![zoomcheck_display_end](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_display_end.png?raw=true)

Date of original discovery is displayed in the third column, with any subsequent (current) check date displayed after (shown in brackets).

First row entry is the number of game titles listed. Last row entry is the number of game titles currently found versus number listed.

The date in the DATE column of the Display Viewer, is also a way of checking for games that no longer exist at the ZOOM Platform.

The 'Titles List' button opens the 'Games.txt' file in your default text file viewer (i.e. Notepad).

The entries in the 'Games.txt' file will always be in complete alphanumeric order, but the most recent game title additions, will have the text ' (NEW)' after the name, which you can easily search for.

![zoomcheck_notepad](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/Zoomcheck_notepad.png?raw=true)

Game titles no longer existing at the ZOOM Platform, won't appear in this file.

ZOOM Checker.exe can also be used from the command-line, so you could create a Registry right-click entry for it with HTML files if you wished, instead of using drag & drop with the floating dropbox.
