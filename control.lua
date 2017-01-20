global.itemRotated = {}
global.entityRemoved = {}
entityCache = {}
global.spectating = {}

ranks = {
	owner={id=1,name='owner',tag='[Owner]',	rights={}},
	dev={id=2,name='dev',tag='[Dev]',		rights={}},
	admin={id=3,name='admin',tag='[Admin]',	rights={}},
	mod={id=4,name='mod',tag='[Mod]',		rights={}},
	reg={id=5,name='reg',tag='[Reg]',		rights={}},
	guest={id=6,name='guest',tag='',		rights={'Anti Grefer'}},
	jail={id=7,name='jail',tag='[Jailed]',	rights={'Anti Grefer'}},
}

lotOfBelt = 5
lotOfRemoving = 5
warningAllowed = 2
timeForRegular = 180
timeForMod = 600
defaultRank = ranks['guest']
--------------------------------------------------------------------------------
function ticktohour (tick)
    local hour = tostring(math.floor(tick * (1 /(60*game.speed)) / 3600))
    return hour
end

function ticktominutes (tick)
  	local minutes = math.floor((tick * (1 /(60*game.speed))) / 60)
    return minutes
end

function clearElement (elementToClear)
  if elementToClear ~= nil then
    for i, element in pairs(elementToClear.children_names) do
      elementToClear[element].destroy()
    end
  end
end
--------------------------------------------------------------------------------
function getRank(player)
	if player then
		for _,rank in pairs(ranks) do
			if player.tag == rank.tag then return rank end
		end
	end
end

function setOwner(player)
	if player then
		for _,a in pairs(game.players) do
			if getRank(a).name == 'owner' then 
				a.tag = defaultRank.tag
				break
			end
		end
		player.tag = ranks.owner.tag	
	else
		for i,player in pairs(game.players) do
			if player.connected then 
				player.tag = ranks.owner.tag 
				break
			end
		end
	end
end

function hasRight(rank, testRight) -- rank can be a player
	if rank and right then
		if ranks[rank] == nil then rank = getRank(rank) end
		rights = rank.rights
		for _,right in pairs(rights) do
			if right == testRight then return true else return false end
		end
	end
end

function autoRank()
	for _,player in pairs(game.players) do
		rankId = getRank(player).id
		if rankID > 4 and ticktominutes(player.online_time) > timeForMod then player.tag = ranks.mod.tag
		elseif rankID > 5 and ticktominutes(player.online_time) > timeForRegular then player.tag = ranks.reg.tag
		end
	end
end

function callRank(msg, rank)
	if ranks[rank] ~= nil then rank = rank.id end
	rank = rank or 4 -- default mod or higher
	for _, player in pairs(game.players) do 
		rankId = getRank(player).id
		if rankID >= rank then player.print(msg) end
	end
end
----------------------------------------------------------------------------------------
---------------------------Player Events------------------------------------------------
----------------------------------------------------------------------------------------	
script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  player.insert{name="iron-plate", count=8}
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
  player.insert{name="burner-mining-drill", count = 1}
  player.insert{name="stone-furnace", count = 1}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
  player.tag = defaultRank.tag
  if (#game.players <= 1) then
    game.show_message_dialog{text = {"msg-intro"}}
  else
    player.print({"msg-intro"})
  end
end)

script.on_event(defines.events.on_player_respawned, function(event)
  local player = game.players[event.player_index]
  player.insert{name="pistol", count=1}
  player.insert{name="firearm-magazine", count=10}
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.players[event.player_index]
  player.print({"", "Welcome"})
  player.print({"", "Please join our discond and forum links are in server infor under read me"})
  if player.gui.left.PlayerList ~= nil then
    player.gui.left.PlayerList.destroy()
  end
  if player.gui.center.README ~= nil then
    player.gui.center.README.destroy()
  end
  drawToolbar(player)
  drawPlayerList()
  local playerStringTable = encode(game.players, "players", {"name", "admin", "online_time", "connected", "index"})
  game.write_file("players.json", playerStringTable, false)
  if not player.admin and ticktominutes(player.online_time) < 1 then
    ReadmeGui(player, "Rules")
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  local player = game.players[event.player_index]
  drawPlayerList()
end)
----------------------------------------------------------------------------------------
---------------------------Gui Events---------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_gui_click, function(event)
  local player = game.players[event.player_index]
  if event.element.name == "btn_readme" then
    ReadmeGui(player, "Rules", true)
  elseif event.element.name == "btn_readme_rules" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Rules")
  elseif event.element.name == "btn_readme_server_info" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Server info")
  elseif event.element.name == "btn_readme_chat" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Chat")
  elseif event.element.name == "btn_readme_admins" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Admins")
  elseif event.element.name == "btn_readme_players" then
    player.gui.center.README.destroy()
    ReadmeGui(player, "Players")
  elseif event.element.name == "btn_readme_close" then
    player.gui.center.README.destroy()
  elseif event.element.name == "btn_toolbar_playerList" then
    playerListGuiSwitch(player)
  elseif event.element.name == "btn_toolbar_getPlayerInventory" then
    drawGetPlayerInventory(player, nil)
  elseif event.element.name == "btn_getPlayerInventory_close" then
    player.gui.center.getPlayerInventory.destroy()
  elseif event.element.name == "btn_Spectate" then
    spectate(player)
  elseif event.element.name == "btn_Modifier" then
    modifierGui(player, false)
  elseif event.element.name == "btn_Modifier_apply" then
    modifierGui(player, true)
  elseif event.element.name == "btn_Modifier_close" then
    player.gui.center.modifier.destroy()
  elseif event.element.name == "btn_toolbar_rocket_score" then
    satelliteGuiSwitch(player)
  end
