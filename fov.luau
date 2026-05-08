-- (have fun pasting! also not my code)
if Visuals and Visuals.Unload then
    pcall(function() Visuals.Unload() end)
end

if Visuals and Visuals.Holder and Visuals.Holder.Parent then
    Visuals.Holder:Destroy()
    Visuals.Holder = nil
end

if not LPH_OBFUSCATED then
    LPH_NO_VIRTUALIZE = function(Func) return Func end
end

local game = game
local GetService = game.GetService
local Service = function(Name)
    return cloneref(GetService(game, Name))
end

local Players = Service("Players")
local RunService = Service("RunService")
local Workspace = Service("Workspace")
local HttpService = Service("HttpService")
local UserInputService = Service("UserInputService")

local Color3_fromRGB, Color3_new, Color3_fromHSV, Color3_fromHex = Color3.fromRGB, Color3.new, Color3.fromHSV, Color3.fromHex
local table_clear, table_insert, table_remove, table_unpack, table_find, table_sort, table_concat = table.clear, table.insert, table.remove, table.unpack, table.find, table.sort, table.concat
local string_find, string_match, string_format, string_gsub, string_lower, string_upper, string_sub = string.find, string.match, string.format, string.gsub, string.lower, string.upper, string.sub
local task_wait, task_spawn, task_delay, task_defer = task.wait, task.spawn, task.delay, task.defer
local coroutine_wrap, coroutine_close, coroutine_create, coroutine_resume = coroutine.wrap, coroutine.close, coroutine.create, coroutine.resume
local os_clock, os_date = os.clock, os.date
local Vector2_new, Vector3_new, Vector3_one, Vector3_zero = Vector2.new, Vector3.new, Vector3.one, Vector3.zero
local UDim2_new, UDim2_fromScale, UDim2_fromOffset, UDim_new = UDim2.new, UDim2.fromScale, UDim2.fromOffset, UDim.new
local CFrame_Angles, CFrame_new = CFrame.Angles, CFrame.new
local math_clamp, math_round, math_floor, math_huge, math_sin, math_cos, math_pi, math_min, math_deg, math_max, math_random, math_exp, math_tan, math_rad = math.clamp, math.round, math.floor, math.huge, math.sin, math.cos, math.pi, math.min, math.deg, math.max, math.random, math.exp, math.tan, math.rad
local Drawing_new, Instance_new, Rect_new, Font_new, ColorSequence_new, ColorSequenceKeypoint_new, TweenInfo_new, NumberSequence_new, NumberSequenceKeypoint_new = Drawing.new, Instance.new, Rect.new, Font.new, ColorSequence.new, ColorSequenceKeypoint.new, TweenInfo.new, NumberSequence.new, NumberSequenceKeypoint.new
local FindFirstChild, GetChildren, GetDescendants, WaitForChild, FindFirstChildWhichIsA, IsA = game.FindFirstChild, game.GetChildren, game.GetDescendants, game.WaitForChild, game.FindFirstChildWhichIsA, game.IsA

local Client = Players.LocalPlayer
local CurrentCamera = FindFirstChildWhichIsA(Workspace, "Camera") or Workspace.CurrentCamera

-- Aura optimized WorldToViewportPoint
local Camera = {}
do
    local ScreenSize, ScreenSizeX, ScreenSizeY
    local HalfScreenX, HalfScreenY
    local FrustumX, FrustumY, FrustumXDiv, FrustumYDiv
    local ToRad = math_rad
    local Tan = math_tan

    Camera.UpdateSize = function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        ScreenSize = cam.ViewportSize
        ScreenSizeX = ScreenSize.X
        ScreenSizeY = ScreenSize.Y
        HalfScreenX = ScreenSizeX / 2
        HalfScreenY = ScreenSizeY / 2
        Camera.HalfScreenX = HalfScreenX
        Camera.HalfScreenY = HalfScreenY
        if FrustumX and FrustumY then
            FrustumXDiv = ScreenSizeX / (FrustumX * 2)
            FrustumYDiv = ScreenSizeY / (FrustumY * 2)
        end
    end

    Camera.UpdateFOV = function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local vp = cam.ViewportSize
        ScreenSizeX = ScreenSizeX or vp.X
        ScreenSizeY = ScreenSizeY or vp.Y
        HalfScreenX = ScreenSizeX / 2
        HalfScreenY = ScreenSizeY / 2
        FrustumY = Tan(ToRad(cam.FieldOfView) / 2)
        FrustumX = ScreenSizeX / ScreenSizeY * FrustumY
        FrustumXDiv = ScreenSizeX / (FrustumX * 2)
        FrustumYDiv = ScreenSizeY / (FrustumY * 2)
        Camera.HalfScreenX = HalfScreenX
        Camera.HalfScreenY = HalfScreenY
    end

    Camera.WorldToViewportPoint = function(Position, CheckScreen)
        local cam = Workspace.CurrentCamera
        if not cam then return Vector3_new(0, 0, 0), false end
        local Projected = cam.CFrame:PointToObjectSpace(Position)
        local Z = -Projected.Z
        local PositionX = HalfScreenX + Projected.X / Z * FrustumXDiv
        local PositionY = HalfScreenY - Projected.Y / Z * FrustumYDiv
        local OnScreen = CheckScreen and Z > 0 and PositionX >= 0 and PositionX <= ScreenSizeX and PositionY >= 0 and PositionY <= ScreenSizeY
        return Vector3_new(PositionX, PositionY, Z), OnScreen
    end

    task.defer(function()
        CurrentCamera = Workspace.CurrentCamera
        if CurrentCamera then
            CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(Camera.UpdateFOV)
            CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Camera.UpdateSize)
        end
    end)
    Camera.UpdateFOV()
    Camera.UpdateSize()
