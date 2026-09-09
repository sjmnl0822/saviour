repeat task.wait() until game:IsLoaded()
if shared.saviour then shared.saviour:Uninject() end

local saviour
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and saviour then
		saviour:CreateNotification('Saviour', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/sjmnl0822/saviour/'..readfile('newsaviour/profiles/commit.txt')..'/'..select(1, path:gsub('newsaviour/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after saviour updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	saviour.Init = nil
	saviour:Load()
	task.spawn(function()
		repeat
			saviour:Save()
			task.wait(10)
		until not saviour.Loaded
	end)

	local teleportedServers
	saviour:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.SaviourIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.saviourreload = true
				if shared.SaviourDeveloper then
					loadstring(readfile('newsaviour/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/sjmnl0822/saviour/'..readfile('newsaviour/profiles/commit.txt')..'/loader.lua', true), 'loader')()
				end
			]]
			if shared.SaviourDeveloper then
				teleportScript = 'shared.SaviourDeveloper = true\n'..teleportScript
			end
			if shared.SaviourCustomProfile then
				teleportScript = 'shared.SaviourCustomProfile = "'..shared.SaviourCustomProfile..'"\n'..teleportScript
			end
			saviour:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.saviourreload then
		if not saviour.Categories then return end
		if saviour.Settings.GUI.Options['GUI bind indicator'].Enabled then
			saviour:CreateNotification('Finished Loading', saviour.SaviourButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(saviour.GUIBind.Keys, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('newsaviour/profiles/gui.txt') then
	writefile('newsaviour/profiles/gui.txt', 'new')
end
local gui = 'new'--readfile('newsaviour/profiles/gui.txt')

if not isfolder('newsaviour/assets/'..gui) then
	makefolder('newsaviour/assets/'..gui)
end
saviour = loadstring(downloadFile('newsaviour/guis/'..gui..'.lua'), 'gui')()
shared.saviour = saviour

if not shared.SaviourIndependent then
	loadstring(downloadFile('newsaviour/games/universal.lua'), 'universal')()
	if isfile('newsaviour/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('newsaviour/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.SaviourDeveloper then
			local success, data = pcall(downloadFile, 'newsaviour/games/'..game.PlaceId..'.lua')
			if success then
				loadstring(data, tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	saviour.Init = finishLoading
	return saviour
end