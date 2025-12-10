# iterative-backtracking-maze-generator
Version 1.0.0

**Short pitch:** A fast, server-friendly procedural maze generator for Roblox games. Generates reproducible mazes via seed, scales to 100×100 cells, and uses chunked asynchronous rendering with rectangular merging.

## Features
- Iterative backtracking (stack-based) — avoids recursion limits
- Seeded PRNG for reproducible results
- Coroutine-stepped generation (yield every N cells)
- Chunked renderer with run-length wall merging to reduce part count
- Configurable: cell size, chunk size, wall thickness, material, color
- Simple API: `:Generate()` and `:Render()`

## Quick demo
1. Open `example/` in this repo.
2. Place `SimpleDemoController.server.lua` in `ServerScriptService`.
3. Place `DemoGui.client.lua` in `StarterPlayerScripts` (or `StarterGui` as a LocalScript).
4. Play in Studio and use the UI to adjust settings and generate a maze.

## Installation
See `INSTALLATION.md` for exact steps.

## Usage example
```lua
local MazePkg = require(path.to.MazeGenerator.src.init)
local maze = MazePkg.new({ width = 50, height = 50, cellSize = 6, seed = 12345, chunkSize = 10 })
maze:Generate()
maze:Render(workspace)
```

## Configuration options
width (int) — cells horizontally. Default: 20

height (int) — cells vertically. Default: 20

cellSize (float) — studs per cell. Default: 4

seed (int) — reproducible seed. Default: random

chunkSize (int) — cells per chunk for renderer. Default: 10

yieldEvery (int) — generator/renderer yield frequency. Default: 50

## License
MIT — see LICENSE file.

## Contact / Credits
Packaged by TheEggCommander — https://x.com/TheEggCommander 
https://www.youtube.com/@TheEggCommander 
https://github.com/theeggcommander 
