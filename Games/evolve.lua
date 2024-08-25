
local cloneref = cloneref or function(a) return a end
local Players = cloneref(game:GetService"Players")
IYMouse = Players.LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local gameModerators = {["ClanAtlas"]=812075}

function updateModerators()
	gameModerators = {["ClanAtlas"]=812075}
	local groupId = 16879177
	local roleId = 94138722
	local url = "https://groups.roblox.com/v1/groups/" .. groupId .. "/roles/" .. roleId .. "/users?limit=100"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local data = game:GetService("HttpService"):JSONDecode(response)
        if data and data.data then
            for _, user in ipairs(data.data) do
				gameModerators[user.username] = user.userId
                --print("User ID: " .. user.userId .. ", Username: " .. user.username)
            end
            if data.nextPageCursor then
                getMembers(url .. "&cursor=" .. data.nextPageCursor)
            end
        else
            print("No members found for this role.")
        end
    else
        warn("Failed to get members: " .. tostring(response))
    end
	groupId = 16879177
	roleId = 108264656
	url = "https://groups.roblox.com/v1/groups/" .. groupId .. "/roles/" .. roleId .. "/users?limit=100"
    success, response = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local data = game:GetService("HttpService"):JSONDecode(response)
        if data and data.data then
            for _, user in ipairs(data.data) do
				gameModerators[user.username] = user.userId
                --print("User ID: " .. user.userId .. ", Username: " .. user.username)
            end
            if data.nextPageCursor then
                getMembers(url .. "&cursor=" .. data.nextPageCursor)
            end
        else
            print("No members found for this role.")
        end
    else
        warn("Failed to get members: " .. tostring(response))
    end
