--[[
	ConfigSetup

	This module initializes and configures character settings and behaviors.

	@param Controller Instance - The character controller instance.
	@param Config table - Optional configuration table.

	@return table - The character configuration table.

	CharConfig table structure:
		- Modifications: table - Stores character modifications.
		- Remotes: table - Stores remote events and functions.
		- Controller: Instance - The character controller instance.
		- PastActions: table - Stores past actions.
		- ActionMods: table - Stores action modifications.
		- Script: Instance - The script instance.
		- Childs: table - Stores child scripts.
		- Events: table - Stores event connections.
		- PlayerServer: boolean - Indicates if the player is on the server.
		- Signal: table - Stores signal functions.
		- Animator: Instance - The character animator instance.
		- Mover: Instance - The character mover instance.
		- MovementAnim: Instance - The current movement animation.
		- JumpAnim: Instance - The current jump animation.
		- JumpTask: thread - The jump animation task.
		- RunBoost: number - The run boost multiplier.
		- Inputs: table - Stores input configurations.
		- Data: table - Stores character data.
		- Loaded: boolean - Indicates if the character is loaded.

	Functions:
		- CharScriptConnect(Script: Instance, Index: string) - Connects character scripts.
		- SetupFolder(v: Folder) - Sets up folder connections.
		- DoAction(ActionName: string, Options: table) - Executes a character action.
		- Cleanup() - Cleans up character configurations and connections.
		- PlayJumpAnim() - Plays the jump animation.
		- PlayFallAnim() - Plays the fall animation.
		- StopFallJump() - Stops the fall and jump animations.
		- ChangeMovementAnim(Movement: string) - Changes the movement animation.
		- Run(Toggle: boolean) - Toggles the run animation.
		- Signal functions - Various signal functions for character actions and animations.
]]
return function(Controller:Instance,Config)
	local RunService = game:GetService("RunService")
	local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
	local CharConfig
	--if RunService:IsServer() then
	Config = Config or {}


	CharConfig = {
		Modifications = {

		},
		Remotes = {},
		Controller = Controller,
		PastActions = {},
		ActionMods = {},
		Script = script,
		Childs = {},
		Events = {},



	}
	if RunService:IsServer() and game.Players:GetPlayerFromCharacter(Controller) then
		CharConfig.PlayerServer = true
		
	end
--[[
local ActionTab = Config.ActionTab or {}
for i,v in ActionTab do
	CharConfig.ActionMods[i] = v
end]]

	

	local function CharScriptConnect(Script,Index)
		if not Script then return end
		if CharConfig.Childs[Script] then return end
		CharConfig.Childs[Script] = true
		
		local OleCharConfig = CharConfig
		
		local InitFunc
		local function ScriptAdded(CharConfig,v:Instance)
			--print(v)
			local EntryTab = {
				CurrentTab = CharConfig,
				CharConfig = OleCharConfig,
				Instance = v,
				
			}
			if v:IsA("ModuleScript") then
				local Req = require(v)
				if InitFunc then
					EntryTab.Req = Req
					
				else
					
				if typeof(Req) == "function" then
					CharConfig[v.Name] = Req(CharConfig)
				else
					CharConfig[v.Name] = Req
				end
end

			elseif v:IsA("RemoteEvent") or v:IsA("UnreliableRemoteEvent") or v:IsA("RemoteFunction") then
				if InitFunc then
					else
				CharConfig.Remotes[v.Name] = v
				end
			end
			if InitFunc then
			InitFunc(EntryTab)
			end
		end
		
		if not CharConfig[Index] then
			local Init = Script:FindFirstChild("_INIT")
			CharConfig[Index] = {
				Childs = {},
				Events = {}
			}
			if Init and Init:IsA("ModuleScript") then
			Init = require(Init)
			if typeof(Init) == "function" then
				
					Init(CharConfig,Index)
			elseif typeof(Init) == "table" then
				if Init.Init then
						Init.Init(CharConfig,Index)
				end
				if Init.ChildAdded then
					InitFunc = Init.ChildAdded
				end
				if typeof(Init.ScriptAddedFunc) == "function" then
					ScriptAdded = Init.ScriptAddedFunc
				end
				for i,v in Init do
					if i ~= "Init" and i ~= "ScriptAddedFunc" then
						CharConfig[Index][i] = v
					end
				end
			end
			end

		end
		local OleCharConfig = CharConfig
		local CharConfig = CharConfig[Index] 
		
		--print(Script)
		

		for i,v in Script:GetChildren() do
			ScriptAdded(CharConfig,v)
		end
		table.insert(CharConfig.Events,Script.ChildAdded:Connect(function(v)
			ScriptAdded(CharConfig,v)
		end))
	end