end)
----------------------------------------------------------------------------------------
---------------------------Grefer Events------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
    if event.entity.type ~= "tree" and event.entity.type ~= "simple-entity" then
      event.entity.cancel_deconstruction("player")
      player.print("You are not allowed to do this yet, play for a bit longer. Try again in about: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
      callRank(player.name .. " tryed to deconstruced something")
    end
	end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
		if event.entity.name == "express-transport-belt" or event.entity.name == "fast-transport-belt" or event.entity.name == "transport-belt" then
			itemRotated[event.player_index] = itemRotated[event.player_index] or 0
			itemRotated[event.player_index] = itemRotated[event.player_index] +1
			if itemRotated[event.player_index] >= lotOfBelt then
				itemRotated[event.player_index]=0
				callRank(player.name .. " has rotated a lot of belts")
			end
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	if hasRight(player, 'Anti Grefer') then
		if event.created_entity.type == "tile-ghost" then
			event.created_entity.destroy()
			player.print("You are not allowed to do this yet, play for a bit longer. Try: " .. math.floor((timeForRegular - ticktominutes(player.online_time))) .. " minutes")
			callRank(player.name .. " tryed to place concrete/stone with robots")
		end
	end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
	local player = game.players[event.player_index]
	if not player.admin and ticktominutes(player.online_time) < 10 then
		name = event.item_stack.name
		if name ~= 'raw-wood' and name ~= 'coal' and name ~= 'copper-ore' and name ~= 'iron-ore' and name ~= 'stone' then
			entityRemoved[event.player_index] = entityRemoved[event.player_index] or 0
			entityRemoved[event.player_index] = entityRemoved[event.player_index] +1
			if entityRemoved[event.player_index] >= lotOfRemoving then
				entityRemoved[event.player_index]=0
				callRank(player.name .. " has removed alot of stuff and got from it a " .. name)
			end
		end
	end
end)
----------------------------------------------------------------------------------------
---------------------------Other Events-------------------------------------------------
----------------------------------------------------------------------------------------
script.on_event(defines.events.on_rocket_launched, function(event)
  local force = event.rocket.force
  if event.rocket.get_item_count("satellite") == 0 then
    if (#game.players <= 1) then
      game.show_message_dialog{text = {"gui-rocket-silo.rocket-launched-without-satellite"}}
    else
      for index, player in pairs(force.players) do
        player.print({"gui-rocket-silo.rocket-launched-without-satellite"})
      end
    end
    return
  end
  if not global.satellite_sent then
    global.satellite_sent = {}
  end
  if global.satellite_sent[force.name] then
    global.satellite_sent[force.name] = global.satellite_sent[force.name] + 1   
  else
    game.set_game_state{game_finished=true, player_won=true, can_continue=true}
    global.satellite_sent[force.name] = 1
  end
  for index, player in pairs(force.players) do
    if player.gui.left.rocket_score then
      player.gui.left.rocket_score.rocket_count.caption = tostring(global.satellite_sent[force.name])
    else
      local frame = player.gui.left.add{name = "rocket_score", type = "frame", direction = "horizontal", caption={"score"}}
      frame.add{name="rocket_count_label", type = "label", caption={"", {"rockets-sent"}, ":"}}
      frame.add{name="rocket_count", type = "label", caption=tostring(global.satellite_sent[force.name])}
    end
  end 
end)
----------------------------------------------------------------------------------------
---------------------------IDK What There Do Functions----------------------------------
----------------------------------------------------------------------------------------
function encode ( table, name, items )
  local encodeString
  local encodeSubString
  local encodeSubSubString
  for i, keyTable in pairs(table) do
    encodeSubSubString = nil
    for i, keyItem in pairs(items) do
      if type(keyTable[keyItem]) == "string" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        else
          encodeSubSubString = "\"" .. keyItem .. "\": \"" .. keyTable[keyItem] .. "\""
        end
      elseif type(keyTable[keyItem]) == "number" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      elseif type(keyTable[keyItem]) == "boolean" then
        if encodeSubSubString ~= nil then
          encodeSubSubString = encodeSubSubString .. ",\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        else
          encodeSubSubString = "\"" .. keyItem .. "\": " .. tostring(keyTable[keyItem])
        end
      end
    end
    if encodeSubSubString ~= nil and encodeSubString ~= nil then
      encodeSubString = encodeSubString .. ", {" .. encodeSubSubString .. "}"
    else
      encodeSubString = "{" .. encodeSubSubString .. "}"
    end
  end
  encodeString = "{" .. "\"" .. name .. "\": [" .. encodeSubString .. "]}"
  return encodeString
end
----------------------------------------------------------------------------------------
---------------------------Tool Bar-----------------------------------------------------
----------------------------------------------------------------------------------------
function drawToolbar(player)
    local frame = player.gui.top
    clearElement(frame)
    if hasRight(player, 'toolbar_rocket_score') then frame.add{name="btn_toolbar_rocket_score", type = "button", caption="Rocket score", tooltip="Show the satellite launched counter if a satellite has launched."} end
    if hasRight(player, 'toolbar_playerList') then frame.add{name="btn_toolbar_playerList", type = "button", caption="Playerlist", tooltip="Adds a player list to your game."} end
    if hasRight(player, 'readme') then frame.add{name="btn_readme", type = "button", caption="Readme", tooltip="Rules, Server info, How to chat, Playerlist, Adminlist."} end
    if hasRight(player, 'Spectate') then frame.add{name="btn_Spectate", type = "button", caption="Spectate", tooltip="Spectate how the game is doing."} end
    if hasRight(player, 'Modifier') then frame.add{name="btn_Modifier", type = "button", caption="Modifiers", tooltip="Modify game speeds."} end
end

function satelliteGuiSwitch(play)
  if play.gui.left.rocket_score ~= nil then
    if play.gui.left.rocket_score.style.visible == false then
      play.gui.left.rocket_score.style.visible = true
    else
      play.gui.left.rocket_score.style.visible = false
    end
  end
end

function playerListGuiSwitch(play)
  if play.gui.left.PlayerList ~= nil then
    if play.gui.left.PlayerList.style.visible == false then
      play.gui.left.PlayerList.style.visible = true
    else
      play.gui.left.PlayerList.style.visible = false
    end
  end
end

function spectate (player)
  if player.character ~= nil then
    spectating[player.index] = player.character
   player.character = nil
    player.print("You are spectating")
  else
    player.character = spectating[player.index]
    spectating[player.index] = nil
    player.print("You are not spectating")
  end
end
----------------------------------------------------------------------------------------
---------------------------Player List--------------------------------------------------
----------------------------------------------------------------------------------------
function drawPlayerList()
  for i, a in pairs(game.players) do
    if a.gui.left.PlayerList == nil then
      a.gui.left.add{name= "PlayerList", type = "frame", direction = "vertical"}
    end
	local pList = a.gui.left.PlayerList
    clearElement(pList)
    for i, player in pairs(game.connected_players) do
	  playerRank = getRank(player).name
      if playerRank == 'owner' then
		pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - OWNER"}}
		pList[player.name].style.font_color = {r=170,g=0,b=0}
	  elseif playerRank == 'dev' then
		pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - DEV"}}
		pList[player.name].style.font_color = {r=65,g=233,b=233}
      elseif playerRank == 'admin' then
		pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - ADMIN"}}
		pList[player.name].style.font_color = {r=233,g=63,b=233}
	  elseif playerRank == 'mod' then
		pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - MOD"}}
		pList[player.name].style.font_color = {r=233,g=0,b=233}
      elseif playerRank == 'reg' then
        pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
        pList[player.name].style.font_color = {r=24,g=172,b=188}
	  elseif playerRank == 'guest' then
        pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name}}
        pList[player.name].style.font_color = {r=255,g=159,b=27}
	  elseif playerRank == 'jail' then
		pList.add{type = "label",  name=player.name, style="caption_label_style", caption={"", ticktohour(player.online_time), " H - " , player.name , " - Jailed"}}
		pList[player.name].style.font_color = {r=175,g=175,b=175}
      end
    end
  end
