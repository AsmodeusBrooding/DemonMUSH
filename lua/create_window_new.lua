  require "mw"
  require "movewindow" 
 
  -- our window frame/background colours
  border_colour = ColourNameToRGB("White")
  background_colour = ColourNameToRGB("Black")
  
  -- a unique ID
  win_guid = GetVariable("win_guid") 
  table_info = {}
  
  --bring Window Settings
  win_width = GetVariable("win_width")
  win_height = GetVariable("win_height")
  clicked_items = 1  
  
  -- font IDs
  font_id = "popup_font"  
  heading_font_id = "popup_heading_font"  
  heading_font_btn_id = "popup_heading_btn"  

  font_size = 8

  -- use 8 pt Dina or 10 pt Courier
  local fonts = utils.getfontfamilies ()

  -- choose a font that exists
  
  if fonts.Dina then
    font_name = "Dina"    
  elseif fonts ["Lucida Sans Unicode"] then
    font_name = "Lucida Sans Unicode"
  else
    font_size = 10
    font_name = "Courier"
  end -- if
    
  -- load fonts - mouseover window
  WindowCreate (win_guid, 0, 0, 1, 1, 0, 0, ColourNameToRGB "Black")   -- make 1-pixel wide window
  
  -- install the fonts  (49 is modern / fixed pitch)
  WindowFont (win_guid, font_id, font_name, font_size, false, false, false, false, 0, 49) 
  WindowFont (win_guid, heading_font_id, font_name, font_size + 2, false, false, false, false, 0, 49)         
  WindowFont (win_guid, heading_font_btn_id, font_name, font_size - 4, false, false, false, false, 0, 49)           
  
  --bring on front
  local z_order_plugin = "462b665ecb569efbf261422f"
  if (IsPluginInstalled(z_order_plugin) and GetPluginInfo(z_order_plugin, 17)) then
			CallPlugin(z_order_plugin, "boostMe", win_guid)
  end 			   
  
  -- NOW DISPLAY A WINDOW  
  -- what to say - one line per table entry, with imbedded colour codes
function display_window(show_table, heading)  	
	  table_info = show_table
	  left, top = pos_x or 200,pos_y or 300	  
	  align_right = false
	  align_bottom = false
	  capitalize = true	  	  
	  -- show it  
	  mw.popup (win_guid,           -- window name to use
				heading_font_id,   -- font to use for the heading
				font_id,           -- font to use for each line
				heading,           -- heading text
				table_info,              -- table of lines to show (with colour codes)
				left, top,         -- where to put it
				border_colour,     -- colour for round rectangle line
				background_colour, -- colour for background
				capitalize,        -- if true, force the first letter to upper case
				align_right,       -- if true, align right side on "Left" parameter
				align_bottom)      -- if true, align bottom side on "Top" parameter		
	win_width = WindowInfo (win_guid, 3)
	win_height = WindowInfo (win_guid, 4)			
	--create a nice header
	header_width = WindowTextWidth(win_guid, heading_font_id, heading)
	TITLE_HEIGHT = 22
	WINDOW_BORDER_COLOUR = 0xE8E8E8
	WINDOW_BACKGROUND_COLOUR=ColourNameToRGB("Green")
	TITLE_COLOR = ColourNameToRGB("White")	
	WindowGradient(win_guid, 3, 2, win_width-4, 22, WINDOW_BACKGROUND_COLOUR, 0x444444, 2)
	WindowText(win_guid, heading_font_id, heading, (win_width-header_width)/2, ((TITLE_HEIGHT-18)/2)-1, win_width, TITLE_HEIGHT, TITLE_COLOR, false)     
	WindowLine(win_guid, 0, 22-1, win_width, 22-1, WINDOW_BORDER_COLOUR, 0 + 0x0200, 1)		
	
	--minimize btn
    WindowRectOp (win_guid, 4, win_width-25, 3, win_width-6, 19, ColourNameToRGB("white"), ColourNameToRGB("white"))			
	WindowText(win_guid, heading_font_id, "X", win_width-20, 3, win_width-4, 19, TITLE_COLOR, false)     	
	WindowAddHotspot(win_guid, 
						"changetab_10",  -- HS id
						win_width-25, 3, win_width-6, 19, -- rectangle
						"mouseover", 
						"cancelmouseover", 
						"mousedown",
						"cancelmousedown", 
						"mouseup", 
						"Minimize Window",  -- tooltip text
						0, 0)
	
	if clicked_items == 1 then
		create_clicked_items(show_table)
	end
	
	
	WindowAddHotspot(win_guid, 
						"hsDrag1",  -- HS id
						0, 0, 0, win_height, -- rectangle
						"mouseover", 
						"cancelmouseover", 
						"mousedown",
						"cancelmousedown", 
						"mouseup", 
						"Drag to move",  -- tooltip text
						1, 0)  -- 4-way arrows				
	WindowDragHandler(win_guid, "hsDrag1", "dragmove", "dragrelease", 0) 
	
