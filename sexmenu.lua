local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Jenny Mod",
    Icon = 0,
    LoadingTitle = "gigachad hub V2",
    LoadingSubtitle = "sent ip to bitdancer",
    Theme = "Ocean",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = false,
    ConfigurationSaving = {Enabled = false},
    KeySystem = false,
})

local ModelTab = Window:CreateTab("Models", 4483362458)
local PlayersTab = Window:CreateTab("Players", 4483362458)
local OverlayTab = Window:CreateTab("Dih", 4483362458)
local AnimTab = Window:CreateTab("Animations", 4483362458)
local UtilsTab = Window:CreateTab("Misc", 4483362458)
local MapTab = Window:CreateTab("Map", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera

local Connections = {}
local spawnedModel = nil
local activeAnimation = nil
local legParts = {}
local animTracks = {model = nil, player = nil}
local freecamEnabled = false
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local spawnedMap = nil
local mapLightingBackup = {}
local usePlayerAvatar = false
local noclipConnection = nil

local Config = {
    ModelID = "6505562993",
    IdleID = "78892921889565",
    FreecamSpeed = 50
}

local AnimationData = {
    HandJob = {
        ModelAnimID = "86221594512888",
        PlayerAnimID = nil,
        OffsetR15 = Vector3.new(0.3, -1.0, -1.2),
        OffsetR6 = Vector3.new(0.5, -1.3, -1.3),
        Rotation = 90,
        HideLegs = true,
        Speed = 1
    },
    Backshots = {
        ModelAnimID = "124467382434182",
        PlayerAnimID = "105663812664252",
        OffsetR15 = Vector3.new(0, 0, -1.2),
        OffsetR6 = Vector3.new(0, 0, -1.1),
        Rotation = 0,
        HideLegs = false,
        Speed = 1
    },
    Twerk = {
        ModelAnimID = "109245869344007",
        PlayerAnimID = nil,
        OffsetR15 = Vector3.new(0, 0.1, -4.1),
        OffsetR6 = Vector3.new(0, 0.1, -4.1),
        Rotation = 0,
        HideLegs = false,
        Speed = 1
    },
    Oral = {
        ModelAnimID = "75351140540467",
        PlayerAnimID = nil,
        OffsetR15 = Vector3.new(0, 0, -1.7),
        OffsetR6 = Vector3.new(0, -0.2, -1.8),
        Rotation = 180,
        HideLegs = true,
        Speed = 1
    },
    Stretch = {
        ModelAnimID = "126017588998166",
        PlayerAnimID = nil,
        OffsetR15 = Vector3.new(0, 0, -2),
        OffsetR6 = Vector3.new(0, 0, -2),
        Rotation = 180,
        HideLegs = false,
        Speed = 1
    }
}

local function GetGravityCoil()
    local Tool = Instance.new("Tool")
    Tool.Name = "Gravity Coil"
    Tool.TextureId = "rbxassetid://16619617"
    Tool.CanBeDropped = true
    
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(1, 1.2, 2)
    Handle.CanCollide = false
    Handle.Parent = Tool
    
    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshId = "http://www.roblox.com/asset/?id=16606212"
    Mesh.TextureId = "http://www.roblox.com/asset/?id=16606141"
    Mesh.Scale = Vector3.new(0.7, 0.7, 0.7)
    Mesh.Parent = Handle
    
    local function onEquip()
        local char = Tool.Parent
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bf = Instance.new("BodyForce")
                bf.Name = "GravityCoilEffect"
                bf.Force = Vector3.new(0, workspace.Gravity * hrp.AssemblyMass * 0.8, 0)
                bf.Parent = hrp
            end
        end
    end
    
    local function onUnequip()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bf = char.HumanoidRootPart:FindFirstChild("GravityCoilEffect")
            if bf then bf:Destroy() end
        end
    end
    
    Tool.Equipped:Connect(onEquip)
    Tool.Unequipped:Connect(onUnequip)
    
    return Tool
end

local function GetSword()
    local Tool = Instance.new("Tool")
    Tool.Name = "Classic Sword"
    Tool.TextureId = "rbxasset://Textures/Sword128.png"
    Tool.GripForward = Vector3.new(-1, 0, 0)
    Tool.GripPos = Vector3.new(0, 0, -1.5)
    Tool.GripRight = Vector3.new(0, 1, 0)
    Tool.GripUp = Vector3.new(0, 0, 1)
    Tool.CanBeDropped = true
    
    local Handle = Instance.new("Part")
    Handle.Name = "Handle"
    Handle.Size = Vector3.new(1, 0.8, 4)
    Handle.CanCollide = false
    Handle.Reflectance = 0.4
    Handle.BrickColor = BrickColor.new("Dark stone grey")
    Handle.Parent = Tool
    
    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshId = "rbxasset://fonts/sword.mesh"
    Mesh.TextureId = "rbxasset://textures/SwordTexture.png"
    Mesh.Parent = Handle
    
    Tool.Activated:Connect(function()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://12575034"
        local track = Tool.Parent:FindFirstChild("Humanoid"):LoadAnimation(anim)
        track:Play()
    end)
    
    return Tool
end

local function Cleanup()
    if spawnedModel then spawnedModel:Destroy() spawnedModel = nil end
    if Character:FindFirstChild("Cock") then Character.Cock:Destroy() end
    for _, conn in pairs(Connections) do conn:Disconnect() end
    Connections = {}
    
    if animTracks.model then animTracks.model:Stop() end
    if animTracks.player then animTracks.player:Stop() end
    animTracks = {model = nil, player = nil}
    
    if freecamEnabled then
        Camera.CameraType = Enum.CameraType.Custom
        Humanoid.WalkSpeed = defaultWalkSpeed
        Humanoid.JumpPower = defaultJumpPower
        freecamEnabled = false
    end
    
    activeAnimation = nil
end

local function UpdateCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(function()
    Cleanup()
    UpdateCharacter()
end)

local function LoadAnimation(humanoid, id)
    local success, objects = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    local anim = nil
    if success and objects and objects[1] then
        anim = objects[1]:IsA("Animation") and objects[1] or objects[1]:FindFirstChildOfClass("Animation", true)
    end
    if not anim then
        anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://" .. id
    end
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    return track
end

local function SetLegs(visible)
    local transparency = visible and 0 or 1
    for _, part in pairs(legParts) do
        if part and part.Parent then part.Transparency = transparency end
    end
end

local function SpawnModel(id)
    if spawnedModel then spawnedModel:Destroy() end
    legParts = {}
    
    local success, assets = pcall(function() return game:GetObjects("rbxassetid://" .. id) end)
    if not success or not assets[1] then 
        Rayfield:Notify({Title = "Error", Content = "Failed to load model.", Duration = 3})
        return 
    end
    
    spawnedModel = assets[1]
    spawnedModel.Name = "LinkedModel"
    spawnedModel.Parent = Workspace
    
    if not spawnedModel.PrimaryPart then
        for _, part in pairs(spawnedModel:GetDescendants()) do
            if part:IsA("BasePart") then
                spawnedModel.PrimaryPart = part
                break
            end
        end
    end
    
    for _, v in pairs(spawnedModel:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.Massless = true
            if v.Name:lower():find("leg") or v.Name:lower():find("foot") then
                table.insert(legParts, v)
            end
        end
    end

    local mHum = spawnedModel:FindFirstChildOfClass("Humanoid")
    if mHum then
        mHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        local idle = LoadAnimation(mHum, Config.IdleID)
        idle.Looped = true
        idle:Play()
    end
    
    Connections["FollowLoop"] = RunService.Heartbeat:Connect(function()
        if not spawnedModel or not spawnedModel.PrimaryPart or not RootPart then return end
        
        if activeAnimation then
            local data = AnimationData[activeAnimation]
            local isR15 = Humanoid.RigType == Enum.HumanoidRigType.R15
            local offset = isR15 and data.OffsetR15 or data.OffsetR6
            spawnedModel:PivotTo(RootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.rad(data.Rotation), 0))
        else
            local targetPos = (RootPart.CFrame * CFrame.new(2.5, -0.5, 3)).Position
            spawnedModel:PivotTo(CFrame.new(targetPos, RootPart.Position))
        end
    end)
end

local function SpawnR6Girl()
    local modelId = "127481679655212"
    local success, assets = pcall(function()
        return game:GetObjects("rbxassetid://" .. modelId)
    end)

    if success and assets[1] then
        if spawnedModel then spawnedModel:Destroy() end
        spawnedModel = assets[1]
        spawnedModel.Name = "R6GirlModel"
        spawnedModel.Parent = Workspace
        
        local hrp = Character:WaitForChild("HumanoidRootPart")
        local spawnPos = hrp.CFrame * CFrame.new(0, 0, -5)
        
        if spawnedModel:IsA("Model") then
            spawnedModel:PivotTo(spawnPos)
        end
        
        Connections["R6GirlFollow"] = RunService.Heartbeat:Connect(function()
            if not spawnedModel or not spawnedModel.PrimaryPart or not RootPart then return end
            
            if activeAnimation then
                local data = AnimationData[activeAnimation]
                local isR15 = Humanoid.RigType == Enum.HumanoidRigType.R15
                local offset = isR15 and data.OffsetR15 or data.OffsetR6
                spawnedModel:PivotTo(RootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.rad(data.Rotation), 0))
            else
                local targetPos = (RootPart.CFrame * CFrame.new(2.5, -0.5, 3)).Position
                spawnedModel:PivotTo(CFrame.new(targetPos, RootPart.Position))
            end
        end)
        
        local mHum = spawnedModel:FindFirstChildOfClass("Humanoid")
        if mHum then
            mHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            local idle = LoadAnimation(mHum, Config.IdleID)
            idle.Looped = true
            idle:Play()
        end
    end
