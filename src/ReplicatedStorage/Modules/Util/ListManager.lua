--!nonstrict
--[[
Paras,2024
Allows for multiple lists to be kept and accessed throughout Client or Serverside
]]

local ListKeeper = {	

}
local Lists:{
[any]:ListObject<any,any>	
} = {}

type ObjectList<IndexType,Type> = {
	[IndexType]:Type
}

export type ListObject<IndexType,Type> = {
	Objects:ObjectList<IndexType,Type>,
	AddEntry:(IndexType,Type)->(),
	RemoveEntry:(IndexType)->(),
	RemoveAll:()->(),
	Destroy:()->()
}


function ListKeeper.CreateList(ListName,Presets):ListObject<any,any>
	local CurrentList:ListObject<any,any>
	if Lists[ListName] then
		CurrentList = Lists[ListName]
	else
		Presets = Presets or {}
		local self:ListObject<typeof(ListName),typeof(Presets)> = {
		Objects = Presets	
		}
		self.RemoveEntry = function(Entry:any)
			self.Objects[Entry] = nil
		end
		self.AddEntry = function(Name:any,Entry:any)
			self.Objects[Name] = Entry
			
			
		end
		self.RemoveAll = function()
			table.clear(self.Objects)
		end
		self.Destroy = function()
			self.RemoveAll()
			table.clear(self)
			Lists[ListName] = nil
		end
		Lists[ListName] = self
		CurrentList = self
		
	end
	return CurrentList
end



return ListKeeper
