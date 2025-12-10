local RunService = game:GetService("RunService")
local ChunkRenderer = {}
ChunkRenderer.__index = ChunkRenderer

local DEFAULT_WALL_HEIGHT = 6
local DEFAULT_WALL_THICKNESS = 0.5
local DEFAULT_MATERIAL = Enum.Material.SmoothPlastic
local DEFAULT_COLOR = Color3.fromRGB(40, 40, 40)

function ChunkRenderer.New(mazeGenerator, chunkSize)
	local self = setmetatable({}, ChunkRenderer)
	self.Maze = mazeGenerator
	self.ChunkSize = chunkSize or 10
	self.YieldEvery = self.Maze.YieldEvery or 50
	self.WallHeight = mazeGenerator.WallHeight or DEFAULT_WALL_HEIGHT
	self.Thickness = mazeGenerator.Thickness or DEFAULT_WALL_THICKNESS
	self.Material = mazeGenerator.Material or DEFAULT_MATERIAL
	self.Color = mazeGenerator.Color or DEFAULT_COLOR
	self._renderCoroutine = nil
	return self
end

function ChunkRenderer:_CellCenterPos(x, y)
	local size = self.Maze.CellSize
	local halfW = self.Maze.Width * size / 2
	local halfH = self.Maze.Height * size / 2
	-- x,y input here are grid indices (floats allowed)
	local worldX = (x - 0.5) * size - halfW
	local worldZ = (y - 0.5) * size - halfH
	return Vector3.new(worldX, 0, worldZ)
end