end

local function GetPlayersList()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    if #players == 0 then table.insert(players, "No Players Found") end
    return players
end

local function SpawnPlayerModel(playerName, useAvatar)
    if not playerName then return end
    local player = Players:FindFirstChild(playerName)
    if not player or not player.Character then return end
    
    if spawnedModel then spawnedModel:Destroy() end
    legParts = {}
    
    if useAvatar then
        local success, clone = pcall(function()
            local char = player.Character
            char.Archivable = true
            local c = char:Clone()
            char.Archivable = false
            return c
        end)

        if not success or not clone then return end

        clone.Name = "PlayerAvatarClone"
        clone.Parent = Workspace
        spawnedModel = clone
        
        for _, v in pairs(clone:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
                v.Massless = true
                v.Anchored = false
                if v.Name:lower():find("leg") or v.Name:lower():find("foot") then
                    table.insert(legParts, v)
                end
            elseif v:IsA("Script") or v:IsA("LocalScript") then
                v:Destroy()
            end
        end

        local mHum = clone:FindFirstChildOfClass("Humanoid")
        if mHum then
            mHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            mHum.PlatformStand = false
            local idle = LoadAnimation(mHum, Config.IdleID)
            idle.Looped = true
            idle:Play()
        end
        
        Connections["PlayerFollow"] = RunService.Heartbeat:Connect(function()
            if not spawnedModel or not spawnedModel.PrimaryPart or not RootPart then return end
            
            if activeAnimation then
                local data = AnimationData[activeAnimation]
                local isR15 = Humanoid.RigType == Enum.HumanoidRigType.R15
                local offset = isR15 and data.OffsetR15 or data.OffsetR6
                spawnedModel:PivotTo(RootPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, math.rad(data.Rotation), 0))
            else
                local targetPos = (RootPart.CFrame * CFrame.new(2.5, -0.5, 3)).Position
                spawnedModel:PivotTo(CFrame.new(targetPos, RootPart.Position))
            end
        end)
    else
        local marker = Instance.new("Part")
        marker.Size = Vector3.new(2, 4, 2)
        marker.Color = Color3.fromRGB(255, 0, 0)
        marker.Transparency = 0.5
        marker.CanCollide = false
        marker.Anchored = true
        marker.Name = "PlayerMarker"
        marker.Parent = Workspace
        spawnedModel = marker
        
        Connections["MarkerFollow"] = RunService.Heartbeat:Connect(function()
            if not spawnedModel or not player.Character or not player.Character.PrimaryPart then return end
            spawnedModel.CFrame = player.Character.PrimaryPart.CFrame * CFrame.new(0, 5, 0)
        end)
    end
