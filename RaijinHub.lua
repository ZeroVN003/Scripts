if game:GetService("CoreGui"):FindFirstChild("RaijinHub") then
    game:GetService("CoreGui"):FindFirstChild("RaijinHub"):Destroy()
    task.wait(0.2)
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VIM = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local hasDrawing = pcall(function() return Drawing.new end)

local theme = {
    bg = Color3.fromRGB(9, 9, 13),
    panel = Color3.fromRGB(20, 20, 28),
    side = Color3.fromRGB(13, 13, 19),
    accent = Color3.fromRGB(255, 64, 92),
    dim = Color3.fromRGB(140, 32, 52),
    text = Color3.fromRGB(238, 238, 245),
    sub = Color3.fromRGB(140, 140, 155),
    off = Color3.fromRGB(44, 44, 56),
}

local flags = {
    autoAttack = false, attackTp = true, farmRange = 400, farmDelay = 0.4, autoClick = false,
    priority = "Gan nhat",
    autoStats = false, autoEquip = false,
    speedEnabled = false, speedVal = 60, jumpEnabled = false, jumpVal = 100,
    noclip = false, fly = false, flySpeed = 60, fovEnabled = false, fovVal = 70,
    espEnabled = false, espBox = false, espName = false, espTracer = false, espHealth = true,
    espPlayers = true, espMobs = false, espFruits = false, espChests = false, espDist = 4000,
    sniper = false, sniperTp = false, sniperGrab = false,
    fullbright = false, timeEnabled = false, timeVal = 12,
    autosave = true, tpIsland = "Starter",
}

local Engine = { threads = {}, conns = {}, dead = false }
function Engine.spawn(fn)
    local th = task.spawn(fn)
    table.insert(Engine.threads, th)
    return th
end
function Engine.connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(Engine.conns, c)
    return c
end

local function new(class, props)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do i[k] = v end
    return i
end
local function corner(i, r)
    local c = new("UICorner", { CornerRadius = UDim.new(0, r or 8) })
    c.Parent = i
    return c
end
local function notify(title, text, dur)
    local g = new("ScreenGui", { Name = "RaijinNotif", Parent = game:GetService("CoreGui") })
    local f = new("Frame", { BackgroundColor3 = Color3.fromRGB(18, 18, 26), BorderSizePixel = 0, Size = UDim2.fromOffset(260, 60), Position = UDim2.new(1, -280, 0, -60), Parent = g })
    corner(f, 8)
    new("UIStroke", { Color = theme.accent, Thickness = 1.5, Parent = f })
    new("TextLabel", { Text = title, TextColor3 = theme.accent, Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 6), TextXAlignment = Enum.TextXAlignment.Left, Parent = f })
    new("TextLabel", { Text = text, TextColor3 = Color3.fromRGB(220, 220, 230), Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 26), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = f })
    local t1 = TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Position = UDim2.new(1, -280, 0, 20) })
    t1:Play()
    task.delay(dur or 3, function()
        local t2 = TweenService:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, -280, 0, -60) })
        t2:Play()
        t2.Completed:Connect(function() g:Destroy() end)
    end)
end

local gui = new("ScreenGui", { Name = "RaijinHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = game:GetService("CoreGui") })
local main = new("Frame", { BackgroundColor3 = theme.bg, BorderSizePixel = 0, Size = UDim2.fromOffset(580, 420), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Parent = gui })
corner(main, 12)
new("UIStroke", { Color = theme.accent, Thickness = 1.5, Parent = main })

local side = new("Frame", { BackgroundColor3 = theme.side, BorderSizePixel = 0, Size = UDim2.new(0, 120, 1, 0), Parent = main })
new("TextLabel", { Text = "RAIJIN", TextColor3 = theme.accent, Font = Enum.Font.GothamBlack, TextSize = 20, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 14), Parent = side })
new("TextLabel", { Text = "KING LEGACY", TextColor3 = theme.sub, Font = Enum.Font.GothamBold, TextSize = 9, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 40), Parent = side })
new("TextLabel", { Text = "NO KEY - FREE", TextColor3 = Color3.fromRGB(90, 220, 140), Font = Enum.Font.GothamBold, TextSize = 10, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 0, 58), Parent = side })