local function SetupFolder(v:Folder)
	if v:IsA("Folder") and not v:GetAttribute("DontConnect") then
		CharScriptConnect(v,v.Name)
	end
end
for i,v in script:GetChildren() do
	SetupFolder(v)
end
table.insert(CharConfig.Events, script.ChildAdded:Connect(SetupFolder))
	task.spawn(function()
		local OldScript = script.Parent
		while CharConfig.Script and CharConfig.Controller.Parent do
			task.wait()
			if script.Parent ~= OldScript then
				CharScriptConnect(script,CharConfig)
				print(script:GetChildren())
				CharScriptConnect(script:WaitForChild("Actions"),CharConfig.Actions)
			end
			OldScript = script.Parent
		end
	end)
	--print(CharConfig)



	function CharConfig:DoAction(ActionName:string,Options)
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
		_G.WaitUntil("IndexesLoaded")
			--[[if not _G.Check("IndexesLoaded") then
				repeat task.wait() until _G.Check("IndexesLoaded")
			end]]
			
		Options = Options or {}
		local Type = CharConfig.Actions[ActionName]
		--	print(ActionName)
		--print(Options)
		--print(CharConfig.Actions)
		if Type then
			--print(Options)
			if RunService:IsClient() then
				--_G.WaitUntil("IndexesLoaded")
				--print(Controller.Name)
				--print("DoAction",ActionName,Options)
				Indexes.Modules.Systems.Networker:SendPortData("PlayerCharManager"..Controller.Name,_G.Enums.NetworkSendType[Type.RemoteType or "FastEvent"],"DoAction",ActionName,Options)
			end
			Type.Func(CharConfig,Options)
		end
	end


	local function Cleanup()
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
		_G.WaitUntil("IndexesLoaded")
			--[[if not _G.Check("IndexesLoaded") then
				repeat task.wait() until _G.Check("IndexesLoaded")
			end
			Indexes.Modules.Util.Array:Cleanup(CharConfig)]]
			if CharConfig.Events then
			for i,v in CharConfig.Events do
				v:Disconnect()
			end
			end
			CharConfig.Data = nil
for i,v in CharConfig do
	if typeof(v) == "table" and i ~= "Data" then
		table.clear(v)
		
	end
