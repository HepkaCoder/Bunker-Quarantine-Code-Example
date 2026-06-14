local npc = {}

local players = game:GetService("Players")
local rep = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")
local chatService = game:GetService("Chat")
local tweenService = game:GetService("TweenService")

local data = require(rep:WaitForChild("data"):WaitForChild("npc"))
local spotHandler = require(script.spotHandler)
local optionHandler = require(script.optionHandler)
local config = require(rep:WaitForChild("modules"):WaitForChild("config"))

local npcUnderInspection = rep:WaitForChild("NpcUnderInspection")
local amountOfActiveNpcs = rep:WaitForChild("AmountOfActiveNpcs")

-- events
local events = rep:WaitForChild("events")
local npcProcessed = events:WaitForChild("bindable"):WaitForChild("NpcProcessed")

-- varibles
local npcs = rep:WaitForChild("npcs")
local activeNpcs = workspace:WaitForChild("ActiveNpcs")

local npcPathFolder = workspace:WaitForChild("NpcPath")
local npcSpawn = npcPathFolder:WaitForChild("NpcSpawn")
--
local open = false

local function getRandomNpcData()
	local totalWight = 0
	
	for _, v in pairs(data.npcs) do
		totalWight += v.spawnChance
	end
	
	local random = math.random(1, totalWight)
	local current = 0
	
	for _, v in pairs(data.npcs) do
		current += v.spawnChance
		
		if random <= current then
			return v
		end
	end
end

