# API_REFERENCE.md

## Package entry 

```
local MazePkg = require(path.to.proceduralMaze)
MazePkg.new(config) 
```
Constructs a new maze generator instance.

## Config fields (defaults):
width (int) — 20

height (int) — 20

cellSize (number) — 4

seed (int|nil) — nil (random)

chunkSize (int) — 10

yieldEvery (int) — 50

parentModel (Instance) — where rendered Model will be parented

Returns: a MazeGenerator instance.

## MazeGenerator methods
```
maze:Generate()
```
Runs the iterative backtracking algorithm and populates internal Grid.

Synchronous from the caller's perspective; internally yields to RunService to avoid timeouts.

Usage: maze:Generate()

```
maze:Render(parent)
```
Asynchronously renders the previously-generated grid using chunking and rectangular merging.

Returns the created Model (or nil if render failed). If you call while a render is in progress, it returns nil and warns.

Usage: local model = maze:Render(workspace)

```
maze:SetSeed(seed)
```
Updates the seed manager to use a new seed for the next :Generate().

```
maze:GetGrid()
```
Returns the internal grid table (read-only conventionally).

## Implementation caveats & tips

For very large mazes (100×100), tune chunkSize and yieldEvery to your target environment.

Consider disabling collisions during heavy creation and enabling after any union step to improve performance.

If you intend to export mazes to meshes or save to Datastore, add a mesh-exporter utility that converts the final union into a mesh.
