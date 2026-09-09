local saviour = shared.saviour
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and saviour then
		saviour:CreateNotification('Saviour', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
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

saviour.Place = 6872274481
if isfile('newsaviour/games/'..saviour.Place..'.lua') then
	loadstring(readfile('newsaviour/games/'..saviour.Place..'.lua'), 'bedwars')()
else
	if not shared.SaviourDeveloper then
		local success, result = pcall(downloadFile, 'newsaviour/games/'..saviour.Place..'.lua')
		if success and result then
			loadstring(result, 'bedwars')()
		end
	end
end