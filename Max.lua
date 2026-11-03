local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
player.CharacterAdded:Connect(function(nChar)
character = nChar
end)
-- 1. ตัวแปรเก็บสถานะ (Toggles)
local Toggles = {
AutoKill = false,
AuraKill = false,
AutoPlay = false,
AutoReplay = false
}
-- 2. ระบบค้นหาเป้าหมาย & ทำการโจมตี
-- ฟังก์ชันค้นหามอนสเตอร์ที่ใกล้ที่สุดแบบยืดหยุ่น (สแกนทักษะ Humanoid)
local function getClosestTarget()
local closest = nil
local maxDist = 80 -- ระยะทำการ
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
for _, obj in pairs(workspace:GetDescendants()) do
if obj:IsA("Humanoid") and obj.Health > 0 and obj.Parent ~= character then
local targetHrp = obj.Parent:FindFirstChild("HumanoidRootPart") or obj.Parent:FindFirstChild("UpperTorso")
if targetHrp and not Players:GetPlayerFromCharacter(obj.Parent) then
local dist = (targetHrp.Position - hrp.Position).Magnitude
if dist < maxDist then
maxDist = dist
closest = targetHrp
end
end
end
end
return closest
end
-- ลูปการทำงานโจมตี (Auto Attack / Aura Kill)
RunService.RenderStepped:Connect(function()
if Toggles.AuraKill or Toggles.AutoKill then
local targetHrp = getClosestTarget()
local myHrp = character:FindFirstChild("HumanoidRootPart")
if targetHrp and myHrp then
-- ถ้าเปิด Auto Kill ให้เคลื่อนที่ไปประกบมอนสเตอร์
if Toggles.AutoKill then
myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 2.5)
end
-- จำลองการคลิกโจมตี
VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end
end
end)
-- 3. ระบบค้นหาและกดปุ่มอัตโนมัติ (Auto Play / Replay)
task.spawn(function()
while task.wait(1) do
local pGui = player:FindFirstChild("PlayerGui")
if pGui then
-- สแกนหา TextButton ทุกตัวในหน้าจอ
for _, btn in pairs(pGui:GetDescendants()) do
if btn:IsA("TextButton") and btn.Visible then
local text = string.lower(btn.Text)
-- ตรวจจับ Auto Play (หาคำว่า Play / Start)
if Toggles.AutoPlay and (string.find(text, "play") or string.find(text, "start")) then
pcall(function()
for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
conn:Fire()
end
end)
end
-- ตรวจจับ Auto Replay (หาคำว่า Replay / Retry)
if Toggles.AutoReplay and (string.find(text, "replay") or string.find(text, "retry")) then
pcall(function()
for _, conn in pairs(getconnections(btn.MouseButton1Click)) do
conn:Fire()
end
end)
end
end
end
end
end
end)
-- 4. การสร้าง UI
local function buildMacUI()
local pGui = player:WaitForChild("PlayerGui")
if pGui:FindFirstChild("MacHub2") then pGui.MacHub2:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "MacHub2"
gui.ResetOnSpawn = false
gui.Parent = pGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 310)
frame.Position = UDim2.new(0.05, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "🍎 MAC HUB v2.0"
title.TextColor3 = Color3.fromRGB(0, 255, 120)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = frame
local function createToggle(name, yPos, key)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0, yPos)
btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
btn.Text = name .. " : [ OFF ]"
btn.TextColor3 = Color3.fromRGB(200, 200, 200)
btn.TextSize = 14
btn.Parent = frame
local bCorner = Instance.new("UICorner")
bCorner.CornerRadius = UDim.new(0, 6)
bCorner.Parent = btn
btn.MouseButton1Click:Connect(function()
Toggles[key] = not Toggles[key]
if Toggles[key] then
btn.Text = name .. " : [ ON ]"
btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
else
btn.Text = name .. " : [ OFF ]"
btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
btn.TextColor3 = Color3.fromRGB(200, 200, 200)
end
end)
end
createToggle("⚔️ Auto Kill (วาร์ปฟาร์ม)", 55, "AutoKill")
createToggle("💥 Aura Kill (ตีรอบตัว)", 110, "AuraKill")
createToggle("▶️ Auto Play (กดเริ่มด่าน)", 165, "AutoPlay")
createToggle("🔄 Auto Replay (เล่นซ้ำ)", 220, "AutoReplay")
end
buildMacUI()
print("✅ Mac Hub v2.0 โหลดเรียบร้อยแล้ว!")
