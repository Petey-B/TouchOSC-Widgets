### MIDI Editor Note Length Setter/Adjuster
**How To Use:**  
- Open the TouchOSC file **ME_gNoteLength.tosc**
	- the **gNoteLen** control group can be pasted into another control surface
	- if you change the colors of the toggles, the control scripts will have to be edited
- Copy the Lua script **MEN_Length.lua** into your Reaper scripts folder and add it to the Action List
- Add the **OSC** shortcut:
	- select MEN_Length.lua, click **Add...** and tap any of the blue buttons
	- the script should now be triggered by **/MEN_Length**
- Open a MIDI editor window
	- The buttons in the top row adjust the length of the selected notes
		- **×2** - doubles the note length
		- **÷2** - halves the note length
		- **•**  - increases to note length by 50%
	- The buttons in the left column set/adjust the note length by the value selected in the grid
		- **=** - sets the note length
		- **+** - adds to the note length
		- **-** - subtracts from the note length
	- If nothing is selected none of the buttons do anything

**Notes:**
	- When subtracting, the minimum note length is a 256th note
	- When halving a note, there is no minimum. However:  
		At Reaper's default of 960 PPQ a 256th note is 7 ticks long.  
		All PPQ calculations are done with integer values so halving and doubling  
		notes shorter than 7 ticks will not result in the original length.  
		Keep this in mind if your PPQ setting is not the default value.