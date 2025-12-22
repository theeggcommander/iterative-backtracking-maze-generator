local mazeGenerator = require(game.ServerScriptService.MazeModules.MazeGenerator) -- Adjust path to the MazeGenerator module

local requestGenerationEvent = game.ReplicatedStorage.RequestGeneration -- Path to RemoteEvent connecting client and server

local function checkIfNum(x: any): number | false
	if typeof(x) == "number" then return x end
	local nx = tonumber(x)
	if typeof(nx) == "number" then return nx end
	return false
end

local currentMaze

requestGenerationEvent.OnServerEvent:Connect(function(_, h, w, s) -- Height, width, seed
	h = checkIfNum(h)
	if not h then h = 20 end
	w = checkIfNum(w)
	if not w then w = 20 end
	s = checkIfNum(s)
	if not s then s = tick() * 1000 end
	
	
	local opts = {
		Height = h,
		Width = w,
		Seed = s,
		-- defaults
		ChunkSize = 10,
		ParentModel = workspace,
		YieldEvery = 50,
		DestroyPrevious = true -- setting this to false will prevent maze destruction
	}
	
	local newMaze = mazeGenerator.New(opts) -- New MazeGenerator instance created
	newMaze:Generate() -- Generate maze
	
	-- Destroys previous maze, commenting this out also disables destruction
	if currentMaze then
		currentMaze = nil
		newMaze:DestroyPreviousMaze()
	end
	
	newMaze:Render() -- Render maze
	
	currentMaze = newMaze
end)