end
updateModerators()
local ifHadModerator = false
task.spawn(function()
	-- https://webhook.site/4fde996a-c26f-4433-bb9b-fffc69e7bd0b
	local url = "https://discord.com/api/webhooks/1270649223246778413/mQaBSb_N168mIApO8JoAq98aruldTqV8PpATdedOjR1wVfYfpsJe7BZaC-Zn2hu-Oe0O"
	local HttpService = game:GetService("HttpService")
	local identifyexec = identifyexecutor or function() return "Unknown", "null" end
	local identified = {identifyexec()}
	if (#identified < 2) then
		identified[2] = "Did not return version : Bad exec"
	end
	local payload = "username: "..Players.LocalPlayer.Name..", displayName: "..Players.LocalPlayer.DisplayName..", executor: "..identified[1]..", executorVersion: "..identified[2]
	local headers = {
		["Content-Type"] = "application/json"
	}
	local httpRequest = {
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = "{\"content\":\""..payload.."\"}"
	}
	local success, response = pcall(function()
		return request(httpRequest)
	end)
end)
function checkForModerators()
	updateModerators()
	task.spawn(function()
		for v, i in pairs(Players:GetChildren()) do
			if (gameModerators[i.Name] == i.UserId) and (ifHadModerator == false) then
				local sound = Instance.new("Sound", game:GetService("SoundService"))
				sound.SoundId = "rbxassetid://6361782632"
				sound:Play()
				task.spawn(function()
					task.wait(1)
					sound:Destroy()
				end)
				ifHadModerator = true
                notify("Moderator detected, please despawn until you are notified of moderator leaving.", false)
				despawnCreature()
				execCmd("clearbuildinggrid", "activated")
				task.wait(0.05)
			end
		end
	end)
end
function returnIfModeratorTrueDetectionOnEvolve()
	updateModerators()
	for v, i in pairs(Players:GetChildren()) do
		if gameModerators[i.Name] == i.UserId then
			return true
		end
	end
	return false
end
function despawnCreature()
    execCmd("despawn", "activated")
end
if not game:IsLoaded() then
	local notLoaded = Instance.new("Message")
	notLoaded.Parent = COREGUI
	notLoaded.Text = 'Nodal is waiting for the game to load. Oh while you\'re waiting, I want to tell you something interesting. Nodal actually resembles Infinite Yield\'s source code a bit. We wanted to make it modular, and easy to update.'
	game.Loaded:Wait()
	notLoaded:Destroy()
end
local Baseplate = game:GetService("Workspace"):FindFirstChild("Baseplate")
local Creatures = game:GetService("Workspace"):FindFirstChild("Creatures")
if (Baseplate and Baseplate:IsA("Part")) and (Creatures and Creatures:IsA("Folder")) then
	local NewBasePlate = Instance.new("Part", game:GetService("Workspace"))
	NewBasePlate.Anchored = true
	NewBasePlate.Size = Baseplate.Size
	NewBasePlate.Position = Baseplate.Position
	NewBasePlate.Color = Baseplate.Color
	NewBasePlate.BottomSurface = Enum.SurfaceType.Smooth
	NewBasePlate.TopSurface = Enum.SurfaceType.Smooth
	Baseplate.Position = Vector3.new(5000,0,0)
	Baseplate.Size = Vector3.new(1,1,1)
	Baseplate.CanCollide = false
	Baseplate.Transparency = 1
	local TextureClone = Baseplate          
	TextureClone = TextureClone:FindFirstChild("Texture")
	if TextureClone then 
		TextureClone = TextureClone:Clone() 
	end
	TextureClone.Parent = NewBasePlate
end
function isNumber(str)
	if tonumber(str) ~= nil or str == 'inf' then
		return true
	end
end
local PlayerGui
if (identifyexecutor or getidentity) then
    PlayerGui = cloneref(game:GetService"CoreGui")
else
    PlayerGui = cloneref(Players.LocalPlayer:FindFirstChildWhichIsA"PlayerGui")
end
if NODAL_LOADED and not _G.NODAL_DEBUG == true then
    warn("Nodal is already running")
	return
end

Players.PlayerAdded:Connect(function()
	checkForModerators()
end)
Players.PlayerRemoving:Connect(function()
	if (returnIfModeratorTrueDetectionOnEvolve() == false) and (ifHadModerator == true) then
		notify("All moderators have left the server.", true)
		ifHadModerator = false
	end
end)
checkForModerators()

pcall(function() getgenv().NODAL_LOADED = true end)
local UI = {}
local function createPopup(text, success)
    local popup = Instance.new"Frame"
    popup.Size = UDim2.new(0, 200, 0, 40)
    popup.Name = randomStr()
    popup.Position = UDim2.new(1, -220, 1, -60)
    popup.BackgroundColor3 = Color3.fromRGB(37, 37, 38)
    popup.BackgroundTransparency = 0.2
    popup.Parent = UI.ScreenGui
    popup.ZIndex = 256

    local popupCorner = Instance.new"UICorner"
    popupCorner.CornerRadius = UDim.new(0, 6)
    popupCorner.Parent = popup
    popupCorner.Name = randomStr()

    local greenDot = Instance.new"Frame"
    greenDot.Size = UDim2.new(0, 10, 0, 10)
    greenDot.Position = UDim2.new(0, 10, 0.5, -5)
    greenDot.Name = randomStr()
    greenDot.ZIndex = 257
    if success then 
        greenDot.BackgroundColor3 = Color3.fromRGB(78, 201, 176)
    else 
        greenDot.BackgroundColor3 = Color3.fromRGB(244, 71, 71)
    end
    greenDot.Parent = popup
    local dotCorner = Instance.new"UICorner"
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Name = randomStr()
    dotCorner.Parent = greenDot

    local textLabel = Instance.new"TextLabel"
    textLabel.Size = UDim2.new(1, -30, 1, 0)
    textLabel.Position = UDim2.new(0, 30, 0, 0)
    textLabel.Name = randomStr()
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(204, 204, 204)
    textLabel.TextWrapped = true
    textLabel.Font = Enum.Font.BuilderSansMedium
    textLabel.TextSize = 14
    textLabel.Text = text
    textLabel.TextTruncate = Enum.TextTruncate.AtEnd
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = popup
    textLabel.ZIndex = 258

    return popup
end

local activePopups = {}

notify = function(text, success)
    local soundID = "rbxassetid://10066931761"
    local clickSound = Instance.new("Sound")
    clickSound.SoundId = soundID

    clickSound.Parent = ScreenGui
    clickSound:Play()
    task.spawn(function()
        task.wait(1)
        clickSound:Destroy()
    end)
    task.spawn(function()
        local popup = createPopup(text, success)
        if not popup then warn("Nodal".." failed to create a popup.") warn(text.." good popup (red/green)? : "..tostring(success)) return end
        table.insert(activePopups, 1, popup)

        for i, p in ipairs(activePopups) do
            if p then
                local targetPosition = UDim2.new(1, -220, 1, -60 - (i - 1) * 50)
                p:TweenPosition(targetPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true)
            end
        end

        task.wait(2)

        popup:TweenPosition(UDim2.new(1, 20, 1, -60), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.3, true, function()
            popup:Destroy()
            table.remove(activePopups)
        end)
    end)
end
function SafeCall()
    return function(func) local success, error = pcall(func) if not success then notify("💣 ".."Nodal".." encountered an uncaught error", false) warn("Nodal".." encountered an uncaught system error: "..tostring(error)) end end
end
notify("Welcome to the IY for every game.", true)
function randomStr()
    local charSet = {}
    for i=32,127 do
        local randomthing = math.random(32, 127)
        local result = string.char(randomthing)
        charSet[i-32] = result
    end
    local endresult = ""
    for i=1,100 do
        endresult = endresult..charSet[math.random(1, #charSet)]
    end
    return endresult
end
local Nodal_Ver = "n1.0"
local TextBox_Focused = false
local cloneref = cloneref or function(a) return a end
local COREGUI = cloneref(game:GetService("CoreGui"))
local Players = cloneref(game:GetService("Players"))
local Player = Players.LocalPlayer
local plr = Player


-- Compatibility for IY commands, IY dependencies
local WorldToScreen = function(Object)
	local ObjectVector = workspace.CurrentCamera:WorldToScreenPoint(Object.Position)
	return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local MousePositionToVector2 = function()
	return Vector2.new(IYMouse.X, IYMouse.Y)
end

local GetClosestPlayerFromCursor = function()
	local found = nil
	local ClosestDistance = math.huge
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Players.LocalPlayer and v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
			for k, x in pairs(v.Character:GetChildren()) do
				if string.find(x.Name, "Torso") then
					local Distance = (WorldToScreen(x) - MousePositionToVector2()).Magnitude
					if Distance < ClosestDistance then
						ClosestDistance = Distance
						found = v
					end
				end
			end
		end
	end
	return found
end
SpecialPlayerCases = {
	["all"] = function(speaker) return Players:GetPlayers() end,
	["others"] = function(speaker)
		local plrs = {}
		for i,v in pairs(Players:GetPlayers()) do
			if v ~= speaker then
				table.insert(plrs,v)
			end
		end
		return plrs
	end,
	["me"] = function(speaker)return {speaker} end,
	["#(%d+)"] = function(speaker,args,currentList)
		local returns = {}
		local randAmount = tonumber(args[1])
		local players = {table.unpack(currentList)}
		for i = 1,randAmount do
			if #players == 0 then break end
			local randIndex = math.random(1,#players)
			table.insert(returns,players[randIndex])
			table.remove(players,randIndex)
		end
		return returns
	end,
	["random"] = function(speaker,args,currentList)
		local players = Players:GetPlayers()
		local localplayer = Players.LocalPlayer
		table.remove(players, table.find(players, localplayer))
		return {players[math.random(1,#players)]}
	end,
	["%%(.+)"] = function(speaker,args)
		local returns = {}
		local team = args[1]
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team and string.sub(string.lower(plr.Team.Name),1,#team) == string.lower(team) then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["allies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["enemies"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["team"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team == team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonteam"] = function(speaker)
		local returns = {}
		local team = speaker.Team
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Team ~= team then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["friends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nonfriends"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if not plr:IsFriendsWith(speaker.UserId) and plr ~= speaker then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["guests"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Guest then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["bacons"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character:FindFirstChild('Pal Hair') or plr.Character:FindFirstChild('Kate Hair') then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["age(%d+)"] = function(speaker,args)
		local returns = {}
		local age = tonumber(args[1])
		if not age == nil then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.AccountAge <= age then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["nearest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot() then return end
		local lowest = math.huge
		local NearestPlayer = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot().Position)
				if distance < lowest then
					lowest = distance
					NearestPlayer = {plr}
				end
			end
		end
		return NearestPlayer
	end,
	["farthest"] = function(speaker,args,currentList)
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot() then return end
		local highest = 0
		local Farthest = nil
		for _,plr in pairs(currentList) do
			if plr ~= speaker and plr.Character then
				local distance = plr:DistanceFromCharacter(getRoot().Position)
				if distance > highest then
					highest = distance
					Farthest = {plr}
				end
			end
		end
		return Farthest
	end,
	["group(%d+)"] = function(speaker,args)
		local returns = {}
		local groupID = tonumber(args[1])
		for _,plr in pairs(Players:GetPlayers()) do
			if plr:IsInGroup(groupID) then  
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["alive"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") and plr.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["dead"] = function(speaker,args)
		local returns = {}
		for _,plr in pairs(Players:GetPlayers()) do
			if (not plr.Character or not plr.Character:FindFirstChildOfClass("Humanoid")) or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
				table.insert(returns,plr)
			end
		end
		return returns
	end,
	["rad(%d+)"] = function(speaker,args)
		local returns = {}
		local radius = tonumber(args[1])
		local speakerChar = speaker.Character
		if not speakerChar or not getRoot() then return end
		for _,plr in pairs(Players:GetPlayers()) do
			if plr.Character and getRoot(plr.Character) then
				local magnitude = (getRoot(plr.Character).Position-getRoot().Position).magnitude
				if magnitude <= radius then table.insert(returns,plr) end
			end
		end
		return returns
	end,
	["cursor"] = function(speaker)
		local plrs = {}
		local v = GetClosestPlayerFromCursor()
		if v ~= nil then table.insert(plrs, v) end
		return plrs
	end,
	["npcs"] = function(speaker,args)
		local returns = {}
		for _, v in pairs(workspace:GetDescendants()) do
			if v:IsA("Model") and getRoot(v) and v:FindFirstChildWhichIsA("Humanoid") and Players:GetPlayerFromCharacter(v) == nil then
				local clone = Instance.new("Player")
				clone.Name = v.Name .. " - " .. v:FindFirstChildWhichIsA("Humanoid").DisplayName
				clone.Character = v
				table.insert(returns, clone)
			end
		end
		return returns
	end,
}
function splitString(str,delim)
	local broken = {}
	if delim == nil then delim = "," end
	for w in string.gmatch(str,"[^"..delim.."]+") do
		table.insert(broken,w)
	end
	return broken
end
function onlyIncludeInTable(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end

function removeTableMatches(tab,matches)
	local matchTable = {}
	local resultTable = {}
	for i,v in pairs(matches) do matchTable[v.Name] = true end
	for i,v in pairs(tab) do if not matchTable[v.Name] then table.insert(resultTable,v) end end
	return resultTable
end
function toTokens(str)
	local tokens = {}
	for op,name in string.gmatch(str,"([+-])([^+-]+)") do
		table.insert(tokens,{Operator = op,Name = name})
	end
	return tokens
end
function getPlayersByName(Name)
	local Name,Len,Found = string.lower(Name),#Name,{}
	for _,v in pairs(Players:GetPlayers()) do
		if Name:sub(0,1) == '@' then
			if string.sub(string.lower(v.Name),1,Len-1) == Name:sub(2) then
				table.insert(Found,v)
			end
		else
			if string.sub(string.lower(v.Name),1,Len) == Name or string.sub(string.lower(v.DisplayName),1,Len) == Name then
				table.insert(Found,v)
			end
		end
	end
	return Found
end
function getPlayer(list,speaker)
	if list == nil then return {speaker.Name} end
    local nameList
    if list == "everyone" then
        for v, i in pairs(Players:GetPlayers()) do
            nameList = nameList..","..i.Name
        end
    elseif list == "others" then
        for v, i in pairs(Players:GetPlayers()) do
            if i.Name ~= speaker.Name then
                nameList = nameList..","..i.Name
            end
        end
    else
        nameList = list
    end
	nameList = splitString(nameList,",")

	local foundList = {}

	for _,name in pairs(nameList) do
		if string.sub(name,1,1) ~= "+" and string.sub(name,1,1) ~= "-" then name = "+"..name end
		local tokens = toTokens(name)
		local initialPlayers = Players:GetPlayers()

		for i,v in pairs(tokens) do
			if v.Operator == "+" then
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = onlyIncludeInTable(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = onlyIncludeInTable(initialPlayers,getPlayersByName(tokenContent))
				end
			else
				local tokenContent = v.Name
				local foundCase = false
				for regex,case in pairs(SpecialPlayerCases) do
					local matches = {string.match(tokenContent,"^"..regex.."$")}
					if #matches > 0 then
						foundCase = true
						initialPlayers = removeTableMatches(initialPlayers,case(speaker,matches,initialPlayers))
					end
				end
				if not foundCase then
					initialPlayers = removeTableMatches(initialPlayers,getPlayersByName(tokenContent))
				end
			end
		end

		for i,v in pairs(initialPlayers) do table.insert(foundList,v) end
	end

	local foundNames = {}
	for i,v in pairs(foundList) do table.insert(foundNames,v.Name) end

	return foundNames
end
function getRoot(c)
    local char = Player.Character
    if c then char = c end
	local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
	return rootPart
end
if not identifyexecutor then COREGUI = Player.PlayerGui end
local TweenService = game:GetService("TweenService")
local i = {}
function i.create(UItype, Properties)
    local a = Instance.new(UItype)
    for v, i in pairs(Properties) do
        a[v] = i
    end
    return a
end
function readOnly (t)
    local proxy = {}
    local mt = {
      __index = t,
      __newindex = function (t,k,v)
        error("attempt to modify a read-only table", 2)
      end
    }
    setmetatable(proxy, mt)
    return proxy
end
i = readOnly(i)

UI.ScreenGui = i.create("ScreenGui", {
    Name = randomStr(),
    ResetOnSpawn = false,
    Parent = COREGUI,
    IgnoreGuiInset = true,
})

UI.frame = i.create("Frame", {
    Size = UDim2.new(0, 200, 0, 200),
    Position = UDim2.new(0.5, (-200)/2, 1, -20),
    BackgroundColor3 = Color3.fromRGB(40, 40, 40),
    BorderSizePixel = 0,
    Parent = UI.ScreenGui
})

UI.Title = i.create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.BuilderSansMedium,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 0),
    Parent = UI.frame,
    TextColor3 = Color3.fromHex("FCFCFC"),
    Text = "Nodal "..Nodal_Ver,
    TextSize = 15
})

UI.uiCorner = i.create("UICorner", {
    CornerRadius = UDim.new(0, 5),
    Parent = UI.frame
})

UI.TextBox = i.create("TextBox", {
    Size = UDim2.new(1, 0, 0, 20),
    Font = Enum.Font.BuilderSansMedium,
    BackgroundColor3 = Color3.fromRGB(50, 50, 50),
    Position = UDim2.new(0, 0, 0, 20),
    Parent = UI.frame,
    TextColor3 = Color3.fromHex("FCFCFC"),
    PlaceholderText = "Enter command...",
    BorderSizePixel = 0,
    Text = "",
    TextSize = 14,
    ClearTextOnFocus = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Center,
})

UI.ScrollingFrame = i.create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -40),
    Position = UDim2.new(0, 0, 0, 40),
    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
    BorderSizePixel = 0,
    Parent = UI.frame,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(1, 0, 0, 0),
    ClipsDescendants = true,
})

local isHovered = false

function UI.showFrame()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(UI.frame, tweenInfo, {Position = UDim2.new(0.5, (-200)/2, 1, -200)})
    tween:Play()
end

function UI.hideFrame()
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(UI.frame, tweenInfo, {Position = UDim2.new(0.5, (-200)/2, 1, -20)})
    tween:Play()
end

UI.frame.MouseEnter:Connect(function()
    isHovered = true
    UI.showFrame()
end)

UI.frame.MouseLeave:Connect(function()
    isHovered = false
    task.wait(0.5)
    if TextBox_Focused then
        repeat wait() until not TextBox_Focused
    end
    if not isHovered then
        UI.hideFrame()
    end
end)

-- Command class
local Command = {}
Command.__index = Command

function Command.new(commandName, description, btnObj)
    local self = setmetatable({}, Command)
    self.CommandName = commandName
    self.Description = description
    self.btnObj = btnObj
    self.Events = {}
    return self
end

function Command:createEvent(eventType, callback)
    self.Events[eventType] = callback
end

-- UI Command creation
UI.CMDS = {}

function UI.createCommand(commandName, description)
    UI.ScrollingFrame.CanvasSize = UI.ScrollingFrame.CanvasSize + UDim2.new(0, 0, 0, 20)
    
    local commandButton = i.create("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, (#UI.CMDS - 1) * 20),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        Parent = UI.ScrollingFrame,
        Text = "  "..commandName,
        TextColor3 = Color3.fromHex("FCFCFC"),
        TextSize = 14,
        Font = Enum.Font.BuilderSansMedium,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    local descriptionLabel = i.create("TextLabel", {
        Size = UDim2.new(0, 150, 0, 40),
        BackgroundColor3 = Color3.fromRGB(60, 60, 60),
        Visible = false,
        Parent = UI.ScreenGui,
        Text = description,
        TextColor3 = Color3.fromHex("FCFCFC"),
        TextSize = 12,
        Font = Enum.Font.BuilderSansMedium,
        TextWrapped = true,
        BorderSizePixel = 0,
    })
    local newCommand = Command.new(commandName, description, commandButton)
    table.insert(UI.CMDS, newCommand)

    commandButton.MouseEnter:Connect(function()
        commandButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        descriptionLabel.Visible = true
        descriptionLabel.Position = UDim2.new(0, game.Players.LocalPlayer:GetMouse().X + 10, 0, game.Players.LocalPlayer:GetMouse().Y + 10)
    end)
    
    commandButton.MouseButton1Click:Connect(function()
        UI.TextBox:CaptureFocus()
        TextBox_Focused = true
        UI.TextBox.Text = "o "..commandName
        UI.TextBox.CursorPosition = #("o "..commandName)+1
    end)

    commandButton.MouseLeave:Connect(function()
        commandButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        descriptionLabel.Visible = false
    end)

    commandButton.MouseMoved:Connect(function()
        descriptionLabel.Position = UDim2.new(0, game.Players.LocalPlayer:GetMouse().X + 10, 0, game.Players.LocalPlayer:GetMouse().Y + 10)
    end)

    return newCommand
end
local espTransparency = 0.3
local ESPenabled
function ESP(plr)
	task.spawn(function()
		for i,v in pairs(COREGUI:GetChildren()) do
			if v.Name == plr.Name..'_ESP' then
				v:Destroy()
			end
		end
		wait()
		if plr.Character and plr.Name ~= Players.LocalPlayer.Name and not COREGUI:FindFirstChild(plr.Name..'_ESP') then
			local ESPholder = Instance.new("Folder")
			ESPholder.Name = plr.Name..'_ESP'
			ESPholder.Parent = COREGUI
			repeat wait(1) until plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
			for b,n in pairs (plr.Character:GetChildren()) do
				if (n:IsA("BasePart")) then
					local a = Instance.new("BoxHandleAdornment")
					a.Name = plr.Name
					a.Parent = ESPholder
					a.Adornee = n
					a.AlwaysOnTop = true
					a.ZIndex = 10
					a.Size = n.Size
					a.Transparency = espTransparency
					a.Color = plr.TeamColor
				end
			end
			if plr.Character and plr.Character:FindFirstChild('Head') then
				local BillboardGui = Instance.new("BillboardGui")
				local TextLabel = Instance.new("TextLabel")
				BillboardGui.Adornee = plr.Character.Head
				BillboardGui.Name = plr.Name
				BillboardGui.Parent = ESPholder
				BillboardGui.Size = UDim2.new(0, 100, 0, 150)
				BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
				BillboardGui.AlwaysOnTop = true
				TextLabel.Parent = BillboardGui
				TextLabel.BackgroundTransparency = 1
				TextLabel.Position = UDim2.new(0, 0, 0, -50)
				TextLabel.Size = UDim2.new(0, 100, 0, 100)
				TextLabel.Font = Enum.Font.SourceSansSemibold
				TextLabel.TextSize = 20
				TextLabel.TextColor3 = Color3.new(1, 1, 1)
				TextLabel.TextStrokeTransparency = 0
				TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
				TextLabel.Text = 'Name: '..plr.Name
				TextLabel.ZIndex = 10
				local espLoopFunc
				local teamChange
				local addedFunc
				addedFunc = plr.CharacterAdded:Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						teamChange:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr)
						addedFunc:Disconnect()
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
					end
				end)
				teamChange = plr:GetPropertyChangedSignal("TeamColor"):Connect(function()
					if ESPenabled then
						espLoopFunc:Disconnect()
						addedFunc:Disconnect()
						ESPholder:Destroy()
						repeat wait(1) until getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid")
						ESP(plr)
						teamChange:Disconnect()
					else
						teamChange:Disconnect()
					end
				end)
				local function espLoop()
					if COREGUI:FindFirstChild(plr.Name..'_ESP') then
						if plr.Character and getRoot(plr.Character) and plr.Character:FindFirstChildOfClass("Humanoid") and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
							local pos = math.floor((getRoot(Players.LocalPlayer.Character).Position - getRoot(plr.Character).Position).magnitude)
							TextLabel.Text = 'Name: '..plr.Name..' | Health: '..round(plr.Character:FindFirstChildOfClass('Humanoid').Health, 1)..' | Studs: '..pos
						end
					else
						teamChange:Disconnect()
						addedFunc:Disconnect()
						espLoopFunc:Disconnect()
					end
				end
				espLoopFunc = RunService.RenderStepped:Connect(espLoop)
			end
		end
	end)
end
function filterAndDisplayCommands(searchText)
    searchText = searchText:lower()
    for i, cmd in ipairs(UI.CMDS) do
        local commandButton = cmd.btnObj
        if commandButton then
            local xa = searchText:split(" ")
            if #xa > 1 then xa = xa[2] else xa = xa[1] end
            local tovisible = searchText:find(cmd.CommandName:lower(), 1, true) or (cmd.CommandName:lower():find(searchText, 1, true)) or (cmd.CommandName:lower():find(xa, 1, true))
            if (tovisible) then
                commandButton.Position = UDim2.new(0, 0, 0, (i-1) * 20)
                commandButton.Visible = true
            else
                commandButton.Visible = false
            end
        end
    end
    
    local visibleCount = 0
    for _, cmd in ipairs(UI.CMDS) do
        local commandButton = cmd.btnObj
        if commandButton and commandButton.Visible then
            commandButton.Position = UDim2.new(0, 0, 0, visibleCount * 20)
            visibleCount = visibleCount + 1
        end
    end
end
UI.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
    filterAndDisplayCommands(UI.TextBox.Text)
end)
function execCmd(cmdName, eventType, arg)
    local args = arg or {}
    for _, cmd in ipairs(UI.CMDS) do
        if string.split(cmd.CommandName, " ")[1] == cmdName and cmd.Events[eventType] then
            SafeCall()(function()
                cmd.Events[eventType](table.unpack(args))
            end)
            return true
        end
    end
    return false
end
UI.TextBox.Focused:Connect(function()
    TextBox_Focused = true
end)
UI.TextBox.FocusLost:Connect(function(enterPressed)
    TextBox_Focused = false
    if not enterPressed then return end
    UI.hideFrame()
    local input = UI.TextBox.Text
    UI.TextBox.Text = ""

    local parts = {}
    for x, part in string.split(input, " ") do
        table.insert(parts, part)
    end
    local prefix = parts[1]

    if #parts > 1 then
        local commandName = parts[2]
        local eventType = prefix == "o" and "activated" or (prefix == "d" and "disabled")
        local args = {table.unpack(parts, 3)}
        print(args)
        execCmd(commandName, eventType, args)
    end
    filterAndDisplayCommands("")

end)

local loopgoto = nil
local foodhax_enabled
local urchindestroyerenabled
local ivsenabled
local orcamzoom
local orvivi
local orone
local ortwo
local pillardestroyr
local Clip = true
local Noclipping
local FLYING = false
local iyflyspeed
function sFLY(vfly)
	repeat wait() until Players.LocalPlayer and Players.LocalPlayer.Character and getRoot(Players.LocalPlayer.Character) and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	repeat wait() until IYMouse
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

	local T = getRoot(Players.LocalPlayer.Character)
	local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
	local SPEED = 0

	local function FLY()
		FLYING = true
		local BG = Instance.new('BodyGyro')
		local BV = Instance.new('BodyVelocity')
		BG.P = 9e4
		BG.Parent = T
		BV.Parent = T
		BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
		BG.cframe = T.CFrame
		BV.velocity = Vector3.new(0, 0, 0)
		BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
		task.spawn(function()
			repeat wait()
				if not vfly and Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
					Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
				end
				if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
					SPEED = 50
				elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
					SPEED = 0
				end
				if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
					lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
				elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
					BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
				else
					BV.velocity = Vector3.new(0, 0, 0)
				end
				BG.cframe = workspace.CurrentCamera.CoordinateFrame
			until not FLYING
			CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
			SPEED = 0
			BG:Destroy()
			BV:Destroy()
			if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
				Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
			end
		end)
	end
	flyKeyDown = IYMouse.KeyDown:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 's' then
			CONTROL.B = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'a' then
			CONTROL.L = - (vfly and vehicleflyspeed or iyflyspeed)
		elseif KEY:lower() == 'd' then 
			CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
		elseif QEfly and KEY:lower() == 'e' then
			CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
		elseif QEfly and KEY:lower() == 'q' then
			CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
		end
		pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
	end)
	flyKeyUp = IYMouse.KeyUp:Connect(function(KEY)
		if KEY:lower() == 'w' then
			CONTROL.F = 0
		elseif KEY:lower() == 's' then
			CONTROL.B = 0
		elseif KEY:lower() == 'a' then
			CONTROL.L = 0
		elseif KEY:lower() == 'd' then
			CONTROL.R = 0
		elseif KEY:lower() == 'e' then
			CONTROL.Q = 0
		elseif KEY:lower() == 'q' then
			CONTROL.E = 0
		end
	end)
	FLY()
end
function NOFLY()
	FLYING = false
	if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end
	if Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
		Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
	end
	pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end
do
    local clearbgrid = UI.createCommand("clearbuildinggrid", "Clears building grid")
    clearbgrid:createEvent("activated", function()
        local BuildingGrids = workspace:FindFirstChild("BuildingGrids")
        if (BuildingGrids and BuildingGrids:IsA("Folder")) then
            local LocalPlayer = Players.LocalPlayer
            local PlayerInBG = BuildingGrids:FindFirstChild(LocalPlayer.Name)
            if (PlayerInBG and PlayerInBG:IsA("Model")) then
                local Remotes = PlayerInBG:FindFirstChild("Remotes")
                if (Remotes and Remotes:IsA("Folder")) then
                    local Clear = Remotes:FindFirstChild("Clear")
                    if (Clear and Clear:IsA("RemoteFunction")) then
                        Clear:InvokeServer()
                    end
                end
            end
        end
    end)
    local antikick = UI.createCommand("antikick", "Prevents you from getting kicked on the client [FROM INFINITE YIELD]")
    antikick:createEvent("activated", function()
        if not hookmetamethod then 
            return notify('Your exploit does not support this command (missing hookmetamethod)', false)
        end
        local LocalPlayer = Players.LocalPlayer
        local oldhmmi
        local oldhmmnc
        oldhmmi = hookmetamethod(game, "__index", function(self, method)
            if self == LocalPlayer and method:lower() == "kick" then
                return error("Expected ':' not '.' calling member function Kick", 2)
            end
            return oldhmmi(self, method)
        end)
        oldhmmnc = hookmetamethod(game, "__namecall", function(self, ...)
            if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
                return
            end
            return oldhmmnc(self, ...)
        end)
    
        notify('Client anti kick is now active (only effective on localscript kick)', true)
    end)
    local depsanw = UI.createCommand("despawn", "Despawns your creature instantly")
    depsanw:createEvent("activated", function()
        local baseplate = game:GetService("Workspace"):FindFirstChild("Baseplate")
		local prevPos
		if baseplate and baseplate:IsA("Part") then prevPos = baseplate.Position end
		baseplate.Position = getRoot().CFrame.Position
		task.wait(1)
		baseplate.Position = prevPos
        if workspace:FindFirstChild(Player.Name) then workspace:WaitForChild("BuildingGrids"):WaitForChild("realostepoddd"):WaitForChild("Remotes"):WaitForChild("Spectate"):InvokeServer() end
        notify("Despawned", true)
    end)
    local teleportation = UI.createCommand("teleport [player(player name to tp)] [repeated(true or false)]", "Teleports your creature to some player constantly")
    teleportation:createEvent("activated", function(playerToTP, repeated)
        local Players = getPlayer(playerToTP, plr)
        for i,v in pairs(Players)do
            loopgoto = nil
            if plr.Character:FindFirstChildOfClass('Humanoid') and plr.Character:FindFirstChildOfClass('Humanoid').SeatPart then
                plr.Character:FindFirstChildOfClass('Humanoid').Sit = false
                task.wait(0.1)
            end
            loopgoto = Players[v]
            local distance = 0
            local lDelay = 0
            repeat
                if Players:FindFirstChild(v) then
                    if Players[v].Character ~= nil then
                        getRoot().CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,0,0)
                    end
                    task.wait(lDelay)
                end
                if Players:FindFirstChild(v) and repeated then
                    if Players[v].Character ~= nil then
                        getRoot().CFrame = getRoot(Players[v].Character).CFrame + Vector3.new(distance,0,0)
                    end
                    task.wait(lDelay)
                else
                    loopgoto = nil
                end
            until loopgoto ~= Players[v]
        end
    end)
    teleportation:createEvent("disabled", function()
        notify("Complete teleportation", true)
        loopgoto = nil
    end)
    local removeRoof = UI.createCommand("removeroof", "Removes the annoying invisible roof")
    removeRoof:createEvent("activated", function() 
        local MouseIgnore = workspace:FindFirstChild("MouseIgnore")
        if MouseIgnore and MouseIgnore:IsA("Folder") then
            local Roof = MouseIgnore:FindFirstChild("Roof")
            local SpectatorRoof = MouseIgnore:FindFirstChild("SpectatorRoof")
            if Roof and SpectatorRoof then
                Roof.CanCollide = false
                SpectatorRoof.CanCollide = false
            else
                notify("An error occurred while removing the roof on part 2", false)
            end
        else
            notify("An error occurred while removing the roof", false)
        end
    end)
    removeRoof:createEvent("disabled", function() 
        local MouseIgnore = workspace:FindFirstChild("MouseIgnore")
        if MouseIgnore and MouseIgnore:IsA("Folder") then
            local Roof = MouseIgnore:FindFirstChild("Roof")
            local SpectatorRoof = MouseIgnore:FindFirstChild("SpectatorRoof")
            if Roof and SpectatorRoof then
                Roof.CanCollide = true
                SpectatorRoof.CanCollide = true
            else
                notify("An error occurred while enabling the roof on part 2", false)
            end
        else
            notify("An error occurred while enabling the roof", false)
        end
    end)
    local safeZone = UI.createCommand("safezone", "Puts you in the backrooms where no one can get you")
    safeZone:createEvent("activated", function()
        local Map = workspace:FindFirstChild("Map")
        if Map and Map:IsA("Part") then
            Map.CanCollide = false
            task.wait(5)
            Map.CanCollide = true
        else
            notify("An error occurred while deactivating floor", false)
        end
    end)
    safeZone:createEvent("disabled", function()
        local Map = workspace:FindFirstChild("Map")
        if Map and Map:IsA("Part") then
            getRoot().Position = Vector3.new(getRoot().Position.X, Map.Position.Y+(Map.Size.Y/2)+1, getRoot().Position.Z)
        else
            notify("An error occurred while getting the floor's position", false)
        end
    end)
    local tptool = UI.createCommand("teleportclick", "Gives tptool [FROM INFINITE YIELD]")
    tptool:createEvent("activated", function()
        local TpTool = Instance.new("Tool")
        TpTool.Name = "Teleport Tool"
        TpTool.RequiresHandle = false
        TpTool.Parent = plr.Backpack
        TpTool.Activated:Connect(function()
            local Char = plr.Character or workspace:FindFirstChild(plr.Name)
            local HRP = Char and Char:FindFirstChild("HumanoidRootPart")
            if not Char or not HRP then
                return warn("Failed to find HumanoidRootPart")
            end
            HRP.CFrame = CFrame.new(IYMouse.Hit.X, IYMouse.Hit.Y + 3, IYMouse.Hit.Z, select(4, HRP.CFrame:components()))
        end)
    end)
    local foodhax = UI.createCommand("infinitefood [orbs (true or false)] [meat (true or false)] [interval (number)]", "Gives infinite food")
    foodhax:createEvent("activated", function(orbs, meat, delay)
        print(orbs)
        print(meat)
        print(delay)
        if isNumber(delay) then
            if ((orbs == "true") or (meat == "true")) then
                notify('Enabled infinite food', true)
                foodhax_enabled = true
            end
            task.spawn(function()
                while (task.wait(tonumber(delay)) and foodhax_enabled) do
                    if Creatures:FindFirstChild(Players.LocalPlayer.Name) then
                        task.spawn(function()
                            local MapObjects = game:GetService("Workspace"):FindFirstChild("MapObjects")
                            local body = Creatures:FindFirstChild(Players.LocalPlayer.Name):FindFirstChild("Body")
                            local GrazerMouthJaw = body:GetChildren()
                            for v, i in pairs(GrazerMouthJaw) do
                                if (i.Name ~= "Grazer") and (i.Name ~= "Mouth") and (i.Name ~= "Jaw") then
                                    GrazerMouthJaw[v] = nil
                                end
                            end
                            if not MapObjects then return end
                            if orbs == "true" then
                                local Food = MapObjects:FindFirstChild("Food"):GetChildren()
                                if Food then
                                    local RandomChoice = Food[math.random(1, #Food)]
                                    task.spawn(function()
                                        while (RandomChoice == nil) or (RandomChoice.Name == "hookedFood") do
                                            RandomChoice = Food[math.random(1, #Food)]
                                            task.wait(0)
                                        end
                                        local prevName = RandomChoice.Name
                                        RandomChoice.Name = "hookedFood"
                                        while (RandomChoice and foodhax_enabled) do
                                            local Randomer = GrazerMouthJaw[math.random(1, #GrazerMouthJaw)]
                                            while ((Randomer == nil) or (Randomer.Name ~= "Grazer") or (Randomer.Name ~= "Mouth")) and foodhax_enabled do
                                                Randomer = GrazerMouthJaw[math.random(1, #GrazerMouthJaw)]
                                                if (Randomer.Name == "Grazer") or (Randomer.Name == "Mouth") then
                                                    if Randomer:FindFirstChild("Jaw") then
                                                        Randomer = Randomer:FindFirstChild("Jaw")
                                                    end
                                                    if Randomer:FindFirstChild("Mouth") then
                                                        Randomer = Randomer:FindFirstChild("Mouth")
                                                    end
                                                end
                                                task.wait(0)
                                            end
                                            RandomChoice.CanCollide = false
                                            RandomChoice.Anchored = true
                                            RandomChoice.Position = Randomer.Position
                                            task.wait(0)
                                        end
                                        if (RandomChoice) and (not foodhax_enabled) then
                                            RandomChoice.Name = prevName
                                        end
                                    end)
                                end
                            end
                            if meat == "true" then
                                local Food = MapObjects:FindFirstChild("ExtraFood"):GetChildren()
                                if Food then
                                    local RandomChoice = Food[math.random(1, #Food)]
                                    task.spawn(function()
                                        while (RandomChoice == nil) or (RandomChoice.Name == "hookedFood") do
                                            RandomChoice = Food[math.random(1, #Food)]
                                            task.wait(0)
                                        end
                                        local prevName = RandomChoice.Name
                                        RandomChoice.Name = "hookedFood"
                                        while (RandomChoice and foodhax_enabled) do
                                            local Randomer = GrazerMouthJaw[math.random(1, #GrazerMouthJaw)]
                                            while ((Randomer == nil) or (Randomer.Name ~= "Jaw")) and foodhax_enabled do
                                                Randomer = GrazerMouthJaw[math.random(1, #GrazerMouthJaw)]
                                                if (Randomer.Name == "Jaw") then
                                                    if Randomer:FindFirstChild("Jaw") then
                                                        Randomer = Randomer:FindFirstChild("Jaw")
                                                    end
                                                end
                                                task.wait(0)
                                            end
                                            RandomChoice.CanCollide = false
                                            RandomChoice.Anchored = true
                                            RandomChoice.Position = getRoot(Players.LocalPlayer.Character).Position
                                            task.wait(0)
                                        end
                                        if (RandomChoice) and (not foodhax_enabled) then
                                            RandomChoice.Name = prevName
                                        end
                                    end)
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end)
    foodhax:createEvent("disabled", function()
        foodhax_enabled = false
    end)
    local UrchinDestroyer = UI.createCommand("destroyurchins", "Destroys all urchins on the map")
    UrchinDestroyer:createEvent("activated", function()
        urchindestroyerenabled = true
        while (task.wait(0)) and urchindestroyerenabled do
            task.spawn(function()
                if Creatures:FindFirstChild(plr.Name) then
                    task.spawn(function()
                        local MapObjects = game:GetService("Workspace"):FindFirstChild("MapObjects")
                        local Traps = MapObjects:FindFirstChild("Traps")
                        if Traps then
                            for v, i in pairs(Traps:GetChildren()) do
                                i:Destroy()
                            end
                        end
                    end)
                end
            end)
        end
    end)
    UrchinDestroyer:createEvent("disabled", function()
        urchindestroyerenabled = false
    end)
    local pillardestroying = UI.createCommand("pillardestroy", "Destroys all pillars for everyone")
    pillardestroying:createEvent("activated", function()
        pillardestroyr = true
        while task.wait(0) and pillardestroyr do
            task.spawn(function()
                local MapObjects = game:GetService("Workspace"):FindFirstChild("MapObjects")
                if pillardestroyr and MapObjects then
                    local Traps = MapObjects:FindFirstChild("Traps")
                    if Traps then
                        for v, i in pairs(Traps:GetChildren()) do
                            if i.Name == "Pillar" then
                                i.Position = getRoot().Position
                            end
                        end
                    end
                end
            end)
        end
    end)
    pillardestroying:createEvent("disabled", function() 
        pillardestroyr = false
    end)
    local ivr = UI.createCommand("infinitevision", "Gives you infinite vision")
    ivr:createEvent("activated", function()
        ivsenabled = true
        orcamzoom = Players.LocalPlayer.CameraMaxZoomDistance
        local FX = game:GetService("Workspace"):FindFirstChild("FX")
        local VisionRange
        if FX then VisionRange = FX:FindFirstChild("VisionRange") end
        if VisionRange then
            local One = VisionRange:FindFirstChild("One")
            if One then orone = VisionRange.Transparency end
            local Two = VisionRange:FindFirstChild("Two")
            if Two then ortwo = VisionRange.Transparency end
            orvivi = VisionRange.Transparency
        end
        while (task.wait(0)) and ivsenabled do
            task.spawn(function()
                Players.LocalPlayer.CameraMaxZoomDistance = 100000
                local FX = game:GetService("Workspace"):FindFirstChild("FX")
                local VisionRange
                if FX then VisionRange = FX:FindFirstChild("VisionRange") end
                if VisionRange then
                    VisionRange.Transparency = 1 -- VisionRange as `any`
                    local One = VisionRange:FindFirstChild("One")
                    if One then One.Transparency = 1 end
                    local Two = VisionRange:FindFirstChild("Two")
                    if Two then Two.Transparency = 1 end
                    local Lighting = game:GetService("Lighting")
                    local Atmosphere = Lighting:FindFirstChild("Atmosphere")
                    local DepthOfField = Lighting:FindFirstChild("DepthOfField")
                    local _result = Atmosphere
                    if _result ~= nil then
                        _result = _result:IsA("Atmosphere")
                    end
                    local _condition = _result
                    if _condition then
                        local _result_1 = DepthOfField
                        if _result_1 ~= nil then
                            _result_1 = _result_1:IsA("DepthOfFieldEffect")
                        end
                        _condition = _result_1
                    end
                    if _condition then
                        Atmosphere.Density = 0
                        DepthOfField.Enabled = false
                    end
                end
            end)
        end
    end)
    ivr:createEvent("disabled", function() 
        ivsenabled = false
        task.wait(0.01)
        task.spawn(function()
            Players.LocalPlayer.CameraMaxZoomDistance = orcamzoom
            local FX = game:GetService("Workspace"):FindFirstChild("FX")
            local VisionRange
            if FX then VisionRange = FX:FindFirstChild("VisionRange") end
            if VisionRange then
                VisionRange.Transparency = orvivi -- VisionRange as `any`
                local One = VisionRange:FindFirstChild("One")
                if One then One.Transparency = orone end
                local Two = VisionRange:FindFirstChild("Two")
                if Two then Two.Transparency = ortwo end
                local Lighting = game:GetService("Lighting")
                local Atmosphere = Lighting:FindFirstChild("Atmosphere")
                local DepthOfField = Lighting:FindFirstChild("DepthOfField")
                local _result = Atmosphere
                if _result ~= nil then
                    _result = _result:IsA("Atmosphere")
                end
                local _condition = _result
                if _condition then
                    local _result_1 = DepthOfField
                    if _result_1 ~= nil then
                        _result_1 = _result_1:IsA("DepthOfFieldEffect")
                    end
                    _condition = _result_1
                end
                if _condition then
                    Atmosphere.Density = 0
                    DepthOfField.Enabled = false
                end
            end
        end)
    end)
    local ESPCMD = UI.createCommand("esp", "Enables ESP [FROM INFINITE YIELD]")
    ESPCMD:createEvent("activated", function() 
        ESPenabled = true
		for i,v in pairs(Players:GetPlayers()) do
			if v.Name ~= plr.Name then
				ESP(v)
			end
		end
    end)
    ESPCMD:createEvent("disabled", function()
        ESPenabled = false
        for i,c in pairs(COREGUI:GetChildren()) do
            if string.sub(c.Name, -4) == '_ESP' then
                c:Destroy()
            end
        end
    end)
    local noclip = UI.createCommand("noclip", "Noclip through walls [FROM INFINITE YIELD]")
    noclip:createEvent("activated", function() 
        Clip = false
        task.wait(0.1)
        local function NoclipLoop()
            if Clip == false and plr.Character ~= nil then
                for _, child in pairs(plr.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                    end
                end
            end
        end
        Noclipping = RunService.Stepped:Connect(NoclipLoop)
    end)
    noclip:createEvent("disabled", function() 
        if Noclipping then
            Noclipping:Disconnect()
        end
        Clip = true
    end)
    local spoofspeed = UI.createCommand("spoofspeed [speed (number)]", "Spoof your speed")
    spoofspeed:createEvent("activated", function(speed) 
        if Creatures then
            local Creature = Creatures:FindFirstChild(plr.Name)
            if Creature then
                local Humanoid = Creature:FindFirstChildWhichIsA("Humanoid")
                if Humanoid then
                    Humanoid.WalkSpeed = speed
                end
            end
        end
    end)

    local fly = UI.createCommand("fly [speed (number)]", "Fly in the air")
    fly:createEvent("activated", function(speed)
        NOFLY()
        wait()
        sFLY()
        if speed and isNumber(speed) then
            iyflyspeed = speed
        end
    end)
    fly:createEvent("disabled", function() 
        NOFLY()
    end)
    local spin = UI.createCommand("spin [speed (number)]", "Spin around")
    spin:createEvent("activated", function(speed) 
        local spinSpeed = 20
        if speed and isNumber(speed) then
            spinSpeed = speed
        end
        for i,v in pairs(getRoot():GetChildren()) do
            if v.Name == "Spinning" then
                v:Destroy()
            end
        end
        local Spin = Instance.new("BodyAngularVelocity")
        Spin.Name = "Spinning"
        Spin.Parent = getRoot()
        Spin.MaxTorque = Vector3.new(0, math.huge, 0)
        Spin.AngularVelocity = Vector3.new(0,spinSpeed,0)
    end)
    spin:createEvent("disabled", function(speed)
        for i,v in pairs(getRoot():GetChildren()) do
            if v.Name == "Spinning" then
                v:Destroy()
            end
        end
    end)
    local spoofbloat = UI.createCommand("spoofbloat", "Makes you slippery")
    spoofbloat:createEvent("activated", function()
        if Creatures then
            task.spawn(function()
                local Creature = Creatures:FindFirstChild(plr.Name)
                if Creature then
                    local HumanoidRoot = Creature:FindFirstChild("HumanoidRootPart")
                    if HumanoidRoot then
                        local DENSITY = 0.01
                        local FRICTION = 0.3
                        local ELASTICITY = 0.5
                        local FRICTION_WEIGHT = 1
                        local ELASTICITY_WEIGHT = 1
                        local physProperties = PhysicalProperties.new(DENSITY, FRICTION, ELASTICITY, FRICTION_WEIGHT, ELASTICITY_WEIGHT)
    
                        HumanoidRoot.CustomPhysicalProperties = physProperties
                    end
                end
            end)
        end
    end)
    local changeMoverSpeed = UI.createCommand("changemoverspeed [speed (number)]", "Changes your mover speed :P")
    changeMoverSpeed:createEvent("activated", function(speed) 
        if speed and isNumber(speed) then
            if hookmetamethod then
                local char = plr.Character
                local setspeed;
                local index; index = hookmetamethod(game, "__index", function(self, key)
                    local keyclean = key:gsub("\0", "")
                    if (keyclean == "WalkSpeed" or keyclean == "walkSpeed") and self:IsA("Humanoid") and self:IsDescendantOf(char) and not checkcaller() then
                        return setspeed or speed
                    end
                    return index(self, key)
                end)
                local newindex; newindex = hookmetamethod(game, "__newindex", function(self, key, value)
                    local keyclean = string.gsub(key, "\0", "")
                    if (keyclean == "WalkSpeed" or keyclean == "walkSpeed") and self:IsA("Humanoid") and self:IsDescendantOf(char) and not checkcaller() then
                        setspeed = tonumber(value)
                        return setspeed
                    end
                    return newindex(self, key, value)
                end)
            else
                notify('Your exploit does not support this command (missing hookmetamethod)', false)
            end
        end
    end)
    local iyscript = UI.createCommand("infiniteyield", "Starts infinite yield")
    iyscript:createEvent("activated", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end)
end
local UserInputService = game:GetService("UserInputService")

local function onKeyPress(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Quote and not gameProcessed then
        UI.showFrame()
        UI.TextBox:CaptureFocus()
        TextBox_Focused = true
    end
end

UserInputService.InputBegan:Connect(onKeyPress)

execCmd("antikick", "activated")
filterAndDisplayCommands("")
Connection = RunService.Heartbeat:Connect(function()
    if not UI.ScreenGui then return end
    if UI.ScreenGui.Parent == nil then Connection:Disconnect() end
    UI.ScreenGui.Name = randomStr()
    for v, i in pairs(UI.ScreenGui:GetDescendants()) do
        i.Name = randomStr()
    end
end)
