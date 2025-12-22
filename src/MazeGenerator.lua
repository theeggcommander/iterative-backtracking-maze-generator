local RunService = game:GetService("RunService")

local MazeGenerator = {}
MazeGenerator.__index = MazeGenerator

-- Requires (assumes same folder / sibling ModuleScripts)
local moduleFolder = script.Parent -- you may parent sibling modules to this script, just adjust this to say script only
local ChunkRenderer = require(moduleFolder:FindFirstChild("ChunkRenderer") or moduleFolder.ChunkRenderer)
local SeedManager = require(moduleFolder:FindFirstChild("SeedManager") or moduleFolder.SeedManager)

local mazeFolder = Instance.new("Folder", workspace)
mazeFolder.Name = "MazeFolder"
game:GetService("CollectionService"):AddTag(mazeFolder, "MazeFolder")

-- Constructor
function MazeGenerator.New(opts)
	opts = opts or {}
	local self = setmetatable({}, MazeGenerator)

	self.Width = opts.Width or 20         -- cells
	self.Height = opts.Height or 20       -- cells

	self.CellSize = opts.CellSize or 10    -- studs per cell
	self.WallHeight = opts.WallHeight or 30
	self.Seed = opts.Seed or tick() * 1000
	self.SeedManager = SeedManager.New(self.Seed)
	self.Grid = {}        -- 2D table: visited & walls representation
	self.ProcessedCells = 0
	self._generateCoroutine = nil
	self._chunkRenderer = ChunkRenderer.New(self, opts.ChunkSize or 10) -- chunk size in cells
	self.ParentModel = opts.ParentModel or mazeFolder -- where to parent visual model (renderer controls this)

	-- Performance flags
	self.YieldEvery = opts.YieldEvery or 50 -- yield every N processed cells (as requested)
	self.CanBeDestroyed = opts.CanBeDestroyed or true -- allows maze to be destroyed when a new one is created
	--self.UseUnionIfAvailable = opts.UseUnionIfAvailable == nil and true or opts.UseUnionIfAvailable

	return self
end

-- Initialize grid
function MazeGenerator:_InitGrid()
	local w, h = self.Width, self.Height
	self.Grid = {}
	
	for x = 1, w do
		self.Grid[x] = {}
		for y = 1, h do
			-- walls: true means wall exists (we'll treat walls as between cells). For generation we'll track visited.
			self.Grid[x][y] = {
				visited = false,
				-- we'll later treat edges: we'll store which walls are removed by connecting cells
				walls = {N = true, S = true, E = true, W = true}
			}
		end
	end
	self.ProcessedCells = 0
end

-- Internal helper to in-bounds check
function MazeGenerator:_InBounds(x, y)
	return x >= 1 and x <= self.Width and y >= 1 and y <= self.Height
end

-- get unvisited neighbors returns list of {x,y,dir,opposite}
local DIRS = {
	{dx=0, dy=-1, dir="N", opp="S"},
	{dx=1, dy=0, dir="E", opp="W"},
	{dx=0, dy=1, dir="S", opp="N"},
	{dx=-1, dy=0, dir="W", opp="E"}
}

-- Generate the maze data using an iterative stack-based version of recursive backtracking.
-- It uses a coroutine internally that yields every self.YieldEvery processed cells.
-- This function will run the coroutine to completion but will yield to RunService.Heartbeat between chunks.
function MazeGenerator:Generate()
	self:_InitGrid()

	-- the worker coroutine
	local function worker()
		local sm = self.SeedManager
		local stack = {}
		local startX = sm:RandomRange(1, self.Width)
		local startY = sm:RandomRange(1, self.Height) -- random start cell

		self.Grid[startX][startY].visited = true
		table.insert(stack, {x = startX, y = startY}) -- add to stack for reference later

		local processedSinceYield = 0

		while #stack > 0 do
			local top = stack[#stack]
			local x, y = top.x, top.y

			-- collect unvisited neighbors
			local neighbors = {}
			for _, d in ipairs(DIRS) do
				local nx, ny = x + d.dx, y + d.dy
				if self:_InBounds(nx, ny) and not self.Grid[nx][ny].visited then
					table.insert(neighbors, {x = nx, y = ny, dir = d.dir, opp = d.opp})
				end
			end

			if #neighbors > 0 then
				-- choose random neighbor
				local pick = neighbors[sm:RandomRange(1, #neighbors)]
				-- remove walls between current and neighbor
				self.Grid[x][y].walls[pick.dir] = false
				self.Grid[pick.x][pick.y].walls[pick.opp] = false

				-- mark neighbor visited and push to stack
				self.Grid[pick.x][pick.y].visited = true
				table.insert(stack, {x = pick.x, y = pick.y})

				self.ProcessedCells = self.ProcessedCells + 1
				processedSinceYield = processedSinceYield + 1

				if processedSinceYield >= self.YieldEvery then
					processedSinceYield = 0
					coroutine.yield("yield") -- yield back to driver
				end
			else
				-- backtrack
				table.remove(stack)
				-- count backtracking as processed for fairness (optional)
				self.ProcessedCells = self.ProcessedCells + 1
				processedSinceYield = processedSinceYield + 1
				if processedSinceYield >= self.YieldEvery then
					processedSinceYield = 0
					coroutine.yield("yield")
				end
			end
		end
	end

	-- create coroutine and drive it to completion, stepping with Heartbeat to prevent blocking
	self._generateCoroutine = coroutine.create(worker)

	-- run until done
	while true do
		local ok, res = coroutine.resume(self._generateCoroutine)
		if not ok then
			warn("MazeGenerator: error during generation:", res)
			break
		end
		if coroutine.status(self._generateCoroutine) == "dead" then
			break
		end
		-- wait until next heartbeat before resuming so the server doesn't lock
		RunService.Heartbeat:Wait()
	end

	-- generation finished
	return true
end

-- Render function: delegates to chunk renderer
-- :Render(parentModel) - optional parentModel overrides configured ParentModel
function MazeGenerator:Render(parentModel)
	parentModel = parentModel or self.ParentModel
	return self._chunkRenderer:Render(parentModel)
end

-- Utility to get the grid (read-only recommended)
function MazeGenerator:GetGrid()
	return self.Grid
end

-- Utility to set seed
function MazeGenerator:SetSeed(seed)
	self.Seed = seed
	self.SeedManager:SetSeed(seed)
end

-- Utility to destroy the current maze
function MazeGenerator:DestroyMaze()
	if not self.CanBeDestroyed then return end
	self.ParentModel:FindFirstChild(("Maze_%dx%d"):format(self.Width, self.Height)):Destroy()
end

return MazeGenerator
