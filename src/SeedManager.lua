-- SeedManager.lua
-- Simple deterministic PRNG using mulberry32 (fast, repeatable)
-- Usage: local sm = SeedManager.New(12345); sm:RandomRange(1,10)

local SeedManager = {}
SeedManager.__index = SeedManager

-- mulberry32
local bit32 = bit32

local function imul(a: number, b: number): number
	-- 32-bit integer multiply with wraparound
	return bit32.band(a * b, 0xFFFFFFFF)
end

-- Yeah this is hard to look at if you aren't used to it.
-- As the Roblox AI puts it: "It's a 32-bit LCG (Linear Congruential Generator) with a = 1664525, c = 1013904223, m = 2^32."
-- This uses the mulberry32 algorithm to get a random number based on a certain seed. Inputting the seed again replicates the same value, resulting in the same maze each time.
local function mulberry32(seed: number)
	seed = bit32.band(seed or 0, 0xFFFFFFFF)

	return function(): number
		seed = bit32.band(seed + 0x6D2B79F5, 0xFFFFFFFF)
		local t = seed

		t = imul(bit32.bxor(t, bit32.rshift(t, 15)), bit32.bor(t, 1))
		t = bit32.bxor(t, t + imul(bit32.bxor(t, bit32.rshift(t, 7)), bit32.bor(t, 61)))
		t = bit32.band(t, 0xFFFFFFFF)

		local u = bit32.band(bit32.bxor(t, bit32.rshift(t, 14)), 0xFFFFFFFF)
		return u / 4294967296 -- [0, 1)
	end
end

-- creates a new SeedManager instance based on a certain seed (handles all the functions based on this seed)
function SeedManager.New(seed)
	local self = setmetatable({}, SeedManager)
	seed = bit32.band(math.floor(seed or (tick() * 1000)), 0xFFFFFFFF)
	self._seed = seed
	self._rng = mulberry32(self._seed)
	return self
end

-- sets seed of an existing SeedManager instance
function SeedManager:SetSeed(seed)
	self._seed = bit32.band(seed, 0xFFFFFFFF)
	self._rng = mulberry32(self._seed)
end

-- returns random number based on current seed
function SeedManager:Random()
	return self._rng()
end

-- same as the above but within a range
function SeedManager:RandomRange(a, b)
	a = math.floor(a)
	b = math.floor(b)
	if b < a then a, b = b, a end
	local r = self:Random()
	return a + math.floor(r * (b - a + 1))
end

return SeedManager
