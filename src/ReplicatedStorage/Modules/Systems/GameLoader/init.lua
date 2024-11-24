

local RepStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")

local Events = RepStorage:WaitForChild("Events")

local Indexes = require(RepStorage:WaitForChild("Indexes"))
local Config = require(script:WaitForChild("Config"))
local GameLoader = {}
local Include = {
	"BasePart",
	"Decal",
	"ParticleEmitter",
	"SurfaceAppearence",
	"Animation",
	"AnimationTrack",
	"Light",
	"ColorCorrectionEffect",
	"Material",
	"SpecialMesh",
	"Texture",
	"Trail",
	"Skybox",
	"Bloom",
	"Blur",
	"GUIBase",
	"Beam"
}

function GameLoader:Load()
	if GameLoader.Loading or GameLoader.Loaded then return end
	GameLoader.Loading = true
	if game:GetService("RunService"):IsServer() then
		repeat task.wait()
		--print(_G)	
		until _G.GetGameInfo 
	end
	local function LoadTab(Tab,Skippable:boolean?)
		if (Skippable and GameLoader.Skipped) then
			return
		end
		local Amounts = {}
		local Utilized = {}
		for i,v in Tab do
			if game:GetService("RunService"):IsClient() then
			Amounts[v] = Events:WaitForChild("GetGameInfo"):InvokeServer(v)
			else
				Amounts[v] = _G.GetGameInfo(nil,v)
			end
		end
		for i,v in Amounts do
			if (Skippable and GameLoader.Skipped) then
				break
			end	
			task.spawn(function()
				repeat task.wait()
					if (Skippable and GameLoader.Skipped) then
						break
					end	
				until #(i:GetDescendants()) >= v
				Utilized[i] = true
			end)
		end

		local function AllLoaded()
			local Valid = true
			for i,v in Amounts do
				if not Utilized[i] then
					return false
				end
			end
			return true
		end

		repeat task.wait() until AllLoaded() or (Skippable and GameLoader.Skipped)
		if not (Skippable and GameLoader.Skipped) then
			local Loaders = {}
			local Total = 0
			local LoadAtTime = 0
			local AmountCurrent = 0
			local Confirmation = false
			local Amount = 0
			local LoadTab = {}

			local function AddTab(Child:Instance)
				local Valid = false
				for a,k in Include do
					if Child:IsA(k) then
						Valid = true
						break
					end
				end
				--print(x,Valid)
				if not Valid then return end
				Total += 1

				task.spawn(function()
					if (Skippable and GameLoader.Skipped) then
						return
					end
					if LoadAtTime >= 500 then
						repeat task.wait()

						until LoadAtTime <= 100 or (Skippable and GameLoader.Skipped)
						--print("Passed")

					end
					LoadAtTime += 1
					--print(Child:GetFullName())
					local success,fail = pcall(function()
						if game:GetService("RunService"):IsClient() then
						ContentProvider:PreloadAsync({Child},function(...)


							--table.remove(LoadTab,table.find(LoadTab,Child))

						end)
						end
						LoadAtTime -= 1
						AmountCurrent += 1
						if AmountCurrent%500 == 0 then
							--print(AmountCurrent," Loaded")
						end
					end)
					--print(success,fail)
					if not success then
						--	print(fail)
						Total -= 1
						LoadAtTime -= 1
					end

				end)
			end
			for i,v in Tab do
				for e,x in v:GetDescendants() do


					if (Skippable and GameLoader.Skipped) then break end

					AddTab(x)
				--[[	if Total % 200 == 0 then
						task.wait()
					end--]]







				end
				v.DescendantAdded:Connect(AddTab)
			end 

			repeat task.wait()
			until Total == 0 or (Skippable and GameLoader.Skipped) or AmountCurrent >= Total * .99
			--_G.print("Load")
		end	
	end
	LoadTab(Config.Important)
	LoadTab(Config.Skippable,true)
	--print("Fully loaded!")
	local Success,Amount = Indexes:Load()
	if not Success then
		print("Amount of modules failed: ",Amount)
	else
		print("Load Success!")
	end
	if game:GetService("RunService"):IsClient() then
		require(script:WaitForChild("Client"))(GameLoader)
	elseif game:GetService("RunService"):IsServer() then
		require(script:WaitForChild("Server"))(GameLoader)
	end
	GameLoader.Loaded = true
	_G.Loaded = true
end

return GameLoader
