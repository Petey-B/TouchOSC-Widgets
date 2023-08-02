### MIDI Editor Span Selector
**How To Use:**  
- Open the TouchOSC file
	- the **gSelSpan** control group can be pasted into another control surface
	- if you change the colors of the toggles, the control scripts will have to be edited
- Copy the Lua script **ME_selSpan.lua** into your Reaper scripts folder and add it to the Action List
- Add the **OSC** shortcut:
	- select ME_selSpan.lua, click **Add...** and tap any of the green buttons
	- the script should now be triggered by **/ME_selSpan**
- Open a MIDI editor window and start selecting
	- Tapping any of the green buttons will execute the selection of notes
	- The blue radio controls modify how the selection is made:
		- The top radio pertains to the buttons above it
		- The bottom radio controls the buttons below it
	- The round toggle buttons on the right modify what gets included/excluded
		- **+** - determines whether this is a new selection or extends an existing selection
		- **⊏♪** - includes only notes that start within the selection span
		- **♪⊐** - includes only notes that end within the selection span
	- If neither start nor end is on, notes are selected if any part of them falls within the selection span
	- The start/end buttons have no effect when selecting notes @ the edit cursor
	- None of these modifiers apply when selecting all notes in the current take

**Notes:**
- The toggles change their default values and are persistent only if the file is explicitly saved.  
	The changes do not flag the file as dirty, so it can be closed without prompting.  
	This actually has advantages; if you want it to start up a certain way, just save it.  
	TouchOSC needs an [b]onExit()[/b] callback.
- The selection algorithm uses exact PPQ values to determine inclusion.  
	As a result, boundary conditions may result in unintended selections.  
	If this turns out to be overly annoying I'll add a few more "if" blocks.