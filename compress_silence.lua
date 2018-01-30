--[[
 * ReaScript Name: Compress Silence
 * Description: Shrinks silence between items in proportion to the silence's length. Functions similarly to Audacity's Truncate Silence feature. Currently reduces silences by 60%.
 * Instructions: Select two items minimum on the same or different tracks. Currently, it will not shrink properly if there is overlap between items.
 * Author: quantumdotdot
 * Repository URI: TBD
 * File URI: TBD
 * Licence: TBD
 * REAPER: 5.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-01-30)
  + Initial Release
--]]


function msg(m) reaper.ShowConsoleMsg("\n" .. tostring(m.."\n")) end
----------------------------
---------
---------

function Compress_Silence(Sel_Items,item_cnt)
	
  -- for each set of items in the item array, unselect previous items, and select only 1 set
  for i=1, item_cnt-1 do
      	reaper.Main_OnCommand(40289,0)
      	
      	local Item = Sel_Items[i+1]
      	local PrevItem = Sel_Items[i]

      	reaper.SetMediaItemSelected(Item, true)
    	
    -- for each media item, set a variable for first item end and second item start
    local PrevItemEnd = reaper.GetMediaItemInfo_Value(PrevItem, "D_POSITION") + reaper.GetMediaItemInfo_Value(PrevItem, "D_LENGTH")
		local ThisItemStart = reaper.GetMediaItemInfo_Value(Item, "D_POSITION")
		
    -- only decrease space if second item start > than first item end
		if ThisItemStart > PrevItemEnd then
			-- take the difference between previous item and current item and reduce it by 60%
			local NewPos = ((((ThisItemStart - PrevItemEnd)*.75)*.2) + (ThisItemStart - PrevItemEnd)*.25) + PrevItemEnd
			
      -- only change second item position if the calculated position is greater than the original one
      if NewPos > PrevItemEnd then
				reaper.GetSet_LoopTimeRange(true, false, NewPos, ThisItemStart, false)
				reaper.Main_OnCommand(40201,0)
			end
		end
    end
end

-------------------------------------------
---  Start  -------------------------------
-------------------------------------------
-- get number of selected items & initialize variable
local item_cnt = reaper.CountSelectedMediaItems(0)
local Sel_Media = {}

-- send selected items to array indexed by their time positions ---------------------
for i=1, item_cnt do
	local index = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, i-1), "D_POSITION")
	Sel_Media[index] = reaper.GetSelectedMediaItem(0, i-1)
end
Sel_Sorted = {}
inc = 1
-- make array sorted by the time positions of the media items
for pos,media in pairs(Sel_Media) do
    Sel_Sorted[inc] = pos
    inc = inc + 1
end
table.sort(Sel_Sorted)

-- Sel_Items = [pos, media]
-- Sel_Sorted = [index, position]
-- make a new array with the media items in order
local Sel_Items = {}

local inc = 1
while inc < item_cnt do
   	for k,v in pairs(Sel_Sorted) do
    	-- k = index
    	-- v = pos
    		Sel_Items[inc] = Sel_Media[v]
    		inc = inc + 1
	end  
end

----- Main Loop
----------------------------
reaper.PreventUIRefresh(111)
--------------------
    reaper.Undo_BeginBlock()
    Compress_Silence(Sel_Items,item_cnt)
    reaper.Undo_EndBlock("Compress Silence", -1)  
    --------------------  
reaper.PreventUIRefresh(-111)
-----
-- TODO: 
---- reselect items after Compress_Silence is done compressing
---- add check for whether there's another item that overlaps currently selected items
---- add UI to input compression %