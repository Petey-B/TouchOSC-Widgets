### Edit Cursor Jog Wheel
**How To Set Up:**  
- Open the TouchOSC file **WDG_gECjog.tosc**
	- the **gECjog** control group can be pasted into another control surface
	- unlike my previous widgets this works with both the Track List and the MIDI Editor
	- if a MIDI Editor is open, its grid setting and start/end of the current take are used
	- otherwise the Track List grid and project start/end are used
	- functionally, everything else works the same
- Copy the Lua script **EC_Jog.lua** into your Reaper scripts folder and add it to the Action List
	- the setup buttons on the right side are not part of the widget but make assigning the shortcuts easier
- Add the **OSC** shortcut:
	- select EC_Jog.lua, click **Add...** and tap the bottom setup button or any of the other buttons
	- the script should now be triggered by **/EC_Jog**
- Add the **MIDI** shortcuts:
	- select the appropriate native transport actions from the **Main** section of the action list
	- click **Add...** and tap the corresponding setup buttons
	- when assigning, set the **MIDI CC** dropdown to **Relative 2**


**How To Use:**  
- The button pads at the top act on the project, or current take if the MIDI Editor is open
	- **|◀** - moves to the start
	- **▶|** - moves to the end
- The button pads at the bottom do the same thing as the jog wheel, but move by a single interval
	- **◀**  - moves left
	- **▶**  - moves right
	- these buttons do not snap to the current interval
- The inner (purple) ring is the encoder that does the actual jogging
- The half circle toggle buttons in the center activate **Scrub** mode
	- uses the jog encoder to trigger Reaper's native scrub actions
	- these are usually associated with a mouse wheel modifier
	- the actions are triggered by MIDI CC's 14 and 15 on vhannel 16
	- scrubbing issues when running on a local display can be resolved by either
		- uncommenting the lines  
			> local hWnd = r.GetMainHwnd()  
			> r.BR_Win32_SetFocus(hWnd)  
		- arming a track for MIDI recording

**Notes:**
	- **SCALING**:  Keep the document the same size as the destination screen
		- The tolerances are pretty tight and scaling may cause overlap and clipping
	- See the post in the Reaper forum  
		- **MIDI Hardware, Control Surfaces, and OSC** > TouchOSC Widgets for Reaper  
		for additional details...
