### Current Project Monitor
**How To Use:**  
- Paste the widget into an existing control surface
- Copy the Lua scripts into your Reaper scripts folder and add them to the Action List
- You'll have to either:
	- set the MIDI device ID that Reaper uses for bridge to 20, or
	- edit the **OSCcurrentProject.lua** file and change local ID to your device ID + 16
 	- if you want to use a channel other than 16, change it in the widget and the script
  	- the CC#, which defaults to 90, can be changed in the widget's main group (message and script)
- In the Action List
	- Select **OSCcurrentProject.lua**
	- Click **Add** and hit the power button
	- Select **OSCexit.lua**
	- Click **Add** and hit the power button again
- The next time you hit the power button the widget should be active

**Known Issues**
  - If you're running TouchOSC locally on a touchscreen monitor there are problems with the initial MIDI messages being received by the widget. This has to do with the active application focus switching when you tap the power button. If the widget is not updated when turning on or off, uncomment the 2 lines
  	- **r.midi_init(ID-16,-1)**
