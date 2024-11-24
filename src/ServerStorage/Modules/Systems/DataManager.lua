local DSService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local HTTPService = game:GetService("HttpService")

local DataSave = {}

function DataSave.new(Topic:string,Config)
	if DataSave[Topic] then
		return DataSave[Topic]
	end
	local Tab = {
		Errored = {}
	}
	Tab.DS = DSService:GetDataStore(Topic)
	--[[if Config.Ordered then
		Tab.DS = DSService:GetOrderedDataStore(Key)
	else
		Tab.DS = DSService:GetDataStore(Key)
	end]]
	
	local function UpdateData(Key:string,Data,Clear,TransformFunc)
		Key = Key or "Default"
		local Valid = true
		if Data == nil and not Clear then
			Valid = false
		end
		if Tab.Errored[Key] then
			return
		end
		Data = Data and HTTPService:JSONEncode(Data) 
		local CurrentData
		--print(Key)
		Tab.DS:UpdateAsync(Key,function(currentData,KeyInfo:DataStoreKeyInfo)
			if Data then
				if not TransformFunc then
				CurrentData = Data
				else
					if currentData == nil then
						currentData = HTTPService:JSONEncode({})
					end
					currentData = HTTPService:JSONDecode(currentData)
					Data = HTTPService:JSONDecode(Data)
					TransformFunc(CurrentData,Data)
					CurrentData = HTTPService:JSONEncode(CurrentData)
				end
				MessagingService:PublishAsync("DataStore",{
					Key = Topic,
					Data = HTTPService:JSONDecode(Data)
				})
			else
				CurrentData = currentData
			end
			return CurrentData
		end)
		return HTTPService:JSONDecode(Data)
	end
	function Tab:Set(Key:string,Data)
		Key = Key or "Default"
		local success
		for i = 1, 5 do
			
		xpcall(function()
			UpdateData(Key,Data,true)
		end,function(Message)
			if Message then
			warn(`Script Error: {Message}`)
			else
				success = true
			end
		end)
		if success then
			break
		end
			task.wait(.5)
		end
		if not success then
			print("DATA SAVING FAILED")
		end
	end
	function Tab:Transform(Key:string,Data,TransformFunc)
		Key = Key or "Default"
		local success
		for i = 1, 5 do

			xpcall(function()
				UpdateData(Key,Data,true,TransformFunc)
			end,function(Message)
				if Message then
					warn(`Script Error: {Message}`)
				else
					success = true
				end
			end)
			if success then
				break
			end
			task.wait(.5)
		end
		if not success then
			print("DATA TRANSFORM FAILED")
		end
	end
	function Tab:Get(Key:string)
		Key = Key or "Default"
		local success
		local Data
		for i = 1, 5 do

			xpcall(function()
				Data = UpdateData(Key)
			end,function(Message)
				if Message then
					warn(`Script Error: {Message}`)
				else
					success = true
				end
			end)
			if success then
				break
			end
			task.wait(.5)
		end
		if not success then
			--print("DATA GETTING FAILED")
			Tab.Errored[Key] = true
		end
		
	end
	
	DataSave[Topic] = Tab
	return Tab
end

if not DataSave.Running then
	DataSave.Running = true
	MessagingService:SubscribeAsync("DataStore",function(message)
		local Data = message.Data
		local KeyDS = DataSave[Data.Key]
		if not KeyDS then
			return 
		end
		KeyDS:Set(nil,Data.Data)
		
		
		
	end)
	setmetatable(DataSave,{
		__call = function(Tab,...)
			--print(...)
			return DataSave.new(...)
		end,
	})
end

return DataSave