end

function drawPlayerTable(play, guiroot, tablename, isAdminonly)
  guiroot.add{name=tablename, type="table", colspan=5}
  guiroot[tablename].style.minimal_width = 500
  guiroot[tablename].style.maximal_width = 500
  guiroot[tablename].add{name="id", type="label", caption="id"}
  guiroot[tablename].add{name="name", type="label", caption="name"}
  guiroot[tablename].add{name="status", type="label", caption="status"}
  guiroot[tablename].add{name="hours", type="label", caption="Hours"}
  guiroot[tablename].add{name="admin", type="label", caption="Admin"}
  for i, player in pairs(game.players) do
    if isAdminonly == true and player.admin == false then
      
    else
      if guiroot[tablename][player.name] == nil then
        guiroot[tablename].add{name=i .. "id", type="label", caption=i}
        guiroot[tablename].add{name=player.name, type="label", caption=player.name}
        if playerconnected == true then
          guiroot[tablename].add{name=player.name .. "Status", type="label", caption="ONLINE"}
        else
          guiroot[tablename].add{name=player.name .. "Status", type="label", caption="OFFLINE"}
        end
        guiroot[tablename].add{name=player.name .. "Hours", type="label", caption=ticktohour(player.online_time)}
        guiroot[tablename].add{name=player.name .. "Admin", type="label", caption=tostring(player.admin)}
      end
    end
  end
