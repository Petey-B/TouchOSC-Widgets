### MIDI Editor Note Selector
**Installation:**
- Open the TouchOSC file
	- the **gSelNote** control group can be copied and pasted into another control surface
	- if you change the colors of the toggles, the control scripts will have to be edited
- Copy the three support scripts into your Reaper scripts folder and add them to the Action List
	- **ME_selByIDX.lua**
	- **ME_selByPPQ.lua**
	- **ME_selByOffset.lua**
	- I split these into seperate files to keep the load time down
- Add the **OSC** shortcuts:
	- select **ME_selByIDX.lua**, click **Add...** and tap any of the purple Index triangles
	- select **ME_selByPPQ.lua**, click **Add...** and tap either of the green PPQ triangles
	- select **ME_selByOffset.lua**, click **Add...** and tap the **ByOffset** button
	- the scripts should now be triggered by their OSC namesakes

**Usage:**
- Open a MIDI editor window and start selecting
	- the top two triangle buttons **◁ ▷** select the prev/next note
	- the middle two triangle buttons **▷◁** trims an existing selection by removing the first/last note
	- the bottom two triangle buttons **◁ ▷** select all the prev/next notes that have the same PPQ
		- this allows the selection of chords with a single tap
		- if the MIDI has been recorded or humanized the PPQs may not be exactly the same
		- in this case see the **slop toggle**
	- the prev/next buttons are flanked by oval toggle buttons which affect the selection as follows:
		- **+** - determines whether this is a new selection or extends an existing selection
		- **🔁** - determines whether the selection will wrap when it reaches the end of the take
	- below the Index/PPQ section there is a slop toggle ... *aka tolerance (but it's slop)*
		- **≈** - activates a radio control for selecting notes in a PPQ range instead of at exact values
		- the first note's PPQ is snapped to the nearest even value set by the radio control
		- subsequent notes are checked to see if they fall within the range +/- have the slop value
		- **G** uses the current grid settings for the slop value
		- the slop toggle also applies to the **By Offset** button
		- it has no effect on the index based selectiors
	- the **By Offset** button was inspired by Lokasenna's MIDI Note Selector, with some accoutrements
		- to use it start by selecting a note or notes
		- tapping the button will select all the notes that occur at the same offset in every measure
		- useful, for example, if you want to select all the offbeats in a percussion track
		- the span radio control determines whether the offset is calculated from the start of, and applied to, a single measure, multiple measures of a half-measure
		- slop is taken into account if toggled on
		- the **=♪** toggle limits the selection to notes of the same pitch


**Notes:**
	- The toggles change their default values and are persistent only if the file is explicitly saved.  
		The changes do not flag the file as dirty, so it can be closed without prompting.  
		This actually has advantages; if you want it to start up a certain way, just save it.  