-- creates the walls
local function CreateWallPart(sizeVec, cframe, color, material, parent)
	local p = Instance.new("Part")
	p.Size = sizeVec
	p.Anchored = true
	p.CanCollide = true
	p.Material = material or DEFAULT_MATERIAL
	p.Color = color or DEFAULT_COLOR
	p.CFrame = cframe
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function ChunkRenderer:Render(parent)
	parent = parent or workspace
	-- sanity checks
	if self._renderCoroutine and coroutine.status(self._renderCoroutine) ~= "dead" then
		warn("ChunkRenderer: Render already in progress.")
		return nil
	end

	local model = Instance.new("Model")
	model.Name = ("Maze_%dx%d"):format(self.Maze.Width, self.Maze.Height)
	model.Parent = parent

	local grid = self.Maze:GetGrid()
	if not grid or #grid == 0 then
		warn("ChunkRenderer: No grid data. Generate first.")
		model:Destroy()
		return nil
	end

	local cellSize = self.Maze.CellSize
	local w, h = self.Maze.Width, self.Maze.Height
	local chunkSz = self.ChunkSize
	local createdCount = 0

	local function worker()
		for chunkX = 1, w, chunkSz do
			for chunkY = 1, h, chunkSz do
				local x0 = chunkX
				local x1 = math.min(chunkX + chunkSz - 1, w)
				local y0 = chunkY
				local y1 = math.min(chunkY + chunkSz - 1, h)

				for y = y0, y1 do
					-- north walls
					local runStart = nil
					local runLength = 0
					for x = x0, x1 do
						local cell = grid[x] and grid[x][y]
						local hasWall = cell and cell.walls and cell.walls.N

						if hasWall then
							if not runStart then runStart = x; runLength = 1 else runLength = runLength + 1 end
						else
							if runStart then
								local midX = (runStart + (x - 1)) / 2
								local center = self:_CellCenterPos(midX, y - 0.5) -- Shift Up
								local sizeVec = Vector3.new(runLength * cellSize + self.Thickness, self.WallHeight, self.Thickness)
								local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

								CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
								createdCount = createdCount + 1
								runStart = nil
							end
						end
						if self.YieldEvery > 0 and createdCount % self.YieldEvery == 0 then coroutine.yield() end
					end
					-- flush
					if runStart then
						local midX = (runStart + x1) / 2
						local runLen = (x1 - runStart + 1)
						local center = self:_CellCenterPos(midX, y - 0.5)
						local sizeVec = Vector3.new(runLen * cellSize + self.Thickness, self.WallHeight, self.Thickness)
						local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

						CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
						createdCount = createdCount + 1
						runStart = nil
					end

					-- south walls (for the last row)
					if y == h then
						runStart = nil
						runLength = 0
						for x = x0, x1 do
							local cell = grid[x] and grid[x][y]
							local hasWall = cell and cell.walls and cell.walls.S -- check S wall

							if hasWall then
								if not runStart then runStart = x; runLength = 1 else runLength = runLength + 1 end
							else
								if runStart then
									local midX = (runStart + (x - 1)) / 2
									local center = self:_CellCenterPos(midX, y + 0.5) 
									local sizeVec = Vector3.new(runLength * cellSize + self.Thickness, self.WallHeight, self.Thickness)
									local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

									CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
									createdCount = createdCount + 1
									runStart = nil
								end
							end
							if self.YieldEvery > 0 and createdCount % self.YieldEvery == 0 then coroutine.yield() end
						end
						-- flush
						if runStart then
							local midX = (runStart + x1) / 2
							local runLen = (x1 - runStart + 1)
							local center = self:_CellCenterPos(midX, y + 0.5)
							local sizeVec = Vector3.new(runLen * cellSize + self.Thickness, self.WallHeight, self.Thickness)
							local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

							CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
							createdCount = createdCount + 1
							runStart = nil
						end
					end
				end

				for x = x0, x1 do
					-- west walls
					local runStart = nil
					for y = y0, y1 do
						local cell = grid[x] and grid[x][y]
						local hasWall = cell and cell.walls and cell.walls.W

						if hasWall then
							if not runStart then runStart = y end
						else
							if runStart then
								local midY = (runStart + (y - 1)) / 2
								local center = self:_CellCenterPos(x - 0.5, midY) 
								local sizeVec = Vector3.new(self.Thickness, self.WallHeight, (y - runStart) * cellSize + self.Thickness)
								local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

								CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
								createdCount = createdCount + 1
								runStart = nil
							end
						end
						if self.YieldEvery > 0 and createdCount % self.YieldEvery == 0 then coroutine.yield() end
					end
					-- flush
					if runStart then
						local midY = (runStart + y1) / 2
						local runLen = (y1 - runStart + 1)
						local center = self:_CellCenterPos(x - 0.5, midY)
						local sizeVec = Vector3.new(self.Thickness, self.WallHeight, runLen * cellSize + self.Thickness)
						local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

						CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
						createdCount = createdCount + 1
						runStart = nil
					end

					-- east wall (last only again)
					if x == w then
						runStart = nil
						for y = y0, y1 do
							local cell = grid[x] and grid[x][y]
							local hasWall = cell and cell.walls and cell.walls.E -- check E wall

							if hasWall then
								if not runStart then runStart = y end
							else
								if runStart then
									local midY = (runStart + (y - 1)) / 2
									local center = self:_CellCenterPos(x + 0.5, midY) 
									local sizeVec = Vector3.new(self.Thickness, self.WallHeight, (y - runStart) * cellSize + self.Thickness)
									local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

									CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
									createdCount = createdCount + 1
									runStart = nil
								end
							end
							if self.YieldEvery > 0 and createdCount % self.YieldEvery == 0 then coroutine.yield() end
						end
						-- flush
						if runStart then
							local midY = (runStart + y1) / 2
							local runLen = (y1 - runStart + 1)
							local center = self:_CellCenterPos(x + 0.5, midY)
							local sizeVec = Vector3.new(self.Thickness, self.WallHeight, runLen * cellSize + self.Thickness)
							local cf = CFrame.new(center + Vector3.new(0, self.WallHeight/2, 0))

							CreateWallPart(sizeVec, cf, self.Color, self.Material, model)
							createdCount = createdCount + 1
							runStart = nil
						end
					end
				end

				coroutine.yield()
			end
		end
		return model
	end

	self._renderCoroutine = coroutine.create(worker)
	-- main loop
	while true do
		local status = coroutine.status(self._renderCoroutine)
		if status == "dead" then break end
		local ok, res = coroutine.resume(self._renderCoroutine)
		if not ok then
			warn("ChunkRenderer Error:", res)
			if model then model:Destroy() end
			self._renderCoroutine = nil
			return nil
		end
		if coroutine.status(self._renderCoroutine) == "dead" then break end
		RunService.Heartbeat:Wait()
	end

	self._renderCoroutine = nil
	return model
end

return ChunkRenderer
