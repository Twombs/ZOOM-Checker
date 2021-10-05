# ZOOM-Checker

## NEW METHOD

This program downloads (checks for) a list of all games available at the ZOOM Platform store.

![zoomcheck_gui](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/ZOOM_gui_3.png?raw=true)

It also keeps a record of important changes to a game (removal, rename, price).

1. Columns can be sorted by clicking on the header.
2. Redundant entries can be removed (row color is Olive).
3. A game entry marked for removal has a row color of Black.
4. REMOVE button marks a game for removal or (UNSET) restores.
5. APPLY button removes all listings marked for removal.
6. Removed games populate a file called 'Removals.ini'.
7. New additions to the list have a row color of Fuchsia, and should be shown at the end of the unsorted list. Game listings by default are not necessarily sorted alphanumeric, until the 'Game' column for title is clicked.
8. Games can be marked as owned (OWN) or a favorite (FAV), with the store or stores (Multiple) specified. Any unlisted store name can be set, but best to keep them short (so abbreviate if needed).
9. Row color is Skyblue (owned) or Yellow (favorite).
10. Price changes are also indicated by a row color if different to the 'Prior' value - Lime (less) or Red (more).
11. The SAVE button uses a web connection to download the web page for the selected game, extracting & saving the summary. It also downloads the image file. DETAIL button shows both.

![Zoomcheck_details](https://github.com/Twombs/ZOOM-Checker/blob/main/Screenshots/ZOOM_detail.png?raw=true)

12. Summary and Image file can be saved to a selected location (i.e. game folder).
13. A log record is kept for some processes.
14. Can go to the web page for the selected game with a button click.

BIG THANKS to Adam @ ZOOM Platform for the 'CHECK' link.

© April 2021 by Timboli (aka TheSaint) (updated to this new method in October 2021).