end

local function SpawnCock()
    local folderName = "meshes"
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local function getAsset(id)
        if id:find("rbxassetid://") or id:find("http") then return id end
        local cleanId = id:match("([^/]+)$") or id
        local path = folderName .. "/" .. cleanId
        if isfile and isfile(path) then
            return getcustomasset(path)
        end
        return id:find("rbxasset://") and id or "rbxassetid://" .. cleanId
    end

    local Cock = Instance.new("Model")
    Cock.Name = "Cock"
    Cock.Parent = char

    local BaseBone = Instance.new("Bone")
    BaseBone.Name = "BaseBone"

    local MidBone = Instance.new("Bone")
    MidBone.Name = "MidBone"
    MidBone.Position = Vector3.new(0, -0.4, 0)

    local TipBone = Instance.new("Bone")
    TipBone.Name = "TipBone"
    TipBone.Position = Vector3.new(0, -0.4, 0)

    local P_C = Instance.new("Part")
    P_C.Name = "P_C"
    P_C.Size = Vector3.new(1.484, 0.526, 0.539)
    P_C.Color = Color3.fromRGB(163, 162, 165)
    P_C.Material = Enum.Material.SmoothPlastic
    P_C.CanCollide = false
    P_C.Massless = false
    P_C.CustomPhysicalProperties = PhysicalProperties.new(0.5, 0.3, 0.5, 1, 1)
    P_C.Parent = Cock

    BaseBone.Parent = P_C
    MidBone.Parent = BaseBone
    TipBone.Parent = MidBone

    local baseAttachment = Instance.new("Attachment")
    baseAttachment.Name = "BaseAttachment"
    baseAttachment.Position = Vector3.new(0, 0.26, 0)
    baseAttachment.Parent = P_C

    local midAttachment = Instance.new("Attachment")
    midAttachment.Name = "MidAttachment"
    midAttachment.Position = Vector3.new(0, -0.14, 0)
    midAttachment.Parent = P_C

    local tipAttachment = Instance.new("Attachment")
    tipAttachment.Name = "TipAttachment"
    tipAttachment.Position = Vector3.new(0, -0.54, 0)
    tipAttachment.Parent = P_C

    local P_C_Mesh = Instance.new("SpecialMesh")
    P_C_Mesh.MeshId = getAsset("7093427066")
    P_C_Mesh.MeshType = Enum.MeshType.FileMesh
    P_C_Mesh.Parent = P_C

    local X_B = Instance.new("Part")
    X_B.Name = "X_B"
    X_B.Size = Vector3.new(0.447, 0.852, 0.723)
    X_B.Color = Color3.fromRGB(234, 184, 146)
    X_B.CanCollide = false
    X_B.Massless = true
    X_B.Parent = P_C

    local X_B_Mesh = Instance.new("SpecialMesh")
    X_B_Mesh.MeshId = getAsset("afdbbb7cf29f0798d6fa6ff07e08553e")
    X_B_Mesh.MeshType = Enum.MeshType.FileMesh
    X_B_Mesh.Parent = X_B

    local XB_Weld = Instance.new("Weld")
    XB_Weld.Part0 = P_C
    XB_Weld.Part1 = X_B
    XB_Weld.C0 = CFrame.new(0.27, -0.31, 0.12) * CFrame.Angles(math.rad(-20.7), math.rad(-180), math.rad(8.76))
    XB_Weld.Parent = X_B

    local NewPC = Instance.new("Part")
    NewPC.Name = "NewPC"
    NewPC.Size = Vector3.new(1.484, 0.526, 0.539)
    NewPC.Color = Color3.fromRGB(234, 184, 146)
    NewPC.CanCollide = false
    NewPC.Massless = true
    NewPC.Parent = P_C

    local NewPC_Mesh = Instance.new("SpecialMesh")
    NewPC_Mesh.MeshId = getAsset("767088ba9f373e77b2f56a757248670f")
    NewPC_Mesh.MeshType = Enum.MeshType.FileMesh
    NewPC_Mesh.Parent = NewPC

    local NewPC_Weld = Instance.new("Weld")
    NewPC_Weld.Part0 = P_C
    NewPC_Weld.Part1 = NewPC
    NewPC_Weld.C0 = CFrame.new(-0.0023, 0, -0.004)
    NewPC_Weld.Parent = NewPC

    local T = Instance.new("Part")
    T.Name = "T"
    T.Size = Vector3.new(0.431, 0.383, 0.428)
    T.Color = Color3.fromRGB(218, 134, 122)
    T.Material = Enum.Material.Glass
    T.CanCollide = false
    T.Massless = true
    T.Parent = P_C

    local T_Mesh = Instance.new("SpecialMesh")
    T_Mesh.MeshId = getAsset("564d1bf18317a0a46b5a2b0077733b4f")
    T_Mesh.MeshType = Enum.MeshType.FileMesh
    T_Mesh.Parent = T

    local T_Joint = Instance.new("Motor6D")
    T_Joint.Name = "NewPC"
    T_Joint.Part0 = P_C
    T_Joint.Part1 = T
    T_Joint.C0 = CFrame.new(-0.711918, 0.040504, 0.005760, -0.994518, 0, -0.104565, 0, 1, 0, 0.104565, 0, -0.994518)
    T_Joint.Parent = P_C

    local Cum = Instance.new("ParticleEmitter")
    Cum.Name = "Cum"
    Cum.Texture = "http://www.roblox.com/asset/?id=141285996"
    Cum.Rate = 0
    Cum.Lifetime = NumberRange.new(3.25)
    Cum.Speed = NumberRange.new(1)
    Cum.Acceleration = Vector3.new(0, -1, 0)
    Cum.Size = NumberSequence.new(0.3)
    Cum.EmissionDirection = Enum.NormalId.Bottom
    Cum.Parent = T

    local root = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso") or char.HumanoidRootPart
    local isR15 = char:FindFirstChild("LowerTorso") ~= nil

    local weldOffset, weldRotation
    if isR15 then
        weldOffset = CFrame.new(0, -0.1, -0.8)
        weldRotation = CFrame.Angles(math.rad(20), math.rad(-90), math.rad(0))
    else
        weldOffset = CFrame.new(0.02, -0.97, -0.91)
        weldRotation = CFrame.Angles(math.rad(3.43), math.rad(-90.86), math.rad(10.29))
    end

    local BodyWeld = Instance.new("Weld")
    BodyWeld.Name = "BodyWeld"
    BodyWeld.Part0 = root
    BodyWeld.Part1 = P_C
    BodyWeld.C0 = weldOffset * weldRotation
    BodyWeld.Parent = P_C

    local ballSocket = Instance.new("BallSocketConstraint")
    ballSocket.Name = "MidSocket"
    ballSocket.Attachment0 = baseAttachment
    ballSocket.Attachment1 = midAttachment
    ballSocket.LimitsEnabled = true
    ballSocket.UpperAngle = 45
    ballSocket.TwistLimitsEnabled = true
    ballSocket.TwistUpperAngle = 30
    ballSocket.TwistLowerAngle = -30
    ballSocket.Parent = P_C

    local spring = Instance.new("SpringConstraint")
    spring.Name = "MidSpring"
    spring.Attachment0 = baseAttachment
    spring.Attachment1 = midAttachment
    spring.FreeLength = 0.4
    spring.Stiffness = 150
    spring.Damping = 15
    spring.Parent = P_C

    local tipSocket = Instance.new("BallSocketConstraint")
    tipSocket.Name = "TipSocket"
    tipSocket.Attachment0 = midAttachment
    tipSocket.Attachment1 = tipAttachment
    tipSocket.LimitsEnabled = true
    tipSocket.UpperAngle = 35
    tipSocket.TwistLimitsEnabled = true
    tipSocket.TwistUpperAngle = 25
    tipSocket.TwistLowerAngle = -25
    tipSocket.Parent = P_C

    local tipSpring = Instance.new("SpringConstraint")
    tipSpring.Name = "TipSpring"
    tipSpring.Attachment0 = midAttachment
    tipSpring.Attachment1 = tipAttachment
    tipSpring.FreeLength = 0.4
    tipSpring.Stiffness = 100
    tipSpring.Damping = 12
    tipSpring.Parent = P_C

    Connections["CockWobble"] = RunService.Heartbeat:Connect(function()
        if not P_C or not P_C.Parent then return end
        local velocity = P_C.AssemblyLinearVelocity
        local speed = velocity.Magnitude
        
        if speed > 2 then
            local wobbleForce = speed * 0.5
            midAttachment.WorldPosition = midAttachment.WorldPosition + Vector3.new(
                math.sin(tick() * 8) * wobbleForce * 0.01,
                0,
                math.cos(tick() * 8) * wobbleForce * 0.01
            )
        end
    end)

    local toggle = false
    Connections["CumToggle"] = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F then
            toggle = not toggle
            Cum.Rate = toggle and 58 or 0
        end
    end)