end

getgenv().Visuals = {
    Settings = {
        Font = "ProggyClean",
        FontSize = 12,
        RefreshRate = 60,

        Crosshair = {
            Enabled = false,

            Dot = false,
            Color = {Color3_fromRGB(200, 150, 255), Color3_fromRGB(255, 250, 255)},
            GradientAnimation = true,
            GradientRotation = 90,
            AnimationSpeed = 1.2,

            Lines = {
                Enabled = false,
                Rotate = {true, 5},
                Amount = 4,
                Length = 10,
                Thickness = 1,
                Gap = 6,
                Pulse = {true, 1.2},
                PulseAmount = 0.5,
            },

            Watermark = {
                Enabled = false,
                Color = {Color3_fromRGB(255, 255, 255), Color3_fromRGB(200, 150, 255)},
                Text = `yes<font color="rgb(230, 210, 255)">Hub</font>`,
            },

            -- "Mouse" = follow mouse, "Screen" = center of screen (also read by FoV)
            Method = "Screen",

            Follow = function()
                local v = getgenv().Visuals
                local method = (v and v.Settings and v.Settings.FoVs and v.Settings.FoVs.SilentAim and v.Settings.FoVs.SilentAim.Method)
                    or (v and v.Settings and v.Settings.Crosshair and v.Settings.Crosshair.Method)
                    or "Mouse"
                if string_lower(tostring(method)) == "screen" then
                    if v and v.Camera and v.Camera.HalfScreenX then
                        return Vector2_new(v.Camera.HalfScreenX, v.Camera.HalfScreenY)
                    end
                    local camera = Workspace.CurrentCamera
                    if not camera then return Vector2_new(0, 0) end
                    local viewportSize = camera.ViewportSize
                    return Vector2_new(viewportSize.X / 2, viewportSize.Y / 2)
                end
                return UserInputService:GetMouseLocation()
            end
        },

        FoVs = {
            SilentAim = {
                Enabled = false,
                Size = 200,
                Thickness = 2,
                Color = {Color3_fromRGB(180, 120, 255), Color3_fromRGB(255, 250, 255)},
                ZIndex = 1,
                AnimationSpeed = 1,
                CircleAnimation = "Scroll",

                Fill = {
                    Enabled = false,
                    Color = {Color3_fromRGB(180, 120, 255), Color3_fromRGB(255, 250, 255)},
                    Transparency = 0.45,
                    Rotation = 90,
                    Animation = "Vortex",
                },

                Glow = {
                    Enabled = false,
                    Color = {Color3_fromRGB(180, 120, 255), Color3_fromRGB(255, 250, 255)},
                    Transparency = 0.25,
                    TransparencyOuter = 0.5,
                    SizeScale = 1.2,
                    SizeScaleOuter = 1.55,
                    Rotation = 90,
                    Animation = "Scroll",
                },

                Outline = {
                    Enabled = false,
                    Color = Color3_fromRGB(200, 150, 255),
                    Thickness = 2,
                },

                Watermark = {
                    Enabled = false,
                    Text = ``,
                    Color = {Color3_fromRGB(200, 150, 255), Color3_fromRGB(255, 250, 255)},
                    FontSize = 12,
                },

                -- "Mouse" Follow Mouse, "Screen" Stuck in middle of screen
                Method = "Screen",
                Follow = function()
                    local camera = Workspace.CurrentCamera
                    if not camera then
                        return Vector2_new(0, 0)
                    end
                    local v = getgenv().Visuals
                    local method = (v and v.Settings and v.Settings.FoVs and v.Settings.FoVs.SilentAim and v.Settings.FoVs.SilentAim.Method)
                        or (v and v.Settings and v.Settings.Crosshair and v.Settings.Crosshair.Method)
                        or "Mouse"
                    if string_lower(tostring(method)) == "screen" then
                        if v and v.Camera and v.Camera.HalfScreenX then
                            return Vector2_new(v.Camera.HalfScreenX, v.Camera.HalfScreenY)
                        end
                        local viewportSize = camera.ViewportSize
                        return Vector2_new(viewportSize.X / 2, viewportSize.Y / 2)
                    end
                    return UserInputService:GetMouseLocation()
                end
            },
        },
    },

    Connections = {},
    Errors = {},
    Objects = {},
    FoVs = {},
    Folder = "Visuals",
    Crosshair = nil,
    Font = nil,
    Holder = nil,
}
Visuals.Camera = Camera
Visuals.WorldToViewportPoint = Camera.WorldToViewportPoint