end
----------------------------------------------------------------------------------------
---------------------------Modifier Gui-------------------------------------------------
----------------------------------------------------------------------------------------
function modifierGui(play, button)
  local forceModifiers = {
    "manual_mining_speed_modifier",
    "manual_crafting_speed_modifier",
    "character_running_speed_modifier",
    "worker_robots_speed_modifier",
    "worker_robots_storage_bonus",
    "character_build_distance_bonus",
    "character_item_drop_distance_bonus",
    "character_reach_distance_bonus",
    "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus",
    "character_loot_pickup_distance_bonus"
  }
  local function apply()
    play.print("apply")
    for i, modifier in pairs(forceModifiers) do 
      local number = tonumber(( play.gui.center.modifier.flowContent.modifierTable[modifier .. "_input"].text):match("[%d]+[.%d+]"))
      if number ~= nil then
        if number >= 0 and number < 50 and number ~= play.force[modifier] then
          play.force[modifier] = number
          play.print(modifier .. " changed to number: " .. tostring(number))
        elseif number == play.force[modifier] then
          play.print(modifier .. " Did not change")
        else
          play.print(modifier .. " needs to be a higher number or it contains an letter")
        end
      end
    end
  end
  local function drawFrame ()
    if play.admin == true or play.name == "test" then
      local frame = play.gui.center.add{name= "modifier", type = "frame", caption="Modifiers panel", direction = "vertical"}
            frame.add{type = "scroll-pane", name= "flowContent", direction = "vertical", vertical_scroll_policy="always", horizontal_scroll_policy="never"}
            frame.add{type = "flow", name= "flowNavigation",direction = "horizontal"}
            frame.flowContent.add{name="modifierInfi", type="label", caption="Only use if you know what you are doing"}
            frame.flowContent.add{name="modifierTable", type="table", colspan=3}
            frame.flowContent.modifierTable.add{name="name", type="label", caption="name"}
            frame.flowContent.modifierTable.add{name="input", type="label", caption="input"}
            frame.flowContent.modifierTable.add{name="current", type="label", caption="current"}
      for i, modifier in pairs(forceModifiers) do
            frame.flowContent.modifierTable.add{name=modifier, type="label", caption=modifier}
            frame.flowContent.modifierTable.add{name=modifier .. "_input", type="textfield", caption="inputTextField"}
            frame.flowContent.modifierTable.add{name=modifier .. "_current", type="label", caption=tostring(play.force[modifier])}
      end
            frame.flowNavigation.add{name="btn_Modifier_apply", type = "button", caption="Apply", tooltip="Apply ."}
            frame.flowNavigation.add{name="btn_Modifier_close", type = "button", caption="Close", tooltip="Close the modifier panel."}
    end
  end
  if button == true then
    apply()
  else
    if play.gui.center.modifier ~= nil then
      play.gui.center.modifier.destroy()
    else
      drawFrame()
    end
  end
end