local drag, dragOffset = false, Vector2.new()
Engine.connect(side.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = true
        dragOffset = UIS:GetMouseLocation() - main.AbsolutePosition
    end
end)
Engine.connect(side.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
end)
Engine.connect(UIS.InputChanged, function(input)
    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
        local m = UIS:GetMouseLocation()
        main.Position = UDim2.fromOffset(m.X - dragOffset.X, m.Y - dragOffset.Y)
    end
end)
Engine.connect(UIS.InputBegan, function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        gui.Enabled = not gui.Enabled
    end
end)

local content = new("Frame", { BackgroundColor3 = theme.bg, BorderSizePixel = 0, Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 120, 0, 0), Parent = main })
local tabBtns, tabBars, pages, pageY = {}, {}, {}, {}
local function makeTab(name)
    local i = #tabBtns + 1
    local btn = new("TextButton", { Text = name, TextColor3 = theme.sub, Font = Enum.Font.GothamBold, TextSize = 12, BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, -16, 0, 34), Position = UDim2.new(0, 8, 0, 84 + (i - 1) * 38), TextXAlignment = Enum.TextXAlignment.Left, Parent = side })
    local bar = new("Frame", { BackgroundColor3 = theme.accent, BorderSizePixel = 0, Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 2, 0.5, -9), Visible = false, Parent = btn })
    table.insert(tabBtns, btn)
    table.insert(tabBars, bar)
    local page = new("ScrollingFrame", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = theme.accent, Visible = i == 1, Parent = content })
    table.insert(pages, page)
    pageY[page] = 8
    btn.MouseButton1Click:Connect(function()
        for pi, p in ipairs(pages) do p.Visible = (pi == i) end
        for bi, b in ipairs(tabBtns) do
            b.TextColor3 = (bi == i) and theme.accent or theme.sub
            tabBars[bi].Visible = (bi == i)
        end
    end)
    if i == 1 then
        btn.TextColor3 = theme.accent
        tabBars[1].Visible = true
    end
    return page
end
local function bump(page, h)
    local y = pageY[page]
    pageY[page] = y + h
    page.CanvasSize = UDim2.new(0, 0, 0, pageY[page] + 10)
    return y
end
local function section(page, title)
    local y = bump(page, 34)
    new("TextLabel", { Text = title, TextColor3 = theme.accent, Font = Enum.Font.GothamBlack, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, y), TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
end
local function toggle(page, name, flag, cb)
    local y = bump(page, 42)
    local f = new("Frame", { BackgroundColor3 = theme.panel, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, y), Parent = page })
    corner(f, 8)
    new("TextLabel", { Text = name, TextColor3 = theme.text, Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = f })
    local knob = new("Frame", { BackgroundColor3 = theme.off, BorderSizePixel = 0, Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -50, 0.5, -11), Parent = f })
    corner(knob, 11)
    local dot = new("Frame", { BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 3, 0.5, -8), Parent = knob })
    corner(dot, 8)
    local state = flags[flag] or false
    local function render()
        knob.BackgroundColor3 = state and theme.accent or theme.off
        TweenService:Create(dot, TweenInfo.new(0.15), { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) }):Play()
    end
    render()
    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            flags[flag] = state
            render()
            if cb then cb(state) end
        end
    end)
end
local function slider(page, name, flag, min, max, step, suffix, cb)
    local y = bump(page, 56)
    local f = new("Frame", { BackgroundColor3 = theme.panel, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 10, 0, y), Parent = page })
    corner(f, 8)
    local lbl = new("TextLabel", { TextColor3 = theme.text, Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 4), TextXAlignment = Enum.TextXAlignment.Left, Parent = f })
    local bar = new("Frame", { BackgroundColor3 = theme.off, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 12), Position = UDim2.new(0, 10, 0, 30), Parent = f })
    corner(bar, 6)
    local fill = new("Frame", { BackgroundColor3 = theme.accent, BorderSizePixel = 0, Size = UDim2.new(0, 0, 1, 0), Parent = bar })
    corner(fill, 6)
    local grab = new("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.new(0, 10, 0, 25), Parent = f })
    local value = flags[flag] or min
    local dragging = false
    local function set(pct)
        pct = math.clamp(pct, 0, 1)
        value = math.round((min + (max - min) * pct) / step) * step
        fill.Size = UDim2.fromScale(pct, 1)
        lbl.Text = name .. ": " .. tostring(value) .. (suffix or "")
        flags[flag] = value
        if cb then cb(value) end
    end
    local function pctFrom(input)
        return (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
    end
    set((value - min) / (max - min))
    grab.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true set(pctFrom(input)) end
    end)
    grab.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    grab.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then set(pctFrom(input)) end
    end)
