# INSTALLATION.md

Put the `src/` folder inside your project or require it as a module.

From a server script (ServerScriptService) require the package: `local MazeGenerator = require(game.ReplicatedStorage.ProceduralMaze.src.MazeGenerator)` (adapt path).

Place the example client script into `StarterPlayerScripts` and the example server script into `ServerScriptService`.

Create a `RemoteEvent` named `MazeGenerate` inside `ReplicatedStorage` (the example code will create one if missing).

Note: Always run generation on the server for authoritative mazes. The client UI should only request generation.
