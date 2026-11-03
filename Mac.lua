-- ==========================================
-- Mac Hub v1.0 (Anime Dimensions Simulator)
-- สคริปต์เพื่อการศึกษา โครงสร้างการทำ Auto Farm & UI
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
-- อัปเดตตัวแปร Character เมื่อผู้เล่นเกิดใหม่
player.CharacterAdded:Connect(function(newChar)
character = newChar
end)
-- 1. ตัวแปรเก็บสถานะ Toggle ของฟีเจอร์ต่างๆ
local Toggles = {
AutoKill = false,
AuraKill = false,
AutoPlay = false,
AutoReplay = false
}
local Settings = {
AuraDistance = 50 -- ระยะทำการของ Aura Kill (นับตาม Studs)
}
-- 2. ฟังก์ชันหลักในการทำงาน (Logic Layer)
-- ระบบ Anti-AFK ป้องกันเกมหลุดขณะเปิด Auto
player.Idled:Connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new(0,0))
end)
-- ฟังก์ชันทำลาย/โจมตีมอนสเตอร์ (Auto Kill & Aura Kill)
local function getClosestMonster()
local closest = nil
local shortestDistance = Settings.AuraDistance
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return nil end
-- ค้นหามอนสเตอร์จากโฟลเดอร์มอนสเตอร์ในแมพ (ปรับตามแมพ Anime Dimensions)
local folder = workspace:FindFirstChild("Folder") or workspace:FindFirstChild("Enemies") or workspace
for _, v in pairs(folder:GetChildren()) do
if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
if v ~= character and not Players:GetPlayerFromCharacter(v) then
local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
if dist < shortestDistance then
shortestDistance = dist
closest = v
end
end
end
end
return closest
end
-- ลูปการทำ Aura Kill / Auto Attack
RunService.Stepped:Connect(function()
if Toggles.AuraKill or Toggles.AutoKill then
local target = getClosestMonster()
if target and target:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("HumanoidRootPart") then
-- ถ้าเปิด Auto Kill ให้เคลื่อนที่ไปหามอนสเตอร์
if Toggles.AutoKill then
character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
end
-- จำลองการส่ง Remote Event โจมตี/ใช้สกิล (คลิกโจมตีพื้นฐาน)
VirtualUser:ClickButton1(Vector2.new(500, 500))
end
end
end)
-- ลูปตรวจสอบ Auto Replay / Auto Play
task.spawn(function()
while task.wait(1.5) do
-- Auto Replay (เล่นซ้ำเมื่อจบด่าน)
if Toggles.AutoReplay then
-- ตรวจสอบ UI ปุ่ม Replay เมื่อจบดันเจี้ยน
local pGui = player:FindFirstChild("PlayerGui")
if pGui then
local resultUI = pGui:FindFirstChild("Results") or pGui:FindFirstChild("RetryUI")
if resultUI and resultUI.Visible then
local retryBtn = resultUI:FindFirstChild("Replay", true) or resultUI:FindFirstChild("Retry", true)
if retryBtn then
-- จำลองการกดปุ่ม Replay
for _, connection in pairs(getconnections(retryBtn.MouseButton1Click)) do
connection:Fire()
end
end
end
end
end
-- Auto Play (กดเริ่มดันเจี้ยนอัตโนมัติ)
if Toggles.AutoPlay then
local pGui = player:FindFirstChild("PlayerGui")
if pGui then
local startBtn = pGui:FindFirstChild("Start", true) or pGui:FindFirstChild("Play", true)
if startBtn and startBtn.Visible then
for _, connection in pairs(getconnections(startBtn.MouseButton1Click)) do
connection:Fire()
end
end
end
end
end
end)
-- 3. การสร้างหน้าต่าง GUI (UI Layer)
local function createUI()
local pGui = player:WaitForChild("PlayerGui")
-- ลบ GUI เก่าถ้ามีอยู่แล้ว
if pGui:FindFirstChild("MacHubGui") then
pGui.MacHubGui:Destroy()
end
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "MacHubGui"
mainGui.ResetOnSpawn = false
mainGui.Parent = pGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 340)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- ทำให้ลากเคลื่อนย้ายหน้าต่างได้
frame.Parent = mainGui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame
-- หัวข้อหลัก
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Text = "🍎 MAC HUB | Anime Dimensions"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.Parent = frame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title
-- ฟังก์ชันสร้างปุ่ม Toggle สวยงาม
local function makeToggleButton(text, positionY, toggleKey)
local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0, positionY)
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
btn.Text = text .. " : [ OFF ]"
btn.TextColor3 = Color3.fromRGB(200, 200, 200)
btn.TextSize = 14
btn.Font = Enum.Font.SourceSans
btn.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = btn
btn.MouseButton1Click:Connect(function()
Toggles[toggleKey] = not Toggles[toggleKey]
if Toggles[toggleKey] then
btn.Text = text .. " : [ ON ]"
btn.BackgroundColor3 = Color3.fromRGB(0, 170, 100)
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
else
btn.Text = text .. " : [ OFF ]"
btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
btn.TextColor3 = Color3.fromRGB(200, 200, 200)
end
end)
end
-- สร้างปุ่มการทำงานตามตำแหน่ง Y
makeToggleButton("⚔️ Auto Kill (วาร์ปฆ่ามอน)", 60, "AutoKill")
makeToggleButton("💥 Aura Kill (ฆ่ามอนในระยะ)", 110, "AuraKill")
makeToggleButton("▶️ Auto Play (กดเริ่มอัตโนมัติ)", 160, "AutoPlay")
makeToggleButton("🔄 Auto Replay (เล่นซ้ำอัตโนมัติ)", 210, "AutoReplay")
-- ข้อความแสดงเครดิตสื่อการสอน
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, 0, 0, 30)
footer.Position = UDim2.new(0, 0, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "Educational Script for Computer Class"
footer.TextColor3 = Color3.fromRGB(120, 120, 120)
footer.TextSize = 12
footer.Parent = frame
end
-- รันฟังก์ชันสร้าง UI
createUI()
print("✅ โหลด Mac Hub สำเร็จพร้อมใช้งาน!")
