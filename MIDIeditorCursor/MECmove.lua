--[[	MECmove.lua	-	/MECmove "+/-  G/M/N/Q  [S/E]"
			
			F MoveEC (qn)
			F SnapEC (qpi,right)
			F ECtoNote (start, prev)

]]

local r = reaper
local GAC = r.get_action_context
local GCP = r.GetCursorPosition -- () in seconds
local SECP = r.SetEditCurPos -- (n time, b moveview, b seekplay)
local GMI = r.GetMediaItemTake_Item -- (take)
local GMIV = r.GetMediaItemInfo_Value -- (item, string)

local MGA = r.MIDIEditor_GetActive -- ()
local MGT = r.MIDIEditor_GetTake -- (hWnd)
local MGG = r.MIDI_GetGrid -- (take)
local GTS = r.TimeMap_GetTimeSigAtTime --i num, i denom, n tempo = (proj, n time)
local MCE = r.MIDI_CountEvts
local MGN = r.MIDI_GetNote


local t2qn = r.TimeMap_timeToQN -- (time)
local qn2t = r.TimeMap_QNToTime -- (qn)
local pt2ppq = r.MIDI_GetPPQPosFromProjTime -- ( take, projtime )
local ppq2pt = r.MIDI_GetProjTimeFromPPQPos -- (take, PPQpos)

local tix = r.SNM_GetIntConfigVar("miditicksperbeat",0)
local take

-- MOVE THE EDIT CURSOR BY QUARTER NOTES
local MoveEC = function (qn)
	SECP(qn2t(t2qn(GCP())+qn),true,false)
end

-- qpi == quarters per interval
-- right (bool) indicates direction
local SnapEC = function (qpi,right)
	-- get absolute ppq
	local ippq = math.floor(t2qn(GMIV(GMI(take),"D_POSITION"))*tix + 0.5)
	local ppq = pt2ppq(take,GCP()) + ippq
	local snap = tix * qpi
	ppq = (right and (snap * (1 + (ppq-1)//snap))
				or (snap * (ppq//snap))) - ippq
	
	SECP(ppq2pt(take,ppq),true,false)
end

local ECtoNote = function(start, prev)
	local _, nCt = MCE(take)
	local cppq = pt2ppq(take,GCP())	-- xlat EC to take PPQ
	local found = false
	-- loop params
	local fs, fe = prev and nCt-1 or 0, prev and  0 or nCt-1
	local stp = prev and -1 or 1
	local ridx = start and 4 or 5
	local nppq

	for idx = fs,fe,stp do
		nppq = ({MGN(take,idx)})[ridx]
		if (prev and nppq < cppq) or (not prev and nppq > cppq) then
			found = true
			break
		end
	end

	if found then
		SECP(ppq2pt(take,nppq),true,false)
	end
end

-- +/-	G/M/N/Q	[S/E]

local _,_,_,_,_,_,_,conStr = GAC()
local dir,op,se = string.match(conStr,".+:s=([%+%-])([GMNQ])([SE]*)")
local d = dir == "+" and 1 or -1

local hWnd = MGA()
if hWnd then
	take =MGT(hWnd)
	if take then
		
		if op =="N" then
			ECtoNote(se == "S",d < 0)
		else
			local t
			if op =="Q" then
				t = 1
			elseif op =="M" then
				local bpm,bpi = GTS(0,GCP())
				t = 4 * bpm/bpi
			elseif op =="G" then
				t = MGG(take)
			else
				r.MB("Unknown op ... '"..op.."'","Oopsy in ECmove.lua",0)
				return
			end
			if se == "S" then
				SnapEC(t,d==1)
			else
				SECP(qn2t(t2qn(GCP()) + (d * t)),true,false)
			end
		end

	else
		r.MB("Couldn't get MIDI Editor Take","Script Error",0)
	end
else
	r.MB("MIDI Editort unavailable...hWnd is bad or no MIDI editor","Script Error",0)
end



