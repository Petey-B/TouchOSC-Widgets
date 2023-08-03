### MIDI Editor Note Selector
**How To Use:**  
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

- Open a MIDI editor window and start selecting
	- the top two triangle buttons **◁▷** select the prev/next note
	- the middle two triangle buttons **▷◁** trims an existing selection by removing the first/last note
	- the bottom two triangle buttons **◁▷** select all the prev/next notes that have the same PPQ