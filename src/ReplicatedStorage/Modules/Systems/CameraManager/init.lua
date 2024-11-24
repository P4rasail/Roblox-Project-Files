local CameraManager = {}

function CameraManager:ConnectCam(Cam:Camera)
	if Cam then
		local Found = Cam:FindFirstChild("CameraObject")
		if Found then
			return require(Found)
		end
		local Clone = script.CameraObject:Clone()
		Clone.Parent = Cam
		return require(Clone)
	end
end

if not CameraManager.Running then
	CameraManager.Running = true
end

return CameraManager
