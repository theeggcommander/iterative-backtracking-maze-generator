local mazeGenerator = require(game.ServerScriptService.MazeModules.MazeGenerator)

local requestGenerationEvent = game.ReplicatedStorage.RequestGeneration

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
		CellSize = 10,
		WallHeight = 30,
		ChunkSize = 10,
		ParentModel = workspace,
		YieldEvery = 50,
		CanBeDestroyed = true -- setting this to false will prevent maze destruction when a new maze is created
	}
	
	local newMaze = mazeGenerator.New(opts) -- New MazeGenerator instance created
	newMaze:Generate() -- Generate maze
	
	-- Destroys previous maze, commenting this out also disables destruction
	if currentMaze then
		currentMaze:DestroyMaze()
		currentMaze = nil
	end
	
	newMaze:Render() -- Render maze
	
	currentMaze = newMaze
end)
