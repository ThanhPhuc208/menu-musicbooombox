-- (Creator = Thanh Phuc)
-- 💟 Thanh Phuc - Boombox Khối Vuông Gốc: Giật Cầu Vồng Theo Nhịp Nhạc + Sửa Lỗi Die Hoàn Toàn 💟
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

-- Giữ nguyên bộ phát âm thanh chuẩn của bạn
local LocalSound = Instance.new("Sound")
LocalSound.Name = "ThanhPhucLocalSound"
LocalSound.Parent = LocalPlayer:WaitForChild("PlayerWorkspace", 5) or workspace
LocalSound.Volume = 2
LocalSound.Looped = true

local FakeBoombox = nil
local RainbowConnection = nil

-- Hàm dọn dẹp loa cũ để tránh trùng lặp
local function RemoveBoombox()
    if RainbowConnection then RainbowConnection:Disconnect() RainbowConnection = nil end
    if FakeBoombox then FakeBoombox:Destroy() FakeBoombox = nil end
end

-- TẠO BOOMBOX CẦU VỒNG GỐC THEO NHỊP (Chính xác như ảnh 1000056602.jpg)
local function CreateFakeBoombox()
    RemoveBoombox()
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("UpperTorso") and not character:FindFirstChild("Torso") then return end
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    -- Tạo khối Mesh cho Boombox giống hệt bản đầu tiên của bạn
    local part = Instance.new("Part")
    part.Name = "ThanhPhucBoombox"
    part.Size = Vector3.new(2, 2, 2)
    part.CanCollide = false
    part.Massless = true
    
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshId = "rbxassetid://114134812" -- Mesh ID gốc của Boombox Roblox
    mesh.TextureId = "rbxassetid://114134769" -- Texture gốc
    mesh.Parent = part
    
    FakeBoombox = part
    part.Parent = character
    
    -- Gắn chặt Boombox vào lưng nhân vật
    local weld = Instance.new("Weld")
    weld.Part0 = torso
    weld.Part1 = part
    weld.C0 = CFrame.new(0, 0, 0.7) * CFrame.Angles(0, math.rad(180), 0) -- Căn chuẩn sau lưng
    weld.Parent = part
    
    -- VÒNG LẶP CHỚP MÀU + GIẬT THEO NHỊP BASS & TIẾNG HÁT
    local hue = 0
    RainbowConnection = RunService.RenderStepped:Connect(function()
        if part and part.Parent and mesh then
            -- Chạy màu cầu vồng nền mượt mà
            hue = (hue + 1) % 360
            local baseColor = Color3.fromHSV(hue/360, 1, 1)
            
            -- Phân tích độ lớn âm thanh (Bao gồm cả bass và lời nói lớn nhỏ)
            local loudness = LocalSound.PlaybackLoudness
            local intensity = math.clamp(loudness / 250, 0.4, 2.5) -- Đẩy độ sáng chớp theo nhịp
            
            -- Tạo màu động chớp nháy mạnh/nhẹ theo âm thanh
            local dynamicColor = Color3.new(
                math.clamp(baseColor.R * intensity, 0, 1),
                math.clamp(baseColor.G * intensity, 0, 1),
                math.clamp(baseColor.B * intensity, 0, 1)
            )
            
            part.Color = dynamicColor
            mesh.VertexColor = Vector3.new(dynamicColor.R, dynamicColor.G, dynamicColor.B)
            
            -- Loa giật co giãn (nhấp nhô) to nhỏ theo sát từng lời hát/tiếng nhạc
            local scaleMultiplier = 1 + (math.clamp(loudness / 800, 0, 0.2))
            mesh.Scale = Vector3.new(scaleMultiplier, scaleMultiplier, scaleMultiplier)
        else
            RemoveBoombox()
        end
    end)
end

-- Tự động dọn dẹp khi nhân vật biến mất để chuẩn bị cho lần hồi sinh tiếp theo
LocalPlayer.CharacterRemoving:Connect(function()
    RemoveBoombox()
end)

-- TẠO GIAO DIỆN GUI NGUYÊN BẢN OỔN ĐỊNH
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Draggable = true
MainFrame.Active = true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Nút ẨN MENU
local HideBtn = Instance.new("TextButton", MainFrame)
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(0.85, 0, 0.05, 0)
HideBtn.Text = "-"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Instance.new("UICorner", HideBtn)
HideBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false 
end)

-- NÚT MỞ MENU (TP 🎵) - Kéo rê tự do
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.5, 0)
OpenBtn.Text = "TP 🎵"
OpenBtn.TextColor3 = Color3.new(1, 1, 1)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
OpenBtn.Draggable = true
OpenBtn.Active = true
Instance.new("UICorner", OpenBtn)
OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true 
end)

-- Tiêu đề Menu
local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(0.8, 0, 0, 30)
Title.Position = UDim2.new(0.05, 0, 0.05, 0)
Title.Text = "🎵 THANH PHÚC MUSIC"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Ô nhập ID Nhạc
local InputBox = Instance.new("TextBox", MainFrame)
InputBox.Size = UDim2.new(0.9, 0, 0, 40)
InputBox.Position = UDim2.new(0.05, 0, 0.25, 0)
InputBox.PlaceholderText = "Nhập ID nhạc..."
InputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InputBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", InputBox)

-- Nút PHÁT NHẠC
local PlayBtn = Instance.new("TextButton", MainFrame)
PlayBtn.Size = UDim2.new(0.9, 0, 0, 40)
PlayBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
PlayBtn.Text = "PHÁT NHẠC"
PlayBtn.TextColor3 = Color3.new(1, 1, 1)
PlayBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
Instance.new("UICorner", PlayBtn)

-- Xử lý khi nhấn Phát Nhạc (Bao gồm hồi sinh nhấn lại luôn luôn hiện)
PlayBtn.MouseButton1Click:Connect(function()
    local cleanID = InputBox.Text:match("%d+")
    if cleanID then
        LocalSound.SoundId = "rbxassetid://" .. cleanID
        LocalSound:Play()
        
        -- Kích hoạt ngay lập tức khối loa giật theo nhịp bài hát mới, sửa hoàn toàn lỗi mất loa
        CreateFakeBoombox()
        print("Thanh Phuc phát nhạc + Đồng bộ loa giật theo nhạc thành công!")
    else
        InputBox.Text = ""
        InputBox.PlaceholderText = "ID không hợp lệ!"
    end
end)