end
local function button(page, name, cb)
    local y = bump(page, 42)
    local b = new("TextButton", { Text = name, TextColor3 = theme.text, Font = Enum.Font.GothamBold, TextSize = 13, BackgroundColor3 = theme.dim, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, y), Parent = page })
    corner(b, 8)
    b.MouseButton1Click:Connect(cb)
end
local function dropdown(page, name, flag, items, cb)
    local y = bump(page, 42)
    local holder = new("Frame", { BackgroundColor3 = theme.panel, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, y), Parent = page })
    corner(holder, 8)
    local btn = new("TextButton", { Text = name .. ": " .. (flags[flag] or items[1] or "Chon"), TextColor3 = theme.text, Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = holder })
    local list = new("ScrollingFrame", { BackgroundColor3 = theme.panel, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, #items * 26), Position = UDim2.new(0, 0, 1, 2), CanvasSize = UDim2.new(0, 0, 0, #items * 26), ScrollBarThickness = 2, ScrollBarImageColor3 = theme.accent, Visible = false, ZIndex = 20, Parent = holder })
    corner(list, 8)
    for i, it in ipairs(items) do
        local ib = new("TextButton", { Text = it, TextColor3 = theme.text, Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, (i - 1) * 26), ZIndex = 21, Parent = list })
        ib.MouseButton1Click:Connect(function()
            btn.Text = name .. ": " .. it
            flags[flag] = it
            list.Visible = false
            if cb then cb(it) end
        end)
    end
    btn.MouseButton1Click:Connect(function() list.Visible = not list.Visible end)
end
local function textbox(page, placeholder)
    local y = bump(page, 42)
    local tb = new("TextBox", { PlaceholderText = placeholder, Text = "", TextColor3 = theme.text, PlaceholderColor3 = theme.sub, Font = Enum.Font.Gotham, TextSize = 13, BackgroundColor3 = theme.panel, BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, 36), Position = UDim2.new(0, 10, 0, y), Parent = page })
    corner(tb, 8)
    return tb
end
local function label(page, text)
    local y = bump(page, 30)
    new("TextLabel", { Text = text, TextColor3 = theme.sub, Font = Enum.Font.Gotham, TextSize = 11, BackgroundTransparency = 1, TextWrapped = true, Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, y), TextXAlignment = Enum.TextXAlignment.Left, Parent = page })
end

local scan = { mobs = {}, fruits = {}, chests = {} }
local function scanMobs()
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v ~= LocalPlayer.Character then
            local hum = v:FindFirstChildOfClass("Humanoid")
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 and hum.MaxHealth > 0 then
                table.insert(t, { model = v, hum = hum, hrp = hrp, player = Players:GetPlayerFromCharacter(v) })
            end
        end
    end
    scan.mobs = t
end
local fruitKw = { "gomu", "magu", "goro", "pika", "suna", "yami", "dragon", "dough", "phoenix", "leopard", "venom", "spirit", "control", "flame", "ice", "dark", "light", "string", "quake", "soul", "shadow", "snow", "sand", "smoke", "bomb", "barrier", "rubber", "mochi", "paw", "ope", "gas", "zushi", "horo", "suke", "doa", "supa" }
local function isFruitName(n)
    local ln = string.lower(n)
    for _, k in ipairs(fruitKw) do
        if string.find(ln, k, 1, true) then return true end
    end
    return false
end
local function scanFruits()
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if (v:IsA("Model") or v:IsA("BasePart")) and isFruitName(v.Name) then
            table.insert(t, v)
        end
    end
    scan.fruits = t
end
local function scanChests()
    local t = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and string.find(string.lower(v.Name), "chest") then
            table.insert(t, v)
        end
    end
    scan.chests = t
end
Engine.spawn(function() while true do scanMobs() task.wait(3) end end)
Engine.spawn(function() while true do scanFruits() scanChests() task.wait(5) end end)

