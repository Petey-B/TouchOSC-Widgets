### MIDI Editor View Scroll/Zoom
**How To Use:**  
- Open the TouchOSC file
	- after the initial setup you only need the **gView** control group
	- you can copy and paste it into another file
- Copy the two Lua scripts into your Reaper scripts folder and add them to the Action List
	- MEV_scroll.lua
	- MEV_zoom.lua
- Edit the scripts if necessary:
	- The scripts use MIDI channel 16 and CC#'s 10 through 13
	- Change the parameters to StuffMIDIMessage( 1, 0xBF, CC#, CCval )
	- channel 16 is 0xBF, 1-15 would be 0xB0 - 0xBE
	- the CC#s must be four distinct values
	- the values are up to you, but must be set before assigning the shortcuts

- Add the **OSC** shortcuts:
	- make sure the mode it set to "Scroll"
	- select MEV_scroll.lua click **Add...** and nudge the fader
	- tap the mode button to switch to "Zoom"
	- select MEV_zoom.lua click **Add...** and nudge the fader
	- the two scripts should now be triggered by their OSC namesakes

- Add the **MIDI** shortcuts:
	- in the Action List **Section** dropdown, select **MIDI Editor**
	- using the **Filter** box search for "wheel"
	- select the following scripts, click **Add...** and tap the corresponding button in the widget
		- View: Scroll horizontally (MIDI relative/mousewheel)
		- View: Scroll vertically (MIDI relative/mousewheel)
		- View: Zoom horizontally (MIDI relative/mousewheel)
		- View: Zoom vertically (MIDI relative/mousewheel)
	- when assigning, set the **MIDI CC** dropdown to **Relative 2**
	- if you changed the CC values, change them in the MIDI message that the buttons send

- ***If you are running TouchOSC locally*** on a touchscreen monitor that grabs focus:
	- arm a track for MIDI input if the button's MIDI messages aren't picked up
	- if this doesn't work, try running it on a phone or tablet

**Caveats:**
  - If you're running TouchOSC locally on a touchscreen monitor there are problems with the MIDI messages being received by Reaper. This has to do with the active application focus switching when you tap the control surface. 	- This issue is resolved by the call to:
		>SN_FocusMIDIEditor()
- If you don't plan on ever using TouchOSC locally, this line can be removed from the scripts.
- This function is part of the SWS extensions API, if you leave it in you'll need to have SWS.