end

local function ToggleAnimation(name)
    if not spawnedModel then return end
    
    if activeAnimation and activeAnimation ~= name then
        if animTracks.model then animTracks.model:Stop() end
        if animTracks.player then animTracks.player:Stop() end
    end

    local data = AnimationData[name]
    activeAnimation = name
    SetLegs(not data.HideLegs)

    local isR15 = Humanoid.RigType == Enum.HumanoidRigType.R15

    local mHum = spawnedModel:FindFirstChildOfClass("Humanoid")
    if mHum then
        for _, t in pairs(mHum:GetPlayingAnimationTracks()) do t:Stop() end
        animTracks.model = LoadAnimation(mHum, data.ModelAnimID)
        animTracks.model.Looped = true
        animTracks.model:AdjustSpeed(data.Speed)
        animTracks.model:Play()
    end

    if data.PlayerAnimID then
        for _, t in pairs(Humanoid:GetPlayingAnimationTracks()) do t:Stop() end
        animTracks.player = LoadAnimation(Humanoid, data.PlayerAnimID)
        animTracks.player.Looped = true
        animTracks.player:AdjustSpeed(data.Speed)
        animTracks.player:Play()
    end
end

local function ToggleFreecam(enable)
    freecamEnabled = enable
    
    if enable then
        defaultWalkSpeed = Humanoid.WalkSpeed
        defaultJumpPower = Humanoid.JumpPower
        Humanoid.WalkSpeed = 0
        Humanoid.JumpPower = 0
        
        Camera.CameraType = Enum.CameraType.Scriptable
        
        Connections["Freecam"] = RunService.RenderStepped:Connect(function(dt)
            if not freecamEnabled then return end
            
            local speed = Config.FreecamSpeed * (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 2 or 1)
            local move = Vector3.new()
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then move = move + Camera.CFrame.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then move = move - Camera.CFrame.UpVector end
            
            Camera.CFrame = Camera.CFrame + (move * speed * dt)
            
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                local delta = UserInputService:GetMouseDelta()
                Camera.CFrame = Camera.CFrame * CFrame.Angles(math.rad(-delta.Y * 0.5), math.rad(-delta.X * 0.5), 0)
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
        end)
    else
        if Connections["Freecam"] then Connections["Freecam"]:Disconnect() end
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        Humanoid.WalkSpeed = defaultWalkSpeed
        Humanoid.JumpPower = defaultJumpPower
        if animTracks.player then animTracks.player:Stop() end
    end