local remoteCache = {}
local function cachedRemotes(kw)
    if remoteCache[kw] == nil then
        local out = {}
        local function walk(inst)
            for _, c in ipairs(inst:GetChildren()) do
                if c:IsA("RemoteEvent") and string.find(string.lower(c.Name), kw, 1, true) then
                    table.insert(out, c)
                end
                walk(c)
            end
        end
        walk(ReplicatedStorage)
        remoteCache[kw] = out
    end
    return remoteCache[kw]
end

local function pickTarget(range, mode)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bv = nil, nil
    for _, m in ipairs(scan.mobs) do
        if not m.player and m.hrp and m.hrp.Parent and m.hum.Health > 0 then
            local d = (m.hrp.Position - root.Position).Magnitude
            if d <= range then
                if mode == "Yeu nhat" then
                    if not bv or m.hum.Health < bv then best, bv = m, m.hum.Health end
                elseif mode == "Manh nhat" then
                    if not bv or m.hum.MaxHealth > bv then best, bv = m, m.hum.MaxHealth end
                else
                    if not bv or d < bv then best, bv = m, d end
                end
            end
        end
    end
    return best
end
local function w2s(v3)
    local p, on = Camera:WorldToScreenPoint(v3)
    return Vector2.new(p.X, p.Y), on
end
local function tpToPart(part)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and part then
        root.CFrame = part.CFrame * CFrame.new(0, 8, 0)
        return true
    end
    return false
end
local function findLocation(name)
    local matches = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if (v:IsA("Model") or v:IsA("BasePart")) and string.find(string.lower(v.Name), string.lower(name), 1, true) then
            table.insert(matches, v)
        end
    end
    if #matches == 0 then return nil end
    local best, bestSize = matches[1], -1
    for _, m in ipairs(matches) do
        local part = m:IsA("BasePart") and m or m:FindFirstChildOfClass("BasePart")
        if part and part.Size.Magnitude > bestSize then
            best, bestSize = m, part.Size.Magnitude
        end
    end
    return best
end

Engine.spawn(function()
    while true do
        if flags.autoAttack then
            local target = pickTarget(flags.farmRange, flags.priority)
            if target and target.hrp then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if flags.attackTp then root.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 6) end
                    for _, r in ipairs(cachedRemotes("attack")) do pcall(function() r:FireServer() end) end
                    for _, r in ipairs(cachedRemotes("click")) do pcall(function() r:FireServer() end) end
                    if flags.autoClick then
                        local p, on = w2s(target.hrp.Position)
                        if on then
                            VIM:SendMouseButtonEvent(p.X, p.Y, 0, true, game, 0)
                            task.wait(0.04)
                            VIM:SendMouseButtonEvent(p.X, p.Y, 0, false, game, 0)
                        end
                    end
                end
            end
        end
        task.wait(flags.farmDelay)
    end
end)
Engine.spawn(function()
    while true do
        task.wait(2)
        if flags.autoStats then
            local tries = { {}, { "Strength" }, { "Strength", 1 }, { "Melee" }, { "Sword" } }
            for _, r in ipairs(cachedRemotes("stat")) do
                for _, args in ipairs(tries) do pcall(function() r:FireServer(unpack(args)) end) end
            end
            for _, r in ipairs(cachedRemotes("upgrade")) do pcall(function() r:FireServer() end) end
        end
    end
end)
Engine.spawn(function()
    while true do
        task.wait(2.5)
        if flags.autoEquip then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local tools = LocalPlayer.Backpack:GetChildren()
                local pick = nil
                for i = #tools, 1, -1 do
                    local t = tools[i]
                    if t:IsA("Tool") then
                        if string.find(string.lower(t.Name), "sword") then pick = t break end
                        pick = pick or t
                    end
                end
                if pick then pcall(function() hum:EquipTool(pick) end) end
            end
        end
    end
end)
Engine.spawn(function()
    while true do
        task.wait(1)
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = flags.speedEnabled and flags.speedVal or 16
                hum.JumpPower = flags.jumpEnabled and flags.jumpVal or 50
            end
        end
    end
end)
Engine.spawn(function()
    while true do
        task.wait(0.15)
        if flags.noclip then
            local char = LocalPlayer.Character
            if char then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end
    end
end)
Engine.spawn(function()
    while true do
        task.wait()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if flags.fly and root and hum then
            hum.PlatformStand = true
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            if dir.Magnitude > 0 then dir = dir.Unit end
            root.AssemblyLinearVelocity = dir * flags.flySpeed
        end
    end
end)
Engine.spawn(function()
    while true do
        task.wait(0.5)
        Camera.FieldOfView = flags.fovEnabled and flags.fovVal or 70
    end
end)
Engine.spawn(function()
    while true do
        task.wait(1)
        if flags.fullbright then
            Lighting.Brightness = 2
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
        if flags.timeEnabled then Lighting.ClockTime = flags.timeVal end
    end
end)
Engine.spawn(function()
    while true do
        task.wait(20)
        if flags.autosave then
            pcall(function() writefile("raijin_kl.cfg", HttpService:JSONEncode(flags)) end)
        end
    end
end)

