local AssetService = game:GetService("AssetService")

local ShaderSystem = {}

function ShaderSystem:HookObject(Mesh:MeshPart,Options)
	if typeof(Mesh) ~= "Instance" or not Mesh:IsA("MeshPart") then return end
	Options = Options or {}
	print(Mesh)
	local Clone = Content.fromAssetId(tonumber(string.sub(Mesh.MeshId,14,#(Mesh.MeshId))))
	local ShaderData = {
		Colors = {},
		Faces = {},
		ShadeTones = {}
	}
	local NewMesh = AssetService:CreateEditableMeshAsync(Clone,{
		FixedSize = true
	})
	local AllFaces = NewMesh:GetFaces()
	local CurrColorIds = NewMesh:GetColors()
	local function SetShadeTone(Type,Modification,IndexShade)
		ShaderData.Colors[Type] = {}
		if Type == "Origin" then
			for i,v in CurrColorIds do
				local Color = NewMesh:GetColor(v)
				ShaderData.Colors.Origin[v] = Color
				ShaderData.ShadeTones[Color] = {
					v
				}
			end
		elseif typeof(Modification) == "function" then
			local Clone = table.clone(ShaderData.Colors.Origin)
			local CloneData = {}
			for i,v in Clone do
				local Alpha = NewMesh:GetColorAlpha(i)
				local NewColor = Modification(v)
				local ID = NewMesh:AddColor(NewColor,Alpha)
				CloneData[ID] = NewColor
				ShaderData.ShadeTones[v][IndexShade] = ID
			end
			ShaderData.Colors[Type] = CloneData
		end
	end
	SetShadeTone("Origin")
	local AmountTones = Options.Tones or 2
	local ColorShift = 100/255
	local function Sub(R)
		return math.clamp(R-ColorShift,0,255)
	end
	for i = 2, AmountTones + 1 do
		SetShadeTone(i,function(Color)
			return Color3.new(Sub(Color.R),Sub(Color.B),Sub(Color.B))
		end)
	end
	local CurrFaces = NewMesh:GetFaces()
	local Positions = {}
	local ColorFaces = {}
	for i,v in CurrFaces do
		Positions[v] =NewMesh:GetFaceVertices(v)
		local Color = NewMesh:GetFaceColors(v)
		local Normal = NewMesh:GetFaceNormals(v)
		ColorFaces[i] = {}
		for e,x in Positions[v] do
			ColorFaces[i][e] ={
				Color = Color[e],
				Normal = Normal[e],
				Vertice = x,
				
			}
		end
	end
	local Lighting = game:GetService("Lighting")
	local function DetermineShade(CF:CFrame)
		local Angle = Lighting:GetSunDirection()
		local DotProduct = (CF.LookVector:Dot(Angle)) + 1
		DotProduct /= 2
		DotProduct = 1-DotProduct
		return math.round(DotProduct*(AmountTones - 1)) + 1
	end
	task.spawn(function()
		
		while Mesh.Parent do
			task.wait()
			local CF = Mesh.CFrame
			for i,v in ColorFaces do
				local FaceColors = {}
				for e,x in v do
					local ShadeTone = DetermineShade(CF * CFrame.new(x.Normal))
					FaceColors[e] = ShaderData.ShadeTones[x.Color][ShadeTone] 
				end
				NewMesh:SetFaceColors(i,FaceColors)
			end
		end
	end)
	
end

return ShaderSystem