end

local function SaveLighting()
    mapLightingBackup = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        FogColor = Lighting.FogColor
    }
end

local function RestoreLighting()
    if not mapLightingBackup.Ambient then return end
    Lighting.Ambient = mapLightingBackup.Ambient
    Lighting.OutdoorAmbient = mapLightingBackup.OutdoorAmbient
    Lighting.Brightness = mapLightingBackup.Brightness
    Lighting.ClockTime = mapLightingBackup.ClockTime
    Lighting.FogEnd = mapLightingBackup.FogEnd
    Lighting.FogColor = mapLightingBackup.FogColor
    
    for _, v in pairs(Lighting:GetChildren()) do
        if v.Name == "MapEffect" then v:Destroy() end
    end
end

local function CleanMap()
    if spawnedMap then 
        spawnedMap:Destroy() 
        spawnedMap = nil 
    end
    Terrain:Clear()
    RestoreLighting()
end

local function CreatePart(size, pos, color, material, parent, anchored)
    local p = Instance.new("Part")
    p.Size = size
    p.Position = pos
    p.Anchored = (anchored == nil and true or anchored)
    p.Color = color
    p.Material = material or Enum.Material.Plastic
    p.Parent = parent
    return p
end

local function CreateClassicBaseplate()
    CleanMap()
    SaveLighting()
    
    local map = Instance.new("Model")
    map.Name = "ClassicBaseplate"
    map.Parent = Workspace
    spawnedMap = map

    local base = CreatePart(
        Vector3.new(512, 1, 512),
        Vector3.new(0, 5000, 0),
        Color3.fromRGB(60, 60, 60),
        Enum.Material.Concrete,
        map
    )
    
    local texture = Instance.new("Texture")
    texture.Texture = "rbxassetid://6372755229"
    texture.StudsPerTileU = 4
    texture.StudsPerTileV = 4
    texture.Face = Enum.NormalId.Top
    texture.Parent = base
    
    local wallHeight = 12
    for i = -1, 1, 2 do
        CreatePart(
            Vector3.new(512, wallHeight, 2),
            Vector3.new(0, 5000 + (wallHeight/2), i * 256),
            Color3.fromRGB(40, 40, 40),
            Enum.Material.Concrete,
            map
        )
        CreatePart(
            Vector3.new(2, wallHeight, 512),
            Vector3.new(i * 256, 5000 + (wallHeight/2), 0),
            Color3.fromRGB(40, 40, 40),
            Enum.Material.Concrete,
            map
        )
    end
    
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
end