local ConnectionsTable = Visuals.Connections
local ObjectsTable = Visuals.Objects
local FolderLocation = Visuals.Folder
local VisualsErrors = Visuals.Errors
local VisualsSettings = Visuals.Settings
local FontsFolder = FolderLocation .. "\\Fonts"
local FontsToDownload = {
    ["Tahoma"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/main/zekton_rg.ttf"},
    ["Minecraftia"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Minecraftia.ttf"},
    ["Silkscreen"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/refs/heads/main/Silkscreen.ttf"},
    ["ProggyClean"] = {Link = "https://github.com/LuckyHub1/LuckyHub/raw/main/ProggyClean.ttf", FileName = "Proggy Clean"},
}

do
    for Name, Table in FontsToDownload do
        local fileKey = Table.FileName or Name
        local ttfPath = FontsFolder .. "\\" .. fileKey .. ".ttf"
        local fontPath = FontsFolder .. "\\" .. fileKey .. ".font"
        if not isfile(ttfPath) then
            writefile(ttfPath, game:HttpGet(Table.Link))
        end
        if not isfile(fontPath) or ExecutorName == "Potassium" then
            local fontData = {
                name = Name,
                faces = {{ name = Name, weight = 400, style = "Regular", assetId = getcustomasset(ttfPath) }}
            }
            writefile(fontPath, HttpService:JSONEncode(fontData))
        end
    end

    if not getgenv().Fonts then
        getgenv().Fonts = { Loaded = {} }
    end
    local Fonts = getgenv().Fonts
    Fonts.Loaded = {}
    local function tryLoadFont(name, fontPath)
        if not fontPath or not isfile(fontPath) then return nil end
        local ok, font = pcall(function()
            return Font_new(getcustomasset(fontPath), Enum.FontWeight.Regular)
        end)
        if not ok or not font then
            local pathSlash = string_gsub(fontPath, "\\", "/")
            ok, font = pcall(function()
                return Font_new(getcustomasset(pathSlash), Enum.FontWeight.Regular)
            end)
        end
        return ok and font or nil
    end

    for Name, Table in FontsToDownload do
        local fileKey = Table and Table.FileName or Name
        local fontPath = FontsFolder .. "\\" .. fileKey .. ".font"
        Fonts.Loaded[Name] = tryLoadFont(Name, fontPath)
        if not Fonts.Loaded[Name] then
            local altPath = fileKey .. ".font"
            if isfile(altPath) then
                Fonts.Loaded[Name] = tryLoadFont(Name, altPath)
            end
        end
    end


    Fonts.FileNames = { ProggyClean = "Proggy Clean" }
    function Fonts.GetFont(fontName)
        if not fontName or fontName == "" then
            return Font.new("Arial", Enum.FontWeight.Regular)
        end
        if Fonts.Loaded[fontName] then
            return Fonts.Loaded[fontName]
        end
        local fileKey = Fonts.FileNames and Fonts.FileNames[fontName] or fontName
        local fontPath = FontsFolder .. "\\" .. fileKey .. ".font"
        if isfile(fontPath) then
            local font = tryLoadFont(fontName, fontPath)
            if font then
                Fonts.Loaded[fontName] = font
                return font
            end
        end
        local altPath = fileKey .. ".font"
        if isfile(altPath) then
            local font = tryLoadFont(fontName, altPath)
            if font then
                Fonts.Loaded[fontName] = font
                return font
            end
        end
       
        local builtin = ({ ProggyClean = "Code", Tahoma = "GothamBold", Minecraftia = "Code", Silkscreen = "Gotham" })[fontName]
        return Font.new(builtin or "Arial", Enum.FontWeight.Regular)
    end
end

local Utility = {}; do
    function Utility.AddConnection(Signal, Function)
        local Connection = Signal:Connect(function(...)
            local Args = {...}
            
            local Success, Message = pcall(function() coroutine_wrap(Function)(table_unpack(Args)) end)
            
            if not Success and not VisualsErrors[Message] then
                local ErrorMessage = string_format("[ERROR] | An error has occured:\n%s", Message)

                warn(ErrorMessage)
                
                VisualsErrors[Message] = Message
                
                if ConnectionsTable[Connection] then
                    ConnectionsTable[Connection] = nil
                end
                
                return Connection and Connection:Disconnect()
            end
        end)
        
        if Connection and ConnectionsTable then
            table_insert(ConnectionsTable, Connection)
        end
        
        return Connection
    end

    function Utility.CreateObject(Type, Properties, Hidden)
        local Hidden = Hidden or false
        local Object = Instance_new(Type)

        for Index, Value in Properties do
            Object[Index] = Value
        end

        table_insert(ObjectsTable, Object)

        return Object
    end

    function Utility.CalculateCrosshair(Lines, Center, TimeAngle, Length, Thickness, Gap)
        local Results = {}
        local Step = (math_pi * 2) / Lines
        local Radius = math_floor(Gap + Length / 2 + 0.5)
        local len = math_floor(Length + 0.5)
        local thick = math_floor(Thickness + 0.5)
        local spinning = type(TimeAngle) == "number" and math.abs(TimeAngle) > 0.001

        for i = 1, Lines do
            local BaseAngle = Step * (i - 1)
            local Angle = BaseAngle + TimeAngle

            local OffsetX = math_floor(math_cos(Angle) * Radius + 0.5)
            local OffsetY = math_floor(math_sin(Angle) * Radius + 0.5)

            if not spinning then
                if math.abs(math_cos(Angle)) >= math.abs(math_sin(Angle)) then
                    OffsetY = 0
                else
                    OffsetX = 0
                end
               
                if math.abs(Angle) < 0.1 or math.abs(Angle - math_pi * 2) < 0.1 then
                    OffsetX = OffsetX + 1
                elseif math.abs(Angle - math_pi / 2) < 0.1 then
                    OffsetY = OffsetY + 1
                end
            end

            local sizeW, sizeH, rot
            if spinning then
                sizeW, sizeH, rot = len, thick, math_deg(Angle)
            else
                if math.abs(math_cos(Angle)) >= math.abs(math_sin(Angle)) then
                    sizeW, sizeH = len, thick
                else
                    sizeW, sizeH = thick, len
                end
                rot = 0
            end

            Results[i] = {
                Size = UDim2_fromOffset(sizeW, sizeH),
                Position = Center + UDim2_fromOffset(OffsetX, OffsetY),
                Rotation = rot
            }
        end
        return Results
    end
end

do -- Functions
    local coreGui = gethui and gethui() or game:GetService("CoreGui")
    if coreGui then
        for _, child in pairs(coreGui:GetChildren()) do
            if child:IsA("ScreenGui") and child.Name == "FovLoadVisuals" then
                child:Destroy()
            end
        end
    end
    Visuals.Holder = Utility.CreateObject("ScreenGui", {
		Name = "FovLoadVisuals",
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ZIndexBehavior = Enum.ZIndexBehavior.Global,
		ResetOnSpawn = false,
		DisplayOrder = 10000,
		IgnoreGuiInset = true,
		Parent = gethui()
	})

   
    local DEFAULT_GRADIENT_SPEED = 1.2
    local Animation = {}
    local function colorAtSmooth(colors, t)
        t = t % 1
        if t < 1/3 then
            return colors[1]:Lerp(colors[2], t * 3)
        elseif t < 2/3 then
            return colors[2]:Lerp(colors[3], (t - 1/3) * 3)
        else
            return colors[3]:Lerp(colors[1], (t - 2/3) * 3)
        end
    end
    function Animation.GetGradientColors(colors, enabled, time, speed)
        if not enabled or #colors < 3 then
            local c1, c2, c3 = colors[1], colors[2], colors[3] or colors[2]
            return ColorSequence_new{
                ColorSequenceKeypoint_new(0, c1),
                ColorSequenceKeypoint_new(0.5, c2),
                ColorSequenceKeypoint_new(1, c3),
            }
        end
        local phase = (time * (speed or DEFAULT_GRADIENT_SPEED) * 0.4) % 1
        local n = 12
        local keypoints = {}
        for i = 0, n do
            local pos = i / n
            table_insert(keypoints, ColorSequenceKeypoint_new(pos, colorAtSmooth(colors, pos + phase)))
        end
        return ColorSequence_new(keypoints)
    end
    local function colorAt2(c1, c2, t)
        t = t % 1
        if t < 0.5 then return c1:Lerp(c2, t * 2) else return c2:Lerp(c1, (t - 0.5) * 2) end
    end
    function Animation.GetGradientColors2(colors, enabled, time, speed)
        if not enabled or enabled == "Vortex" or #colors < 2 then
            return ColorSequence_new{ColorSequenceKeypoint_new(0, colors[1]), ColorSequenceKeypoint_new(1, colors[2])}
        end
        local c1, c2 = colors[1], colors[2]
        local phase = (time * (speed or DEFAULT_GRADIENT_SPEED) * 0.4) % 1
        local n = 10
        local keypoints = {}
        for i = 0, n do
            local pos = i / n
            table_insert(keypoints, ColorSequenceKeypoint_new(pos, colorAt2(c1, c2, pos + phase)))
        end
        return ColorSequence_new(keypoints)
    end

    
    function Animation.BuildWatermarkScrollText(colors, rawText, phase)
        if not colors or #colors < 2 then
            return rawText
        end
        local plain = string_gsub(rawText, "<[^>]+>", "")
        if plain == "" then return rawText end
        local c1, c2 = colors[1], colors[2]
        local out = {}
        for i = 1, #plain do
            local ch = string_sub(plain, i, i)
            local pos = ((i - 1) / #plain + phase) % 1
            local col = colorAt2(c1, c2, pos)
            local r, g, b = math_floor(col.R * 255), math_floor(col.G * 255), math_floor(col.B * 255)
            table_insert(out, string_format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, ch))
        end
        return table_concat(out)
    end

    
    function Animation.GetWatermarkScrollGradient(colors)
        if not colors or #colors < 2 then
            local c = (colors and colors[1]) or Color3_new(1, 1, 1)
            return ColorSequence_new{ColorSequenceKeypoint_new(0, c), ColorSequenceKeypoint_new(1, c)}
        end
        local c1, c2 = colors[1], colors[2]
        local n = 16
        local keypoints = {}
        for i = 0, n do
            local pos = i / n
            table_insert(keypoints, ColorSequenceKeypoint_new(pos, colorAt2(c1, c2, pos)))
        end
        return ColorSequence_new(keypoints)
    end
    function Animation.GetVortexRotation(time, speed)
        return (time * (speed or 1) * 120) % 360
    end
    function Animation.GetColorAtTime(colors, time, speed)
        if not colors or #colors == 0 then return Color3_new(1, 1, 1) end
        if #colors == 1 then return colors[1] end
        local phase = (time * (speed or DEFAULT_GRADIENT_SPEED) * 0.4) % 1
        if #colors >= 3 then return colorAtSmooth({colors[1], colors[2], colors[3]}, phase) end
        return colorAt2(colors[1], colors[2], phase)
    end
    local function getGradientForColors(colors, enabled, time, speed)
        if not colors or #colors < 2 then
            local c = (colors and colors[1]) or Color3_new(1, 1, 1)
            return ColorSequence_new{ColorSequenceKeypoint_new(0, c), ColorSequenceKeypoint_new(1, c)}
        end
        if #colors == 2 then return Animation.GetGradientColors2(colors, enabled, time, speed) end
        if #colors >= 3 then return Animation.GetGradientColors({colors[1], colors[2], colors[3]}, enabled, time, speed) end
        return Animation.GetGradientColors2(colors, enabled, time, speed)
    end

    function Visuals.CreateCrosshair()
        local CrosshairObject = {
            Connection = nil,
            SpinAngle = 0,
            Objects = {},
            LastTick = os_clock(),
            LastSpinTime = os_clock(),
            CrosshairGradientTime = 0,
            CrosshairPulsePhase = 0,
        }

        local Settings = VisualsSettings.Crosshair
        local LineSettings = Settings.Lines
        local WatermarkSettings = Settings.Watermark
        local Objects = CrosshairObject.Objects
        local LastTick = CrosshairObject.LastTick
        local VisualsHolder = Visuals.Holder
        local LinesAmount = LineSettings.Amount
        local CrosshairFunction = Settings.Follow

        local Fonts = getgenv().Fonts
        local ESPFont = (Fonts and Fonts.GetFont and Fonts.GetFont(VisualsSettings.Font)) or Font.new("Arial", Enum.FontWeight.Regular)
        local ESPFontSize = VisualsSettings.FontSize

        do -- Functions
            function CrosshairObject.Init()
                Objects["CrosshairDot"] = Utility.CreateObject("Frame", {Parent = VisualsHolder, ZIndex = 1000, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 0, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 2, 0, 2), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Utility.CreateObject("UIStroke", {Parent = Objects["CrosshairDot"], Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter})
                Utility.CreateObject("UIGradient", {Parent = Objects["CrosshairDot"], Rotation = 90})

                Objects["CrosshairWatermark"] = Utility.CreateObject("TextLabel", {
                    Parent = VisualsHolder,
                    FontFace = ESPFont,
                    TextSize = ESPFontSize,
                    TextColor3 = Color3_fromRGB(255, 255, 255),
                    RichText = true,
                    Text = "",
                    AnchorPoint = Vector2_new(0.5, 0.5),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundTransparency = 1,
                    ZIndex = 1001,
                    AutomaticSize = Enum.AutomaticSize.XY,
                    Size = UDim2_new(1, 0, 0, 0)
                })
                Utility.CreateObject("UIGradient", {Parent = Objects["CrosshairWatermark"], Rotation = 0})
                Utility.CreateObject("UIStroke", {Parent = Objects["CrosshairWatermark"], Color = Color3_fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter})
                
                for i = 1, LinesAmount do
                    Objects["Line_" .. i] = Utility.CreateObject("Frame", {Parent = VisualsHolder, ZIndex = 1000, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 0, Position = UDim2_new(0, 0, 0, 0), BorderColor3 = Color3_fromRGB(0, 0, 0), Size = UDim2_new(0, 2, 0, 2), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                    Utility.CreateObject("UIStroke", {Parent = Objects["Line_" .. i], Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter})
                    Utility.CreateObject("UIGradient", {Parent = Objects["Line_" .. i], Rotation = 90})
                end
            end

            function CrosshairObject.Update(Delta)
                
                if (os_clock() - LastTick) < (1 / VisualsSettings.RefreshRate) then return end
                LastTick = os_clock()

                local dt = type(Delta) == "number" and Delta > 0 and math_min(Delta, 0.1) or (1 / 60)
                CrosshairObject.CrosshairGradientTime = (CrosshairObject.CrosshairGradientTime or 0) + dt * (Settings.AnimationSpeed or 1.2)
                CrosshairObject.CrosshairPulsePhase = (CrosshairObject.CrosshairPulsePhase or 0) + dt * (LineSettings.Pulse and LineSettings.Pulse[2] or 1.2)

                local pulseScale = 1
                if LineSettings.Pulse and LineSettings.Pulse[1] then
                    pulseScale = 1 + (LineSettings.PulseAmount or 0.1) * math_sin((CrosshairObject.CrosshairPulsePhase or 0) * math_pi * 2)
                end
                local effGap = math_floor(LineSettings.Gap * pulseScale + 0.5)
                local effLength = math_floor(LineSettings.Length * pulseScale + 0.5)

                local CrosshairPosition = CrosshairFunction()
                local cx = math_floor(CrosshairPosition.X + 0.5)
                local cy = math_floor(CrosshairPosition.Y + 0.5)
                local CenterPosition = UDim2_fromOffset(cx, cy)
                local CrosshairData = Utility.CalculateCrosshair(
                    LinesAmount,
                    CenterPosition,
                    CrosshairObject.SpinAngle,
                    effLength,
                    LineSettings.Thickness,
                    effGap
                )

                local crosshairColor = type(Settings.Color) == "table" and Settings.Color[1] or Settings.Color
                local colorList = type(Settings.Color) == "table" and Settings.Color or {Settings.Color}
                local useGradient = Settings.GradientAnimation and #colorList >= 2
                local t = CrosshairObject.CrosshairGradientTime or 0
                local gradSeq = useGradient and getGradientForColors(colorList, true, t, Settings.AnimationSpeed or 1.2) or ColorSequence_new{ColorSequenceKeypoint_new(0, crosshairColor), ColorSequenceKeypoint_new(1, crosshairColor)}

                local crosshairGradRot = (Settings.GradientRotation or 90)
                local CrosshairDot = Objects["CrosshairDot"]; do
                    if Settings.Enabled and Settings.Dot then
                        CrosshairDot.Visible = true
                        local g = CrosshairDot:FindFirstChildOfClass("UIGradient")
                        if g then g.Color = gradSeq; g.Rotation = crosshairGradRot end
                        CrosshairDot.BackgroundColor3 = crosshairColor
                        CrosshairDot.Position = CenterPosition
                    else
                        CrosshairDot.Visible = false
                    end
                end

                local CrosshairWatermark = Objects["CrosshairWatermark"]; do
                    if Settings.Enabled and WatermarkSettings.Enabled then
                        CrosshairWatermark.Visible = true
                        local wmColor = WatermarkSettings.Color
                        if type(wmColor) == "table" and #wmColor >= 2 then
                            local phase = (t * (Settings.AnimationSpeed or 1.2) * 0.4) % 1
                            CrosshairWatermark.TextColor3 = Color3_fromRGB(255, 255, 255)
                            CrosshairWatermark.Text = Animation.BuildWatermarkScrollText(wmColor, WatermarkSettings.Text, phase)
                            local wmGrad = CrosshairWatermark:FindFirstChildOfClass("UIGradient")
                            if wmGrad then wmGrad.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, wmColor[1]), ColorSequenceKeypoint_new(1, wmColor[1])} end
                        else
                            local currentColor = type(wmColor) == "table" and wmColor[1] or wmColor
                            CrosshairWatermark.TextColor3 = currentColor
                            CrosshairWatermark.Text = WatermarkSettings.Text
                            local wmGrad = CrosshairWatermark:FindFirstChildOfClass("UIGradient")
                            if wmGrad then wmGrad.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, currentColor), ColorSequenceKeypoint_new(1, currentColor)} end
                        end
                        local baseGap, baseLength = LineSettings.Gap, LineSettings.Length
                        CrosshairWatermark.Position = CenterPosition + UDim2_fromOffset(0, 14 + baseGap + baseLength)
                    else
                        CrosshairWatermark.Visible = false
                    end
                end

                for i, Info in CrosshairData do
                    local Line = Objects["Line_" .. i]

                    if Settings.Enabled and LineSettings.Enabled then
                        if LineSettings.Rotate[1] then
                            local Now = os_clock()
                            local Elapsed = Now - CrosshairObject.LastSpinTime
                            CrosshairObject.LastSpinTime = Now
                            CrosshairObject.SpinAngle += Elapsed * LineSettings.Rotate[2]
                        end

                        Line.Visible = true
                        local g = Line:FindFirstChildOfClass("UIGradient")
                        if g then g.Color = gradSeq; g.Rotation = crosshairGradRot end
                        Line.BackgroundColor3 = crosshairColor
                        Line.Size = Info.Size
                        Line.Position = Info.Position
                        Line.Rotation = Info.Rotation
                    else
                        Line.Visible = false
                    end
                end
            end

            function CrosshairObject.Remove()
                for _, Object in Objects do
                    Object:Destroy()
                end

                Visuals.Crosshair = nil
            end
        end

        CrosshairObject.Init()
        Visuals.Crosshair = CrosshairObject
    end

    function Visuals.RegisterFoV(Name, Settings)
        if Visuals.FoVs[Name] then return end

        local FoVObject = {
            Objects = {},
            LastTick = os_clock(),
            FovGradientTime = 0,
        }

        local Objects = FoVObject.Objects
        local LastTick = FoVObject.LastTick
        local VisualsHolder = Visuals.Holder
        local FovFunction = Settings.Follow
        local FillSettings = Settings.Fill or {}
        local GlowSettings = Settings.Glow or {}
        local OutlineSettings = Settings.Outline or {}
        local WatermarkSettings = Settings.Watermark or {}
        local mainColor = type(Settings.Color) == "table" and Settings.Color[1] or Settings.Color

        do 
            function FoVObject.Init()
                local z, z1, z2 = Settings.ZIndex or 1, Settings.ZIndex or 1, (Settings.ZIndex or 1) + 2

                
                Objects["FoVHolder"] = Utility.CreateObject("Frame", {Parent = VisualsHolder, ZIndex = z, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, ClipsDescendants = false})
                Objects["FoVGlow"] = Utility.CreateObject("ImageLabel", {Parent = Objects["FoVHolder"], ZIndex = 0, AnchorPoint = Vector2_new(0, 0), Visible = true, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), Size = UDim2_new(1, 0, 1, 0), BorderSizePixel = 0, Image = "rbxassetid://95287658758651", ScaleType = Enum.ScaleType.Stretch, ImageColor3 = Color3_fromRGB(255, 255, 255)})
                Utility.CreateObject("UIGradient", {Parent = Objects["FoVGlow"], Rotation = 90})

                Objects["FoVFill"] = Utility.CreateObject("Frame", {Parent = Objects["FoVHolder"], ZIndex = 1, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0.5, 0, 0.5, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Utility.CreateObject("UICorner", {Parent = Objects["FoVFill"], CornerRadius = UDim_new(1, 0)})
                Utility.CreateObject("UIGradient", {Parent = Objects["FoVFill"], Rotation = 90})

                Objects["FoVMain"] = Utility.CreateObject("Frame", {Parent = VisualsHolder, ZIndex = z2, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                local FoVMainStroke = Utility.CreateObject("UIStroke", {Parent = Objects["FoVMain"], Thickness = 1, LineJoinMode = Enum.LineJoinMode.Round})
                Utility.CreateObject("UIGradient", {Parent = FoVMainStroke, Rotation = 90, Color = ColorSequence_new{ColorSequenceKeypoint_new(0, Color3_fromRGB(255, 255, 255)), ColorSequenceKeypoint_new(1, Color3_fromRGB(255, 255, 255))}, Transparency = NumberSequence_new{NumberSequenceKeypoint_new(0, 0), NumberSequenceKeypoint_new(1, 0)}})
                Utility.CreateObject("UICorner", {Parent = Objects["FoVMain"], CornerRadius = UDim_new(1, 0)})

                Objects["FoVOutline"] = Utility.CreateObject("Frame", {Parent = VisualsHolder, ZIndex = z2 - 1, AnchorPoint = Vector2_new(0.5, 0.5), Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), Size = UDim2_new(0, 0, 0, 0), BorderSizePixel = 0, BackgroundColor3 = Color3_fromRGB(255, 255, 255)})
                Utility.CreateObject("UIStroke", {Parent = Objects["FoVOutline"], Thickness = 3, LineJoinMode = Enum.LineJoinMode.Round})
                Utility.CreateObject("UICorner", {Parent = Objects["FoVOutline"], CornerRadius = UDim_new(1, 0)})

                local Fonts = getgenv().Fonts
                local wmFont = (Fonts and Fonts.GetFont and Fonts.GetFont(VisualsSettings.Font)) or Font.new("Arial", Enum.FontWeight.Regular)
                local wmSize = WatermarkSettings.FontSize or 18
                Objects["FoVWatermark"] = Utility.CreateObject("TextLabel", {Parent = VisualsHolder, ZIndex = z2 + 1, AnchorPoint = Vector2_new(0.5, 0), Visible = false, BackgroundTransparency = 1, Position = UDim2_new(0, 0, 0, 0), Size = UDim2_new(0, 300, 0, 28), FontFace = wmFont, TextSize = wmSize, TextColor3 = Color3_fromRGB(255, 255, 255), Text = "", RichText = true, BorderSizePixel = 0})
                Utility.CreateObject("UIGradient", {Parent = Objects["FoVWatermark"], Rotation = 0})
                Utility.CreateObject("UIStroke", {Parent = Objects["FoVWatermark"], Color = Color3_fromRGB(0, 0, 0), Thickness = 1, LineJoinMode = Enum.LineJoinMode.Miter})
            end

            function FoVObject.Update(Delta)
                local frameDt = type(Delta) == "number" and Delta > 0 and math_min(Delta, 0.1) or (1 / 60)
                local animSpeed = Settings.AnimationSpeed or 1
                FoVObject.FovGradientTime = (FoVObject.FovGradientTime or 0) + frameDt * animSpeed
                local t = FoVObject.FovGradientTime or 0
                local vortexRot = Animation.GetVortexRotation(t, animSpeed)

                local FoVPosition = FovFunction()
                local FoVSize = Settings.Size or 150
                local FoVMain, FoVOutline = Objects["FoVMain"], Objects["FoVOutline"]

                if Settings.Enabled then
                    local fovGradientColors = type(Settings.Color) == "table" and Settings.Color or {Settings.Color, Settings.Color}
                    local c1, c2 = fovGradientColors[1], fovGradientColors[2] or fovGradientColors[1]
                    local circleAnim = Settings.CircleAnimation or Settings.GradientAnimation or "Scroll"
                    if circleAnim == "" then circleAnim = "Scroll" end
                    local fillAnim = type(FillSettings.Animation) == "string" and FillSettings.Animation or (FillSettings.Animation and "Scroll" or false)
                    local glowAnim = type(GlowSettings.Animation) == "string" and GlowSettings.Animation or (GlowSettings.Animation and "Scroll" or false)

                    local circleColorSeq = Animation.GetGradientColors2({c1, c2}, circleAnim == "Scroll", t, animSpeed)
                    local circleRot = 90 + (circleAnim == "Vortex" and vortexRot or 0)

                    local MainUIStroke = FoVMain:FindFirstChildOfClass("UIStroke")
                    local MainStrokeGradient = MainUIStroke and MainUIStroke:FindFirstChildOfClass("UIGradient")
                    local OutlineUIStroke = FoVOutline:FindFirstChildOfClass("UIStroke")

                    FoVMain.Visible = true
                    FoVMain.Position = UDim2_fromOffset(FoVPosition.X, FoVPosition.Y)
                    FoVMain.Size = UDim2_fromOffset(FoVSize, FoVSize)
                    if MainUIStroke then
                        MainUIStroke.Thickness = Settings.Thickness or 2
                        MainUIStroke.Color = Color3_fromRGB(255, 255, 255)
                        if MainStrokeGradient then
                            MainStrokeGradient.Color = circleColorSeq
                            MainStrokeGradient.Rotation = circleRot
                        end
                    end

                    FoVOutline.Visible = OutlineSettings.Enabled ~= false
                    FoVOutline.Position = UDim2_fromOffset(FoVPosition.X, FoVPosition.Y)
                    FoVOutline.Size = UDim2_fromOffset(FoVSize - 2, FoVSize - 2)
                    if OutlineUIStroke then
                        OutlineUIStroke.Thickness = (Settings.Thickness or 2) + (OutlineSettings.Thickness or 2)
                        local outlineC = OutlineSettings.Color or mainColor
                        OutlineUIStroke.Color = type(outlineC) == "table" and (outlineC[1] or outlineC[2]) or outlineC
                    end

                    local FoVHolder = Objects["FoVHolder"]
                    local FoVGlow = Objects["FoVGlow"]
                    local glowSize = GlowSettings.Enabled and (FoVSize * (GlowSettings.SizeScaleOuter or 1.35)) or FoVSize
                    FoVHolder.Visible = true
                    FoVHolder.Position = UDim2_fromOffset(FoVPosition.X, FoVPosition.Y)
                    FoVHolder.Size = UDim2_fromOffset(glowSize, glowSize)

                    if GlowSettings.Enabled then
                        FoVGlow.Visible = true
                        FoVGlow.ImageTransparency = GlowSettings.TransparencyOuter or 0.55
                        local glowGrad = FoVGlow:FindFirstChildOfClass("UIGradient")
                        if glowGrad then
                            local glowColorSeq = Animation.GetGradientColors2({c1, c2}, glowAnim == "Scroll", t, animSpeed)
                            glowGrad.Color = glowColorSeq
                            glowGrad.Rotation = (GlowSettings.Rotation or 90) + (glowAnim == "Vortex" and vortexRot or 0)
                        end
                    else
                        FoVGlow.Visible = false
                    end

                    local FoVFill = Objects["FoVFill"]
                    if FillSettings.Enabled then
                        local fillColors = type(FillSettings.Color) == "table" and #FillSettings.Color >= 2 and FillSettings.Color or {c1, c2}
                        local fillC1, fillC2 = fillColors[1], fillColors[2] or fillColors[1]
                        FoVFill.Visible = true
                        FoVFill.BackgroundTransparency = FillSettings.Transparency or 0.65
                        FoVFill.BackgroundColor3 = fillC1
                        FoVFill.Position = UDim2_new(0.5, 0, 0.5, 0)
                        FoVFill.Size = UDim2_fromOffset(FoVSize, FoVSize)
                        local fillGrad = FoVFill:FindFirstChildOfClass("UIGradient")
                        if fillGrad then
                            local fillColorSeq
                            if #fillColors >= 3 then
                                fillColorSeq = Animation.GetGradientColors({fillColors[1], fillColors[2], fillColors[3]}, fillAnim == "Scroll", t, animSpeed)
                            else
                                fillColorSeq = Animation.GetGradientColors2({fillC1, fillC2}, fillAnim == "Scroll", t, animSpeed)
                            end
                            fillGrad.Color = fillColorSeq
                            fillGrad.Rotation = (FillSettings.Rotation or 90) + (fillAnim == "Vortex" and vortexRot or 0)
                        end
                    else
                        FoVFill.Visible = false
                    end

                    local FoVWatermark = Objects["FoVWatermark"]
                    if WatermarkSettings.Enabled and WatermarkSettings.Text and WatermarkSettings.Text ~= "" then
                        FoVWatermark.Visible = true
                        FoVWatermark.Position = UDim2_fromOffset(FoVPosition.X, FoVPosition.Y + FoVSize / 2 + 8)
                        FoVWatermark.Text = WatermarkSettings.Text
                        local wmColor = WatermarkSettings.Color or mainColor
                        if type(wmColor) == "table" and #wmColor >= 2 then
                            local phase = (t * animSpeed * 0.4) % 1
                            FoVWatermark.TextColor3 = Color3_fromRGB(255, 255, 255)
                            FoVWatermark.Text = Animation.BuildWatermarkScrollText(wmColor, WatermarkSettings.Text, phase)
                            local wmGrad = FoVWatermark:FindFirstChildOfClass("UIGradient")
                            if wmGrad then wmGrad.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, wmColor[1]), ColorSequenceKeypoint_new(1, wmColor[1])} end
                        else
                            FoVWatermark.TextColor3 = type(wmColor) == "table" and wmColor[1] or wmColor
                            local wmGrad = FoVWatermark:FindFirstChildOfClass("UIGradient")
                            if wmGrad then
                                local c = type(wmColor) == "table" and wmColor[1] or wmColor
                                wmGrad.Color = ColorSequence_new{ColorSequenceKeypoint_new(0, c), ColorSequenceKeypoint_new(1, c)}
                            end
                        end
                        FoVWatermark.TextSize = WatermarkSettings.FontSize or 18
                    else
                        FoVWatermark.Visible = false
                    end
                else
                    FoVMain.Visible = false
                    FoVOutline.Visible = false
                    Objects["FoVFill"].Visible = false
                    if Objects["FoVHolder"] then Objects["FoVHolder"].Visible = false end
                    Objects["FoVWatermark"].Visible = false
                end
            end

            function FoVObject.Remove()
                for _, Object in pairs(Objects) do
                    if Object and Object.Destroy then
                        Object:Destroy()
                    end
                end
                Visuals.FoVs[Name] = nil
            end
        end

        FoVObject.Init()
        Visuals.FoVs[Name] = FoVObject
    end

    function Visuals.Init()
        Visuals.CreateCrosshair()
        for FovName, FovSettings in pairs(VisualsSettings.FoVs or {}) do
            if type(FovSettings) == "table" and not Visuals.FoVs[FovName] then
                Visuals.RegisterFoV(FovName, FovSettings)
            end
        end
        if VisualsSettings.FoVs and VisualsSettings.FoVs.SilentAim and type(VisualsSettings.FoVs.SilentAim) == "table" and not Visuals.FoVs.SilentAim then
            Visuals.RegisterFoV("SilentAim", VisualsSettings.FoVs.SilentAim)
        end
    end

    function Visuals.Unload()
        for _, Connection in ConnectionsTable do
            Connection:Disconnect()
        end
        table_clear(ConnectionsTable)

        if Visuals.Crosshair and type(Visuals.Crosshair.Remove) == "function" then
            Visuals.Crosshair.Remove()
        end
        Visuals.Crosshair = nil

        for FovName, FoV in pairs(Visuals.FoVs or {}) do
            if FoV and type(FoV.Remove) == "function" then
                FoV.Remove()
            end
        end
        if Visuals.FoVs then table_clear(Visuals.FoVs) end

        if Visuals.Holder and Visuals.Holder.Destroy then
            Visuals.Holder:Destroy()
            Visuals.Holder = nil
        end

        for _, Object in ObjectsTable do
            if Object and Object.Destroy then
                Object:Destroy()
            end
        end
        table_clear(ObjectsTable)

        getgenv().Fonts = nil
    end
end

do 
    Visuals.Init()

    Utility.AddConnection(RunService.Heartbeat, LPH_NO_VIRTUALIZE(function(Delta)
        local dt = type(Delta) == "number" and Delta > 0 and Delta or (1 / 60)
        local CrosshairObject = Visuals.Crosshair

        if CrosshairObject then
            CrosshairObject.Update(dt)
        end

        for _, FoV in pairs(Visuals.FoVs) do
            FoV.Update(dt)
        end
    end))
end