end
  
function create_clicked_items(table_info)  		
	line_spacing = 13
	offset = 23
	--24-36-48
	--WindowRectOp (win_guid, 2, 0, 0, win_width, win_height, ColourNameToRGB("White"),ColourNameToRGB("Black"))
	for i,j in ipairs(table_info) do			
		text_width = WindowTextWidth(win_guid, font_id, j)
		local hsLength = (5 + text_width) - win_width
		local hsHeight = ((tonumber(i-1) * line_spacing) + 11 + offset) - win_height
			--WindowText(win_guid, font_id, j, 5, (tonumber(i-1) * line_spacing) + offset, hsLength, hsHeight, ColourNameToRGB("Red"), false)     	
			WindowAddHotspot(win_guid, 
							"click_"..tostring(i),  -- HS id
							5,(tonumber(i-1) * line_spacing) + offset, hsLength, hsHeight,
							"mouseover", 
							"cancelmouseover", 
							"mousedown",
							"cancelmousedown", 
							"mouseup", 
							"Click on "..j,  -- tooltip text
							0, 0)
	end
end
  
function mouseup (flags, hotspot_id)
	if flags == 16 then
		if hotspot_id == "changetab_10" then
			WindowShow( win_guid, false )   	
		elseif string.find(hotspot_id,"click_") then					
			i, j = string.find(hotspot_id,"click_")
				mob_nr = tonumber(string.sub(hotspot_id, j+1))			
			Execute("k "..guess_mob_name(table_info[mob_nr]))
			table.remove(table_info,mob_nr)
			display_window(table_info, heading) 

		end
	elseif flags == 32 then
		Execute("secondary")
	end
end -- mouseover
  
function draw_button(left, top, width, height, text, hsName, hint, textOffset)		
	WindowRectOp (win_guid, miniwin.rect_draw_edge, 
		left, top, (left + width) - win_width, (top + height) - win_height, 
		miniwin.rect_edge_raised, 
		5)  -- raised, filled
end

function dragmove(flags, hotspot_id)
  pos_x, pos_y = WindowInfo (win_guid, 17) - (win_width / 2),
               WindowInfo (win_guid, 18) - (win_height / 2)

  --print ("moved to position", pos_x, pos_y)
                                                      
  -- move the window to the new location
  WindowPosition(win_guid, pos_x, pos_y, 
                 miniwin.pos_stretch_to_view, 
                 miniwin.create_absolute_location)
    
end -- dragmove

function dragrelease(flags, hotspot_id)
end -- dragrelease

function guess_mob_name(mobName)
	
	if (mobName == nil) then
		return nil
	end
		
	local mob = mobName	

	local parts = split(mobName, "[^ ]+")

		--detect if we have a name like "WinkleWinkle, the coder"
		local comma = (string.find(parts[1], ",") or -1)			
		
		if ((#parts > 1) and (comma == #(parts[1]))) then
			mob = string.gsub(parts[1], ",$", "")
		else		

			local clean2 = {}
			local cleanIndex = 1
		
			--clean parts
			for key, value in ipairs(parts) do

				local clean = string.gsub(value, "^[aA]$", "")
				clean = string.gsub(clean, "^[aA]n$", "")
				clean = string.gsub(clean, "^[tT]he$", "")
				clean = string.gsub(clean, "^[oO]f$", "")
				clean = string.gsub(clean, "^[Ss]ome$", "")
									
				clean = split(clean, "[a-zA-Z]+")
	--			tprint(clean)

				if (clean[1] ~= nil and clean[1] ~= "") then
					clean2[cleanIndex] = clean[1]
					cleanIndex = cleanIndex + 1
				end
			end
	--		tprint(clean2)

			if (#clean2 == 0) then
				-- we over-guessed!  User entered "qw whelp" or something
				mob = mobName
			elseif (#clean2 == 1) then
				mob = clean2[1]
			else
				-- improve variances in mob names by only using first four letters of mob name, where we are usign two words
				mob = string.sub(clean2[1], 1, 4) .. " " .. string.sub(clean2[#clean2], 1, 4)
			end
		end
	
	return mob
end

function split(line, delim)

		local result = {}
		local index = 1
		
		for token in string.gmatch(line, delim) do
			result[index] = token
			index = index + 1
		end

		return result
	end
