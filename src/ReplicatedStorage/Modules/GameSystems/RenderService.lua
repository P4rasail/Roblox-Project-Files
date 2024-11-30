local RunService = game:GetService("RunService")
local RepStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Indexes = require(RepStorage:WaitForChild("Indexes"))

local Models = RepStorage:WaitForChild("Models")
local Effects = RepStorage:WaitForChild("Effects")

local RenderService = {
	ShiftFlights = {}
}





function Emit(Mod:Model,Options)
	Options = Options or {}
	local MaxTime = 0
	for i,Part in Mod:GetDescendants() do
		if Part:IsA("ParticleEmitter") then
			task.delay(Part:GetAttribute("EmitDelay"),function()
				Part:Emit(Part:GetAttribute("EmitCount"))
			end)
			local TimeLife = Part:GetAttribute("EmitDelay") or 0
			TimeLife += Part.Lifetime.Max / Part.TimeScale
			MaxTime = math.max(TimeLife,MaxTime)
		end
	end
	if Options.Destroy then
		task.delay(MaxTime,function()
			Mod:Destroy()
		end)
	end
end


if not RenderService.Running then
	RenderService.Running = true
	local function CallClient(Index,...)
		repeat task.wait() until Indexes.Loaded
		_G.Modules.Systems.Networker:SendPortData("Render",nil,nil,Index,...)

	end
	Indexes:OnLoad(function()
		if RunService:IsServer() then
			setmetatable(RenderService,{
				__index = function(Tab,Index)
					local Rawget = rawget(RenderService,Index)
					print(Index)
					print(Rawget)
					print(typeof(Rawget))

					if typeof(Rawget) == "function" then
						return function(...)
							print(...)
							CallClient(Index,...)	
						end
					else
						return Rawget
					end
				end,
				__newindex = function(Tab,Index,Val)
					if typeof(Val) == "function" then
						rawset(Tab,Index, function(...)
							--print(...)
							CallClient(Index,...)	
						end)
					else
						rawset(Tab,Index,Val)
					end
				end,
			})

		else
			_G.Modules.Systems.Networker:CreatePort("Render",function(TypeRender,...)

				local Func = RenderService[TypeRender]
				--print(TypeRender)
				--print(...)
				if typeof(Func) == "function" then
					return Func(...)
				end
			end)
		end

		function RenderService:BindOutfit(Char:Model,OutfitType)
			local Targ:Model
			if OutfitType then
				Targ = Models.Clothes:FindFirstChild(OutfitType)
			end
			local Bound = _G.Modules.GameSystems.BindService:Bind(Targ,Char,{
				Tag = "Outfit",
				Unbind = not Targ
			})
			--[[
			for i,v:MeshPart in Bound.Model:GetDescendants() do
				if v:IsA("MeshPart") then
					Indexes.Modules.Systems.ShaderSystem:HookObject(v,{
						Tones = 2
					})
				end
			end]]

		end

		function RenderService:BindFace(Char:Model,OutfitType)
			local Targ:Model
			if OutfitType then
				Targ = Models.Faces:FindFirstChild(OutfitType)
			end
			for i,v in Char.Head:GetChildren() do
				if v:IsA("Decal") then
					v:Destroy()
				end
			end
			local Bound = _G.Modules.GameSystems.BindService:Bind(Targ,Char,{
				Tag = "Face",
				Unbind = not Targ
			})
			--[[
			for i,v:MeshPart in Bound.Model:GetDescendants() do
				if v:IsA("MeshPart") then
					Indexes.Modules.Systems.ShaderSystem:HookObject(v,{
						Tones = 2
					})
				end
			end]]

		end
		function RenderService:BindHair(Char:Model,HairType,Form)
			local Targ:Model
			if HairType then
				Targ = Models.Hairs:FindFirstChild(HairType)
			end
			Form = Form or "Base"
			if Targ then
				Targ = Targ:FindFirstChild(Form)
			end
			_G.Modules.GameSystems.BindService:Bind(Targ,Char,{
				Tag = "Hair",
				Unbind = not Targ
			})

		end
		function RenderService:ShiftFlight(Char:Model,Options)
			local Toggle = Options.Holding
			if RenderService.ShiftFlights[Char] then
				task.cancel(RenderService.ShiftFlights[Char])
			end
			if not Toggle then
				_G.Modules.GameSystems.BindService:Bind(nil,Char,{
					Tag = "ShiftFlight",
					Unbind = true
				})
				if Options.StopFlight then
					local Bound = _G.Modules.GameSystems.BindService:Bind(Effects.Flight.FlightStop,Char,{
						Tag = "FlightStop",
						Emit = true
					})
				end
			else
				--print(Char,Toggle)
				local Bound = _G.Modules.GameSystems.BindService:Bind(Effects.Flight.FlightAura,Char,{
					Tag = "ShiftFlight"
				})
				RenderService.ShiftFlights[Char] = task.spawn(function()
					while Bound.Events do
						task.wait()
						local Vel = Char:GetAttribute("FlightTravel") or Vector3.new(0,0,1)
						if Vel.Magnitude == 0 then
							Vel = Vector3.new(0,0,1)
						end
						--print(Vel)
						Bound.Offset = CFrame.new(Vector3.zero,Vel *Vector3.new(1,1,-1) )
					end
				end)
			end


		end
		local transTimes = {}
		function RenderService:Transparency(Char:Model,Time)

			if not transTimes[Char] then
				transTimes[Char] = {

				}
			end
			if not transTimes[Char].visibilities then
				transTimes[Char].visibilities = {}
				local function childAdded(new:Instance)
					if new:IsA("BasePart") then
						transTimes[Char].visibilities[new] = new.Transparency
					elseif new:IsA("Decal") then
						transTimes[Char].visibilities[new] = new.Transparency
					end
				end
				for i,v in Char:GetDescendants() do
					childAdded(v)
				end
				Char.DescendantAdded:Connect(function(v)
					childAdded(v)
				end)
			end
			if not transTimes[Char].time or os.clock() + Time >= transTimes[Char].time then
				transTimes[Char].time = os.clock() + Time
			end
			if not transTimes[Char].Thread or coroutine.status( transTimes[Char].Thread) == "dead" then
				if transTimes[Char].Thread then
					task.cancel(transTimes[Char].Thread)
				end
				transTimes[Char].Thread = task.spawn(function()

					while os.clock() < transTimes[Char].time do
						task.wait()
						for i,v in transTimes[Char].visibilities do
							i.Transparency = 1
						end
					end
					for i,v in transTimes[Char].visibilities do
						i.Transparency = v
					end
					return
				end)
			end

		end

		function RenderService:Afterimage(Char:Model,Time)

			local Off = Char.HumanoidRootPart.AssemblyLinearVelocity.Unit * -5
			local mod = Instance.new("Model")
			mod.Parent = workspace:WaitForChild("Effects")
			--print("Effect")
			for i,v in Char:GetChildren() do
				if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animator") or v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then continue end
				local clone:BasePart= v:Clone()
				clone.Parent = nil
				--clone.Parent = game:GetService("ReplicatedStorage")
				if clone:IsA("BasePart") or clone:IsA("MeshPart") then
					clone.Archivable = true
					clone.CanCollide = false
					clone.Anchored = true
					clone.CanQuery = false
					clone.CanTouch = false
					--clone.Position += Off	

					--clone.Transparency = .5
					TweenService:Create(clone,TweenInfo.new(Time-.1),{
						Transparency = 1
					}):Play()
					task.delay(.03,function()
						while mod.Parent do
							task.wait()
							clone.Archivable = true
							clone.CanCollide = false
							clone.Anchored = true
							clone.CanQuery = false
							clone.CanTouch = false
						end
					end)
				elseif clone:IsA("Decal") then
					--clone.Transparency = .5
					TweenService:Create(clone,TweenInfo.new(Time-.1),{
						Transparency = 1
					}):Play()
				end		
				for i,v in clone:GetDescendants() do
					if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") or v:IsA("Animator") or v:IsA("Weld") or v:IsA("WeldConstraint") or v:IsA("Motor6D") then v:Destroy() end
					if v:IsA("BasePart") or v:IsA("MeshPart") then
						
						v.CanCollide = false
						v.Anchored = true
						v.CanQuery = false
						v.CanTouch = false
						--v.Position += Off


						--clone.Transparency = .5
						TweenService:Create(v,TweenInfo.new(Time-.1),{
							Transparency = 1
						}):Play()
						task.delay(.03,function()
							while mod.Parent do
								task.wait()
								v.Archivable = true
								v.CanCollide = false
								v.Anchored = true
								v.CanQuery = false
								v.CanTouch = false
							end
						end)
					elseif v:IsA("Decal") then
						--clone.Transparency = .5
						TweenService:Create(v,TweenInfo.new(Time-.1),{
							Transparency = 1
						}):Play()
						elseif v:IsA("Beam") or v:IsA("ParticleEmitter") then
v:Destroy()
						
					end		
				end

				--if not clone then continue end


				clone.Parent = mod



			end
			mod.Parent = workspace:WaitForChild("Effects")
			game.Debris:AddItem(mod,Time)

		end
		function RenderService:Dash(Char:Model)


			--print(Char,Toggle)
			--repeat task.wait() until Char:GetAttribute("DashDir")
			local function Determine()
				local Vec = Char:GetAttribute("DashDir") or Vector3.new(0,0,1)
				Vec *= Vector3.new(1,1,-1)
				return CFrame.new(Vector3.zero,Vec)
			end
			local Bound = _G.Modules.GameSystems.BindService:Bind(Effects.Dash,Char,{
				Tag = "Dash",
				Emit = true,
				Offset = Determine()
			})
			RenderService:Transparency(Char,.3)
			RenderService:Afterimage(Char,.5)
			task.spawn(function()
				local OsTime = os.clock() + .5
				repeat
					task.wait()
					Bound.Offset = Determine()
				until not Bound.Events
			end)




		end		
		function RenderService:HitEffect(HRP:Model,Options)
			Options = Options or {}
			if not Options.Type then return end
			local EmitOptions = {
				Destroy = true
			}
			local Offset = Options.Offset or CFrame.new()
			local Targ = Effects.Hits:FindFirstChild(Options.Type)
			if Targ then
				Targ = Targ:Clone()
				local function Set(Part:BasePart)
					if Part:IsA("BasePart") then
						Part.Anchored = true
						Part.CanCollide = false
						Part.CanTouch = false
						Part.CanQuery = false
					end
					for i,v in Part:GetChildren() do
						Set(v)
					end
				end
				if Targ:IsA("Model") then
					Targ:PivotTo(HRP.CFrame * Offset)
				elseif Targ:IsA("BasePart") then
					Targ.CFrame = HRP.CFrame * Offset
				end
				Set(Targ)
				Targ.Parent = workspace.Effects
				task.wait()
			Emit(Targ,EmitOptions)
			
			end

			--print(Char,Toggle)
			--repeat task.wait() until Char:GetAttribute("DashDir")





		end		
		function RenderService:Resize(Part2:Instance,Size:Vector3)

		end

	end)
	if RunService:IsServer() then
		for i,v in RenderService do
			if typeof(v) == "function" then
				RenderService[i] = function(...)
					CallClient(i,...)	
				end
			end
		end
	end
end

return RenderService