local drawings = {}
local function wipeDrawings()
    for _, d in ipairs(drawings) do pcall(function() d:Remove() end) end
    table.clear(drawings)
end
local function draw(kind, props)
    if not hasDrawing then return nil end
    local d = Drawing.new(kind)
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    table.insert(drawings, d)
    return d
end
Engine.spawn(function()
    while true do
        task.wait(0.15)
        wipeDrawings()
        if flags.espEnabled then
            local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if me then
                local targets = {}
                if flags.espPlayers then
                    for _, m in ipairs(scan.mobs) do
                        if m.player and m.player ~= LocalPlayer and m.hrp then
                            table.insert(targets, { obj = m.hrp, hum = m.hum, color = Color3.fromRGB(80, 160, 255), label = m.player.Name })
                        end
                    end
                end
                if flags.espMobs then
                    for _, m in ipairs(scan.mobs) do
                        if not m.player and m.hrp then
                            table.insert(targets, { obj = m.hrp, hum = m.hum, color = Color3.fromRGB(255, 90, 90), label = m.model.Name })
                        end
                    end
                end
                if flags.espFruits then
                    for _, f in ipairs(scan.fruits) do
                        local part = f:IsA("BasePart") and f or f:FindFirstChildOfClass("BasePart")
                        if part then table.insert(targets, { obj = part, color = Color3.fromRGB(255, 170, 40), label = "QUA: " .. f.Name }) end
                    end
                end
                if flags.espChests then
                    for _, c in ipairs(scan.chests) do
                        table.insert(targets, { obj = c, color = Color3.fromRGB(255, 220, 60), label = "CHEST" })
                    end
                end
                local count = 0
                for _, t in ipairs(targets) do
                    if count > 60 then break end
                    if t.obj and t.obj.Parent and (t.obj.Position - me.Position).Magnitude < flags.espDist then
                        local s, on = w2s(t.obj.Position)
                        if on then
                            count += 1
                            if flags.espTracer then
                                draw("Line", { From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y), To = s, Color = t.color, Thickness = 1, Transparency = 0.6 })
                            end
                            if flags.espBox then
                                local cf, size = t.obj.CFrame, t.obj.Size
                                local corners = {}
                                for sx = -1, 1, 2 do for sy = -1, 1, 2 do for sz = -1, 1, 2 do
                                    table.insert(corners, w2s((cf * CFrame.new(size.X / 2 * sx, size.Y / 2 * sy, size.Z / 2 * sz)).Position))
                                end end end
                                local edges = { { 1, 2 }, { 1, 3 }, { 1, 5 }, { 2, 4 }, { 2, 6 }, { 3, 4 }, { 3, 7 }, { 4, 8 }, { 5, 6 }, { 5, 7 }, { 6, 8 }, { 7, 8 } }
                                for _, e in ipairs(edges) do
                                    draw("Line", { From = corners[e[1]], To = corners[e[2]], Color = t.color, Thickness = 1, Transparency = 0.5 })
                                end
                            end
                            if flags.espName then
                                draw("Text", { Text = t.label, Position = s - Vector2.new(0, 18), Color = t.color, Size = 12, Center = true, Outline = true })
                            end
                            if flags.espHealth and t.hum then
                                local pct = math.clamp(t.hum.Health / t.hum.MaxHealth, 0, 1)
                                local w = 60
                                local x = s.X - w / 2
                                local yTop = s.Y - 14
                                draw("Line", { From = Vector2.new(x, yTop), To = Vector2.new(x + w, yTop), Color = Color3.fromRGB(0, 0, 0), Thickness = 3, Transparency = 0.5 })
                                draw("Line", { From = Vector2.new(x, yTop), To = Vector2.new(x + w * pct, yTop), Color = pct > 0.5 and Color3.fromRGB(60, 255, 120) or Color3.fromRGB(255, 90, 90), Thickness = 3 })
                            end
                        end
                    end
                end
            end
        end
    end
