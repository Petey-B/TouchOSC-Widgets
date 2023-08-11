package.path = package.path .. 
";C:\\Users\\pjbxm\\AppData\\Roaming\\REAPER\\Scripts\\!MySkripz\\?.lua"
require "_DEBUG"

---- API
local r = reaper
local SMB = r.ShowMessageBox
local GAC = r.get_action_context
local MGA = r.MIDIEditor_GetActive
local MGT = r.MIDIEditor_GetTake

local ESN = r.MIDI_EnumSelNotes
local MSA = r.MIDI_SelectAll
local MCE = r.MIDI_CountEvts
local MGN = r.MIDI_GetNote
    -- bRet, bSel, bMute, nStartPPQpos, nEndPPQpos, iChan, iPitch, iVel = (take, idx)
local MSN = r.MIDI_SetNote

-- LOCAL GLOBALS
local take
local bWrap = true
local bNew = true	-- replace selection
local bPitch, bChan, bVel = false, false, false
local idx, idx2

local SAB = {
["p"] = function(i)
	local _,_,_,_,_,_,pitch = MGN(take,i)
	return pitch
	end,
["c"] = function(i)
	local _,_,_,_,_,chan = MGN(take,i)
	return chan
	end,
["v"] = function(i)
	local _,_,_,_,_,_,_,vel = MGN(take,i)
	return vel
	end
}


-- COMBING THE TWO - this is really hard to follow
local selectIDX = function(bPrev)	-- bool
	local idx, idx2, dir, pitch, chan, vel
	local chkPCV = bPitch or bChan or bVel
	-- we don't always need this...
	local _, nCt = MCE(take)
	local dir, first, last
	-- the first/last selected
	if bPrev	then
		-- get the first selected
		idx = ESN(take,-1)
		dir, first, last = -1, 0, nCt-1
	else
		-- get the last selected
		idx, idx2 = -1, -1
		repeat
			idx,idx2 = idx2, ESN(take,idx)
		until idx2 == -1
		dir, first, last = 1, nCt-1, 0
	end
	-- deselect if indicated
	if bNew then MSA(take,false) end
	local noSel = idx == -1
	-- if nothing selected, then by pitch, chan & vel are moot
	if chkPCV then
		if noSel then return
		else -- SAB not called if bool is false
			pitch = bPitch and SAB.p(idx)
			chan = bChan and SAB.c(idx)
			vel = bVel and SAB.v(idx)
		end
	end
	-- get the prev/next idx, wrap or return
	if noSel or idx == first then
		if bWrap then idx = last
		else return
		end
	else
		idx = idx + dir
	end
	-- we have the idx
	if chkPCV then
		local start = idx-dir
		local np, nc, nv
		-- wrap = -1 for prev, nCt for next
		local wrap = first + dir
		repeat
			_,_,_,_,_,nc,np,nv = MGN(take,idx)
			local pass = true
			if bPitch then pass = np==pitch end
			if pass and bChan then pass = pass and nc==chan end
			if pass and bVel then pass = pass and nv==vel end
			if pass then break
			else
				if idx == start then break
				else
					idx = idx + dir
					if idx == wrap then
						if bWrap then idx = last
						else return
						end
					end
				end
			end
		until false
	end
	MSN(take,idx,true,nil,nil,nil,nil,nil,nil,true)
end

---------------------- MAIN --------------------------------------------------

-- osc msg ( < | > | + | - | c | p | v ) ([P]) ([W]) ([X])

local _,_,_,_,_,_,_,conStr = GAC()
local sOp,sPitch,sChan,sVel,sWrap,sXtnd = 
	string.match(conStr,".+:s=(.)(P*)(C*)(V*)(W*)(X*)")

local hWnd = MGA()
if hWnd then
	take = MGT(hWnd)
	if take then
		-- trim
		if sOp == ">" or sOp == "<" then
			if sOp == ">" then
				idx = ESN(take,-1)
			else
				idx, idx2 = -1, -1
				local _, nCt = MCE(take)
				repeat
					idx,idx2 = idx2, ESN(take,idx)
				until idx2 == -1
			end
			if idx >= 0 then
				MSN(take,idx,false,nil,nil,nil,nil,nil,nil,true)
			end
		-- by pitch, channel, velocity
		elseif ("pcv"):find(sOp,1,true) then
			idx = ESN(take,-1)
			if idx ~= -1 then
				local sab = SAB[sOp]
				local ps = {}
				while idx ~= -1 do
					ps[sab(idx)] = true
					idx = ESN(take,idx)
				end
				local _, nCt = MCE(take)
				for i = 0,nCt-1 do
					MSN(take,i,ps[sab(i)],nil,nil,nil,nil,nil,nil,true)
				end
			end

		elseif sOp == "+" or sOp == "-" then
			bPitch = sPitch=="P"	-- false if ""
			bChan = sChan=="C"
			bVel = sVel=="V"
			bWrap = sWrap == "W"		-- false if ""
			bNew = sXtnd ~= "X"		-- true if ""
			selectIDX(sOp=="-")
			
		else
			SMB("Unknown op: '"..sOp.."'\nPassed in OSC message !",
			"OSC Error",0x30)
		end
	else
		SMB("MIDIEditor_GetTake() failed...\nTake object is bad or unavailable !",
		"ME_selSpan Script Error",0x30)
	end
else
	SMB("MIDIEditor_GetActive() failed...\nhWnd is bad or no MIDI editor open !",
	"ME_selSpan Script Error",0x30)
end