local function CreateModernRoom()
    CleanMap()
    SaveLighting()
    
    local map = Instance.new("Model")
    map.Name = "LuxuryBedroom"
    map.Parent = Workspace
    spawnedMap = map
    
    local floorY = 5000
    local roomSize = 40
    local wallHeight = 14
    
    local floor = CreatePart(
        Vector3.new(roomSize, 1, roomSize),
        Vector3.new(0, floorY, 0),
        Color3.fromRGB(110, 80, 50),
        Enum.Material.WoodPlanks,
        map
    )
    
    local function MakeWall(size, pos, color)
        return CreatePart(size, pos, color, Enum.Material.SmoothPlastic, map)
    end
    
    local wallColor = Color3.fromRGB(235, 235, 230)
    MakeWall(Vector3.new(roomSize, wallHeight, 1), Vector3.new(0, floorY + wallHeight/2, -roomSize/2), wallColor)
    MakeWall(Vector3.new(roomSize, wallHeight, 1), Vector3.new(0, floorY + wallHeight/2, roomSize/2), wallColor)
    MakeWall(Vector3.new(1, wallHeight, roomSize), Vector3.new(-roomSize/2, floorY + wallHeight/2, 0), wallColor)
    MakeWall(Vector3.new(1, wallHeight, roomSize), Vector3.new(roomSize/2, floorY + wallHeight/2, 0), wallColor)
    
    CreatePart(
        Vector3.new(roomSize, 1, roomSize),
        Vector3.new(0, floorY + wallHeight, 0),
        Color3.fromRGB(250, 250, 250),
        Enum.Material.SmoothPlastic,
        map
    )
    
    local bedPos = Vector3.new(0, floorY + 1.5, -roomSize/2 + 6)
    
    CreatePart(Vector3.new(6.5, 1, 8.5), bedPos, Color3.fromRGB(40, 30, 20), Enum.Material.Wood, map)
    CreatePart(Vector3.new(6, 1, 8), bedPos + Vector3.new(0, 1, 0), Color3.fromRGB(240, 240, 240), Enum.Material.Fabric, map)
    CreatePart(Vector3.new(7, 5, 0.5), bedPos + Vector3.new(0, 2, -4.25), Color3.fromRGB(40, 30, 20), Enum.Material.Wood, map)
    CreatePart(Vector3.new(2.5, 0.8, 1.5), bedPos + Vector3.new(-1.5, 1.8, -3), Color3.fromRGB(255, 255, 255), Enum.Material.Fabric, map)
    CreatePart(Vector3.new(2.5, 0.8, 1.5), bedPos + Vector3.new(1.5, 1.8, -3), Color3.fromRGB(255, 255, 255), Enum.Material.Fabric, map)
    
    for i = -1, 1, 2 do
        local nsPos = bedPos + Vector3.new(i * 5, -0.5, -2)
        CreatePart(Vector3.new(2.5, 2.5, 2.5), nsPos, Color3.fromRGB(50, 40, 30), Enum.Material.Wood, map)
        local lampBase = CreatePart(Vector3.new(0.5, 1, 0.5), nsPos + Vector3.new(0, 1.75, 0), Color3.fromRGB(20, 20, 20), Enum.Material.Metal, map)
        local lampShade = CreatePart(Vector3.new(1.5, 1, 1.5), nsPos + Vector3.new(0, 2.5, 0), Color3.fromRGB(255, 250, 220), Enum.Material.Neon, map)
        local light = Instance.new("PointLight", lampShade)
        light.Range = 15
        light.Brightness = 0.8
        light.Color = Color3.fromRGB(255, 240, 200)
    end
    
    CreatePart(Vector3.new(12, 0.1, 10), bedPos + Vector3.new(0, -1.45, 6), Color3.fromRGB(180, 180, 190), Enum.Material.Fabric, map)
    
    Lighting.ClockTime = 21
    Lighting.Brightness = 0.5
    Lighting.Ambient = Color3.fromRGB(40, 40, 40)
    Lighting.OutdoorAmbient = Color3.fromRGB(20, 20, 20)
    
    local blur = Instance.new("BlurEffect", Lighting)
    blur.Name = "MapEffect"
    blur.Size = 2