end)

Engine.spawn(function()
    local seen = {}
    while true do
        task.wait(4)
        if flags.sniper then
            for k in pairs(seen) do
                if not table.find(scan.fruits, k) then seen[k] = nil end
            end
            for _, f in ipairs(scan.fruits) do
                if not seen[f] then
                    seen[f] = true
                    notify("TRAI AC QUY", f.Name .. " da xuat hien!", 6)
                    if flags.sniperTp then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local part = f:IsA("BasePart") and f or f:FindFirstChildOfClass("BasePart")
                        if root and part then root.CFrame = part.CFrame * CFrame.new(0, 6, 0) end
                    end
                    if flags.sniperGrab then
                        task.delay(1.2, function()
                            for _, pp in ipairs(f:GetDescendants()) do
                                if pp:IsA("ProximityPrompt") then
                                    pcall(fireproximityprompt, pp)
                                end
                            end
                            for _, kw in ipairs({ "fruit", "grab", "pick" }) do
                                for _, r in ipairs(cachedRemotes(kw)) do pcall(function() r:FireServer() end) end
                            end
                        end)
                    end
                end
            end
        end
    end
end)

function Engine.stop()
    Engine.dead = true
    for _, th in ipairs(Engine.threads) do pcall(task.cancel, th) end
    for _, c in ipairs(Engine.conns) do pcall(function() c:Disconnect() end) end
    wipeDrawings()
    if flags.autosave then pcall(function() writefile("raijin_kl.cfg", HttpService:JSONEncode(flags)) end) end
    gui:Destroy()
end