local function getRandomUserId()
	local seed = math.random(1, 20)
	if seed > 15 then
		local playerList = players:GetPlayers()
		local player = math.random(1, #playerList)
		
		local success, friendPages = pcall(function()
			return players:GetFriendsAsync(player.UserId)
		end)
		
		if success and friendPages then
			local friendList = {}

			while true do
				for _, friend in ipairs(friendPages:GetCurrentPage()) do
					table.insert(friendList, friend.Id)
				end
				if friendPages.IsFinished then break end
				friendPages:AdvanceToNextPageAsync()
			end

			if #friendList > 0 then
				return friendList[math.random(1, #friendList)]
			end
		end

		local randomIds = data.randomNpc
		return randomIds[math.random(1, #randomIds)]
		
		-- get friends id
	elseif seed >= 13 then
		local famousIds = data.famousNpc
		local randomId = famousIds[math.random(1, #famousIds)]
		return randomId
	else
		local randomIds = data.randomNpc
		local randomId = randomIds[math.random(1, #randomIds)]
		return randomId
	end
end

local function getNpcAppearance(userId: number)
	local success, appearance = pcall(function()
		return players:GetHumanoidDescriptionFromUserIdAsync(userId)
	end)

	if success then
		return appearance
	else
		warn("Failed to get appearance for userId: " .. userId)
		return nil
	end
end

-- main
function npc._newNpc()
	if amountOfActiveNpcs.Value >= config.npc.maxSlots then warn("you have hit the max npc amount") return end
	local npcData = getRandomNpcData()

	local newNpc = npcs:FindFirstChild(npcData.mutation):Clone()
	newNpc:FindFirstChild("HumanoidRootPart").CFrame = npcSpawn.CFrame
	newNpc.Parent = activeNpcs
	newNpc.Name = npcData.mutation .. " Npc"

	local humanoid = newNpc:FindFirstChild("Humanoid")
	local userId = getRandomUserId()
	humanoid:ApplyDescriptionAsync(getNpcAppearance(userId))

	newNpc:SetAttribute("Mutation", npcData["mutation"])

	local minTemp = npcData.temperature[1]
	local maxTemp = npcData.temperature[2]
	local temp = math.random(minTemp * 10, maxTemp * 10) / 10
	newNpc:SetAttribute("Temperature", temp)

	local minHeart = npcData.heartbeat[1]
	local maxHeart = npcData.heartbeat[2]
	local heart = math.random(minHeart, maxHeart)
	newNpc:SetAttribute("Heartbeat", heart)
	
	local minRadiation = npcData.radiation[1]
	local maxRadiation = npcData.radiation[2]
	local radiation = math.random(minRadiation * 10, maxRadiation * 10) / 10
	newNpc:SetAttribute("Radiation", radiation)
	
	local minBreath = npcData.breath[1]
	local maxBreath = npcData.breath[2]
	local breath = math.random(minBreath * 10, maxBreath * 10) / 10
	newNpc:SetAttribute("Breath", breath)
	
	newNpc:SetAttribute("Infected", npcData.infected)
	newNpc:SetAttribute("Answer", npcData.answer)
	newNpc:SetAttribute("CanGetShot", false)
	
	local spot = spotHandler._assignSlot()
	newNpc:SetAttribute("Spot", spot)
	spotHandler._moveNpcToSpot(newNpc)
	
	amountOfActiveNpcs.Value += 1
end

function npc._spawnNpc(mutation: string)
	local npcData = data.npcs[mutation]
	
	local newNpc = npcs:WaitForChild(mutation):Clone()
	newNpc:FindFirstChild("HumanoidRootPart").CFrame = npcSpawn.CFrame
	newNpc.Parent = activeNpcs
	newNpc.Name = npcData.mutation .. " Npc"

	local humanoid = newNpc:FindFirstChild("Humanoid")
	local userId = getRandomUserId()
	humanoid:ApplyDescriptionAsync(getNpcAppearance(userId))

	newNpc:SetAttribute("Mutation", npcData["mutation"])

	local minTemp = npcData.temperature[1]
	local maxTemp = npcData.temperature[2]
	local temp = math.random(minTemp * 10, maxTemp * 10) / 10
	newNpc:SetAttribute("Temperature", temp)

	local minHeart = npcData.heartbeat[1]
	local maxHeart = npcData.heartbeat[2]
	local heart = math.random(minHeart, maxHeart)
	newNpc:SetAttribute("Heartbeat", heart)

	local minRadiation = npcData.radiation[1]
	local maxRadiation = npcData.radiation[2]
	local radiation = math.random(minRadiation * 10, maxRadiation * 10) / 10
	newNpc:SetAttribute("Radiation", radiation)

	local minBreath = npcData.breath[1]
	local maxBreath = npcData.breath[2]
	local breath = math.random(minBreath * 10, maxBreath * 10) / 10
	newNpc:SetAttribute("Breath", breath)

	newNpc:SetAttribute("Infected", npcData.infected)
	newNpc:SetAttribute("Answer", npcData.answer)
	newNpc:SetAttribute("CanGetShot", false)

	local spot = spotHandler._assignSlot()
	newNpc:SetAttribute("Spot", spot)
	spotHandler._moveNpcToSpot(newNpc)

	amountOfActiveNpcs.Value += 1
	
end

function npc._getNpcUnderInspection()
	return npcUnderInspection.Value
end

function npc._sendGreeting()
	if not npcUnderInspection.Value then return end 

	local head = npcUnderInspection.Value:FindFirstChild("Head")
	if not head then return end

	local greetingPhrases = data.greetingPhrases
	if not greetingPhrases or #greetingPhrases == 0 then return end

	local greeting = greetingPhrases[math.random(#greetingPhrases)]
	chatService:Chat(head, greeting)
end

-- options for the active npc
function npc._sendChat()
	if not npcUnderInspection.Value then return end
	-- send chat from npc data
	
	local mutation = npcUnderInspection.Value:GetAttribute("Mutation")
	local npcChatData = data.npcs[mutation].chats
	local chat = npcChatData[math.random(1, #npcChatData)]
	
	local head = npcUnderInspection.Value:FindFirstChild("Head")
	chatService:Chat(head, chat)
end

function npc._revealAnswer()
	if not npcUnderInspection.Value then return end
	
	local mutation = npcUnderInspection.Value:GetAttribute("Mutation")
	local answerData = data.npcs[mutation].answer
end

function npc._killNpc()
	if not npcUnderInspection.Value then return end
	if open == true then return end
	open = true	
	
	optionHandler._enableOptions(false)
	
	local deathTrap = workspace:WaitForChild("DeathTrap")
	local rightHatch = deathTrap:WaitForChild("RightHatch")
	local leftHatch = deathTrap:WaitForChild("LeftHatch")

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local offset = 4.5

	-- org pos
	local rightStart = rightHatch.CFrame
	local leftStart = leftHatch.CFrame

	-- open
	local rightOpen = {
		CFrame = rightStart * CFrame.new(0, 0, offset)
	}

	local leftOpen = {
		CFrame = leftStart * CFrame.new(0, 0, offset)
	}

	local rightTween = tweenService:Create(rightHatch, tweenInfo, rightOpen)
	local leftTween = tweenService:Create(leftHatch, tweenInfo, leftOpen)

	rightTween:Play()
	leftTween:Play()

	rightTween.Completed:Wait()

	task.wait(0.7)

	-- close
	local rightCloseTween = tweenService:Create(rightHatch, tweenInfo, {
		CFrame = rightStart
	})

	local leftCloseTween = tweenService:Create(leftHatch, tweenInfo, {
		CFrame = leftStart
	})

	rightCloseTween:Play()
	leftCloseTween:Play()
	
	rightCloseTween.Completed:Wait()
	open = false
	
	-- updates its spot so next npc can get it and fires to the main server script that its been processed so it can update npc spots and look if the player choice the right answer
	npcUnderInspection.Value:SetAttribute("Spot", "Eliminated")
	npcProcessed:Fire("Eliminate", npcUnderInspection.Value)
	
	npcUnderInspection.Value:Destroy()
	npcUnderInspection.Value = nil
	amountOfActiveNpcs.Value -= 1
end

function npc._removeHats()
	if not npcUnderInspection.Value then return end
	for _, hats in npcUnderInspection.Value:GetChildren() do
		if hats:IsA("Accessory") then
			hats:Destroy()
		end
	end
end

function npc._shotNpc(npcModel: Model, player: Player)
	if npcModel == npcUnderInspection.Value then
		npcUnderInspection.Value:SetAttribute("Spot", "Eliminated")
		npcProcessed:Fire("Eliminate", npcUnderInspection.Value)
		npcUnderInspection.Value = nil
	end
	
	local plrRoot = player.Character:FindFirstChild("HumanoidRootPart")
	local head = npcModel:FindFirstChild("Head")
	if head and plrRoot then
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(50000,50000,50000)
		bv.Velocity = plrRoot.CFrame.LookVector * 100
		bv.P = 3000
		bv.Parent = head
		npcModel:WaitForChild("IsRagdoll").Value = true
		task.delay(0.1,function()
			bv:Destroy()
		end)
	end

	amountOfActiveNpcs.Value -= 1

	task.delay(7,function()
		npcModel:Destroy()
	end)
end
--



return npc
