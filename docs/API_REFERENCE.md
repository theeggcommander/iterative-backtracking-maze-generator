# API_REFERENCE.md

## Package entry 

```lua
local MazePkg = require(path.to.proceduralMaze.src.MazeGenerator)
MazePkg.new(config) 
```
Constructs a new maze generator instance.

## Config fields (defaults):
`Width` (int) — 20

`Height` (int) — 20

`CellSize` (number) — 4

`Seed` (int|nil) — nil (random)

`ChunkSize` (int) — 10

`YieldEvery` (int) — 50

`ParentModel` (Instance) — workspace

`DestroyPrevious` (bool) — true

Returns: a `MazeGenerator` instance.

## MazeGenerator methods
```lua
maze:Generate()
```

Runs the iterative backtracking algorithm and populates internal Grid.

Synchronous from the caller's perspective; internally yields to RunService to avoid timeouts.

Usage: `maze:Generate()`

```lua
maze:Render(parent)
```

Asynchronously renders the previously-generated grid using chunking and rectangular merging.

Returns the created Model (or nil if render failed). If you call while a render is in progress, it returns nil and warns.

Usage: `local model = maze:Render(workspace)`

```lua
maze:SetSeed(seed)
```

Updates the seed manager to use a new seed for the next :Generate().

```lua
maze:GetGrid()
```

Returns the internal grid table (read-only conventionally).

```lua
maze:DestroyPreviousMaze()
```

Destroys the previous maze IF `DestroyPrevious` is true.

For very large mazes (100×100), tune `chunkSize` and `yieldEvery` to your target environment.
