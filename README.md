# ZOOM-Checker
Extract game titles from a saved ZOOM Platform web page.

![zoomcheck_dropbox](https://github.com/Twombs/ZOOM-Checker/blob/main/Zoomcheck_dropbox.png?raw=true)

The ZOOM Platform currently has no easy way to determine what games have been recently added.

ZOOM Checker.exe has been developed for that shortfall.

# HOW TO USE
1. Go to the ZOOM Platform website.
2. Select the 'GAMES' tab.
3. Scroll the list of games until all have been shown.
4. Save the web page to file (i.e. Zoom Platform.html).
5. Start the 'ZOOM Checker.exe' program.
6. Drag & drop your saved file (Zoom Platform.html) onto the drop area of 'ZOOM Checker'.
7. Wait while titles are being extracted and then displayed.

![zoomcheck_display](https://github.com/Twombs/ZOOM-Checker/blob/main/Zoomcheck_display.png?raw=true)

# NOTES
The 'ZOOM Checker' program is a floating dropbox, that will remember its screen position when closed.
The 'ZOOM Checker' program creates two files - Games.txt and Games.ini.
Games.txt is an alphanumeric listing of all games discovered.
Games.ini is also alphanumeric for the most part, but on subsequent runs of the program any newer game titles will appear at the end. It is also a record of games that may no longer exist.
The 'ZOOM Checker' program creates a third file on subsequent runs - Oldgames.txt.
Oldgames.txt is the previous 'Games.txt' file, and can be considered a backup.