end

local function CreateGrassTerrainBaseplate()
    CleanMap()
    SaveLighting()
    
    local map = Instance.new("Model")
    map.Name = "NatureTerrain"
    map.Parent = Workspace
    spawnedMap = map
    
    local center = Vector3.new(0, 5000, 0)
    
    Terrain:FillBlock(CFrame.new(center), Vector3.new(256, 4, 256), Enum.Material.Grass)
    
    for i = 1, 30 do
        local x = math.random(-120, 120)
        local z = math.random(-120, 120)
        local pos = center + Vector3.new(x, 2, z)
        
        local trunkHeight = math.random(6, 10)
        CreatePart(Vector3.new(1.5, trunkHeight, 1.5), pos + Vector3.new(0, trunkHeight/2, 0), Color3.fromRGB(90, 60, 30), Enum.Material.Wood, map)
        
        local leavesPos = pos + Vector3.new(0, trunkHeight, 0)
        local leaves = CreatePart(Vector3.new(8, 6, 8), leavesPos, Color3.fromRGB(30, 100, 30), Enum.Material.Grass, map)
        leaves.Shape = Enum.PartType.Ball
    end
    
    for i = 1, 15 do
        local x = math.random(-120, 120)
        local z = math.random(-120, 120)
        local rock = CreatePart(Vector3.new(math.random(3,6), math.random(2,4), math.random(3,6)), center + Vector3.new(x, 2, z), Color3.fromRGB(100, 100, 100), Enum.Material.Slate, map)
        rock.Orientation = Vector3.new(math.random(0,360), math.random(0,360), math.random(0,360))
    end
    
    Lighting.ClockTime = 12
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(150, 150, 150)
    
    local sky = Instance.new("Sky", Lighting)
    sky.Name = "MapEffect"
    sky.SkyboxBk = "http://www.roblox.com/asset/?id=159454299"
    sky.SkyboxDn = "http://www.roblox.com/asset/?id=159454296"
    sky.SkyboxFt = "http://www.roblox.com/asset/?id=159454293"
    sky.SkyboxLf = "http://www.roblox.com/asset/?id=159454286"
    sky.SkyboxRt = "http://www.roblox.com/asset/?id=159454300"
    sky.SkyboxUp = "http://www.roblox.com/asset/?id=159454288"
end

local function CreateProperObby()
    CleanMap()
    SaveLighting()
    
    local map = Instance.new("Model")
    map.Name = "ProperObby"
    map.Parent = Workspace
    spawnedMap = map
    
    local startPos = Vector3.new(0, 5000, 0)
    
    local startPlat = CreatePart(Vector3.new(16, 1, 16), startPos, Color3.fromRGB(0, 255, 0), Enum.Material.Neon, map)
    local spawn = Instance.new("SpawnLocation", map)
    spawn.Size = startPlat.Size
    spawn.CFrame = startPlat.CFrame + Vector3.new(0, 1, 0)
    spawn.Transparency = 1
    spawn.CanCollide = false
    
    local currentPos = startPos
    for i = 1, 20 do
        currentPos = currentPos + Vector3.new(0, 1, 10)
        CreatePart(Vector3.new(6, 1, 6), currentPos, Color3.fromHSV(i/20, 1, 1), Enum.Material.Plastic, map)
    end
    
    local winPos = currentPos + Vector3.new(0, 0, 15)
    local winPlat = CreatePart(Vector3.new(20, 1, 20), winPos, Color3.fromRGB(255, 215, 0), Enum.Material.Neon, map)
    
    local function MakeGiver(offset, color, toolName, toolFunc)
        local pad = CreatePart(Vector3.new(4, 1, 4), winPos + offset, color, Enum.Material.Neon, map)
        
        local bb = Instance.new("BillboardGui", pad)
        bb.Size = UDim2.new(0, 100, 0, 50)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        local txt = Instance.new("TextLabel", bb)
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = toolName
        txt.TextColor3 = color
        txt.TextStrokeTransparency = 0
        
        pad.Touched:Connect(function(hit)
            if hit.Parent == LocalPlayer.Character then
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack and not backpack:FindFirstChild(toolName) and not LocalPlayer.Character:FindFirstChild(toolName) then
                    local tool = toolFunc()
                    tool.Parent = backpack
                    Rayfield:Notify({Title = "Item Received", Content = "You got " .. toolName, Duration = 2})
                end
            end
        end)
    end
    
    MakeGiver(Vector3.new(-6, 1, 0), Color3.fromRGB(255, 0, 0), "Classic Sword", GetSword)
    MakeGiver(Vector3.new(6, 1, 0), Color3.fromRGB(0, 100, 255), "Gravity Coil", GetGravityCoil)
    
    Lighting.ClockTime = 14
