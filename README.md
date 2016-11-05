# traktor-kontrol-screen-mods

DJ Sems Traktor Kontrol S5/S8 Screen Mods
------------------------------------------------

This repository is all about modding your S5/S8 Screens.
All of my work is heavily based on 
https://github.com/ErikMinekus/traktor-kontrol-screens   as well as
https://www.native-instruments.com/forum/threads/s8-s5-display-mods.288222/  (Native Instruments Forum User "Sydes").

So credits to these two awesome guys!!!

I looked at both of their great work and combined/rearranged their screens and functions so that
it bests fits my DJing style and what I would like to see on the hardware screens.

Before you do ANY modding, make sure to completely backup your "qml" folder from Traktor and store it somewhere save, so that
you can always go back to Traktors initial Screen setup.

Please be aware that I don't take any responsibility for anything that might go wrong when using these mods.
I guess the worst thing that could happen is that the S5/S8 Screens don't show nothing after turning on the Traktor Software. If this happens to you, just revert your changes (by simply overwriting the files back to their original state using the BACKUP you saved before), then you should be fine again.

What's on the screens after applying the mods:
- Browser: Smaller Titles in Browser List, colored musical Key (having a musical background, I always use the musical keys instead of the chamelot ones ...)
- Browser: Track currently loaded in Deck A is displayed in White / Track loaded in Deck B is displaydd in Green
- Deck: Header shows current Phrases/Bars/Beats and Phrases/Bars/Beats until nect User Cue Point (function taken from "Sydes")
- Deck: Header shows current musical Key and underneath original musical key. If key is changed, the current musical key is displayed in red
- Deck: Footer shows BPM, remaining time, Tempo and Loop (I THINK this footer has originally been done by ErikMinekus, I just  rearranged it)

Here is how the modded screens look like:
The Browser List:
![Browser](https://github.com/semomat/traktor-kontrol-screen-mods/blob/screenshots/BrowserList.jpg "Browser")

A Deck with no active Loop, no Sync and changed Key:
![Deck](https://github.com/semomat/traktor-kontrol-screen-mods/blob/screenshots/DeckNoLoopNoSyncChangedKey.jpg "Deck with no active Loop, no Sync and changed Key")

A Deck with an active Loop, Synced switched on and changed Key:
![Deck](https://github.com/semomat/traktor-kontrol-screen-mods/blob/screenshots/DeckActiveLoopChangedKey.jpg "Deck with active Loop, Sync and changed Key")

In order to use this mod on your S5/S8, just follow the instructions mentioned here (its more or less simply a matter of overwriting some files):
http://djtechtools.com/2016/09/23/hack-kontrol-s8s5-screens-advanced-layouts/ (but again: Backup the original files so that you can always revert back!!)

Simply download this repository, and then completely overwrite the "Screens" folder of Traktor with the "Screens" Folder of this repository.

If you are into modding yourself, I added a customizable string property in the file DeckFooter.qml named "custom_branding_name", which looks like this:

  readonly property string custom_branding_name: ""
  
You can change this to whatever you like, for example:

  readonly property string custom_branding_name: "DJ Sem"
 
This string then appears in the lower left corner of the Deck View, mainly to be used for, well, impress ppl staring at your controller screens during a gig :)

Current Open "issues":
- Loop Number not completely properly aligned within the box

That's about all.

Happy Modding :)





