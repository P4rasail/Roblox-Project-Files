local waste = game:IsLoaded() or game.Loaded:Wait()

local  IDs = {
	"rbxassetid://18606410776",
	"rbxassetid://18606412274",
	"rbxassetid://18606413120",
	"rbxassetid://18606413699",
	"rbxassetid://18606414592",
	"rbxassetid://18606415182",
	"rbxassetid://18606422687",
	"rbxassetid://18606423217",
	"rbxassetid://18606423599",
	"rbxassetid://18606423993",
	"rbxassetid://18606424342",
	"rbxassetid://18606425001",
	"rbxassetid://18606434556",
	"rbxassetid://18606435193",
	"rbxassetid://18606435927",
	"rbxassetid://18606436410"
}
local lastTime = os.clock()
local timeWaited = 0
local startTime = os.clock()


while true do
	task.wait()
	script.Parent.Image = IDs[math.floor(((os.clock() - startTime) * 64)%(#IDs) + 1)]
	
end