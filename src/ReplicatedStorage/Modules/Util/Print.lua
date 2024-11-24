local Mod = {
Func = function(Message:string,Config)
	
	local Level = 0
	
	local Source = debug.info(Level,"s")
	local LineFunc = debug.info(Level,"ln")
local TempSource,TempFunc
local Sources = {}
	repeat
		Level += 1
			TempSource = debug.info(Level,"s")
			TempFunc = debug.info(Level,"ln")
			if TempSource then
				Source = TempSource
				
			end
			if TempFunc then
				LineFunc = TempFunc
			end
			if Source then
				table.insert(Sources,Source..":"..LineFunc)
			end

			task.wait()
			
	until not TempSource or not TempFunc
	table.remove(Sources,#Sources)
		print(Message,`\nSource:{Source} \n Function:{LineFunc} \n Call Abstraction Level:{Level}`)
for i,v in Sources do
	print(v)
end
print("\n")
 end
}
if not Mod.Running then
	Mod.Running = true
	_G.print = Mod.Func
end
return Mod