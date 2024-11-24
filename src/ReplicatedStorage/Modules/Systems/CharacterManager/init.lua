

local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Configs = script:WaitForChild("Configs")

local DefaultConfig = Configs:WaitForChild("Default")
local Lists = require(script:WaitForChild("Lists"))


local CharacterManager = {

}

--[[
CharacterManager:Check(Char: Model | Player)
Checks if the given character or player has a ModuleScript with the "CharController" attribute.
@param Char: Model | Player - The character or player to check.
@return ModuleScript - The found ModuleScript with the "CharController" attribute, or nil if not found.
]]



function CharacterManager:Check(Char:Model|Player)
	if typeof(Char) ~= "Instance" then return end
	local Plr = game.Players:GetPlayerFromCharacter(Char)
	if Plr then
		return CharacterManager:Check(Plr)
	end
	for i,v in Char:GetChildren() do
		if v:IsA("ModuleScript") and v:GetAttribute("CharController") then
			return v
		end
	end
end

--[[
Override(Table1, Table2)
Recursively merges Table2 into Table1. If Table1 is nil, returns Table2.
@param Table1: table - The base table to merge into.
@param Table2: table - The table to merge from.
@return table - The merged table.
]]
function Override(Table1,Table2)
	if Table1 == nil then return Table2 end
	if typeof(Table1) == "table" and typeof(Table2) == "table" then
		for i,v in Table2 do
			if typeof(v) == "table" and (not Table1[i] or typeof(Table1[i]) == "table") then
				Table1[i] = Override(Table1[i],v)
			elseif Table1[i] == nil then
				Table1[i] = v

			end 
		end
	end
	return Table1
end
--[[
SetupConfig(Controller, Config, Replace)
Sets up the configuration for a given controller. Clones and merges configuration data.
@param Controller: Instance - The controller instance.
@param Config: string | Instance - The configuration to use.
@param Replace: boolean - Whether to replace existing configuration.
@return Instance, table - The cloned configuration instance and its data module.
]]

function SetupConfig(Controller,Config,Replace)
	local ConfigModule
	--if RunService:IsServer() then
	if typeof(Config) == "string" then
		Config = Configs:FindFirstChild(Config)


	end

	local IsDefault = false

	if typeof(Config) ~= "Instance" or not Config:IsA("ModuleScript")  then
		Config = DefaultConfig:Clone()
		IsDefault = true
	end

	if Config then
		if Lists.Chars[Controller] then
			if Replace then
				if Lists.Chars[Controller]["Cleanup"] then
					Lists.Chars[Controller]:Cleanup()
				end
				Lists.Chars[Controller] = nil
			else
				return Lists.Chars[Controller]
			end
		end
		local function CloneData(Plr:Player|Model)
			if Lists.Data[Plr] then
				return Lists.Data[Plr]
			end
			local Data = script:WaitForChild("Data"):Clone()
			Data.Parent = Plr
			Lists.Data[Plr] = {
				Mod = Data,
				Data = require(Data)(Plr)
			}
			return Lists.Data[Plr]
		end
		--[[if RunService:IsServer() then
			local Plr = game.Players:GetPlayerFromCharacter(Controller)

			if Plr then
				
				return CloneData(Plr)


			end
		end]]
		local Default = script:WaitForChild("ConfigSetup"):Clone()
		--Default.Parent = Controller

		local DefaultModule = require(Default)
		ConfigModule = Config

		local function CloneThings(Module,CloneTo)
			for i,v in Module:GetChildren() do
				local Found = CloneTo:FindFirstChild(v.Name)
				if Found then
					CloneThings(v,Found)
				else
					v = v:Clone()
					v.Parent = CloneTo
				end
			end
		end
		CloneThings(Config,Default)

		Default.Name = "Functionality"
		if RunService:IsServer() and game.Players:GetPlayerFromCharacter(Controller) then
			Default.Name = "FunctionalityServer"
		end
		Default:SetAttribute("CharController",true)
		Default.Parent = Controller
		DefaultModule = DefaultModule(Controller)
		
		require(Config)(DefaultModule)
		
		if RunService:IsServer() then
			Indexes:OnLoad(function()
			local Plr = game.Players:GetPlayerFromCharacter(Controller) or Controller
			local Entry = Lists.Data[Plr] or CloneData(Plr)
			--print(DefaultModule)
			--print(Entry)=
			DefaultModule.Data  =Entry.Data
			Lists.Data[Plr] = Entry
			--print(Default,DefaultModule)
			end)
		end
		Controller.Destroying:Connect(function()
			DefaultModule:Cleanup()
			Lists.Chars[Controller] = nil
			print(Lists)
		end)
		return Default,DefaultModule

	end
	return ConfigModule,Config



end




--[[
CharacterManager:GetController(Char: Model | Player)
Gets the controller for the given character or player.
@param Char: Model | Player - The character or player to get the controller for.
@return table - The controller data for the character or player.
]]


function CharacterManager:GetController(Char:Model|Player)
	if not Char or typeof(Char) ~= "Instance" then return end
	local Plr = Char:IsA("Player") and Char or game.Players:GetPlayerFromCharacter(Char)

	return Lists.Chars[Char]
end

--[[
CharacterManager:Create(Model: Instance, Addons, Options)
Creates a new character controller for the given model with optional addons and options.
@param Model: Instance - The model to create the controller for.
@param Addons: function - The function to add additional functionality.
@param Options: table - The options for creating the controller.
@return table - The created character controller data.
]]
function CharacterManager:Create(Model:Instance,Addons,Options)
	if not Model or typeof(Model) ~= "Instance" then return end

	Options = Options or {}
	local Replace = false
	if Lists.Chars[Model] then
		if not Options.Overwrite then
			return Lists.Chars[Model]
		end
		Replace = true

	end
	local Mod, Configuration
	if not Options.New then
		Mod, Configuration = SetupConfig(Model,Options.Config,Addons)
	else
		Mod,Configuration = Addons(Model)
	end

	Lists.Chars[Model] = {
		Data = Configuration,
		Module = Mod
	}
	return Lists.Chars[Model]
end

if not CharacterManager.Running then
	Indexes:OnLoad(function()
		if RunService:IsServer() then
			Indexes.Modules.Systems.Networker:CreatePort("PlayerCharManager",function(Player:Player)
				local Char = Player.Character
				if not Char then return end
				local Inst = CharacterManager:Create(Char)
				return Inst.Data
			end)

		end
	end)
	setmetatable(CharacterManager,{
		__call = function(...)
			local Args = {...}
			table.remove(Args,1)
			return CharacterManager:Create(unpack(Args))
		end,
	})
	CharacterManager.Completed = true
end

return CharacterManager

