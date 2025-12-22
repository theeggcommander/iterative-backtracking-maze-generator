# INSTALLATION.md

Put the `src/` folder inside your project.

From a server script (ServerScriptService) require the package: `local MazeGenerator = require(game.ServerScriptService.src.MazeGenerator)` (adapt path).

If you want to use a client, connect client-side input from a localscript to the server script you created with a remote event.

In the server script, run `local NewMaze = MazeGenerator.new()` and then `:Generate()` and `:Render()` on the new MazeGenerator instance you created.

Note: Always run generation on the server. The client UI should only request generation.
