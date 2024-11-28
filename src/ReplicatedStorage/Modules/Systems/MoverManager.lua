--!nonstrict
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

local Modules = replicatedStorage:WaitForChild("Modules")

local utilities = Modules:WaitForChild("Util")
local listManager = require(utilities:WaitForChild("ListManager"))



export type moverType = "Vel"|"Gyro"

export type moverObject = {
	val:CFrame|Vector3,
	priority:number,
	ID:string
}

export type moverConstructor = {  
	targ:BasePart,
	velList:{moverObject},	
	gyroList:{moverObject},
	vel:BodyVelocity,
	gyro:BodyGyro
}

local MoverManager = {
	moverList = listManager.CreateList("Movers"),
	running = false
}
function MoverManager:create(part:BasePart?):moverConstructor?
	if MoverManager.moverList.Objects[part] then
		return MoverManager.moverList.Objects[part]
	end
	local mover = Instance.new("BodyVelocity")
	mover.MaxForce = Vector3.zero
	mover.P = 1e5

	mover.Name = "moverVel"
	mover.Parent = part
	local mover2 = Instance.new("BodyGyro")
	mover2.MaxTorque = Vector3.zero
	
	mover2.P = 1e5
	mover2.D = 50
	mover2.Name = "moverGyro"
	mover2.Parent = part
	local newMover:moverConstructor? = {
		velList = {},
		gyroList = {},
		targ = part,
		vel = mover,
		gyro = mover2
	}

	MoverManager.moverList.AddEntry(part,newMover)
	return newMover
end

function MoverManager:add(constructor:moverConstructor?,moverType:moverType,ID:string,val:Vector3|CFrame,priority:number)
	if not ID then return end
	if not constructor then return end
	val = val or (moverType == "Vel" and Vector3.zero or moverType == "Gyro" and CFrame.new() or Vector3.zero)
	priority = priority or 0
	local newVel:moverObject
	local found = false
	if moverType == "Vel" then
		for i,v in constructor.velList do
			if v.ID == ID then
				newVel = v
				found = true
				break
			end
		end
		if not newVel then
			newVel = {
				val = val,
				ID = ID,
				priority = priority
			}
			table.insert(constructor.velList,newVel)
		else
			newVel.val = val
			newVel.priority = priority
			
		end
		table.sort(constructor.velList,function(mover1,mover2)
			return mover1.priority > mover2.priority
		end)

		
	elseif moverType == "Gyro" then
		for i,v in constructor.gyroList do
			if v.ID == ID then
				newVel = v
				found = true
				break
			end
		end
		if not newVel then
			newVel = {
				val = val,
				ID = ID,
				priority = priority
			}
			table.insert(constructor.gyroList,newVel)
		else
			newVel.val = val
			newVel.priority = priority

		end
		table.sort(constructor.gyroList,function(mover1,mover2)
			return mover1.priority > mover2.priority
		end)

	end
end
function MoverManager:destroy(constructor:moverConstructor?,moverType:moverType,ID:string)
	if not constructor then return end
	if moverType == "Vel" then
		
		for i,v in constructor.velList do
			if v.ID == ID then
				table.remove(constructor.velList,i)
			end
		end
		table.sort(constructor.velList,function(mover1,mover2)
			return mover1.priority > mover2.priority
		end)
		
	elseif moverType == "Gyro" then
		for i,v in constructor.gyroList do
			if v.ID == ID then
				table.remove(constructor.gyroList,i)
			end
			table.sort(constructor.gyroList,function(mover1,mover2)
				return mover1.priority > mover2.priority
			end)
		end
		


end
end
function MoverManager:find(constructor:moverConstructor?,moverType:moverType,ID:string)
	if not constructor then return end
	if moverType == "Vel" then
		for i,v in constructor.velList do
			if v.ID == ID then
				return v
			end
		end

	elseif moverType == "Gyro" then
		for i,v in constructor.gyroList do
			if v.ID == ID then
				return v
			end
		end



	end
end
if not MoverManager.running then
	MoverManager.running = true
	local function RunFrame()

		for part,mover:moverConstructor in MoverManager.moverList.Objects do
			if part then
				if #(mover.velList) == 0 then
					mover.vel.MaxForce = Vector3.zero
				else
					mover.vel.Velocity = mover.velList[1].val
					mover.vel.MaxForce = Vector3.one * 1e10

				end

				if #(mover.gyroList) == 0 then
					mover.gyro.MaxTorque = Vector3.zero
				else
					mover.gyro.CFrame = mover.gyroList[1].val
					mover.gyro.MaxTorque = Vector3.one * 1e10

				end

			else
				MoverManager.moverList.RemoveEntry(part)
			end
		end

	end
	if runService:IsClient() then
		runService:BindToRenderStep("MoverManager",Enum.RenderPriority.First.Value,RunFrame)
	else
		runService.Stepped:Connect(RunFrame)
	end
end



return MoverManager
