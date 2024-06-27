--[[
Requires:
********
Chatbox
Player Detector
--]]

--[[
Optional:
********
Warp Zone related commands require attached modem
--]]


local textFunctions = require("utilities/textFunctions")
local det = peripheral.find("playerDetector")
local chatBox = peripheral.find("chatBox")
local chatBoxName = "General"
local penumbra = {EnchantedAlchemy = "front", garbloni = "left", LogHammm = "back", ToomtHunger = "right"}
local helldivers = {KAZOO32323 = "right", xGreex = "left", ComandrMario = "back", CaribbeanP = "front", Wolfchykofth501 = "left"}

chatFunctions = {

	privateMessage = function(text, player)
		local chatMessage = {
			{text = "(Private) ", color = "gray", italic = true},
		}
		chatMessage[2] = text
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, player, chatBoxName)
	end

}

functions = {

	warp = function(commands)

		local player = commands[1]
		local diver = false
		if helldivers[player] ~= nil then diver = true end

		if commands[2] == nil or commands[2] == "" then
			chatFunctions.privateMessage({text = "Enter a warp zone.", color = "red", bold = true}, player)
			return
		end

		if peripheral.find("modem") == nil then
			chatFunctions.privateMessage({text = "No modem on central computer.", color = "red", bold = true}, player)
			return
		else
			peripheral.find("modem", rednet.open)
		end

		local playerSide
		if diver == false then
			playerSide = penumbra[player]
		else
			player = helldivers[player]
		end

		local desiredWarp = string.lower(commands[2])

		local warpComputer
		if diver == false then
			warpComputer = rednet.lookup("warp_zone", desiredWarp)
		else
			warpComputer = rednet.lookup("warp_zone_helldivers", desiredWarp)
		end

		if warpComputer then
			rednet.send(warpComputer, player, "warp_central")
			chatFunctions.privateMessage({text = "Warp request sent.", color = "green", bold = true}, player)
		else
			chatFunctions.privateMessage({text = "Warp zone not found.", color = "red", bold = true}, player)
		end

		rednet.close()

	end,

	ping = function(commands)

		local desiredName = commands[2]
		local registerCaps = commands[3]

		if registerCaps == nil or string.lower(registerCaps) ~= "true" then registerCaps = "false" end

		--No player given
		if desiredName == nil or desiredName == "" then
			chatFunctions.privateMessage({text = "Enter an player username.", color = "red", bold = true}, commands[1])
			return
		end

		local name = ""
		local players = det.getOnlinePlayers()

		if registerCaps == "false" then
			desiredName = string.lower(desiredName)
		end

		for i,v in pairs(players) do
			local compareName = v
			if registerCaps == "false" then 
				compareName = string.lower(v) 
			end
			if string.find(compareName, desiredName) then
				if name == "" or string.len(v) < string.len(name) then
					name = v
				end
			end	
		end

		local table = det.getPlayerPos(name)
		local user = det.getPlayerPos(commands[1])

		if table.x == nil then
			chatFunctions.privateMessage({text = "Invalid username or player is in another dimension.", color = "red", bold = true}, commands[1])
			return
		end

		local distance = math.sqrt((table.x - user.x)^2 + (table.y - user.y)^2 + (table.z - user.z)^2)
		
		chatFunctions.privateMessage({text = "\n" .. name .. ": " .. table.x .. ", " .. table.y .. ", " .. table.z .. "\nDistance: " .. textFunctions.round(distance) .. " Blocks", color = "white", bold = true, italic = false}, commands[1])

	end,

	radar = function(commands)

		local players = det.getPlayersInRange(300)
		local displayedPlayers = ""

		for i,v in pairs(players) do
			if commands[2] == "true" or (v ~= "EnchantedAlchemy" and v ~= "garbloni" and v ~= "LogHammm" and v ~= "ToomtHunger") then
				displayedPlayers = displayedPlayers .. v .. "\n"
			end
		end

		if displayedPlayers ~= "" then
			chatFunctions.privateMessage({text = "Players within 300 blocks of detector:\n" .. displayedPlayers, color = "white", bold = false, italic = false}, commands[1])
		else
			chatFunctions.privateMessage({text = "No players within 300 blocks of detector.", color = "white", bold = false, italic = false}, commands[1])
		end
		

	end,

	nearby = function(commands)

		local testRange = 300
		local numNearby = 0

		local player = commands[1]
		local playerInfo = det.getPlayerPos(player)

		local chatMessage = {
			{text = "(Private) ", color = "gray", italic = true}
		}

		local nameColor = ""

		for i,v in pairs(det.getOnlinePlayers()) do
			if v ~= player then

				local otherInfo = det.getPlayerPos(v)
				if otherInfo.x ~= nil then  --insure players in other dimensions won't be counted

					local distance = math.sqrt((otherInfo.x - playerInfo.x)^2 + (otherInfo.y - playerInfo.y)^2 + (otherInfo.z - playerInfo.z)^2)

					if distance <= testRange then

						numNearby = numNearby + 1

						if numNearby % 2 == 0 then
							nameColor = "dark_aqua"
						else
							nameColor = "aqua"
						end

						chatMessage[#chatMessage + 1] = {text = v..": ", color = nameColor, bold = true, italic = false}
						chatMessage[#chatMessage + 1] = {text = otherInfo.x..", "..otherInfo.y..", "..otherInfo.z.." | Distance: "..textFunctions.round(distance).."\n", color = "white", bold = false, italic = false}

					end

				end

			end
		end

		if numNearby > 0 then
			table.insert(chatMessage, 2, {text = "Players within 300 blocks of you:\n", color = "white", italic = false})
		else
			table.insert(chatMessage, 2, {text = "No players within 300 blocks of you.", color = "white", italic = false})
		end

		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, player, chatBoxName)

	end,

	announce = function(commands)

		local text = commands
		table.remove(text, 1)
		local textString = ""
		for i,v in pairs(text) do
			textString = textString .. v .. " "
		end

		local chatMessage = {
			{text = textString, color = "dark_purple", bold = true, italic = false}
		}
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessage(chatMessage, "Penumbra Research Team", "[]", "")

	end,

	reboot = function(commands)

		if commands[2] == nil or commands[2] == "" then
			chatFunctions.privateMessage({text = "Enter a system type to reboot.", color = "red", bold = true}, commands[1])
			return
		end
		local desiredReboot = string.lower(commands[2])

		if desiredReboot == "general" then

			chatFunctions.privateMessage({text = "Rebooting "..chatBoxName..".", color = "green", bold = true, italic = false}, commands[1])
			os.reboot()

		elseif desiredReboot == "warp" then

			if commands[3] == nil or commands[3] == "" then
				chatFunctions.privateMessage({text = "Enter a warp zone to reboot.", color = "red", bold = true}, commands[1])
				return
			end
			local desiredZone = string.lower(commands[3])

			peripheral.find("modem", rednet.open)
			local zone = rednet.lookup("warp_zone", desiredZone)
			if zone == nil then
				chatFunctions.privateMessage({text = "Invalid warp zone.", color = "red", bold = true}, commands[1])
				return
			end
			rednet.send(zone, "reboot", "warp_central")
			chatFunctions.privateMessage({text = "Rebooting Warp Zone: "..desiredZone..".", color = "green", bold = true, italic = false}, commands[1])

		else

			chatFunctions.privateMessage({text = "Invalid system type.", color = "red", bold = true}, commands[1])

		end

		rednet.close()

	end,

	help = function(commands)

		local chatMessage = {}

		if commands[2] == nil or commands[2] == "" or commands[2] == " " then

			chatMessage = {
				{text = "Type \"$help\" followed by one of the following terms to see more info:\n", color = "white"},
				{text = "general\n", color = "yellow"}, {text = "See info on general commands.\n", color = "gray"},
				{text = "inv\n", color = "yellow"}, {text = "See info on inventory manager commands.\n", color = "gray"}
			}

		elseif commands[2] == "general" then

			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$warp | ", color = "white"}, {text = "location\n", color = "aqua"}, {text = "Activates the given warp zone.\n", color = "gray"},
				{text = "$ping | ", color = "white"}, {text = "username", color = "aqua"}, {text = " | ", color = "white"}, {text = "registers_capslock\n", color = "yellow"}, {text = "Display the given player's location. Not caps sensitive unless registers_capslock is true.\n", color = "gray"},
				{text = "$radar | ", color = "white"}, {text = "include_faction\n", color = "yellow"}, {text = "Displays players within 300 blocks of the computer. Does not include Penumbra unless include_faction is true.\n", color = "gray"},
				{text = "$nearby\n", color = "white"}, {text = "Lists all players within 300 blocks of you.\n", color = "gray"},
				{text = "$announce | ", color = "white"}, {text = "text\n", color = "aqua"}, {text = "Announces a message as the Penumbra Rearch Team.\n", color = "gray"},
				{text = "$reboot | ", color = "white"}, {text = "system_type", color = "aqua"}, {text = " | ", color = "white"}, {text = "other_params\n", color = "yellow"}, {text = "Reboots given system type. Some system types require other_params.\n", color = "gray"}
			}

		elseif commands[2] == "inv" then

			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$take | ", color = "white"}, {text = "mod:item_name", color = "aqua"}, {text = " | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Takes one (or given amount) of the given item if it is in storage.\n", color = "gray"},
				{text = "$store | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Puts held stack (or given amount) of items in storage.\n", color = "gray"},
				{text = "$del | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "DELETES held stack (or given amount) of items.\n", color = "gray"},
				{text = "$list\n", color = "white"}, {text = "Lists all items in storage\n", color = "gray"}
			}

		end

		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, commands[1], chatBoxName)

	end

}

while true do

	local event, user, message, uuid, isHidden = os.pullEvent("chat")
	if isHidden and penumbra[user] ~= nil then

		local commands = {}
		
		for s in string.gmatch(message, "[%w%p:_]+") do
			commands[#commands+1] = s
		end
		
		local mainCommand = commands[1]
		table.remove(commands,1)

		table.insert(commands, 1, user)
		
		if functions[mainCommand] ~= nil then
			functions[mainCommand](commands)
		end

	elseif isHidden and helldivers[user] ~= nil then
		
		local commands = {}
		
		for s in string.gmatch(message, "[%w%p:_]+") do
			commands[#commands+1] = s
		end
		
		local mainCommand = commands[1]
		table.remove(commands,1)

		table.insert(commands, 1, user)
		
		if functions[mainCommand] ~= nil and mainCommand == "warp" then
			functions[mainCommand](commands)
		end

	end

end