end
table.clear(CharConfig)
		script:ClearAllChildren()
		script:Destroy()
	end
	function CharConfig:Cleanup()
		Cleanup()
	end
	task.spawn(function()
		local Indexes = require(game:GetService("ReplicatedStorage"):WaitForChild("Indexes"))
			--[[if not _G.Check("IndexesLoaded") then
				repeat task.wait() until _G.Check("IndexesLoaded")
			end]]
		_G.WaitUntil("IndexesLoaded")
		Indexes.Modules.Util.Array:AddCleanupFunc(CharConfig,Cleanup)
	end)
	
	CharConfig.Controller.Destroying:Once(function()
		CharConfig:Cleanup()
	end)	
	local Hum:Humanoid = Controller:WaitForChild("Humanoid")
	local HRP:BasePart = Controller:WaitForChild("HumanoidRootPart")
	
	Indexes:OnLoad(function()
		CharConfig.Signal = Indexes.Modules.Util.Signal(script)
		if not CharConfig.PlayerServer then
		CharConfig.Animator = Indexes.Modules.Systems.AnimManager:createConstructor(Hum:WaitForChild("Animator"))
		CharConfig.Mover = Indexes.Modules.Systems.MoverManager:create(HRP)
		--print(CharConfig)
		local AnimManager =  Indexes.Modules.Systems.AnimManager
		local function SetTask(Speed)
			if CharConfig.MoveAnimTask then
				task.cancel(CharConfig.MoveAnimTask)
			end
			if Speed then
			CharConfig.MoveAnimTask = task.spawn(function()
				while Controller.Parent do
					task.wait()
					CharConfig.MovementAnim:AdjustSpeed((HRP.AssemblyLinearVelocity * Vector3.new(1,0,1)).Magnitude/Speed)
				end
			end)
			end
		end
		local Anims = {
			Idle = {
			},
			Walk = {
				Speed = 20
			},
			Run = {
				Speed = 48
			},
		}
		local OldMovement 
		CharConfig.Signal.ChangeMovementAnim = function(Movement:string)
			if Movement == OldMovement then return end
			local Tab = Anims[Movement] 
			if Tab then
				if CharConfig.MovementAnim then
					CharConfig.MovementAnim:Stop()
				end
				CharConfig.MovementAnim = AnimManager:PlayAnim(CharConfig.Animator,{
					"Default",
					"Movement",
					Movement
				},{
					Looped = true,
					Priority = Enum.AnimationPriority.Core,
					ID = Movement
				})
				SetTask(Tab.Speed)
			end
		end
			CharConfig.Signal.Run = function(Toggle)
				if Toggle then
					CharConfig.Signal.ChangeMovementAnim("Run")
				elseif Hum.MoveDirection.Magnitude >= .1 then
					CharConfig.Signal.ChangeMovementAnim("Walk")
				else
					CharConfig.Signal.ChangeMovementAnim("Idle")
				end
			end
		CharConfig.Signal.ChangeMovementAnim("Idle")
		Hum:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			if Hum.MoveDirection.Magnitude < .1 then
				CharConfig:DoAction("Run",{
					Holding = false
				})
			elseif CharConfig.MovementAnim and CharConfig.MovementAnim.Name == "Idle" then
				CharConfig.Signal.ChangeMovementAnim("Walk")
			end
		end)
		CharConfig.PlayJumpAnim = function()
				AnimManager:StopAnim(CharConfig.Animator,{"Jump","Fall"})
				CharConfig.JumpAnim = AnimManager:PlayAnim(CharConfig.Animator,{
					"Default",
					"Movement",
					"Jump"
				},{
					Looped = true,
					Priority = Enum.AnimationPriority.Idle,
					ID = "Jump"
				})
				if CharConfig.JumpTask then
					task.cancel(CharConfig.JumpTask)
				end
				CharConfig.JumpTask = task.spawn(function()
					repeat task.wait() until CharConfig.JumpAnim.TimePosition >= (CharConfig.JumpAnim.Length - .06)
					CharConfig.JumpAnim:AdjustSpeed(0)
				end)
		end
		CharConfig.PlayFallAnim = function()
				if CharConfig.JumpTask then
					task.cancel(CharConfig.JumpTask)
				end
				AnimManager:StopAnim(CharConfig.Animator,{"Jump","Fall"})
				CharConfig.JumpAnim = AnimManager:PlayAnim(CharConfig.Animator,{
					"Default",
					"Movement",
					"Fall"
				},{
					Looped = true,
					Priority = Enum.AnimationPriority.Idle,
					ID = "Fall"
				})
				CharConfig.JumpTask = task.spawn(function()
					repeat task.wait() until CharConfig.JumpAnim.TimePosition >= (CharConfig.JumpAnim.Length - .06)
					CharConfig.JumpAnim:AdjustSpeed(0)
				end)
		end
		CharConfig.StopFallJump = function()
				if CharConfig.JumpTask then
					task.cancel(CharConfig.JumpTask)
				end
				AnimManager:StopAnim(CharConfig.Animator,{"Jump","Fall"})

		end
		Hum.StateChanged:Connect(function(old,new)
			if new == Enum.HumanoidStateType.Jumping then
				CharConfig.PlayJumpAnim()
			elseif new == Enum.HumanoidStateType.Freefall then
					CharConfig.PlayFallAnim()
			elseif old == Enum.HumanoidStateType.Freefall and new == Enum.HumanoidStateType.Landed then
					CharConfig.StopFallJump()
			end
		end)
		CharConfig.RunBoost = 1
		task.spawn(function()
			local Delta = 0
			local OldTime = os.clock()
			while Controller.Parent do
				task.wait()
				Delta = os.clock() - OldTime
				OldTime = os.clock()
				Hum.WalkSpeed += (16 * CharConfig.RunBoost - Hum.WalkSpeed) * .15^(1-Delta)
				Hum.UseJumpPower = true
					Hum.JumpPower += (60 + Hum.WalkSpeed/2 - Hum.JumpPower) * .15^(1-Delta)
				--print(Hum.WalkSpeed)
			end
		end)
