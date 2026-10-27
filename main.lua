local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIG
_G.AimbotEnabled = true
_G.SilentAimEnabled = true
_G.ESPEnabled = true
_G.TargetDummy = true
_G.AimPart = "Head"
_G.AimbotSpeed = 0.25
_G.ESPColor = Color3.fromRGB(255,0,0)

local ESP = {}

local function IsValidCharacter(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local part = char:FindFirstChild(_G.AimPart)
	return hum and hum.Health > 0 and part
end

local function GetClosestTarget()
	local closest, shortest = nil, math.huge
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	local function CheckCharacter(char)
		local part = char:FindFirstChild(_G.AimPart)
		if not part then return end

		local pos, visible = Camera:WorldToViewportPoint(part.Position)
		if not visible then return end

		local dist = (Vector2.new(pos.X,pos.Y)-center).Magnitude
		if dist < shortest then
			shortest = dist
			closest = char
		end
	end

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and IsValidCharacter(plr.Character) then
			CheckCharacter(plr.Character)
		end
	end

	if _G.TargetDummy then
		for _,obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Humanoid") then
				local char = obj.Parent
				if char and char:IsA("Model") and char ~= LocalPlayer.Character and IsValidCharacter(char) then
					CheckCharacter(char)
				end
			end
		end
	end

	return closest
end

local function AddESP(char)
	if not _G.ESPEnabled or ESP[char] then return end
	local hl = Instance.new("Highlight")
	hl.FillColor = _G.ESPColor
	hl.OutlineColor = _G.ESPColor
	hl.FillTransparency = 0.7
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Adornee = char
	hl.Parent = char
	ESP[char] = hl
end

RunService.RenderStepped:Connect(function(dt)
	local target = GetClosestTarget()

	if _G.AimbotEnabled and target then
		local part = target:FindFirstChild(_G.AimPart)
		if part then
			local goal = CFrame.lookAt(Camera.CFrame.Position, part.Position)
			Camera.CFrame = Camera.CFrame:Lerp(goal,_G.AimbotSpeed)
		end
	end

	if target then
		AddESP(target)
	end
end)

-- Silent Aim API
_G.GetSilentAimTarget = function()
	if not _G.SilentAimEnabled then
		return nil
	end

	local target = GetClosestTarget()
	if target then
		return target:FindFirstChild(_G.AimPart)
	end

	return nil
end

print("Aim Assist + Silent Aim + ESP Loaded")