local combatPage = makeTab("COMBAT")
section(combatPage, "DANH NHAU")
toggle(combatPage, "Auto Attack", "autoAttack")
toggle(combatPage, "TP toi muc tieu", "attackTp")
dropdown(combatPage, "Muc tieu", "priority", { "Gan nhat", "Yeu nhat", "Manh nhat" })
slider(combatPage, "Tam danh", "farmRange", 50, 2000, 50, " studs")
slider(combatPage, "Do tre", "farmDelay", 0.1, 2, 0.1, "s")
toggle(combatPage, "Auto Click (mouse)", "autoClick")
button(combatPage, "Quet lai quai", function() scanMobs() notify("COMBAT", "Da quet: " .. #scan.mobs .. " thuc the", 2) end)

local playerPage = makeTab("PLAYER")
section(playerPage, "NHAN VAT")
toggle(playerPage, "Speed hack", "speedEnabled")
slider(playerPage, "Toc do chay", "speedVal", 16, 350, 1)
toggle(playerPage, "Jump hack", "jumpEnabled")
slider(playerPage, "Luc nhay", "jumpVal", 50, 500, 5)
toggle(playerPage, "Noclip", "noclip")
toggle(playerPage, "Fly", "fly")
slider(playerPage, "Toc do bay", "flySpeed", 10, 200, 5)
toggle(playerPage, "FOV hack", "fovEnabled")
slider(playerPage, "Goc nhin (FOV)", "fovVal", 30, 120, 1)

local farmPage = makeTab("FARM")
section(farmPage, "FARM TU DONG")
toggle(farmPage, "Auto Stats", "autoStats")
toggle(farmPage, "Auto Equip Vu Khi", "autoEquip")
label(farmPage, "Auto Attack nam o tab COMBAT. Chon muc tieu yeu nhat de farm nhanh.")

local fruitPage = makeTab("FRUIT")
section(fruitPage, "SNIPER TRAI AC QUY")
toggle(fruitPage, "Canh bao khi qua spawn", "sniper")
toggle(fruitPage, "Tu dong TP toi qua", "sniperTp")
toggle(fruitPage, "Tu dong nhat qua", "sniperGrab")
button(fruitPage, "Quet lai qua", function() scanFruits() notify("FRUIT", "Da quet: " .. #scan.fruits .. " qua", 2) end)
button(fruitPage, "Dich toi qua gan nhat", function()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local best, bd = nil, math.huge
    for _, f in ipairs(scan.fruits) do
        local part = f:IsA("BasePart") and f or f:FindFirstChildOfClass("BasePart")
        if part then
            local d = (part.Position - root.Position).Magnitude
            if d < bd then best, bd = part, d end
        end
    end
    if best then
        tpToPart(best)
        notify("FRUIT", "Da dich toi " .. best.Name, 3)
    else
        notify("FRUIT", "Chua quet thay qua nao", 3)
    end
end)

local espPage = makeTab("ESP")
section(espPage, "ESP")
toggle(espPage, "Bat ESP", "espEnabled")
toggle(espPage, "Khung (Box)", "espBox")
toggle(espPage, "Ten (Name)", "espName")
toggle(espPage, "Duong noi (Tracer)", "espTracer")
toggle(espPage, "Thanh mau (HP)", "espHealth")
toggle(espPage, "Nguoi choi", "espPlayers")
toggle(espPage, "Quai", "espMobs")
toggle(espPage, "Trai ac quy", "espFruits")
toggle(espPage, "Rung (Chest)", "espChests")
slider(espPage, "Khoang cach ve", "espDist", 500, 10000, 500, " studs")

local tpPage = makeTab("TELEPORT")
section(tpPage, "TELEPORT")
dropdown(tpPage, "Dao", "tpIsland", { "Starter", "Bubble", "Skypiea", "Fishman", "Shells", "Prison", "Marine", "Desert", "Snow", "Zou", "Wano" })
button(tpPage, "Dich chuyen toi dao", function()
    local found = findLocation(flags.tpIsland or "Starter")
    if found then
        local part = found:IsA("BasePart") and found or found:FindFirstChildOfClass("BasePart")
        if tpToPart(part) then
            notify("TELEPORT", "Da dich toi " .. found.Name, 3)
        end
    else
        notify("TELEPORT", "Khong tim thay dao trong map hien tai", 3)
    end
end)
local playerBox = textbox(tpPage, "Ten nguoi choi...")
button(tpPage, "TP toi nguoi choi", function()
    local target = Players:FindFirstChild(playerBox.Text)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if target and target.Character and root then
        local tr = target.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            root.CFrame = tr.CFrame * CFrame.new(0, 0, 3)
            notify("TELEPORT", "Da dich toi " .. target.Name, 3)
            return
        end
    end
    notify("TELEPORT", "Khong tim thay nguoi choi do", 3)
end)

local worldPage = makeTab("WORLD")
section(worldPage, "THE GIOI")
toggle(worldPage, "Fullbright (sang map)", "fullbright")
toggle(worldPage, "Chinh gio", "timeEnabled")
slider(worldPage, "Gio trong ngay", "timeVal", 0, 24, 0.5)

local settingsPage = makeTab("SETTINGS")
section(settingsPage, "CONFIG")
toggle(settingsPage, "Tu dong luu config", "autosave")
button(settingsPage, "Luu config ngay", function()
    local ok, err = pcall(function() writefile("raijin_kl.cfg", HttpService:JSONEncode(flags)) end)
    notify("CONFIG", ok and "Da luu config" or ("Loi: " .. tostring(err)), 3)
end)
button(settingsPage, "Nap config", function()
    local ok, raw = pcall(function() return readfile("raijin_kl.cfg") end)
    if ok and raw then
        local data = HttpService:JSONDecode(raw)
        for k, v in pairs(data) do if flags[k] ~= nil then flags[k] = v end end
        notify("CONFIG", "Da nap config - chay lai script de ap dung", 3)
    else
        notify("CONFIG", "Chua co file config", 3)
    end
end)
button(settingsPage, "Go script (Unload)", function()
    notify("RAIJIN", "Da go script sach se", 2)
    Engine.stop()
end)
label(settingsPage, "Nhan RightControl de an/hien menu.")

notify("RAIJIN HUB", "Da nap thanh cong - NO KEY, free hoan toan!", 4)
