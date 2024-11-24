local Textures = {15551215068,15551214253,15551213424,15551212557,15551211832,15551211832,15551210573,15551209853,15551209171,15551208077,15551207750,15551206745,15551206090,15551205296} -- put the ids here
local Time =0.25-- in seconds

 while true do
	for i = 1, #Textures do
		script.Parent.Decal.Texture = "rbxassetid://"..Textures[i];
		task.wait(Time/#Textures)
	end 
 end