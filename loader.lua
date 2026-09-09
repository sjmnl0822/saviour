local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
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

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in listfiles(path) do
		if file:find('loader') then continue end
		if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after saviour updates.')) == 1 then
			delfile(file)
		end
	end
end

for _, folder in {'newsaviour', 'newsaviour/games', 'newsaviour/profiles', 'newsaviour/assets', 'newsaviour/libraries', 'newsaviour/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.SaviourDeveloper then
	local _, subbed = pcall(function()
		return game:HttpGet('https://github.com/sjmnl0822/saviour')
	end)

	local assetVer = '1'
	local commit = subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'

	if commit == 'main' or (isfile('newsaviour/profiles/commit.txt') and readfile('newsaviour/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newsaviour')
		wipeFolder('newsaviour/games')
		wipeFolder('newsaviour/guis')
		wipeFolder('newsaviour/libraries')
	end

	if (isfile('newsaviour/profiles/asset.txt') and readfile('newsaviour/profiles/asset.txt') or '') ~= assetVer then
		wipeFolder('newsaviour/assets')
	end

	writefile('newsaviour/profiles/asset.txt', assetVer)
	writefile('newsaviour/profiles/commit.txt', commit)
end

return loadstring(downloadFile('newsaviour/main.lua'), 'main')()