end

local function TeleportToMap()
    if not spawnedMap then return end
    
    local targetY = 5005
    if Character and RootPart then
        RootPart.CFrame = CFrame.new(0, targetY, 0)
    end
end

ModelTab:CreateSection("Models")
ModelTab:CreateButton({
    Name = "Girl (R6)",
    Callback = function() SpawnR6Girl() end,
})

ModelTab:CreateButton({
    Name = "Girl (R15)",
    Callback = function() SpawnModel("12318179443") end,
})

ModelTab:CreateButton({
    Name = "Clean Up Models",
    Callback = function() 
        if spawnedModel then spawnedModel:Destroy() spawnedModel = nil end
        if Character:FindFirstChild("Cock") then Character.Cock:Destroy() end
    end,
})

PlayersTab:CreateSection("Player Selection")
PlayersTab:CreateToggle({
    Name = "Use Player",
    CurrentValue = false,
    Callback = function(Value) usePlayerAvatar = Value end,
})

local playerList = GetPlayersList()
local PlayerDropdown = PlayersTab:CreateDropdown({
    Name = "Select Player",
    Options = playerList,
    CurrentOption = {playerList[1]},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        local name = (type(Option) == "table") and Option[1] or Option
        if name and name ~= "No Players Found" then
            SpawnPlayerModel(name, usePlayerAvatar)
        end
    end,
})

PlayersTab:CreateButton({
    Name = "Refresh Player List",
    Callback = function()
        playerList = GetPlayersList()
        PlayerDropdown:Refresh(playerList)
        PlayerDropdown:Set(playerList[1])
    end,
})

OverlayTab:CreateSection("Dick")
OverlayTab:CreateButton({
    Name = "Spawn Dick",
    Callback = function() SpawnCock() end,
})

AnimTab:CreateSection("Animations")
AnimTab:CreateButton({
    Name = "Hand Job",
    Callback = function() ToggleAnimation("HandJob") end,
})

AnimTab:CreateButton({
    Name = "Backshots",
    Callback = function() ToggleAnimation("Backshots") end,
})

AnimTab:CreateButton({
    Name = "Twerk",
    Callback = function() ToggleAnimation("Twerk") end,
})

AnimTab:CreateButton({
    Name = "Stretch",
    Callback = function() ToggleAnimation("Stretch") end,
})

AnimTab:CreateButton({
    Name = "Head",
    Callback = function() ToggleAnimation("Oral") end,
})

AnimTab:CreateButton({
    Name = "Stop Animations",
    Callback = function() 
        if animTracks.model then animTracks.model:Stop() end
        if animTracks.player then animTracks.player:Stop() end
        activeAnimation = nil
    end,
})

UtilsTab:CreateSection("Utilities")
UtilsTab:CreateToggle({
    Name = "Freecam",
    CurrentValue = false,
    Callback = function(Value) ToggleFreecam(Value) end,
})

UtilsTab:CreateSlider({
    Name = "Freecam Speed",
    Range = {10, 200},
    Increment = 10,
    CurrentValue = 50,
    Suffix = " studs/sec",
    Callback = function(Value)
        Config.FreecamSpeed = Value
    end,
})

UtilsTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            if noclipConnection then noclipConnection:Disconnect() end
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end,
})

UtilsTab:CreateDivider()

UtilsTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/4BhZhsqQJK")
        end
    end,
})

MapTab:CreateSection("Maps to sex on")

MapTab:CreateButton({
    Name = "Baseplate",
    Callback = function()
        CreateClassicBaseplate()
        task.wait(0.5)
        TeleportToMap()
    end,
})

MapTab:CreateButton({
    Name = "Bedroom",
    Callback = function()
        CreateModernRoom()
        task.wait(0.5)
        TeleportToMap()
    end,
})

MapTab:CreateButton({
    Name = "Forest",
    Callback = function()
        CreateGrassTerrainBaseplate()
        task.wait(0.5)
        TeleportToMap()
    end,
})

MapTab:CreateButton({
    Name = "Obby",
    Callback = function()
        CreateProperObby()
        task.wait(0.5)
        TeleportToMap()
    end,
})

MapTab:CreateDivider()

MapTab:CreateButton({
    Name = "Teleport to Map",
    Callback = function() TeleportToMap() end,
})

MapTab:CreateButton({
    Name = "Delete Map",
    Callback = function() CleanMap() end,
})
