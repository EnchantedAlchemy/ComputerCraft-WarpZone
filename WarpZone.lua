local textFunctions = require("utilities/textFunctions")

settings.load(".settings")
if settings.get("warpName") == nil or settings.get("warpName") == "" or settings.get("warpName") == " " then

	settings.define("warpName", {
		description = "The name of the warp zone.",
		default = "",
		type = "string"
	})

	local newName = textFunctions.prompt("Enter a warp zone name:")
	settings.set("warpName", newName)

	settings.save(".settings")

end

print(settings.get("warpName"))
peripheral.find("modem", rednet.open)
rednet.host("warp_zone", settings.get("warpName"))

while true do

	local id, warpSide = rednet.receive("warp_central")
	redstone.setOutput(warpSide, true)
	os.sleep()
	redstone.setOutput(warpSide, false)

end
