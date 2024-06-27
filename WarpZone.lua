--[[
Requires:
********
Modem
--]]

local textFunctions = require("utilities/textFunctions")
local warpSides = {EnchantedAlchemy = "front", garbloni = "left", LogHammm = "back", ToomtHunger = "right"}

settings.load(".settings")
if settings.get("warpName") == nil or settings.get("warpName") == "" or settings.get("warpName") == " " then

	settings.define("warpName", {
		description = "The name of the warp zone.",
		default = "",
		type = "string"
	})

	local newName = string.lower(textFunctions.prompt("Enter a warp zone name:"))
	settings.set("warpName", newName)

	settings.save(".settings")

end

print(settings.get("warpName"))
peripheral.find("modem", rednet.open)
rednet.host("warp_zone", settings.get("warpName"))

local function activateWarp(side)

	redstone.setOutput(warpSide, true)
	os.sleep()
	redstone.setOutput(warpSide, false)

end

while true do

	local id, argument = rednet.receive("warp_central")
	if argument == "reboot" then
		os.reboot()
	elseif warpSides[argument] ~= nil then

		local playerSide = warpSides[argument]
		if pcall(function() 
		
			redstone.setOutput(playerSide, true)
			os.sleep()
			redstone.setOutput(playerSide, false)
		
		end) then
			--Worked
		else
			--Didn't
		end

	end

end