end
	end)
	
	
	
	
	task.spawn(function()
		while Controller.Parent do
			task.wait() 
			if CharConfig.LockedOn then
				CharConfig.Inputs.Look = CFrame.new(HRP.Position,CharConfig.LockedOn.HumanoidRootPart.Position)
			else
				if RunService:IsClient() then
					CharConfig.Inputs.Look = workspace.CurrentCamera.CFrame
				end
			end
		end
	end)
	CharConfig.Inputs = require(script:WaitForChild("Inputs"))(CharConfig)
	if RunService:IsClient() then
		--print("Client")
		Indexes.Modules.Systems.Networker:CreatePort("GetData"..Controller.Name,function(Data)
			--print(TypeAction)
			--print(CharConfig)
			--print(CharConfig)
			--print(Data)
			CharConfig.Data = Data
			
		end,
		{
			List = {
				game.Players:GetPlayerFromCharacter(Controller)
			},
			ListType = "Include",
			Replace = true
		})
	elseif RunService:IsServer() and CharConfig.PlayerServer then
		Indexes:OnLoad(function()
		
		Indexes.Modules.Systems.Networker:CreatePort("PlayerCharManager"..Controller.Name,function(Player:Player,TypeAction,...)
			--print(TypeAction)
			--print(CharConfig)
			if TypeAction == "DoAction" then
				local Args = {...}
				task.spawn(function()
					print(CharConfig)
				CharConfig:DoAction(unpack(Args))
				end)
				
			end
		end,
		{
			List = {
				game.Players:GetPlayerFromCharacter(Controller)
			},
			ListType = "Include",
			Replace = true
		})
		local Plr = game.Players:GetPlayerFromCharacter(Controller)
		task.spawn(function()
			repeat task.wait() 
				print(CharConfig)
			until CharConfig.Data 
			repeat task.wait() until  Indexes.Modules.Systems.Networker:GetPortInfo(Plr,"GetData"..Controller.Name)
				local function SendPort()
					--print(_G.Enums.NetworkSendType.FastEvent)
					Indexes.Modules.Systems.Networker:SendPortData("GetData"..Controller.Name,_G.Enums.NetworkSendType.FastEvent,Plr,table.clone(CharConfig.Data))

				end
			
		local function SetChange(Tab)
			
					--print(Tab,getmetatable(Tab))
			if not getmetatable(Tab) then
			setmetatable(Tab,{
				__newindex = function(tab,index,Val)
					
					if typeof(Val) == "table" then
						SetChange(Val)
					end
					rawset(tab,index,Val)
					SendPort()
				end,
			})
			end
			
			for i,v in Tab do
				if typeof( v) == "table" then
					SetChange(v)
				end
			end
		end
				SendPort()
		SetChange(CharConfig.Data)
		end)
		end)
	end
	
	if CharConfig.PlayerServer then
		script.Name = "PlayerServer"
	end
	CharConfig.Loaded = true
	return CharConfig
	--[[else
		--Client-Sided code
		CharConfig = {}
		CharConfig.Controller = game.Players.LocalPlayer
		--CharConfig.Inputs = require(script:WaitForChild("Inputs"))(CharConfig)
		local Mod = script:FindFirstChild("Environment")
		if Mod then
			CharConfig.Environment = require(Mod)
			CharConfig.Environment:Load(CharConfig)

		end

		return CharConfig
	end]]
end
