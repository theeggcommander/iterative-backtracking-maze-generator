local elements = script.Parent.Elements -- Or whatever frame is holding your inputs
local requestGenerationEvent = game.ReplicatedStorage.RequestGeneration -- Adjust path to a RemoteEvent that the server listens for

-- Fires on a button press
elements.PassInfo.Activated:Connect(function()
	requestGenerationEvent:FireServer(tonumber(elements.HeightInput.Text), tonumber(elements.WidthInput.Text), tonumber(elements.SeedInput.Text)) -- Pass in height, width, seed, respectively, from your inputs.
end)  

-- If you don't want to make a UI and would just like to test directly from the code: (delete the above)

--[[
local requestGenerationEvent = game.RepliactedStorage.RequestGeneration -- Adjust path

task.wait(2) -- however long you need to load in
requestGenerationEvent:FireServer(20, 20, 1234567) -- Adjust numbers for your own height, width, and seed. None NEED to be filled in to run, so you can just do requestGenerationEvent:FireServer() and be fine
]]
