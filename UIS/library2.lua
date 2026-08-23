local LoadingTick = os.clock()

if getgenv().Library then
    getgenv().Library:Unload()
end

local Library do
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Stats = game:GetService("Stats")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new

    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local InstanceNew = Instance.new

    local MathClamp = math.clamp
    local MathFloor = math.floor

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub

    Library = {
        Flags = { },

        Theme = {
            ["Background"] = FromRGB(13, 13, 16),
            ["Inline"] = FromRGB(18, 18, 22),
            ["Page Background"] = FromRGB(24, 24, 29),
            ["Border"] = FromRGB(6, 6, 8),
            ["Outline"] = FromRGB(34, 34, 41),
            ["Accent"] = FromRGB(120, 170, 255),
            ["Element"] = FromRGB(28, 28, 34),
            ["Hovered Element"] = FromRGB(38, 38, 46),
            ["Text"] = FromRGB(222, 222, 228),
            ["Text Border"] = FromRGB(0, 0, 0)
        },

        Presets = {
            ["Blue"] = FromRGB(120, 170, 255),
            ["Purple"] = FromRGB(170, 130, 255),
            ["Green"] = FromRGB(120, 220, 160),
            ["Red"] = FromRGB(255, 105, 115),
            ["Orange"] = FromRGB(255, 165, 90),
            ["Cyan"] = FromRGB(100, 220, 235),
            ["Pink"] = FromRGB(255, 140, 200),
            ["White"] = FromRGB(235, 235, 240)
        },

        MenuKeybind = Enum.KeyCode.RightShift,

        Tween = {
            Time = 0.22,
            Style = Enum.EasingStyle.Quart,
            Direction = Enum.EasingDirection.Out
        },

        Folders = {
            Directory = "kota",
            Configs = "kota/Configs",
            Assets = "kota/Assets"
        },

        Images = {
            ["Saturation"] = {"Saturation.png", "https://github.com/sametexe001/images/blob/main/saturation.png?raw=true" },
            ["Value"] = { "Value.png", "https://github.com/sametexe001/images/blob/main/value.png?raw=true" },
            ["Hue"] = { "Hue.png", "https://github.com/sametexe001/images/blob/main/hue.png?raw=true" },
            ["Scrollbar"] =  { "Scrollbar.png", "https://github.com/sametexe001/images/blob/main/scrollbar.png?raw=true" },
            ["Checkers"] = { "Checkers.png", "https://github.com/sametexe001/images/blob/main/checkers.png?raw=true" },
            ["Resize"] = { "Resize.png", "https://github.com/sametexe001/images/blob/main/resize.png?raw=true" },
        },

        Pages = { },
        Sections = { },
        Connections = { },
        Threads = { },
        ThemeMap = { },
        ThemeItems = { },

        SetFlags = { },

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        Font = nil,
        KeyList = nil,

        CurrentColorpicker = nil
    }

    Library.ActiveTweens = setmetatable({ }, { __mode = "k" })

    Library.FadeBase = setmetatable({ }, { __mode = "k" })

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = " )",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "`",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    for _, FileName in Library.Folders do
        if not isfolder(FileName) then
            makefolder(FileName)
        end
    end

    for _, ImageData in Library.Images do
        local ImageName = ImageData[1]
        local ImageLink = ImageData[2]

        if not isfile(Library.Folders.Assets .. "/" .. ImageName) then
            writefile(Library.Folders.Assets .. "/" .. ImageName, game:HttpGet(ImageLink))
        end
    end

    local Tween = { } do
        Tween.__index = Tween

        Tween.Create = function(self, Item, Info, Goal, IsRawItem)
            Item = IsRawItem and Item or Item.Instance
            Info = Info or TweenInfo.new(Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction)

            local Active = Library.ActiveTweens[Item]
            if not Active then
                Active = { }
                Library.ActiveTweens[Item] = Active
            end

            local NewTween = {
                Tween = TweenService:Create(Item, Info, Goal),
                Info = Info,
                Goal = Goal,
                Item = Item
            }

            for Property in Goal do
                local Running = Active[Property]
                if Running then Running:Cancel() end
                Active[Property] = NewTween.Tween
            end

            NewTween.Tween:Play()

            setmetatable(NewTween, Tween)

            return NewTween
        end

        Tween.Get = function(self)
            if not self.Tween then
                return
            end

            return self.Tween, self.Info, self.Goal
        end

        Tween.Pause = function(self)
            if not self.Tween then
                return
            end

            self.Tween:Pause()
        end

        Tween.Play = function(self)
            if not self.Tween then
                return
            end

            self.Tween:Play()
        end

        Tween.Clean = function(self)
            if not self.Tween then
                return
            end

            Tween:Pause()
            self = nil
        end
    end

    local FadeProperties = {
        "BackgroundTransparency",
        "TextTransparency",
        "ImageTransparency",
        "ScrollBarImageTransparency",
        "Transparency"
    }

    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            local Base = { }
            for _, Property in FadeProperties do
                local Value = tonumber(rawget(Properties, Property))
                if Value == nil then
                    local Ok, Live = pcall(function() return NewItem.Instance[Property] end)
                    Value = Ok and tonumber(Live) or nil
                end
                if Value ~= nil then
                    Base[Property] = Value
                end
            end
            Library.FadeBase[NewItem.Instance] = Base

            return NewItem
        end

        Instances.Border = function(self)
            if not self.Instance then
                return
            end

            local Item = self.Instance
            local UIStroke = Instances:Create("UIStroke", {
                Parent = Item,
                Color = Library.Theme.Border,
                Thickness = 1,
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            UIStroke:AddToTheme({Color = "Border"})

            return UIStroke
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then
                return
            end

            if not self.Instance[Event] then
                return
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Disconnect = function(self, Name)
            if not self.Instance then
                return
            end

            return Library:Disconnect(Name)
        end

        Instances.Clean = function(self)
            if not self.Instance then
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(self)
            if not self.Instance then
                return
            end

            local Gui = self.Instance

            local Dragging = false
            local DragStart
            local StartPosition

            local Set = function(Input)
                local DragDelta = Input.Position - DragStart
                Gui.Position = UDim2New(StartPosition.X.Scale, StartPosition.X.Offset + DragDelta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + DragDelta.Y)
                Library:RepositionOpen()
            end

            self:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true

                    DragStart = Input.Position
                    StartPosition = Gui.Position
                end
            end)

            self:Connect("InputEnded", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Dragging then
                        Set(Input)
                    end
                end
            end)

            return Dragging
        end

        Instances.MakeResizeable = function(self, Minimum, Maximum)
            if not self.Instance then
                return
            end

            local Gui = self.Instance

            local Resizing = false
            local Start = UDim2New()
            local Delta = UDim2New()
            local ResizeMax = Gui.Parent.AbsoluteSize - Gui.AbsoluteSize

            local ResizeButton = Instances:Create("TextButton", {
				Parent = Gui,
				AnchorPoint = Vector2New(1, 1),
				BorderColor3 = FromRGB(0, 0, 0),
				Size = UDim2New(0, 8, 0, 8),
				Position = UDim2New(1, 0, 1, 0),
                Name = "\0",
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
                Visible = true,
                Text = ""
			})

            ResizeButton:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = true

                    Start = Gui.Size - UDim2New(0, Input.Position.X, 0, Input.Position.Y)
                end
            end)

            ResizeButton:Connect("InputEnded", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Resizing = false
                end
            end)

            Library:Connect(UserInputService.InputChanged, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement and Resizing then
					ResizeMax = Maximum or Gui.Parent.AbsoluteSize - Gui.AbsoluteSize

					Delta = Start + UDim2New(0, Input.Position.X, 0, Input.Position.Y)
					Delta = UDim2New(0, math.clamp(Delta.X.Offset, Minimum.X, ResizeMax.X), 0, math.clamp(Delta.Y.Offset, Minimum.Y, ResizeMax.Y))

					Tween:Create(Gui, TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = Delta}, true)
                end
            end)

            return Resizing
        end

        Instances.OnHover = function(self, Function)
            if not self.Instance then
                return
            end

            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then
                return
            end

            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end

    local CustomFont = { } do
        function CustomFont:New(Name, Weight, Style, Data)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end

            if not isfile(Library.Folders.Assets .. "/" .. Name .. ".ttf") then
                writefile(Library.Folders.Assets .. "/" .. Name .. ".ttf", game:HttpGet(Data.Url))
            end

            local FontData = {
                name = Name,
                faces = { {
                    name = "Regular",
                    weight = Weight,
                    style = Style,
                    assetId = getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".ttf")
                } }
            }

            writefile(Library.Folders.Assets .. "/" .. Name .. ".json", HttpService:JSONEncode(FontData))
            return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
        end

        function CustomFont:Get(Name)
            if isfile(Library.Folders.Assets .. "/" .. Name .. ".json") then
                return Font.new(getcustomasset(Library.Folders.Assets .. "/" .. Name .. ".json"))
            end
        end

        CustomFont:New("Windows-XP-Tahoma", 200, "Regular", {
            Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/windows-xp-tahoma.ttf"
        })

        Library.Font = CustomFont:Get("Windows-XP-Tahoma")
    end

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        BorderColor3 = FromRGB(0, 0, 0),
        AnchorPoint = Vector2New(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2New(0.5, 0, 0, 0),
        Name = "\0",
        Size = UDim2New(0.34, 0, 1, -14),
        BorderSizePixel = 0,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDimNew(0, 10)
    })

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]

        if not ImageData then
            return
        end

        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        Number = tonumber(Number)
        if Number == nil or Number ~= Number then return 0 end

        local Precision = tonumber(Float) or 0

        if Precision > 0 and Precision < 1 then
            local Fraction = tostring(Precision):match("%.(%d+)")
            Precision = Fraction and #Fraction or 0
        end

        Precision = MathClamp(MathFloor(Precision), 0, 6)

        if Precision == 0 then
            return MathFloor(Number + 0.5)
        end

        local Result = tonumber(StringFormat("%." .. Precision .. "f", Number))
        if Result == nil or Result ~= Result then return 0 end
        return Result
    end

    Library.GetTransparencyPropertyFromItem = function(self, Item)
        if Item:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Item:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Item:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("UIStroke") then
            return { "Transparency" }
        end
    end

    Library.FadeItem = function(self, Item, Property, Visibility, Speed)
        local Base = Library.FadeBase[Item] and Library.FadeBase[Item][Property]

        if Base == nil then
            Base = tonumber(Item[Property]) or 0
            Library.FadeBase[Item] = Library.FadeBase[Item] or { }
            Library.FadeBase[Item][Property] = Base
        end

        if Visibility then
            Item[Property] = 1
        end

        return Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
            [Property] = Visibility and Base or 1
        }, true)
    end

    Library.Unload = function(self)
        for Index, Value in self.Connections do
            Value.Connection:Disconnect()
        end

        for Index, Value in self.Threads do
            coroutine.close(Value)
        end

        if self.Holder then
            self.Holder:Clean()
        end

        Library = nil
        getgenv().Library = nil
    end

    Library.Thread = function(self, Function)
        local NewThread = coroutine.create(Function)

        coroutine.wrap(function()
            coroutine.resume(NewThread)
        end)()

        TableInsert(self.Threads, NewThread)

        return NewThread
    end

    Library.SafeCall = function(self, Function, ...)
        local Arguements = { ... }
        local Success, Result = pcall(Function, TableUnpack(Arguements))

        if not Success then
            Library:Notification("Error caught in function, report this to the devs:\n"..Result, 5, FromRGB(255, 0, 0))
            warn(Result)
            return false
        end

        return Success
    end

    Library.Connect = function(self, Event, Callback, Name)
        Name = Name or StringFormat("Connection_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        if Event then
            local ok, conn = pcall(function() return Event:Connect(Callback) end)
            if ok then NewConnection.Connection = conn end
        end

        TableInsert(self.Connections, NewConnection)
        return NewConnection
    end

    Library.Disconnect = function(self, Name)
        for _, Connection in self.Connections do
            if Connection.Name == Name then
                Connection.Connection:Disconnect()
                break
            end
        end
    end

    Library.NextFlag = function(self)
        local FlagNumber = self.UnnamedFlags + 1
        return StringFormat("Flag Number %s %s", FlagNumber, HttpService:GenerateGUID(false))
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    Library.GetConfig = function(self)
        local Config = { }

        pcall(function()
            for Index, Value in pairs(Library.Flags) do
                local ok, packed = pcall(function()
                    local t = type(Value)
                    if t == "boolean" or t == "number" or t == "string" then
                        return Value
                    end
                    if t ~= "table" then return nil end

                    if Value.Class == "Keybind" then
                        local k = Value.Key
                        if k == nil or k == "" then k = "None" end
                        local m = Value.Mode
                        if m == nil or m == "" then m = "Toggle" end
                        return { Key = tostring(k), Mode = tostring(m) }
                    end

                    if Value.Class == "Colorpicker" then
                        local hx = Value.HexValue
                        if hx == nil or hx == "" then
                            local col = Value.Color
                            if typeof(col) == "Color3" then hx = col:ToHex() else hx = "FFFFFF" end
                        end
                        return { Color = "#" .. tostring(hx), Alpha = tonumber(Value.Alpha) or 0 }
                    end

                    if Value.Key ~= nil then
                        return { Key = tostring(Value.Key), Mode = tostring(Value.Mode or "Toggle") }
                    end
                    if Value.Color ~= nil then
                        return { Color = "#" .. tostring(Value.HexValue or "FFFFFF"), Alpha = tonumber(Value.Alpha) or 0 }
                    end

                    local clean = {}
                    for k, v in pairs(Value) do
                        local kt = type(k)
                        local vt = type(v)
                        if (kt == "string" or kt == "number") and (vt == "boolean" or vt == "number" or vt == "string") then
                            clean[k] = v
                        end
                    end
                    return clean
                end)
                if ok and packed ~= nil then
                    Config[Index] = packed
                end
            end
        end)

        local OkEnc, Encoded = pcall(function() return HttpService:JSONEncode(Config) end)
        if OkEnc and type(Encoded) == "string" then return Encoded end
        return "{}"
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do
                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        if Success then
            Library:Notification("Successfully loaded config", 5, Color3.fromRGB(0, 255, 0))
        end
    end

    Library.DeleteConfig = function(self, Config)
        local Name = StringGSub(tostring(Config or ""), "%.json$", "")
        if Name == "" then return false end

        local Path = Library.Folders.Configs .. "/" .. Name .. ".json"
        if not isfile(Path) then return false end

        local Ok = pcall(delfile, Path)
        if not Ok then return false end

        Library:Notification("Deleted config " .. Name .. ".json", 5, Color3.fromRGB(0, 255, 0))
        return true
    end

    Library.SaveConfig = function(self, Config)
        local Name = StringGSub(tostring(Config or ""), "%.json$", "")
        if Name == "" then return false end

        pcall(function()
            if not isfolder(Library.Folders.Directory) then makefolder(Library.Folders.Directory) end
            if not isfolder(Library.Folders.Configs) then makefolder(Library.Folders.Configs) end
        end)

        local Body = Library:GetConfig()
        local Path = Library.Folders.Configs .. "/" .. Name .. ".json"
        local Ok, Err = pcall(writefile, Path, Body)

        if not Ok then
            Library:Notification("could not write " .. Name .. ".json: " .. tostring(Err), 5, FromRGB(255, 0, 0))
            return false
        end

        Library:Notification("Saved config " .. Name .. ".json", 5, Color3.fromRGB(0, 255, 0))
        return true
    end

    Library.RefreshConfigsList = function(self, Element)
        local CurrentList = { }
        local List = { }

        local ConfigFolderName = StringGSub(Library.Folders.Configs, Library.Folders.Directory .. "/", "")

        for Index, Value in listfiles(Library.Folders.Configs) do
            local FileName = StringGSub(Value, Library.Folders.Directory .. "\\" .. ConfigFolderName .. "\\", "")
            List[Index] = FileName
        end

        local IsNew = #List ~= CurrentList

        if not IsNew then
            for Index = 1, #List do
                if List[Index] ~= CurrentList[Index] then
                    IsNew = true
                    break
                end
            end
        else
            CurrentList = List
            Element:Refresh(CurrentList)
        end
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then
            return
        end

        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    local Active = self.ActiveTweens[Item.Item]
                    local Running = Active and Active[Property]
                    if Running then
                        Running:Cancel()
                        Active[Property] = nil
                    end
                    Item.Item[Property] = Color
                end
            end
        end
    end

    Library.TurnTokens = setmetatable({ }, { __mode = "k" })

    Library.NextTurn = function(self, Owner)
        local Token = (self.TurnTokens[Owner] or 0) + 1
        self.TurnTokens[Owner] = Token
        return Token
    end

    Library.IsTurn = function(self, Owner, Token)
        return self.TurnTokens[Owner] == Token
    end

    Library.FadeTokens = Library.FadeTokens or { }

    Library.FadeCache = setmetatable({ }, { __mode = "k" })

    Library.DropFadeCache = function(self, Root)
        self.FadeCache[Root] = nil
    end

    Library.CollectFades = function(self, Root)
        local List = self.FadeCache[Root]
        if List then return List end

        List = { }
        local Items = Root:GetDescendants()
        Items[#Items + 1] = Root

        for _, Child in Items do
            local Props = self:GetTransparencyPropertyFromItem(Child)
            if Props then
                local Stored = self.FadeBase[Child]
                for _, Property in Props do
                    local Base = Stored and Stored[Property]
                    if Base == nil then Base = tonumber(Child[Property]) end
                    if Base ~= nil and Base < 1 then
                        List[#List + 1] = { Child, Property, Base }
                    end
                end
            end
        end

        self.FadeCache[Root] = List
        return List
    end

    local Layered = {
        Frame = true,
        ScrollingFrame = true,
        TextLabel = true,
        TextButton = true,
        TextBox = true,
        ImageLabel = true,
        ImageButton = true,
        CanvasGroup = true,
        ScreenGui = true
    }

    Library.Layered = Layered

    local function IsOnScreen(Item, Root)
        local Node = Item
        while Node and Node ~= Root do
            if Layered[Node.ClassName] and Node.Visible == false then
                return false
            end
            Node = Node.Parent
        end
        return true
    end

    Library.PlayFades = function(self, Root, Visible, Info)
        for _, Entry in self:CollectFades(Root) do
            local Child, Property, Base = Entry[1], Entry[2], Entry[3]
            if Child.Parent and IsOnScreen(Child, Root) then
                if Visible then Child[Property] = 1 end
                Tween:Create(Child, Info, { [Property] = Visible and Base or 1 }, true)
            end
        end
    end

    Library.FadeStates = setmetatable({ }, { __mode = "k" })

    Library.FadeWidget = function(self, Item, Visible, Speed)
        local Root = Item.Instance or Item
        Visible = Visible == true

        if self.FadeStates[Root] == Visible then return end
        self.FadeStates[Root] = Visible

        local Info = TweenInfo.new(Speed or 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        local Token = (self.FadeTokens[Root] or 0) + 1
        self.FadeTokens[Root] = Token

        if Visible then
            Root.Visible = true
        end

        local function Fade(Item)
            local Props = self:GetTransparencyPropertyFromItem(Item)
            if not Props then return end
            for _, Property in Props do
                local Current = Item[Property]
                if type(Current) == "number" then
                    local Key = "Base" .. Property
                    if Item:GetAttribute(Key) == nil then
                        Item:SetAttribute(Key, Current)
                    end
                    local Base = Item:GetAttribute(Key)
                    if Visible then Item[Property] = 1 end
                    Tween:Create(Item, Info, { [Property] = Visible and Base or 1 }, true)
                end
            end
        end

        for _, Value in Root:GetDescendants() do
            Fade(Value)
        end
        Fade(Root)

        if not Visible then
            task.delay(Speed or 0.22, function()
                if self.FadeTokens[Root] == Token then
                    Root.Visible = false
                end
            end)
        end
    end

    Library.BindActive = function(self, State, Flag)
        if not State then return false end
        if not Flag then return true end
        local Bind = self.Flags[Flag]
        if type(Bind) ~= "table" then return true end
        if Bind.GetState then return Bind:GetState() end
        if Bind.Mode == "Always" then return true end
        if Bind.Key == nil or Bind.Key == "None" then return false end
        return Bind.Toggled == true
    end

    Library.GetBind = function(self, Flag)
        return self.Flags[Flag]
    end

    Library.MatchesMenuKey = function(self, Input)
        local Key = self.MenuKeybind
        if Key == nil then return false end

        if typeof(Key) == "EnumItem" then
            return Input.KeyCode == Key or Input.UserInputType == Key
        end

        local Text = tostring(Key)
        return tostring(Input.KeyCode) == Text
            or tostring(Input.UserInputType) == Text
            or Input.KeyCode.Name == Text
    end

    Library.Tooltip = function(self, Item, Text)
        if not Text or Text == "" then return end

        if not Library.TipBox then
            local Box = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Size = UDim2New(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BorderSizePixel = 2,
                ZIndex = 400,
                Visible = false,
                BackgroundTransparency = 1,
                BackgroundColor3 = FromRGB(13, 13, 16)
            })  Box:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Box.Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Box.Instance,
                PaddingTop = UDimNew(0, 4),
                PaddingBottom = UDimNew(0, 4),
                PaddingLeft = UDimNew(0, 7),
                PaddingRight = UDimNew(0, 7)
            })

            local Label = Instances:Create("TextLabel", {
                Parent = Box.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                Size = UDim2New(0, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex = 401,
                TextTransparency = 1,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Label:AddToTheme({TextColor3 = "Text"})

            Library.TipBox = Box
            Library.TipText = Label
        end

        local Box = Library.TipBox
        local Label = Library.TipText
        local Token = 0

        Item:OnHover(function()
            Token = Token + 1
            local Mine = Token

            task.delay(0.35, function()
                if Mine ~= Token then return end

                Label.Instance.Text = tostring(Text)
                Box.Instance.Visible = true

                local Spot = UserInputService:GetMouseLocation()
                local Inset = Vector2New(0, 0)
                pcall(function() Inset = GuiService:GetGuiInset() end)

                Box.Instance.Position = UDim2New(0, Spot.X - Inset.X + 14, 0, Spot.Y - Inset.Y + 16)

                local Fade = TweenInfo.new(0.14, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
                Box:Tween(Fade, {BackgroundTransparency = 0})
                Label:Tween(Fade, {TextTransparency = 0})
            end)
        end)

        Item:OnHoverLeave(function()
            Token = Token + 1
            local Mine = Token

            local Fade = TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            Box:Tween(Fade, {BackgroundTransparency = 1})
            Label:Tween(Fade, {TextTransparency = 1})

            task.delay(0.12, function()
                if Mine ~= Token then return end
                Box.Instance.Visible = false
            end)
        end)
    end

    Library.SetClipboard = function(self, Text)
        local Writers = { setclipboard, toclipboard, set_clipboard, writeclipboard }

        for _, Writer in Writers do
            if type(Writer) == "function" then
                local Ok = pcall(Writer, Text)
                if Ok then return true end
            end
        end

        local Clip = syn and syn.write_clipboard
        if type(Clip) == "function" then
            return (pcall(Clip, Text))
        end

        return false
    end

    Library.OpenDropdowns = { }
    Library.OpenKeybinds = { }

    Library.CloseKeybinds = function(self)
        for Item in self.OpenKeybinds do
            if Item.IsOpen then
                pcall(function() Item:SetOpen(false) end)
            end
        end
    end

    Library.RepositionOpen = function(self)
        for Item in self.OpenDropdowns do
            if Item.IsOpen and Item.Reposition then
                pcall(function() Item:Reposition() end)
            end
        end

        for Item in self.OpenKeybinds do
            if Item.IsOpen and Item.Reposition then
                pcall(function() Item:Reposition() end)
            end
        end
    end

    Library.CloseDropdowns = function(self)
        for Item in self.OpenDropdowns do
            if Item.IsOpen then
                pcall(function() Item:SetOpen(false) end)
            end
        end
    end

    Library.CloseColorpicker = function(self, Instant)
        local Open = self.CurrentColorpicker
        if not Open then return end
        Open:SetOpen(false, Instant)
        self.CurrentColorpicker = nil
    end

    Library.Connect(Library, UserInputService.InputBegan, function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local Open = Library.CurrentColorpicker
        if not Open then return end

        if Library:IsMouseOverFrame(Open.Window) then return end
        if Open.Button and Library:IsMouseOverFrame(Open.Button) then return end

        Library:CloseColorpicker()
    end)

    Library.ApplyPreset = function(self, Name)
        local Color = self.Presets[Name]
        if not Color then return false end
        self:ChangeTheme("Accent", Color)
        return true
    end

    Library.GetPresets = function(self)
        local List = { }
        for Name in self.Presets do
            List[#List + 1] = Name
        end
        table.sort(List)
        return List
    end

    Library.IsMouseOverFrame = function(self, Frame)
        Frame = Frame.Instance or Frame
        if not Frame or not Frame.AbsolutePosition then return false end

        local Cursor = UserInputService:GetMouseLocation()
        local Inset = Vector2New(0, 0)
        pcall(function() Inset = GuiService:GetGuiInset() end)
        Cursor = Vector2New(Cursor.X - Inset.X, Cursor.Y - Inset.Y)

        local Pos = Frame.AbsolutePosition
        local Size = Frame.AbsoluteSize

        return Cursor.X >= Pos.X and Cursor.X <= Pos.X + Size.X
           and Cursor.Y >= Pos.Y and Cursor.Y <= Pos.Y + Size.Y
    end

    Library.Watermark = function(self, Name)
        local Watermark = { }

        local Items = { } do
            Items["Watermark"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Size = UDim2New(0, 0, 0, 20),
                Name = "\0",
                Position = UDim2New(0, 15, 0, 15),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Watermark"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["Watermark"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["Watermark"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Items["Watermark"].Instance,
                PaddingTop = UDimNew(0, 2),
                PaddingRight = UDimNew(0, 5),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Watermark"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 1),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Watermark"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -2),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 10, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })
        end

        function Watermark:SetVisibility(Bool)
            Library:FadeWidget(Items["Watermark"], Bool)
        end

        return Watermark
    end

    Library.Notification = function(self, Text, Duration, Color, Icon)
        local Items = { } do
            Items["Notification"] = Instances:Create("Frame", {
                Parent = Library.NotifHolder.Instance,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 22),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Notification"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Items["Notification"].Instance,
                PaddingTop = UDimNew(0, 1),
                PaddingRight = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Notification"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Text,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 13, 0, 2),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -1),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 13, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = Color
            })

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Notification"].Instance,
                ImageColor3 = FromRGB(255, 255, 255),
                ScaleType = Enum.ScaleType.Fit,
                BorderColor3 = FromRGB(0, 0, 0),
                Name = "\0",
                Image = "rbxassetid://94324346713012",
                BackgroundTransparency = 1,
                Position = UDim2New(0, -2, 0, 3),
                Size = UDim2New(0, 13, 0, 13),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            if not Icon then
                Items["Icon"]:Clean()
                Items["Title"].Instance.Position = UDim2New(0, 1, 0, 2)
            else
                Items["Icon"].Instance.Image = Icon[1]
                Items["Icon"].Instance.ImageColor3 = Icon[2] or FromRGB(255, 255, 255)
            end
        end

        Items["Notification"].Instance.BackgroundTransparency = 1
        Items["Notification"].Instance.Size = UDim2New(0, 0, 0, 0)
        for Index, Value in Items["Notification"].Instance:GetDescendants() do
            if Value:IsA("UIStroke") then
                Value.Transparency = 1
            elseif Value:IsA("TextLabel") then
                Value.TextTransparency = 1
            elseif Value:IsA("ImageLabel") then
                Value.ImageTransparency = 1
            elseif Value:IsA("Frame") then
                Value.BackgroundTransparency = 1
            end
        end

        Library:Thread(function()
            Items["Notification"]:Tween(nil, {BackgroundTransparency = 0, Size = UDim2New(0, 0, 0, 22)})

            task.wait(0.06)

            for Index, Value in Items["Notification"].Instance:GetDescendants() do
                if Value:IsA("UIStroke") then
                    Tween:Create(Value, nil, {Transparency = 0}, true)
                elseif Value:IsA("TextLabel") then
                    Tween:Create(Value, nil, {TextTransparency = 0}, true)
                elseif Value:IsA("ImageLabel") then
                    Tween:Create(Value, nil, {ImageTransparency = 0}, true)
                elseif Value:IsA("Frame") then
                    Tween:Create(Value, nil, {BackgroundTransparency = 0}, true)
                end
            end

            task.delay(Duration + 0.1, function()
                for Index, Value in Items["Notification"].Instance:GetDescendants() do
                    if Value:IsA("UIStroke") then
                        Tween:Create(Value, nil, {Transparency = 1}, true)
                    elseif Value:IsA("TextLabel") then
                        Tween:Create(Value, nil, {TextTransparency = 1}, true)
                    elseif Value:IsA("ImageLabel") then
                        Tween:Create(Value, nil, {ImageTransparency = 1}, true)
                    elseif Value:IsA("Frame") then
                        Tween:Create(Value, nil, {BackgroundTransparency = 1}, true)
                    end
                end

                task.wait(0.06)

                Items["Notification"]:Tween(nil, {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0)})

                task.wait(0.5)
                Items["Notification"]:Clean()
            end)
        end)
    end

    Library.KeybindList = function(self)
        local KeybindList = { }
        self.KeyList = KeybindList

        local Items = { } do
            Items["KeybindList"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AnchorPoint = Vector2New(0, 0.5),
                Name = "\0",
                Position = UDim2New(0, 15, 0.5, 0),
                Size = UDim2New(0, 0, 0, 18),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["KeybindList"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["KeybindList"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["KeybindList"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -5),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 10, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Instances:Create("UIPadding", {
                Parent = Items["KeybindList"].Instance,
                PaddingTop = UDimNew(0, 5),
                PaddingBottom = UDimNew(0, 5),
                PaddingRight = UDimNew(0, 5),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["KeybindList"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Keybinds",
                Name = "\0",
                Size = UDim2New(0, 100, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 5, 0, 19),
                BorderColor3 = FromRGB(0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        local Entries = { }

        local function Resize()
            local shown = 0
            for _, Entry in Entries do
                if Entry.Instance.Visible then shown = shown + 1 end
            end
            Items["Title"].Instance.Text = shown > 0 and ("Keybinds [" .. shown .. "]") or "Keybinds"
            Items["Content"].Instance.Visible = shown > 0
        end

        function KeybindList:Add(Mode, Name, Key)
            local NewKey = Instances:Create("TextLabel", {
                Parent = Items["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "(" .. Mode .. ") " .. Name .. " - " .. Key,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  NewKey:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = NewKey.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            function NewKey:Set(Mode, Name, Key)
                NewKey.Instance.Text = "(" .. Mode .. ") " .. Name .. " - " .. Key
            end

            function NewKey:SetStatus(Status)
                if Status == "Active" then
                    NewKey:Tween(nil, {TextColor3 = Library.Theme.Accent})
                    NewKey:ChangeItemTheme({TextColor3 = "Accent"})
                else
                    NewKey:Tween(nil, {TextColor3 = Library.Theme.Text})
                    NewKey:ChangeItemTheme({TextColor3 = "Text"})
                end
            end

            function NewKey:SetVisible(Bool)
                if NewKey.Instance.Visible == Bool then return end
                NewKey.Instance.Visible = Bool
                Resize()
            end

            function NewKey:Remove()
                for Index, Entry in Entries do
                    if Entry == NewKey then
                        TableRemove(Entries, Index)
                        break
                    end
                end
                NewKey:Clean()
                Resize()
            end

            NewKey.Instance.Visible = false
            TableInsert(Entries, NewKey)
            Resize()

            return NewKey
        end

        function KeybindList:SetVisibility(Bool)
            Library:FadeWidget(Items["KeybindList"], Bool)
        end

        return KeybindList
    end

    Library.Notify = function(self, Title, Text, Duration)
        if Text == nil then
            return self:Notification(tostring(Title), Duration or 5)
        end
        return self:Notification(tostring(Title) .. ": " .. tostring(Text), Duration or 5)
    end

    Library.SetScale = function(self, Value)
        self.Scale = tonumber(Value) or 1
    end

    Library.ApplyThemePreset = function(self, Name)
        return self:ApplyPreset(Name)
    end

    Library.GetConfigs = function(self)
        local List = { }
        local Ok, Files = pcall(listfiles, self.Folders.Configs)
        if not Ok or type(Files) ~= "table" then return List end

        for _, Path in Files do
            local Name = tostring(Path):match("([^/\\]+)%.json$")
            if Name then List[#List + 1] = Name end
        end

        table.sort(List)
        return List
    end

    Library.LoadConfigFromFile = function(self, Name)
        local Path = self.Folders.Configs .. "/" .. tostring(Name) .. ".json"
        local Ok, Body = pcall(readfile, Path)
        if not Ok or type(Body) ~= "string" or Body == "" then
            self:Notification("config '" .. tostring(Name) .. "' not found", 5, FromRGB(255, 0, 0))
            return false
        end
        self:LoadConfig(Body)
        return true
    end

    Library.CreateWatermark = function(self, Info)
        Info = Info or { }
        local Mark = self:Watermark(Info.Name or Info.Text or "kota.tech")

        function Mark:SetText(Text)
            Mark:Set(Text)
        end

        return Mark
    end

    Library.EspPreview = function(self, Info)
        Info = Info or { }
        local Preview = {
            Settings = nil,
            OnChange = nil,
            Visible = false
        }

        function Preview:SetSettings(Value) Preview.Settings = Value end
        function Preview:SetOnChange(Value) Preview.OnChange = Value end
        function Preview:Refresh() end
        function Preview:SetVisibility(Bool) Preview.Visible = Bool == true end

        return Preview
    end

    Library.CreateWindow = function(self, Info)
        Info = Info or { }

        local Window = self:Window({
            Name = Info.Title or Info.Name or "kota.tech",
            Size = Info.Size or UDim2New(0, 620, 0, 540)
        })

        local Pages = { }

        function Window:AddTab(Name, UseSubTabs)
            local Page = Window:Page({ Name = Name, Columns = 2, SubTabs = UseSubTabs == true })
            Pages[#Pages + 1] = Page

            local function Box(Side)
                local Group = { Names = { }, Built = nil, Side = Side }

                function Group:AddTab(TabName)
                    if Group.Built then
                        error("library2: AddTab after the tabbox was built", 2)
                    end
                    Group.Names[#Group.Names + 1] = TabName
                    return setmetatable({ }, {
                        __index = function(_, Key)
                            local Section = Group:Resolve(TabName)
                            local Value = Section[Key]
                            if type(Value) == "function" then
                                return function(_, ...) return Value(Section, ...) end
                            end
                            return Value
                        end
                    })
                end

                function Group:Resolve(TabName)
                    if not Group.Built then
                        Group.Built = { Page:MultiSection({ Sections = Group.Names, Side = Group.Side }) }
                    end
                    for Index, Name in Group.Names do
                        if Name == TabName then return Group.Built[Index] end
                    end
                    return Group.Built[1]
                end

                return Group
            end

            local function Attach(Host)
                local function HostBox(Side)
                    local Group = { Names = { }, Built = nil, Side = Side }

                    function Group:AddTab(TabName)
                        if Group.Built then
                            error("library2: AddTab after the tabbox was built", 2)
                        end
                        Group.Names[#Group.Names + 1] = TabName
                        return setmetatable({ }, {
                            __index = function(_, Key)
                                local Section = Group:Resolve(TabName)
                                local Value = Section[Key]
                                if type(Value) == "function" then
                                    return function(_, ...) return Value(Section, ...) end
                                end
                                return Value
                            end
                        })
                    end

                    function Group:Resolve(TabName)
                        if not Group.Built then
                            Group.Built = { Host:MultiSection({ Sections = Group.Names, Side = Group.Side }) }
                        end
                        for Index, TabTitle in Group.Names do
                            if TabTitle == TabName then return Group.Built[Index] end
                        end
                        return Group.Built[1]
                    end

                    return Group
                end

                function Host:AddLeftTabbox() return HostBox(1) end
                function Host:AddRightTabbox() return HostBox(2) end
                function Host:AddLeftGroupbox(GroupName) return Host:Section({ Name = GroupName, Side = 1 }) end
                function Host:AddRightGroupbox(GroupName) return Host:Section({ Name = GroupName, Side = 2 }) end

                return Host
            end

            function Page:AddLeftTabbox() return Box(1) end
            function Page:AddRightTabbox() return Box(2) end
            function Page:AddLeftGroupbox(GroupName) return Page:Section({ Name = GroupName, Side = 1 }) end
            function Page:AddRightGroupbox(GroupName) return Page:Section({ Name = GroupName, Side = 2 }) end

            function Page:AddSubTab(SubName)
                return Attach(Page:SubPage({ Name = SubName, Columns = 2 }))
            end

            return Page
        end

        return Window
    end

    Library.TargetIndicator = function(self, Data)
        Data = Data or { }

        local HUD = {
            Target = nil,
            Weapon = "",
            Distance = 0,
            Damage = 0,
            Statuses = { },
            Visible = false
        }

        local ReplicatedStorage = ReplicatedStorage

        local Items = { } do
            Items["HUD"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AnchorPoint = Vector2New(1, 0),
                Name = "\0",
                Position = UDim2New(1, -15, 0, 15),
                Size = UDim2New(0, 280, 0, 104),
                BorderSizePixel = 2,
                Visible = false,
                BackgroundColor3 = FromRGB(13, 13, 16)
            })  Items["HUD"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["HUD"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["HUD"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["HUD"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(120, 170, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["AvatarBorder"] = Instances:Create("Frame", {
                Parent = Items["HUD"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 8),
                Size = UDim2New(0, 54, 0, 54),
                BorderSizePixel = 2,
                BorderColor3 = FromRGB(10, 10, 10),
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Items["AvatarBorder"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["AvatarBorder"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["Avatar"] = Instances:Create("ImageLabel", {
                Parent = Items["AvatarBorder"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                ScaleType = Enum.ScaleType.Fit,
                Image = "",
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Name"] = Instances:Create("TextLabel", {
                Parent = Items["HUD"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "no target",
                Name = "\0",
                Position = UDim2New(0, 68, 0, 7),
                Size = UDim2New(1, -110, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Name"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Name"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Damage"] = Instances:Create("TextLabel", {
                Parent = Items["HUD"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(120, 170, 255),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -7, 0, 7),
                Size = UDim2New(0, 60, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Damage"]:AddToTheme({TextColor3 = "Accent"})

            Instances:Create("UIStroke", {
                Parent = Items["Damage"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local function Stat(Label, Offset)
                local Key = Instances:Create("TextLabel", {
                    Parent = Items["HUD"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(222, 222, 228),
                    TextTransparency = 0.3,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Label,
                    Name = "\0",
                    Position = UDim2New(0, 68, 0, Offset),
                    Size = UDim2New(0, 74, 0, 14),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Key:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = Key.Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})

                local Value = Instances:Create("TextLabel", {
                    Parent = Items["HUD"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(222, 222, 228),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = "--",
                    Name = "\0",
                    Position = UDim2New(0, 146, 0, Offset),
                    Size = UDim2New(1, -154, 0, 14),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BorderSizePixel = 0,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Value:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = Value.Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})

                return Value
            end

            Items["KD"] = Stat("kd", 24)
            Items["Time"] = Stat("played hours", 38)
            Items["Tool"] = Stat("holding tool", 52)
            Items["Status"] = Stat("status", 66)

            Items["HealthBack"] = Instances:Create("Frame", {
                Parent = Items["HUD"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 88),
                Size = UDim2New(1, -14, 0, 10),
                BorderSizePixel = 2,
                BorderColor3 = FromRGB(10, 10, 10),
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Items["HealthBack"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["HealthBack"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["HealthFill"] = Instances:Create("Frame", {
                Parent = Items["HealthBack"].Instance,
                Name = "\0",
                Size = UDim2New(0, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(120, 170, 255)
            })  Items["HealthFill"]:AddToTheme({BackgroundColor3 = "Accent"})

            Items["HealthText"] = Instances:Create("TextLabel", {
                Parent = Items["HealthBack"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["HealthText"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["HealthText"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

        end

        local Ticked = 0

        local StatusOrder = { "Manipulated", "Manipulating", "Penetrated", "Visible", "Unvisible" }

        local function Elapsed(Status)
            local Seconds = os.clock() - Status.Since
            if Seconds < 1 then return "" end
            if Seconds < 60 then return StringFormat(" %.1fs", Seconds) end
            return StringFormat(" %dm", MathFloor(Seconds / 60))
        end

        local function RefreshStatus()
            for _, Name in StatusOrder do
                local Status = HUD.Statuses[Name]
                if Status and Status.Since then
                    Items["Status"].Instance.Text = string.lower(Name) .. Elapsed(Status)
                    Items["Status"].Instance.TextColor3 = Status.Color or Library.Theme.Accent
                    return
                end
            end

            for Name, Status in HUD.Statuses do
                if Status.Since then
                    Items["Status"].Instance.Text = string.lower(Name) .. Elapsed(Status)
                    Items["Status"].Instance.TextColor3 = Status.Color or Library.Theme.Accent
                    return
                end
            end

            Items["Status"].Instance.Text = "--"
            Items["Status"].Instance.TextColor3 = Library.Theme.Text
        end

        local function GetPlayer(Target)
            if typeof(Target) ~= "Instance" then return nil end
            if Target:IsA("Player") then return Target end
            return Players:GetPlayerFromCharacter(Target)
        end

        local function GetCharacter(Target)
            if typeof(Target) ~= "Instance" then return nil end
            if Target:IsA("Player") then return Target.Character end
            if Target:IsA("Model") then return Target end
            return nil
        end

        local function ReadStats(Player)
            if not Player then return "--", "--" end

            local Ok, Kd, Time = pcall(function()
                local Data = ReplicatedStorage:FindFirstChild("Players")
                local Profile = Data and Data:FindFirstChild(Player.Name)
                local Status = Profile and Profile:FindFirstChild("Status")
                local Journey = Status and Status:FindFirstChild("Journey")
                local Stats = Journey and Journey:FindFirstChild("Statistics")
                if not Stats then return "--", "--" end

                local Kills = tonumber(Stats:GetAttribute("Kills"))
                local Deaths = tonumber(Stats:GetAttribute("Deaths"))
                local Played = tonumber(Stats:GetAttribute("TimePlayed"))
                if Kills == nil and Deaths == nil and Played == nil then return "--", "--" end

                Kills = math.max(MathFloor((Kills or 0) + 0.5), 0)
                Deaths = math.max(MathFloor((Deaths or 0) + 0.5), 0)
                Played = math.max(Played or 0, 0)

                local Ratio = Deaths > 0 and Kills / Deaths or Kills
                return StringFormat("%.2f (%d/%d)", Ratio, Kills, Deaths), StringFormat("%.1fh", Played / 3600)
            end)

            if Ok then return Kd, Time end
            return "--", "--"
        end

        function HUD:SetTarget(Target)
            if HUD.Target == Target then return end

            HUD.Target = Target
            HUD.Damage = 0
            Items["Damage"].Instance.Text = ""
            Items["Avatar"].Instance.Image = ""
            Items["HealthFill"].Instance.Size = UDim2New(0, 0, 1, 0)
            Items["HealthText"].Instance.Text = ""

            if typeof(Target) ~= "Instance" then
                Items["Name"].Instance.Text = "no target"
                Items["KD"].Instance.Text = "--"
                Items["Time"].Instance.Text = "--"
                Items["Tool"].Instance.Text = "--"
                HUD.Weapon = ""
                HUD.Distance = 0
                for _, Status in HUD.Statuses do Status.Since = nil end
                RefreshStatus()
                return
            end

            local Player = GetPlayer(Target)
            Items["Name"].Instance.Text = Player and Player.Name or Target.Name

            local Kd, Time = ReadStats(Player)
            Items["KD"].Instance.Text = Kd
            Items["Time"].Instance.Text = Time

            if not Player then return end

            local UserId = Player.UserId
            Library:Thread(function()
                local Ok, Image = pcall(function()
                    return Players:GetUserThumbnailAsync(UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                end)
                if Ok and Image and HUD.Target == Target then
                    Items["Avatar"].Instance.Image = Image
                end
            end)
        end

        function HUD:SetWeapon(Weapon)
            HUD.Weapon = tostring(Weapon or "")
            local Text = HUD.Weapon
            if Text == "" or Text == "None" then Text = "--" end
            if HUD.Distance > 0 then
                Text = Text .. "  |  " .. MathFloor(HUD.Distance) .. "m"
            end
            Items["Tool"].Instance.Text = Text
        end

        function HUD:SetDistance(Distance)
            HUD.Distance = tonumber(Distance) or 0
            HUD:SetWeapon(HUD.Weapon)
        end

        function HUD:AddDamage(Amount)
            HUD.Damage = HUD.Damage + (tonumber(Amount) or 0)
            Items["Damage"].Instance.Text = MathFloor(HUD.Damage) .. " dmg"

            Items["Damage"]:Tween(TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextSize = 15})
            task.delay(0.08, function()
                Items["Damage"]:Tween(TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextSize = 12})
            end)
        end

        function HUD:SetDamage(Amount)
            HUD.Damage = tonumber(Amount) or 0
            Items["Damage"].Instance.Text = HUD.Damage > 0 and (MathFloor(HUD.Damage) .. " dmg") or ""
        end

        function HUD:ResetDamage()
            HUD.Damage = 0
            Items["Damage"].Instance.Text = ""
        end

        function HUD:SetStatus(Name, Enabled, Color)
            if not Name then return end
            Name = tostring(Name)

            local Status = HUD.Statuses[Name]
            if not Status then
                Status = { }
                HUD.Statuses[Name] = Status
            end

            if Color then Status.Color = Color end

            if Enabled and not Status.Since then
                Status.Since = os.clock()
            elseif not Enabled then
                Status.Since = nil
            end

            RefreshStatus()
        end

        function HUD:HideAllStatuses()
            for _, Status in HUD.Statuses do
                Status.Since = nil
            end
            RefreshStatus()
        end

        function HUD:SetVisibility(Bool)
            HUD.Visible = Bool == true
            Library:FadeWidget(Items["HUD"], HUD.Visible)
        end

        Library:Connect(RunService.Heartbeat, function()
            if not HUD.Visible then return end

            local Now = os.clock()
            if Now - Ticked < 0.1 then return end
            Ticked = Now

            RefreshStatus()

            local Character = GetCharacter(HUD.Target)
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

            if not Humanoid then
                Items["HealthFill"].Instance.Size = UDim2New(0, 0, 1, 0)
                Items["HealthText"].Instance.Text = ""
                return
            end

            local Health = Humanoid.Health
            local MaxHealth = Humanoid.MaxHealth
            local Ratio = MaxHealth > 0 and MathClamp(Health / MaxHealth, 0, 1) or 0

            Items["HealthFill"].Instance.Size = UDim2New(Ratio, 0, 1, 0)
            Items["HealthText"].Instance.Text = StringFormat("%d/%d", MathFloor(Health + 0.5), MathFloor(MaxHealth + 0.5))
        end)

        return HUD
    end

    Library.PlayerList = function(self, Data)
        Data = Data or { }

        local List = {
            Rows = { },
            Selected = nil,
            Statuses = { },
            Visible = false
        }

        local ReplicatedStorage = ReplicatedStorage
        local StatusColors = {
            Friend = FromRGB(120, 220, 160),
            Priority = FromRGB(255, 140, 120),
            Neutral = FromRGB(200, 200, 210)
        }

        local ColumnSpec = {
            { "player", 0.00, 0.34 },
            { "user id", 0.34, 0.21 },
            { "kd", 0.55, 0.16 },
            { "hours", 0.71, 0.13 },
            { "status", 0.84, 0.16 }
        }

        local MinWidth = 320
        local MaxWidth = 520
        local MinHeight = 210
        local MaxHeight = 540
        local RowHeight = 16
        local ChromeHeight = 42 + 76

        local Items = { } do
            Items["List"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, 15, 0, 200),
                Size = UDim2New(0, 340, 0, 300),
                BorderSizePixel = 2,
                Visible = false,
                BackgroundColor3 = FromRGB(13, 13, 16)
            })  Items["List"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["List"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["List"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["List"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(120, 170, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["List"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Players",
                Name = "\0",
                Position = UDim2New(0, 7, 0, 5),
                Size = UDim2New(1, -14, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            for _, Column in ColumnSpec do
                local Header = Instances:Create("TextLabel", {
                    Parent = Items["List"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(222, 222, 228),
                    TextTransparency = 0.3,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Column[1],
                    Name = "\0",
                    Position = UDim2New(Column[2], 7, 0, 22),
                    Size = UDim2New(Column[3], -4, 0, 14),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Header:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = Header.Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})
            end

            Items["Divider"] = Instances:Create("Frame", {
                Parent = Items["List"].Instance,
                Name = "\0",
                Position = UDim2New(0, 1, 0, 38),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -2, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(34, 34, 41)
            })  Items["Divider"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["List"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 5, 0, 42),
                Size = UDim2New(1, -10, 1, -112),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = FromRGB(120, 170, 255),
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Footer"] = Instances:Create("Frame", {
                Parent = Items["List"].Instance,
                Name = "\0",
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 1, 1, -70),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -2, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(34, 34, 41)
            })  Items["Footer"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["FooterHost"] = Instances:Create("Frame", {
                Parent = Items["List"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 7, 1, -6),
                Size = UDim2New(1, -14, 0, 58),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["FooterHost"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        local function ReadStats(Player)
            if not Player then return "--", "--" end

            local Ok, Kd, Hours = pcall(function()
                local Data = ReplicatedStorage:FindFirstChild("Players")
                local Profile = Data and Data:FindFirstChild(Player.Name)
                local Status = Profile and Profile:FindFirstChild("Status")
                local Journey = Status and Status:FindFirstChild("Journey")
                local Stats = Journey and Journey:FindFirstChild("Statistics")
                if not Stats then return "--", "--" end

                local Kills = tonumber(Stats:GetAttribute("Kills"))
                local Deaths = tonumber(Stats:GetAttribute("Deaths"))
                local Played = tonumber(Stats:GetAttribute("TimePlayed"))
                if Kills == nil and Deaths == nil and Played == nil then return "--", "--" end

                Kills = math.max(MathFloor((Kills or 0) + 0.5), 0)
                Deaths = math.max(MathFloor((Deaths or 0) + 0.5), 0)
                Played = math.max(Played or 0, 0)

                local Ratio = Deaths > 0 and Kills / Deaths or Kills
                return StringFormat("%.2f", Ratio), StringFormat("%.1f", Played / 3600)
            end)

            if Ok then return Kd, Hours end
            return "--", "--"
        end

        local Choices = { "Friend", "Priority", "Neutral" }

        local FooterSection = setmetatable({
            Window = Data.Window or { FadeSpeed = Library.Tween.Time },
            Page = nil,
            Elements = { Content = Items["FooterHost"] }
        }, Library.Sections)

        local StatusPick = FooterSection:Dropdown({
            Name = "status",
            Flag = Data.Flag or "playerlist_status",
            Items = Choices,
            Default = "Neutral",
            Callback = function() end
        })

        local function Highlight(Row, On)
            Row.Background.Instance.BackgroundTransparency = On and 0 or 1
        end

        local function Fit()
            local Count = 0
            local Longest = 0

            for _, Row in List.Rows do
                Count = Count + 1
                local Bounds = Row.Name.Instance.TextBounds.X + Row.UserId.Instance.TextBounds.X
                if Bounds > Longest then Longest = Bounds end
            end

            local Width = MathClamp(MathFloor(Longest / 0.55) + 40, MinWidth, MaxWidth)
            local Height = MathClamp(Count * RowHeight + ChromeHeight, MinHeight, MaxHeight)

            Items["List"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2New(0, Width, 0, Height)
            })
        end

        function List:GetStatus(Player)
            if not Player then return "Neutral" end
            local Key = typeof(Player) == "Instance" and Player.Name or tostring(Player)
            return List.Statuses[Key] or "Neutral"
        end

        function List:SetStatus(Player, Status)
            if not Player then return end
            local Key = typeof(Player) == "Instance" and Player.Name or tostring(Player)
            List.Statuses[Key] = Status

            local Row = List.Rows[Key]
            if Row then
                Row.Status.Instance.Text = Status
                Row.Status.Instance.TextColor3 = StatusColors[Status] or StatusColors.Neutral
            end

            if Data.Callback then
                Library:SafeCall(Data.Callback, Key, Status)
            end
        end

        function List:GetSelected()
            return List.Selected
        end

        local function AddRow(Player)
            local Background = Instances:Create("TextButton", {
                Parent = Items["Content"].Instance,
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(38, 38, 46)
            })  Background:AddToTheme({BackgroundColor3 = "Hovered Element"})

            local function Cell(Text, Scale, Width, Color)
                local Label = Instances:Create("TextLabel", {
                    Parent = Background.Instance,
                    FontFace = Library.Font,
                    TextColor3 = Color or FromRGB(222, 222, 228),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = Text,
                    Name = "\0",
                    Position = UDim2New(Scale, 2, 0, 0),
                    Size = UDim2New(Width, -4, 1, 0),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BorderSizePixel = 0,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIStroke", {
                    Parent = Label.Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})

                return Label
            end

            local Kd, Hours = ReadStats(Player)
            local Status = List:GetStatus(Player)

            local Row = {
                Player = Player,
                Background = Background,
                Name = Cell(Player.Name, ColumnSpec[1][2], ColumnSpec[1][3]),
                UserId = Cell(tostring(Player.UserId), ColumnSpec[2][2], ColumnSpec[2][3]),
                KD = Cell(Kd, ColumnSpec[3][2], ColumnSpec[3][3]),
                Hours = Cell(Hours, ColumnSpec[4][2], ColumnSpec[4][3]),
                Status = Cell(Status, ColumnSpec[5][2], ColumnSpec[5][3], StatusColors[Status])
            }

            Row.Name:AddToTheme({TextColor3 = "Text"})
            Row.UserId:AddToTheme({TextColor3 = "Text"})
            Row.KD:AddToTheme({TextColor3 = "Text"})
            Row.Hours:AddToTheme({TextColor3 = "Text"})

            Background:Connect("MouseButton1Down", function()
                for _, Other in List.Rows do
                    Highlight(Other, false)
                end
                Highlight(Row, true)
                List.Selected = Player
                Items["Title"].Instance.Text = "Players - " .. Player.Name
                StatusPick:Set(List:GetStatus(Player))
            end)

            Background:OnHover(function()
                if List.Selected ~= Player then
                    Background.Instance.BackgroundTransparency = 0.6
                end
            end)

            Background:OnHoverLeave(function()
                if List.Selected ~= Player then
                    Background.Instance.BackgroundTransparency = 1
                end
            end)

            List.Rows[Player.Name] = Row
        end

        function List:Refresh()
            for Key, Row in List.Rows do
                Row.Background:Clean()
                List.Rows[Key] = nil
            end

            List.Selected = nil
            Items["Title"].Instance.Text = "Players"

            for _, Player in Players:GetPlayers() do
                if Player ~= LocalPlayer then
                    AddRow(Player)
                end
            end

            Fit()
        end

        function List:Refit()
            Fit()
        end

        function List:SetVisibility(Bool)
            Bool = Bool == true
            if List.Visible == Bool then return end
            List.Visible = Bool
            if Bool then List:Refresh() end
            Library:FadeWidget(Items["List"], Bool)
        end

        FooterSection:Button({
            Name = "Apply Status",
            Callback = function()
                if not List.Selected then return end
                List:SetStatus(List.Selected, StatusPick:Get() or "Neutral")
            end
        })

        Library:Connect(Players.PlayerAdded, function()
            if List.Visible then List:Refresh() end
        end)

        Library:Connect(Players.PlayerRemoving, function()
            if List.Visible then List:Refresh() end
        end)

        return List
    end

    Library.Output = function(self, Data)
        Data = Data or { }

        local Output = {
            Lines = { },
            Commands = { },
            Channels = { },
            History = { },
            HistoryIndex = 0,
            MaxLines = Data.MaxLines or 200,
            Visible = false
        }

        local Levels = {
            INFO = FromRGB(120, 190, 255),
            SUCCESS = FromRGB(120, 230, 150),
            DEBUG = FromRGB(200, 170, 255),
            WARN = FromRGB(255, 200, 100),
            ERROR = FromRGB(255, 110, 120)
        }

        local Items = { } do
            Items["Output"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, 15, 0, 520),
                Size = UDim2New(0, 420, 0, 260),
                BorderSizePixel = 2,
                Visible = false,
                BackgroundColor3 = FromRGB(13, 13, 16)
            })  Items["Output"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["Output"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["Output"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Output"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(120, 170, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Output"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "OUTPUT",
                Name = "\0",
                Position = UDim2New(0, 7, 0, 5),
                Size = UDim2New(1, -14, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Divider"] = Instances:Create("Frame", {
                Parent = Items["Output"].Instance,
                Name = "\0",
                Position = UDim2New(0, 1, 0, 22),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -2, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(34, 34, 41)
            })  Items["Divider"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["Screen"] = Instances:Create("Frame", {
                Parent = Items["Output"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 28),
                Size = UDim2New(1, -14, 1, -80),
                BorderSizePixel = 2,
                BorderColor3 = FromRGB(10, 10, 10),
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Items["Screen"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Screen"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Screen"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 4, 0, 3),
                Size = UDim2New(1, -8, 1, -6),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = FromRGB(120, 170, 255),
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["InputBox"] = Instances:Create("Frame", {
                Parent = Items["Output"].Instance,
                Name = "\0",
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 7, 1, -27),
                Size = UDim2New(1, -14, 0, 18),
                BorderSizePixel = 2,
                BorderColor3 = FromRGB(10, 10, 10),
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Items["InputBox"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["InputBox"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["Prompt"] = Instances:Create("TextLabel", {
                Parent = Items["InputBox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(120, 170, 255),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = ">",
                Name = "\0",
                Position = UDim2New(0, 4, 0, 0),
                Size = UDim2New(0, 10, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Prompt"]:AddToTheme({TextColor3 = "Accent"})

            Items["Input"] = Instances:Create("TextBox", {
                Parent = Items["InputBox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                PlaceholderText = "Enter a command. Print 'help' for list.",
                PlaceholderColor3 = FromRGB(120, 120, 130),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                ClearTextOnFocus = false,
                Name = "\0",
                Position = UDim2New(0, 16, 0, 0),
                Size = UDim2New(1, -20, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Input"]:AddToTheme({TextColor3 = "Text"})

            Items["ClearHost"] = Instances:Create("Frame", {
                Parent = Items["Output"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 7, 1, -5),
                Size = UDim2New(1, -14, 0, 17),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["ClearHost"].Instance,
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        local ClearSection = setmetatable({
            Window = Data.Window or { FadeSpeed = Library.Tween.Time },
            Elements = { Content = Items["ClearHost"] }
        }, Library.Sections)

        local function Stamp()
            return os.date("%H:%M:%S")
        end

        function Output:Write(Level, Text)
            Level = string.upper(tostring(Level or "INFO"))
            local Color = Levels[Level] or Levels.INFO

            local Line = Instances:Create("TextLabel", {
                Parent = Items["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = Color,
                BorderColor3 = FromRGB(0, 0, 0),
                Text = StringFormat("[%s] [%s] %s", Stamp(), Level, tostring(Text)),
                Name = "\0",
                Size = UDim2New(1, 0, 0, 13),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                LayoutOrder = #Output.Lines + 1,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Line.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Line.Instance.TextTransparency = 1
            Tween:Create(Line.Instance, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}, true)

            TableInsert(Output.Lines, Line)

            while #Output.Lines > Output.MaxLines do
                Output.Lines[1]:Clean()
                TableRemove(Output.Lines, 1)
            end

            local Canvas = Items["Content"].Instance
            task.defer(function()
                Canvas.CanvasPosition = Vector2New(0, Canvas.AbsoluteCanvasSize and Canvas.AbsoluteCanvasSize.Y or 9999)
            end)

            return Line
        end

        function Output:Code(Title, Body, Level)
            Level = string.upper(tostring(Level or "DEBUG"))
            local Accent = Levels[Level] or Levels.DEBUG
            Body = tostring(Body or "")

            local Block = Instances:Create("Frame", {
                Parent = Items["Content"].Instance,
                Name = "\0",
                Size = UDim2New(1, -4, 0, 32),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 2,
                BorderColor3 = FromRGB(10, 10, 10),
                LayoutOrder = #Output.Lines + 1,
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Block:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Block.Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Block.Instance,
                PaddingTop = UDimNew(0, 3),
                PaddingBottom = UDimNew(0, 4),
                PaddingLeft = UDimNew(0, 5),
                PaddingRight = UDimNew(0, 5)
            })

            Instances:Create("UIListLayout", {
                Parent = Block.Instance,
                Padding = UDimNew(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            local Header = Instances:Create("Frame", {
                Parent = Block.Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 14),
                BorderSizePixel = 0,
                LayoutOrder = 1,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local Caption = Instances:Create("TextLabel", {
                Parent = Header.Instance,
                FontFace = Library.Font,
                TextColor3 = Accent,
                BorderColor3 = FromRGB(0, 0, 0),
                Text = StringFormat("[%s] %s", Stamp(), tostring(Title or "debug.txt")),
                Name = "\0",
                Size = UDim2New(1, -44, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Caption.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local Copy = Instances:Create("TextButton", {
                Parent = Header.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "copy",
                AutoButtonColor = false,
                Name = "\0",
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, 0, 0, 0),
                Size = UDim2New(0, 40, 1, 0),
                BorderSizePixel = 1,
                TextSize = 12,
                BackgroundColor3 = FromRGB(28, 28, 34)
            })  Copy:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border", TextColor3 = "Text"})

            local Text = Instances:Create("TextLabel", {
                Parent = Block.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Body,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 13),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                BorderSizePixel = 0,
                LayoutOrder = 2,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Text:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Text.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Copy:Connect("MouseButton1Down", function()
                local Ok = Library:SetClipboard(Body)
                Copy.Instance.Text = Ok and "copied" or "no api"
                Copy:Tween(TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Library.Theme.Accent})
                task.delay(0.6, function()
                    Copy.Instance.Text = "copy"
                    Copy:Tween(TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = Library.Theme.Element})
                end)
            end)

            Copy:OnHover(function()
                Copy:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
            end)

            Copy:OnHoverLeave(function()
                Copy:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
            end)

            TableInsert(Output.Lines, Block)

            while #Output.Lines > Output.MaxLines do
                Output.Lines[1]:Clean()
                TableRemove(Output.Lines, 1)
            end

            local Canvas = Items["Content"].Instance
            task.defer(function()
                Canvas.CanvasPosition = Vector2New(0, Canvas.AbsoluteCanvasSize and Canvas.AbsoluteCanvasSize.Y or 9999)
            end)

            return Block
        end

        function Output:Channel(Name, Limit)
            Name = string.lower(tostring(Name))
            local Feed = Output.Channels[Name]
            if not Feed then
                Feed = { Name = Name, Limit = Limit or 25, Entries = { } }
                Output.Channels[Name] = Feed
            elseif Limit then
                Feed.Limit = Limit
            end
            return Feed
        end

        function Output:Push(Name, Text)
            local Feed = Output:Channel(Name)
            TableInsert(Feed.Entries, StringFormat("[%s] %s", Stamp(), tostring(Text)))
            while #Feed.Entries > Feed.Limit do
                TableRemove(Feed.Entries, 1)
            end
            return Feed
        end

        function Output:Dump(Name, Title, Level)
            local Feed = Output.Channels[string.lower(tostring(Name))]
            if not Feed or #Feed.Entries == 0 then
                return Output:Write("WARN", "channel '" .. tostring(Name) .. "' is empty")
            end
            return Output:Code(Title or (Feed.Name .. ".txt"), TableConcat(Feed.Entries, "\n"), Level)
        end

        function Output:Wipe(Name)
            local Feed = Output.Channels[string.lower(tostring(Name))]
            if Feed then Feed.Entries = { } end
        end

        function Output:Info(Text) return Output:Write("INFO", Text) end
        function Output:Success(Text) return Output:Write("SUCCESS", Text) end
        function Output:Debug(Text) return Output:Write("DEBUG", Text) end
        function Output:Warn(Text) return Output:Write("WARN", Text) end

        function Output:Error(Text)
            Output:Write("ERROR", Text)
            return Output:Write("ERROR", "report this to support with the message above")
        end

        function Output:Clear()
            for _, Line in Output.Lines do
                Line:Clean()
            end
            Output.Lines = { }
        end

        function Output:Register(Name, Info)
            Output.Commands[string.lower(Name)] = {
                Name = Name,
                Args = Info.Args or "",
                Help = Info.Help or "",
                Callback = Info.Callback or function() end
            }
        end

        function Output:Run(Line)
            Line = tostring(Line or "")
            if Line:gsub("%s", "") == "" then return end

            Output:Write("INFO", "> " .. Line)
            TableInsert(Output.History, Line)
            Output.HistoryIndex = #Output.History + 1

            local Parts = { }
            for Word in string.gmatch(Line, "%S+") do
                TableInsert(Parts, Word)
            end

            local Name = string.lower(TableRemove(Parts, 1))
            local Command = Output.Commands[Name]

            if not Command then
                Output:Write("ERROR", "unknown command '" .. Name .. "', print 'help' for list")
                return
            end

            local Ok, Result = pcall(Command.Callback, Parts, Output)
            if not Ok then
                Output:Error("command '" .. Name .. "' failed: " .. tostring(Result))
            elseif type(Result) == "string" then
                Output:Write("SUCCESS", Result)
            end
        end

        function Output:SetVisibility(Bool)
            Bool = Bool == true
            if Output.Visible == Bool then return end
            Output.Visible = Bool
            Library:FadeWidget(Items["Output"], Bool)
        end

        Items["Input"]:Connect("FocusLost", function(Enter)
            if not Enter then return end
            local Text = Items["Input"].Instance.Text
            Items["Input"].Instance.Text = ""
            Output:Run(Text)
        end)

        ClearSection:Button({
            Name = "CLEAR OUTPUT",
            Callback = function() Output:Clear() end
        })

        Output:Register("help", {
            Help = "list every command",
            Callback = function(Args, Console)
                local Names = { }
                for Key in Console.Commands do
                    TableInsert(Names, Key)
                end
                table.sort(Names)
                Console:Write("INFO", "commands (" .. #Names .. "):")
                for _, Key in Names do
                    local Command = Console.Commands[Key]
                    local Usage = Command.Args ~= "" and (Key .. " " .. Command.Args) or Key
                    Console:Write("INFO", "  " .. Usage .. "  -  " .. Command.Help)
                end
            end
        })

        Output:Register("clear", {
            Help = "wipe the output",
            Callback = function(Args, Console) Console:Clear() end
        })

        Output:Register("channels", {
            Help = "list debug channels and their size",
            Callback = function(Args, Console)
                local Names = { }
                for Key in Console.Channels do TableInsert(Names, Key) end
                table.sort(Names)
                if #Names == 0 then return Console:Write("WARN", "no channels registered") end
                Console:Write("INFO", "channels (" .. #Names .. "):")
                for _, Key in Names do
                    local Feed = Console.Channels[Key]
                    Console:Write("INFO", StringFormat("  %s  %d/%d", Key, #Feed.Entries, Feed.Limit))
                end
            end
        })

        Output:Register("dump", {
            Args = "<channel>",
            Help = "print a channel as a copyable code block",
            Callback = function(Args, Console)
                local Name = Args[1]
                if not Name then return Console:Write("ERROR", "usage: dump <channel>") end
                Console:Dump(Name)
            end
        })

        Output:Register("wipe", {
            Args = "<channel>",
            Help = "drop everything stored in a channel",
            Callback = function(Args, Console)
                local Name = Args[1]
                if not Name then return Console:Write("ERROR", "usage: wipe <channel>") end
                Console:Wipe(Name)
                Console:Write("SUCCESS", "channel '" .. Name .. "' wiped")
            end
        })

        Output:Register("flags", {
            Args = "[filter]",
            Help = "print flag values",
            Callback = function(Args, Console)
                local Filter = Args[1] and string.lower(Args[1]) or nil
                local Count = 0
                for Key, Value in Library.Flags do
                    if not Filter or StringFind(string.lower(Key), Filter, 1, true) then
                        local Text = type(Value) == "table" and (Value.Key or Value.HexValue or "table") or tostring(Value)
                        Console:Write("DEBUG", Key .. " = " .. Text)
                        Count = Count + 1
                    end
                end
                if Count == 0 then Console:Write("WARN", "no flags matched") end
            end
        })

        Output:Register("get", {
            Args = "<flag>",
            Help = "read one flag",
            Callback = function(Args, Console)
                local Key = Args[1]
                if not Key then return Console:Write("ERROR", "usage: get <flag>") end
                local Value = Library.Flags[Key]
                if Value == nil then return Console:Write("WARN", "flag '" .. Key .. "' not found") end
                Console:Write("DEBUG", Key .. " = " .. tostring(type(Value) == "table" and (Value.Key or Value.HexValue or "table") or Value))
            end
        })

        Output:Register("set", {
            Args = "<flag> <value>",
            Help = "write a flag (true/false/number/text)",
            Callback = function(Args, Console)
                local Key = Args[1]
                local Raw = Args[2]
                if not Key or not Raw then return Console:Write("ERROR", "usage: set <flag> <value>") end

                local Value = Raw
                if Raw == "true" then Value = true
                elseif Raw == "false" then Value = false
                elseif tonumber(Raw) then Value = tonumber(Raw) end

                local Setter = Library.SetFlags[Key]
                if not Setter then return Console:Write("WARN", "flag '" .. Key .. "' has no setter") end

                Setter(Value)
                Console:Write("SUCCESS", Key .. " = " .. tostring(Value))
            end
        })

        Output:Register("toggle", {
            Args = "<flag>",
            Help = "flip a boolean flag",
            Callback = function(Args, Console)
                local Key = Args[1]
                if not Key then return Console:Write("ERROR", "usage: toggle <flag>") end
                local Setter = Library.SetFlags[Key]
                if not Setter then return Console:Write("WARN", "flag '" .. Key .. "' has no setter") end
                local Value = not (Library.Flags[Key] == true)
                Setter(Value)
                Console:Write("DEBUG", Key .. " = " .. tostring(Value))
            end
        })

        Output:Register("binds", {
            Help = "list assigned keybinds",
            Callback = function(Args, Console)
                local Count = 0
                for Key, Value in Library.Flags do
                    if type(Value) == "table" and Value.Mode and Value.Key then
                        Console:Write("DEBUG", StringFormat("%s = %s (%s) active=%s", Key, tostring(Value.Value or Value.Key), Value.Mode, tostring(Library:BindActive(true, Key))))
                        Count = Count + 1
                    end
                end
                if Count == 0 then Console:Write("WARN", "no keybinds assigned") end
            end
        })

        Output:Register("theme", {
            Args = "<key> <r> <g> <b>",
            Help = "change a theme color",
            Callback = function(Args, Console)
                local Key = Args[1]
                local R, G, B = tonumber(Args[2]), tonumber(Args[3]), tonumber(Args[4])
                if not Key or not R or not G or not B then
                    return Console:Write("ERROR", "usage: theme <key> <r> <g> <b>")
                end
                if Library.Theme[Key] == nil then
                    return Console:Write("WARN", "unknown theme key '" .. Key .. "'")
                end
                Library:ChangeTheme(Key, FromRGB(R, G, B))
                Console:Write("SUCCESS", "theme " .. Key .. " updated")
            end
        })

        Output:Register("preset", {
            Args = "<name>",
            Help = "apply an accent preset",
            Callback = function(Args, Console)
                local Name = Args[1]
                if not Name then
                    local Names = Library:GetPresets()
                    return Console:Write("INFO", "presets: " .. TableConcat(Names, ", "))
                end
                if Library:ApplyPreset(Name) then
                    Console:Write("SUCCESS", "preset " .. Name .. " applied")
                else
                    Console:Write("WARN", "unknown preset '" .. Name .. "'")
                end
            end
        })

        Output:Register("config", {
            Args = "<save|load|list> [name]",
            Help = "manage config files",
            Callback = function(Args, Console)
                local Action = Args[1] and string.lower(Args[1]) or ""
                local Name = Args[2]

                if Action == "list" then
                    local Ok, Files = pcall(listfiles, Library.Folders.Configs)
                    if not Ok then return Console:Write("ERROR", "cannot read config folder") end
                    Console:Write("INFO", "configs: " .. #Files)
                    for _, File in Files do Console:Write("INFO", "  " .. tostring(File)) end
                elseif Action == "save" then
                    if not Name then return Console:Write("ERROR", "usage: config save <name>") end
                    Library:SaveConfig(Name)
                    Console:Write("SUCCESS", "saved " .. Name)
                elseif Action == "load" then
                    if not Name then return Console:Write("ERROR", "usage: config load <name>") end
                    local Ok, Body = pcall(readfile, Library.Folders.Configs .. "/" .. Name .. ".json")
                    if not Ok then return Console:Write("ERROR", "config '" .. Name .. "' not found") end
                    Library:LoadConfig(Body)
                    Console:Write("SUCCESS", "loaded " .. Name)
                else
                    Console:Write("ERROR", "usage: config <save|load|list> [name]")
                end
            end
        })

        Output:Register("players", {
            Help = "list players in server",
            Callback = function(Args, Console)
                local All = Players:GetPlayers()
                Console:Write("INFO", "players: " .. #All)
                for _, Player in All do
                    Console:Write("DEBUG", StringFormat("%s  id=%d", Player.Name, Player.UserId))
                end
            end
        })

        Output:Register("fps", {
            Help = "print current framerate",
            Callback = function(Args, Console)
                local Start = os.clock()
                local Frames = 0
                local Connection
                Connection = RunService.Heartbeat:Connect(function()
                    Frames = Frames + 1
                    if os.clock() - Start >= 0.5 then
                        Connection:Disconnect()
                        Console:Write("DEBUG", StringFormat("fps: %.0f", Frames / (os.clock() - Start)))
                    end
                end)
            end
        })

        Output:Register("ping", {
            Help = "print network ping",
            Callback = function(Args, Console)
                local Ok, Value = pcall(function()
                    local Stats = Stats
                    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                if Ok and Value then
                    Console:Write("DEBUG", StringFormat("ping: %.0f ms", Value))
                else
                    Console:Write("WARN", "ping unavailable")
                end
            end
        })

        Output:Register("mem", {
            Help = "print lua memory usage",
            Callback = function(Args, Console)
                Console:Write("DEBUG", StringFormat("memory: %.1f MB", collectgarbage("count") / 1024))
            end
        })

        Output:Register("uptime", {
            Help = "time since the ui loaded",
            Callback = function(Args, Console)
                local Seconds = os.clock() - LoadingTick
                Console:Write("DEBUG", StringFormat("uptime: %.1fs", Seconds))
            end
        })

        Output:Register("echo", {
            Args = "<text>",
            Help = "print text back",
            Callback = function(Args, Console)
                Console:Write("INFO", TableConcat(Args, " "))
            end
        })

        Output:Register("unload", {
            Help = "unload the ui",
            Callback = function(Args, Console)
                Console:Write("WARN", "unloading")
                task.defer(function() Library:Unload() end)
            end
        })

        return Output
    end


    Library.ScriptWindow = function(self, Data)
        Data = Data or { }

        local Panel = {
            Name = Data.Name or "script window",
            Visible = false,
            Sections = { },
            Closed = nil
        }

        local Size = Data.Size or Vector2New(260, 300)
        local Position = Data.Position or Vector2New(700, 260)

        local Items = { } do
            Items["Panel"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, Position.X, 0, Position.Y),
                Size = UDim2New(0, Size.X, 0, Size.Y),
                BorderSizePixel = 2,
                Visible = false,
                BackgroundColor3 = FromRGB(13, 13, 16)
            })  Items["Panel"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["Panel"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["Panel"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(34, 34, 41)
            }):AddToTheme({Color = "Outline"})

            Items["Accent"] = Instances:Create("Frame", {
                Parent = Items["Panel"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(120, 170, 255)
            })  Items["Accent"]:AddToTheme({BackgroundColor3 = "Accent"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Panel"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Panel.Name,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 5),
                Size = UDim2New(1, -30, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["Close"] = Instances:Create("TextButton", {
                Parent = Items["Panel"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(222, 222, 228),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "x",
                AutoButtonColor = false,
                Name = "\0",
                AnchorPoint = Vector2New(1, 0),
                Position = UDim2New(1, -6, 0, 4),
                Size = UDim2New(0, 14, 0, 14),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Close"]:AddToTheme({TextColor3 = "Text"})

            Items["Divider"] = Instances:Create("Frame", {
                Parent = Items["Panel"].Instance,
                Name = "\0",
                Position = UDim2New(0, 1, 0, 22),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -2, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(34, 34, 41)
            })  Items["Divider"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["Body"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Panel"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 28),
                Size = UDim2New(1, -14, 1, -35),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = FromRGB(120, 170, 255),
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Body"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIListLayout", {
                Parent = Items["Body"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        function Panel:SetTitle(Text)
            Panel.Name = tostring(Text)
            Items["Title"].Instance.Text = Panel.Name
        end

        function Panel:SetVisibility(Bool)
            Bool = Bool == true
            if Panel.Visible == Bool then return end
            Panel.Visible = Bool
            Library:FadeWidget(Items["Panel"], Bool)
        end

        function Panel:OnClose(Callback)
            Panel.Closed = Callback
        end

        function Panel:Section(Name)
            local Host = Instances:Create("Frame", {
                Parent = Items["Body"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Host.Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            if Name and Name ~= "" then
                local Header = Instances:Create("TextLabel", {
                    Parent = Host.Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(222, 222, 228),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = tostring(Name),
                    Name = "\0",
                    Size = UDim2New(1, 0, 0, 13),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Header:AddToTheme({TextColor3 = "Text"})
            end

            local Section = setmetatable({
                Window = Data.Window or { FadeSpeed = Library.Tween.Time },
                Elements = { Content = Host }
            }, Library.Sections)

            Panel.Sections[#Panel.Sections + 1] = Section
            return Section
        end

        function Panel:Canvas(Options)
            Options = Options or { }

            local Height = Options.Height or 160

            local Frame = Instances:Create("Frame", {
                Parent = Items["Body"].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, Height),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                ClipsDescendants = true,
                BackgroundColor3 = FromRGB(18, 18, 22)
            })  Frame:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            local Canvas = { Shapes = { }, Render = nil }

            local function Spawn(Class, Props)
                local Item = Instances:Create(Class, Props)
                Canvas.Shapes[#Canvas.Shapes + 1] = Item
                return Item
            end

            local Draw = { }

            function Draw.box(Info)
                Info = Info or { }
                local Point = Info.position or Vector2New()
                local Extent = Info.size or Vector2New(10, 10)

                return Spawn("Frame", {
                    Parent = Frame.Instance,
                    Name = "\0",
                    Position = UDim2New(0, Point.X, 0, Point.Y),
                    Size = UDim2New(0, Extent.X, 0, Extent.Y),
                    BackgroundTransparency = Info.filled == false and 1 or 0,
                    BorderSizePixel = Info.filled == false and 1 or 0,
                    BorderColor3 = Info.color or FromRGB(120, 170, 255),
                    BackgroundColor3 = Info.color or FromRGB(120, 170, 255)
                })
            end

            function Draw.dot(Info)
                Info = Info or { }
                local Point = Info.position or Vector2New()
                local Radius = Info.radius or 3

                local Item = Spawn("Frame", {
                    Parent = Frame.Instance,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Position = UDim2New(0, Point.X, 0, Point.Y),
                    Size = UDim2New(0, Radius * 2, 0, Radius * 2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Info.color or FromRGB(120, 170, 255)
                })

                Instances:Create("UICorner", {
                    Parent = Item.Instance,
                    CornerRadius = UDimNew(1, 0)
                })

                return Item
            end

            function Draw.text(Info)
                Info = Info or { }
                local Point = Info.position or Vector2New()

                return Spawn("TextLabel", {
                    Parent = Frame.Instance,
                    FontFace = Library.Font,
                    Text = tostring(Info.text or ""),
                    Name = "\0",
                    Position = UDim2New(0, Point.X, 0, Point.Y),
                    Size = UDim2New(0, 100, 0, 13),
                    BackgroundTransparency = 1,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    BorderSizePixel = 0,
                    TextSize = Info.size or 12,
                    TextColor3 = Info.color or FromRGB(222, 222, 228),
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })
            end

            function Canvas:Clear()
                for Index = #Canvas.Shapes, 1, -1 do
                    Canvas.Shapes[Index]:Clean()
                    Canvas.Shapes[Index] = nil
                end
            end

            function Canvas:Size()
                return Frame.Instance.AbsoluteSize
            end

            function Canvas:OnRender(Callback)
                Canvas.Render = Callback

                if Canvas.Connection then return end

                Canvas.Connection = Library:Connect(RunService.RenderStepped, function()
                    if not Canvas.Render then return end
                    if not Panel.Visible then return end

                    Canvas:Clear()
                    Canvas.Render(Draw, Frame.Instance.AbsoluteSize)
                end)
            end

            function Canvas:Destroy()
                Canvas:Clear()
                Canvas.Render = nil
                Frame:Clean()
            end

            Panel.Canvases = Panel.Canvases or { }
            Panel.Canvases[#Panel.Canvases + 1] = Canvas

            return Canvas
        end

        function Panel:Destroy()
            for _, Canvas in Panel.Canvases or { } do
                pcall(function() Canvas:Destroy() end)
            end

            Library:DropFadeCache(Items["Panel"].Instance)
            Items["Panel"]:Clean()
        end

        Items["Close"]:Connect("MouseButton1Down", function()
            Panel:SetVisibility(false)
            if Panel.Closed then Library:SafeCall(Panel.Closed) end
        end)

        Items["Close"]:OnHover(function()
            Items["Close"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
        end)

        Items["Close"]:OnHoverLeave(function()
            Items["Close"]:Tween(nil, {TextColor3 = Library.Theme.Text})
        end)

        Panel:SetVisibility(true)

        return Panel
    end

    Library.InventoryViewer = function(self, Data)
        Data = Data or { }

        local Viewer = {
            Target = "",
            Summary = "",
            Visible = false,
            Rows = { }
        }

        local Items = { } do
            Items["Viewer"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, 15, 0, 120),
                Size = UDim2New(0, 210, 0, 58),
                BorderSizePixel = 2,
                Visible = false,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Viewer"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["Viewer"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["Viewer"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Viewer"].Instance,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Viewer"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Inventory",
                Name = "\0",
                Position = UDim2New(0, 5, 0, 4),
                Size = UDim2New(1, -10, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Summary"] = Instances:Create("TextLabel", {
                Parent = Items["Viewer"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 157, 255),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                Position = UDim2New(0, 5, 0, 19),
                Size = UDim2New(1, -10, 0, 14),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                Visible = false,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Summary"]:AddToTheme({TextColor3 = "Accent"})

            Instances:Create("UIStroke", {
                Parent = Items["Summary"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Divider"] = Instances:Create("Frame", {
                Parent = Items["Viewer"].Instance,
                Name = "\0",
                Position = UDim2New(0, 1, 0, 21),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -2, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["Divider"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Viewer"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 5, 0, 25),
                Size = UDim2New(1, -10, 1, -30),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = FromRGB(235, 157, 255),
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        local HeaderHeight = 25

        local function Layout()
            local HasSummary = Viewer.Summary ~= ""
            Items["Summary"].Instance.Visible = HasSummary
            Items["Summary"].Instance.Text = Viewer.Summary
            HeaderHeight = HasSummary and 39 or 25
            Items["Divider"].Instance.Position = UDim2New(0, 1, 0, HasSummary and 35 or 21)
            Items["Content"].Instance.Position = UDim2New(0, 5, 0, HeaderHeight)
            Items["Content"].Instance.Size = UDim2New(1, -10, 1, -(HeaderHeight + 5))
        end

        local function Resize()
            local Longest = Items["Title"].Instance.TextBounds.X
            if Viewer.Summary ~= "" then
                local SummaryWidth = Items["Summary"].Instance.TextBounds.X
                if SummaryWidth > Longest then Longest = SummaryWidth end
            end
            for _, Row in Viewer.Rows do
                local RowWidth = Row.Instance.TextBounds.X
                if RowWidth > Longest then Longest = RowWidth end
            end

            local Width = MathClamp(MathFloor(Longest) + 24, 210, 340)
            local ContentHeight = #Viewer.Rows * 15
            local Height = MathClamp(ContentHeight + HeaderHeight + 6, HeaderHeight + 20, 520)

            Items["Content"].Instance.CanvasSize = UDim2New(0, 0, 0, ContentHeight)
            Items["Viewer"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Size = UDim2New(0, Width, 0, Height)
            })
        end

        local function AddRow(Text, Child, Header)
            local Row = Instances:Create("TextLabel", {
                Parent = Items["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = Header and FromRGB(235, 157, 255) or FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = (Child and "   - " or "") .. Text,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 14),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                LayoutOrder = #Viewer.Rows + 1,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Row:AddToTheme({TextColor3 = Header and "Accent" or "Text"})

            Instances:Create("UIStroke", {
                Parent = Row.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Row.Instance.TextTransparency = 1
            Tween:Create(Row.Instance, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}, true)

            TableInsert(Viewer.Rows, Row)
        end

        function Viewer:Clear()
            for _, Row in Viewer.Rows do
                Row:Clean()
            end
            Viewer.Rows = { }
            Resize()
        end

        function Viewer:SetTarget(Name)
            Viewer.Target = tostring(Name or "")
            Items["Title"].Instance.Text = Viewer.Target == "" and "Inventory" or (Viewer.Target .. "'s Inventory")
            Resize()
        end

        function Viewer:SetSummary(Text)
            Viewer.Summary = tostring(Text or "")
            Layout()
            Resize()
        end

        function Viewer:SetSections(Sections)
            Viewer:Clear()
            if type(Sections) ~= "table" then return end
            for _, Section in Sections do
                local Entries = Section.Entries
                if type(Entries) == "table" and #Entries > 0 then
                    AddRow(tostring(Section.Name or "Inventory"), false, true)
                    for _, Entry in Entries do
                        local Name = tostring(Entry.Name or "")
                        local Count = math.max(MathFloor(tonumber(Entry.Count) or 1), 1)
                        local Amount = math.max(MathFloor(tonumber(Entry.Amount) or 0), 0)
                        if string.lower(Name) == "rubles" and Amount > 1 then
                            Count = Amount
                            Amount = 0
                        end
                        local Prefix = Count > 1 and ("[" .. Count .. "x] ") or ""
                        local Suffix = Amount > 1 and (" (" .. Amount .. "x)") or ""
                        AddRow(Prefix .. Name .. Suffix, true, false)
                    end
                end
            end
            Resize()
        end

        function Viewer:SetItems(Entries)
            Viewer:Clear()
            if type(Entries) ~= "table" then return end
            for _, Entry in Entries do
                local Name = tostring(Entry.Name or "")
                local Count = math.max(MathFloor(tonumber(Entry.Count) or 1), 1)
                local Amount = math.max(MathFloor(tonumber(Entry.Amount) or 0), 0)
                local Prefix = Count > 1 and ("[" .. Count .. "x] ") or ""
                local Suffix = Amount > 1 and (" (" .. Amount .. "x)") or ""
                AddRow(Prefix .. Name .. Suffix, false, false)
            end
            Resize()
        end

        function Viewer:SetVisibility(Bool)
            Bool = Bool == true
            if Viewer.Visible == Bool then return end
            Viewer.Visible = Bool
            Library:FadeWidget(Items["Viewer"], Bool)
        end

        Layout()
        Resize()

        return Viewer
    end

    Library.CreateColorpicker = function(self, Data)
        local Colorpicker = {
            Hue = 0,
            Saturation = 0,
            Value = 0,

            Alpha = 0,

            HexValue = "",

            IsOpen = false,

            Color = FromRGB(0, 0, 0),

            Class = "Colorpicker"
        }

        Library.Flags[Data.Flag] = { }

        local Items = { } do
            Items["ColorpickerButton"] = Instances:Create("TextButton", {
                Parent = Data.Parent.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0.5),
                Name = "\0",
                Position = UDim2New(1, 0, 0.5, 0),
                Size = UDim2New(0, 20, 0, 10),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Colorpicker.CalculateCount = function(self, Index, YScale, YOffset)
                local MaxButtonsAdded = 5

                local Column = Index % MaxButtonsAdded

                local ButtonSize = Items["ColorpickerButton"].Instance.AbsoluteSize
                local Spacing = 4

                local XPosition = (ButtonSize.X + Spacing) * Column - Spacing - 21

                Items["ColorpickerButton"].Instance.Position = UDim2New(1, -XPosition, YScale or 0.5, YOffset or 0)
            end

            Colorpicker:CalculateCount(Data.Count)

            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerButton"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["ColorpickerButton"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                AutoButtonColor = false,
                Text = "",
                Name = "\0",
                Position = UDim2New(0, Data.Parent.Instance.AbsolutePosition.X, 0, Data.Parent.Instance.AbsolutePosition.Y + 15),
                BorderColor3 = FromRGB(10, 10, 10),
                Visible = false,
                Size = UDim2New(0, 238, 0, 224),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["ColorpickerWindow"]:MakeDraggable()
            Items["ColorpickerWindow"]:MakeResizeable(Vector2New(200, 180), Vector2New(9999, 9999))

            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerWindow"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Data.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, -2, 0, -3),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["ColorpickerWindow"].Instance,
                Name = "\0",
                Position = UDim2New(0, -6, 0, -6),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 12, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Instances:Create("UIPadding", {
                Parent = Items["ColorpickerWindow"].Instance,
                PaddingTop = UDimNew(0, 6),
                PaddingBottom = UDimNew(0, 6),
                PaddingRight = UDimNew(0, 6),
                PaddingLeft = UDimNew(0, 6)
            })

            Items["Palette"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 15),
                Size = UDim2New(1, -26, 1, -40),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Items["Saturation"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Saturation"),
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Value"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Value"),
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Palette"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["PaletteDragger"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 2, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["PaletteDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Hue"] = Instances:Create("ImageButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                Image = Library:GetImage("Hue"),
                Name = "\0",
                Position = UDim2New(1, 0, 0, 15),
                Size = UDim2New(0, 18, 1, -15),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["HueDragger"] = Instances:Create("Frame", {
                Parent = Items["Hue"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["HueDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Hue"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Alpha"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, -26, 0, 18),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Alpha"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Checkers"] = Instances:Create("ImageLabel", {
                Parent = Items["Alpha"].Instance,
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Checkers"),
                TileSize = UDim2New(0, 6, 0, 6),
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIGradient", {
                Parent = Items["Checkers"].Instance,
                Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
            })

            Instances:Create("UIGradient", {
                Parent = Items["Alpha"].Instance,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(0, 0, 0))}
            })

            Items["AlphaDragger"] = Instances:Create("Frame", {
                Parent = Items["Alpha"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 1, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["AlphaDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})
        end

        local SlidingPalette = false
        local SlidingHue = false
        local SlidingAlpha = false

        local Debounce = false

        function Colorpicker:SetOpen(Bool, Instant)
            Bool = Bool == true

            if Colorpicker.IsOpen == Bool then return end

            local FadeTime = Instant and 0 or (Data.FadeSpeed or Library.Tween.Time)
            local TurnToken = Library:NextTurn(Colorpicker)

            Colorpicker.IsOpen = Bool

            if Bool then
                local Open = Library.CurrentColorpicker
                if Open and Open ~= Colorpicker then
                    Open:SetOpen(false)
                end
                Library.CurrentColorpicker = Colorpicker
            elseif Library.CurrentColorpicker == Colorpicker then
                Library.CurrentColorpicker = nil
            end

            local Window = Items["ColorpickerWindow"]
            local Anchor = Data.Parent.Instance.AbsolutePosition

            if Bool then
                Window.Instance.Visible = true
                Window.Instance.Position = UDim2New(0, Anchor.X, 0, Anchor.Y + 15)
                Window.Instance.Size = UDim2New(0, 238, 0, 0)
                Window:Tween(TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2New(0, 238, 0, 224)
                })
            else
                Window:Tween(TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2New(0, 238, 0, 0)
                })
            end

            local Descendants = Window.Instance:GetDescendants()
            TableInsert(Descendants, Window.Instance)

            for Index, Value in Descendants do
                local ValueIndex = Library:GetTransparencyPropertyFromItem(Value)

                if not ValueIndex then
                    continue
                end

                if not StringFind(Value.ClassName, "UI") then
                    Value.ZIndex = Bool and 10001 or 1
                end

                if type(ValueIndex) == "table" then
                    for _, Property in ValueIndex do
                        Library:FadeItem(Value, Property, Bool, FadeTime)
                    end
                else
                    Library:FadeItem(Value, ValueIndex, Bool, FadeTime)
                end
            end

            task.delay(FadeTime, function()
                if not Library:IsTurn(Colorpicker, TurnToken) then return end
                Window.Instance.Visible = Bool
            end)
        end

        function Colorpicker:Get()
            return Colorpicker.Value
        end

        function Colorpicker:SetVisibility(Bool)
           Data.Parent.Instance.Visible = Bool
        end

        function Colorpicker:Set(Color, Alpha)
            if type(Color) == "table" then
                local Raw = Color
                Color = FromRGB(Raw[1], Raw[2], Raw[3])
                Alpha = Raw[4]
            elseif type(Color) == "string" then
                Color = FromHex(Color)
            end

            if typeof(Color) ~= "Color3" then
                Color = FromRGB(255, 255, 255)
            end

            self.Hue, self.Saturation, self.Value = Color:ToHSV()
            self.Alpha = tonumber(Alpha) or self.Alpha or 0

            self.Color = FromHSV(self.Hue, self.Saturation, self.Value)
            self.HexValue = self.Color:ToHex()

            Library.Flags[Data.Flag] = {
                Color = self.Color,
                HexValue =  self.HexValue,
                Alpha = self.Alpha
            }

            local ColorPositionX = MathClamp(1 - self.Saturation, 0, 0.989)
            local ColorPositionY = MathClamp(1 - self.Value, 0, 0.989)

            Items["PaletteDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(ColorPositionX, 0, ColorPositionY, 0)})

            local HuePositionY = MathClamp(self.Hue, 0, 0.994)

            Items["HueDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, HuePositionY, 0)})

            local AlphaPositionX = MathClamp(self.Alpha, 0, 0.994)

            Items["AlphaDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(AlphaPositionX, 0, 0, 0)})

            self:Update()
        end

        function Colorpicker:Update(IsFromAlpha)
            self.Color = FromHSV(self.Hue, self.Saturation, self.Value)
            self.HexValue = self.Color:ToHex()

            Library.Flags[Data.Flag] = {
                Color = self.Color,
                HexValue =  self.HexValue,
                Alpha = self.Alpha
            }

            Items["ColorpickerButton"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = self.Color})
            Items["Palette"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = FromHSV(self.Hue, 1, 1)})

            if not IsFromAlpha then
                Items["Alpha"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = self.Color})
            end

            if Data.Callback then
                Library:SafeCall(Data.Callback, self.Color, self.Alpha)
            end
        end

        function Colorpicker:SlidePalette(Input)
            if not Input or not SlidingPalette then
                return
            end

            local ValueX = MathClamp(1 - (Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 1)
            local ValueY = MathClamp(1 - (Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 1)

            self.Saturation = ValueX
            self.Value = ValueY

            local SlideX = MathClamp((Input.Position.X - Items["Palette"].Instance.AbsolutePosition.X) / Items["Palette"].Instance.AbsoluteSize.X, 0, 0.989)
            local SlideY = MathClamp((Input.Position.Y - Items["Palette"].Instance.AbsolutePosition.Y) / Items["Palette"].Instance.AbsoluteSize.Y, 0, 0.989)

            Items["PaletteDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(SlideX, 0, SlideY, 0)})
            self:Update()
        end

        function Colorpicker:SlideHue(Input)
            if not Input or not SlidingHue then
                return
            end

            local ValueY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 1)

            self.Hue = ValueY

            local PositionY = MathClamp((Input.Position.Y - Items["Hue"].Instance.AbsolutePosition.Y) / Items["Hue"].Instance.AbsoluteSize.Y, 0, 0.994)

            Items["HueDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(0, 0, PositionY, 0)})
            self:Update()
        end

        function Colorpicker:SlideAlpha(Input)
            if not Input or not SlidingAlpha then
                return
            end

            local ValueX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 1)

            self.Alpha = ValueX

            local PositionX = MathClamp((Input.Position.X - Items["Alpha"].Instance.AbsolutePosition.X) / Items["Alpha"].Instance.AbsoluteSize.X, 0, 0.994)

            Items["AlphaDragger"]:Tween(TweenInfo.new(0.17, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2New(PositionX, 0, 0, 0)})
            self:Update(true)
        end

        Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
            Colorpicker:SetOpen(not Colorpicker.IsOpen)
        end)

        Items["Palette"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingPalette = true
                Colorpicker:SlidePalette(Input)
            end
        end)

        Items["Palette"]:Connect("InputEnded", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingPalette = false
            end
        end)

        Items["Hue"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingHue = true
                Colorpicker:SlideHue(Input)
            end
        end)

        Items["Hue"]:Connect("InputEnded", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingHue = false
            end
        end)

        Items["Alpha"]:Connect("InputBegan", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingAlpha = true
                Colorpicker:SlideAlpha(Input)
            end
        end)

        Items["Alpha"]:Connect("InputEnded", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                SlidingAlpha = false
            end
        end)

        Library:Connect(UserInputService.InputChanged, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                if SlidingPalette then
                    Colorpicker:SlidePalette(Input)
                end

                if SlidingHue then
                    Colorpicker:SlideHue(Input)
                end

                if SlidingAlpha then
                    Colorpicker:SlideAlpha(Input)
                end
            end
        end)

        Colorpicker.Window = Items["ColorpickerWindow"]
        Colorpicker.Button = Items["ColorpickerButton"]

        if Data.Default then
            local Start = tonumber(Data.DefaultAlpha)
            if Start == nil then Start = tonumber(Data.Alpha) end
            Colorpicker:Set(Data.Default, Start)
        end

        Library.SetFlags[Data.Flag] = function(Color, Alpha)
            Colorpicker:Set(Color, Alpha)
        end

        return Colorpicker
    end

    Library.CreateKeybind = function(self, Data)
        local Keybind = {
            Key = nil,
            Value = "",
            Mode = "",

            Toggled = false,
            IsOpen = false,

            Picking = false,

            Class = "Keybind"
        }

        Library.Flags[Data.Flag] = Keybind

        local KeyListItem

        local Items = { } do
            Items["KeyButton"] = Instances:Create("TextButton", {
                Parent = Data.Parent.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(27, 27, 32),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                Size = UDim2New(0, 0, 1, 1),
                Name = "\0",
                Position = UDim2New(1, 0, 0, 0),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 14,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["KeyButton"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

            if Library.KeyList then
                KeyListItem = Library.KeyList:Add(Keybind.Mode, Data.Name, Keybind.Value)
            end

            Instances:Create("UIStroke", {
                Parent = Items["KeyButton"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(10, 10, 10)
            }):AddToTheme({Color = "Border"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["KeyButton"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "MB2",
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 1, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Instances:Create("UIPadding", {
                Parent = Items["KeyButton"].Instance,
                PaddingRight = UDimNew(0, 3),
                PaddingLeft = UDimNew(0, 3),
                PaddingBottom = UDimNew(0, 2)
            })

            Items["Window"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AnchorPoint = Vector2New(0, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(0, 50, 0, 48),
                BorderSizePixel = 2,
                ZIndex = 520,
                Visible = false,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Window"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Window"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Toggle"] = Instances:Create("TextButton", {
                Parent = Items["Window"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(235, 157, 255),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Toggle",
                AutoButtonColor = false,
                Name = "\0",
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 1, 0, 0),
                Size = UDim2New(1, 0, 0, 15),
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Toggle"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Toggle"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Hold"] = Instances:Create("TextButton", {
                Parent = Items["Window"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Hold",
                AutoButtonColor = false,
                Name = "\0",
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 1, 0, 15),
                Size = UDim2New(1, 0, 0, 15),
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Hold"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Hold"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Always"] = Instances:Create("TextButton", {
                Parent = Items["Window"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Always",
                AutoButtonColor = false,
                Name = "\0",
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 1, 0, 30),
                Size = UDim2New(1, 0, 0, 15),
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Always"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Always"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})
        end

        local Modes = {
            ["Toggle"] = Items["Toggle"],
            ["Hold"] = Items["Hold"],
            ["Always"] = Items["Always"]
        }

        local Update = function()
            if not KeyListItem then return end
            local shown = Keybind:IsEnabled()
                and Keybind.Value ~= nil and Keybind.Value ~= "" and Keybind.Value ~= "None"
            KeyListItem:Set(Keybind.Mode, Data.Name, Keybind.Value)
            KeyListItem:SetStatus(Keybind:GetState() and "Active" or "Inactive")
            KeyListItem:SetVisible(shown)
        end

        function Keybind:OnOwnerChanged()
            if Data.Sync then
                local owner = Data.Owner
                Keybind.Toggled = owner ~= nil and owner.Value == true
                Library.Flags[Data.Flag] = Keybind
            end
            Update()
        end

        function Keybind:Get()
           return Keybind.Toggled, Keybind.Key, Keybind.Mode
        end

        function Keybind:IsEnabled()
            local owner = Data.Owner
            if owner and owner.Class == "Toggle" then
                return owner.Value == true
            end
            return true
        end

        function Keybind:MatchesInput(Input)
            local Key = Keybind.Key
            if not Key or Key == "" or Key == "None" then return false end

            local Bare = StringGSub(StringGSub(Key, "Enum.KeyCode.", ""), "Enum.UserInputType.", "")

            if Input.UserInputType == Enum.UserInputType.Keyboard then
                return Bare == Input.KeyCode.Name
            end

            return Bare == Input.UserInputType.Name
        end

        function Keybind:GetState()
            if not Keybind:IsEnabled() then return false end
            if Keybind.Mode == "Always" then return true end
            if Keybind.Key == nil or Keybind.Key == "" or Keybind.Key == "None" then return false end
            if Keybind.Mode == "Hold" then
                local Bare = StringGSub(StringGSub(Keybind.Key, "Enum.KeyCode.", ""), "Enum.UserInputType.", "")

                if Bare == "MouseButton1" or Bare == "MouseButton2" or Bare == "MouseButton3" then
                    local Button = Enum.UserInputType[Bare]
                    return Button ~= nil and UserInputService:IsMouseButtonPressed(Button)
                end

                local Ok, Code = pcall(function() return Enum.KeyCode[Bare] end)
                if not Ok or not Code then return false end

                return UserInputService:IsKeyDown(Code)
            end
            return Keybind.Toggled == true
        end

        function Keybind:SetVisibility(Bool)
            Data.Parent.Instance.Visible = Bool
        end

        function Keybind:Reposition()
            local Anchor = Items["KeyButton"].Instance
            local Panel = Items["Window"].Instance

            local Spot = Anchor.AbsolutePosition
            local Size = Anchor.AbsoluteSize
            local Root = Library.Holder.Instance.AbsolutePosition
            local Screen = Library.Holder.Instance.AbsoluteSize

            local Left = Spot.X - Root.X + Size.X - 50
            local Below = Spot.Y - Root.Y + Size.Y + 4

            if Below + 48 > Screen.Y - 8 then
                local Above = Spot.Y - Root.Y - 48 - 4
                if Above >= 8 then Below = Above end
            end

            if Left < 4 then Left = 4 end

            Panel.Position = UDim2New(0, Left, 0, Below)
        end

        function Keybind:SetOpen(Bool)
            Bool = Bool == true
            if Keybind.IsOpen == Bool then return end
            Keybind.IsOpen = Bool

            local Info = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            if Bool then
                Library.OpenKeybinds[Keybind] = true

                Keybind:Reposition()

                Items["Window"].Instance.Visible = true
                Items["Window"].Instance.ZIndex = 520
                Items["Window"].Instance.Size = UDim2New(0, 50, 0, 0)
                Items["Window"]:Tween(Info, {BackgroundTransparency = 0, Size = UDim2New(0, 50, 0, 48)})

                for Index, Value in Items["Window"].Instance:GetDescendants() do
                    if Value:IsA("UIStroke") then
                        Tween:Create(Value, Info, {Transparency = 0}, true)
                    elseif Value:IsA("TextButton") then
                        Tween:Create(Value, Info, {TextTransparency = 0}, true)
                        Value.ZIndex = 521
                    end
                end

                if not Keybind.Follow then
                    local WasX, WasY = -1, -1

                    Keybind.Follow = Library:Connect(RunService.Heartbeat, function()
                        if not Keybind.IsOpen then return end

                        local Spot = Items["KeyButton"].Instance.AbsolutePosition
                        if Spot.X == WasX and Spot.Y == WasY then return end

                        WasX, WasY = Spot.X, Spot.Y
                        Keybind:Reposition()
                    end)
                end
            else
                Library.OpenKeybinds[Keybind] = nil

                if Keybind.Follow then
                    pcall(function() Keybind.Follow:Disconnect() end)
                    Keybind.Follow = nil
                end

                for Index, Value in Items["Window"].Instance:GetDescendants() do
                    if Value:IsA("UIStroke") then
                        Tween:Create(Value, Info, {Transparency = 1}, true)
                    elseif Value:IsA("TextButton") then
                        Tween:Create(Value, Info, {TextTransparency = 1}, true)
                        Value.ZIndex = 1
                    end
                end

                Items["Window"]:Tween(Info, {BackgroundTransparency = 1, Size = UDim2New(0, 50, 0, 0)})

                task.delay(0.18, function()
                    if Keybind.IsOpen then return end
                    Items["Window"].Instance.Visible = false
                end)
            end
        end

        function Keybind:Set(Key)
            if StringFind(tostring(Key), "Enum") then
                Keybind.Key = tostring(Key)

                Key = Key.Name == "Backspace" and "None" or Key.Name

                local KeyString = Keys[Keybind.Key] or StringGSub(Key, "Enum.", "") or "None"
                local TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                Keybind.Value = TextToDisplay
                Items["Text"].Instance.Text = TextToDisplay

                if Data.Callback then
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
           elseif TableFind({"Toggle", "Hold", "Always"}, Key) then
                Keybind.Mode = Key

                Keybind:SetMode(Key)

                if Data.Callback then
                    Library:SafeCall(Data.Callback, Keybind.Toggled)
                end
            elseif type(Key) == "table" then
                local RealKey = Key.Key == "Backspace" and "None" or Key.Key
                Keybind.Key = tostring(Key.Key)

                if Key.Mode then
                    Keybind.Mode = Key.Mode
                    Keybind:SetMode(Key.Mode)
                else
                    Keybind.Mode = "Toggle"
                    Keybind:SetMode("Toggle")
                end

                local KeyString = Keys[Keybind.Key] or StringGSub(tostring(RealKey), "Enum.", "") or RealKey
                local TextToDisplay = KeyString and StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "") or "None"

                TextToDisplay = StringGSub(StringGSub(KeyString, "KeyCode.", ""), "UserInputType.", "")

                Keybind.Value = TextToDisplay
                Items["Text"].Instance.Text = TextToDisplay

                if Keybind.Callback and not Keybind.Building then
                    Library:SafeCall(Keybind.Callback, Keybind.Toggled)
                end
            end

            Keybind.Picking = false
            Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
            Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
            Items["Text"].Instance.Size = UDim2New(0, Items["Text"].Instance.TextBounds.X, 1, 1)
            Update()
        end

        function Keybind:SetMode(Mode)
            for Index, Value in Modes do
                if Index == Mode then
                    Value:Tween(nil, {TextColor3 = Library.Theme.Accent})
                    Value:ChangeItemTheme({TextColor3 = "Accent"})
                else
                    Value:Tween(nil, {TextColor3 = Library.Theme.Text})
                    Value:ChangeItemTheme({TextColor3 = "Text"})
                end
            end

            if Keybind.Mode == "Always" then
                Keybind.Toggled = true
            else
                Keybind.Toggled = false
            end

            Library.Flags[Data.Flag] = Keybind

            if Data.Callback and not Keybind.Building then
                Library:SafeCall(Data.Callback, Keybind.Toggled)
            end

            Update()
        end

        function Keybind:Press(Bool)
            if Keybind.Mode == "Toggle" then
                Keybind.Toggled = not Keybind.Toggled
            elseif Keybind.Mode == "Hold" then
                Keybind.Toggled = Bool
            elseif Keybind.Mode == "Always" then
                Keybind.Toggled = true
            end

            Library.Flags[Data.Flag] = Keybind

            if Data.Callback then
                Library:SafeCall(Data.Callback, Keybind.Toggled)
            end

            Update()
        end

        Keybind.Building = true

        Items["KeyButton"]:Connect("MouseButton1Click", function()
            if Keybind.Picking then
                return
            end

            Keybind.Picking = true

            Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
            Items["Text"]:ChangeItemTheme({TextColor3 = "Accent"})

            local InputBegan
            InputBegan = UserInputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind:Set(Input.KeyCode)
                else
                    Keybind:Set(Input.UserInputType)
                end

                InputBegan:Disconnect()
                InputBegan = nil
            end)
        end)

        Items["KeyButton"]:Connect("MouseButton2Down", function()
            Keybind:SetOpen(not Keybind.IsOpen)
        end)

        Library:Connect(UserInputService.InputBegan, function(Input, Busy)
            if not Busy and Keybind:MatchesInput(Input) then
                if Keybind.Mode == "Toggle" then
                    Keybind:Press()
                elseif Keybind.Mode == "Hold" then
                    Keybind:Press(true)
                end
            end

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if not Keybind.IsOpen then return end
                if Library:IsMouseOverFrame(Items["Window"]) then return end
                if Library:IsMouseOverFrame(Items["KeyButton"]) then return end

                task.defer(function()
                    if Keybind.IsOpen then Keybind:SetOpen(false) end
                end)
            end
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if Keybind:MatchesInput(Input) then
                if Keybind.Mode == "Hold" then
                    Keybind:Press(false)
                end
            end
        end)

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Toggle"
            Keybind:SetMode("Toggle")
        end)

        Items["Always"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Always"
            Keybind:SetMode("Always")
        end)

        Items["Hold"]:Connect("MouseButton1Down", function()
            Keybind.Mode = "Hold"
            Keybind:SetMode("Hold")
        end)

        if Data.Default then
            Keybind:Set({
                Key = Data.Default,
                Mode = Data.Mode or "Toggle"
            })
        end

        Keybind.Building = false

        Library.SetFlags[Data.Flag] = function(Value)
            Keybind:Set(Value)
        end

        return Keybind
    end

    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or Data.name or "Window",
            Size = Data.Size or Data.size or UDim2New(0, 500, 0, 600),

            FadeSpeed = Data.FadeSpeed or Data.fadespeed or 0.22,

            OpenListeners = { },

            Pages = { },
            SubPages = { },
            Elements = { },

            IsOpen = true
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                AnchorPoint = Vector2New(0, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = Window.Size,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["MainFrame"].Instance.Position = UDim2New(0, Camera.ViewportSize.X / 4, 0, Camera.ViewportSize.Y / 4)


            Items["MainFrame"]:MakeDraggable()
            Items["MainFrame"]:MakeResizeable(Vector2New(Window.Size.X.Offset, Window.Size.Y.Offset), Vector2New(9999, 9999))

            Items["AccentBorder"] = Instances:Create("UIStroke", {
                Parent = Items["MainFrame"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(235, 157, 255)
            })  Items["AccentBorder"]:AddToTheme({Color = "Accent"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Window.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 6, 0, 1),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Inline"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 20),
                BorderColor3 = FromRGB(27, 27, 32),
                Size = UDim2New(1, -14, 1, -27),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Inline"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Inline"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Border,
                Name = "\0"
            }):AddToTheme({Color = "Border"})

            Items["Pages"] = Instances:Create("Frame", {
                Parent = Items["Inline"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 7),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 0, 19),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Pages"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Inline"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 26),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, -14, 1, -33),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Content"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Content"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Outline,
                Name = "\0"
            }):AddToTheme({Color = "Outline"})
        end

        local Debounce = false

        function Window:OnToggle(Callback)
            TableInsert(Window.OpenListeners, Callback)
        end

        function Window:SetOpen(Bool)
            Bool = Bool == true
            if Window.IsOpen == Bool then return end

            local FadeTime = Window.FadeSpeed or Library.Tween.Time
            local TurnToken = Library:NextTurn(Window)

            if not Bool then
                Library:CloseColorpicker(true)
                Library:CloseDropdowns()
                Library:CloseKeybinds()
            end

            Window.IsOpen = Bool
            Library.MenuVisible = Bool

            local Frame = Items["MainFrame"].Instance
            local Info = TweenInfo.new(FadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            if Window.BaseSize == nil then
                Window.BaseSize = Frame.Size
            end

            local Full = Window.BaseSize
            local Small = UDim2New(Full.X.Scale, MathFloor(Full.X.Offset * 0.94),
                                   Full.Y.Scale, MathFloor(Full.Y.Offset * 0.94))

            for _, Listener in Window.OpenListeners do
                Library:SafeCall(Listener, Bool)
            end

            Library:DropFadeCache(Frame)

            if Bool then
                Frame.Visible = true
                Frame.Size = Small
                Frame.BackgroundTransparency = 1

                Library:PlayFades(Frame, true, Info)
                Items["MainFrame"]:Tween(Info, { Size = Full, BackgroundTransparency = 0 })
            else
                Library:PlayFades(Frame, false, Info)
                Items["MainFrame"]:Tween(Info, { Size = Small, BackgroundTransparency = 1 })

                task.delay(FadeTime, function()
                    if not Library:IsTurn(Window, TurnToken) then return end

                    Frame.Visible = false
                    Frame.Size = Full
                    Frame.BackgroundTransparency = 0

                    for _, Entry in Library:CollectFades(Frame) do
                        if Entry[1].Parent then Entry[1][Entry[2]] = Entry[3] end
                    end
                end)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input, Busy)
            if Busy then return end
            if Library:MatchesMenuKey(Input) then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        Window.Elements = Items

        return setmetatable(Window, Library)
    end

    Library.Page = function(self, Data)
        Data = Data or { }

        local Page = {
            Window = self,

            Name = Data.Name or Data.name or "Page",
            Columns = Data.Columns or Data.columns or 2,

            HasSubtabs = Data.SubTabs or Data.Subtabs or Data.subtabs or false,

            Active = false,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] = Instances:Create("TextButton", {
                Parent = Page.Window.Elements["Pages"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(30, 30, 35)
            })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Inactive"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Outline,
                Name = "\0"
            }):AddToTheme({Color = "Outline"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Inactive"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.47999998927116394,
                Text = Page.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Hide"] = Instances:Create("Frame", {
                Parent = Items["Inactive"].Instance,
                Visible = false,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 3),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["MiscPixel1"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                Size = UDim2New(0, 1, 0, 1),
                Name = "\0",
                Position = UDim2New(0, -1, 0, 1),
                BorderColor3 = FromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["MiscPixel1"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["MiscPixel2"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(1, 0),
                Name = "\0",
                Position = UDim2New(1, 1, 0, 1),
                Size = UDim2New(0, 1, 0, 1),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["MiscPixel2"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["UIGradient"] = Instances:Create("UIGradient", {
                Parent = Items["Inactive"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(108, 108, 108))}
            })

            Items["Page"] = Instances:Create("Frame", {
                Parent = Page.Window.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255),
                Visible = false
            })

            if not Page.HasSubtabs then
                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                })

                for Index = 1, Page.Columns do
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = FromRGB(235, 157, 255),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 1,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Size = UDim2New(0, 100, 0, 100),
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BorderColor3 = FromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        BottomImage = Library:GetImage("Scrollbar"),
                        MidImage = Library:GetImage("Scrollbar"),
                        TopImage = Library:GetImage("Scrollbar"),
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})

                    Instances:Create("UIPadding", {
                        Parent = NewColumn.Instance,
                        PaddingTop = UDimNew(0, 6),
                        PaddingBottom = UDimNew(0, 6),
                        PaddingRight = UDimNew(0, 6),
                        PaddingLeft = UDimNew(0, 6)
                    })

                    Instances:Create("UIListLayout", {
                        Parent = NewColumn.Instance,
                        Padding = UDimNew(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Page.ColumnsData[Index] = NewColumn
                end
            else
                Items["Columns"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 7, 0, 45),
                    BorderColor3 = FromRGB(10, 10, 10),
                    Size = UDim2New(1, -14, 1, -52),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(15, 15, 20)
                })  Items["Columns"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

                Items["SubTabs"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 7, 0, 7),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -14, 0, 35),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubTabs"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
        end

        local Debounce = false

        function Page:Turn(Bool)
            Bool = Bool == true
            if Page.Active == Bool then return end

            local FadeTime = Page.Window.FadeSpeed or Library.Tween.Time
            local TurnToken = Library:NextTurn(Page)

            Page.Active = Bool

            Library:CloseDropdowns()
            Library:CloseKeybinds()
            if Bool then Library:CloseColorpicker(true) end

            if Bool then
                Items["Page"].Instance.Visible = true

                Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})
                Items["Hide"].Instance.Visible = true

                Items["Text"]:ChangeItemTheme({TextColor3 = "Accent"})
            else
                Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.3})
                Items["Hide"].Instance.Visible = false

                Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
            end

            Library:PlayFades(Items["Page"].Instance, Bool,
                TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

            if not Bool then
                Items["Page"].Instance.Visible = false
            end

        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for Index, Value in Page.Window.Pages do
                Value:Turn(Value == Page)
            end
        end)

        if #Page.Window.Pages == 0 then
            Page:Turn(true)
        end

        function Page:Destroy()
            local List = Page.Window.Pages
            local Index = TableFind(List, Page)

            if Index then TableRemove(List, Index) end

            for Position = #Page.Window.SubPages, 1, -1 do
                if Page.Window.SubPages[Position].Page == Page then
                    TableRemove(Page.Window.SubPages, Position)
                end
            end

            Library:DropFadeCache(Items["Page"].Instance)

            Items["Page"]:Clean()
            Items["Inactive"]:Clean()

            if Page.Active and List[1] then
                List[1].Active = false
                List[1]:Turn(true)
            end
        end

        Page.Elements = Items

        TableInsert(Page.Window.Pages, Page)
        return setmetatable(Page, Library.Pages)
    end

    Library.Pages.SubPage = function(self, Data)
        Data = Data or { }

        local SubPage = {
            Window = self.Window,
            Page = self,

            Icon = Data.Icon or Data.icon,
            Name = Data.Name or Data.name,
            Columns = Data.Columns or Data.columns or 2,

            Active = false,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] = Instances:Create("TextButton", {
                Parent = SubPage.Page.Elements["SubTabs"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, -2),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(30, 30, 35)
            })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Inactive"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Hide"] = Instances:Create("Frame", {
                Parent = Items["Inactive"].Instance,
                Visible = false,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 2),
                Size = UDim2New(1, 0, 0, 2),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["MiscPixel1"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                Size = UDim2New(0, 1, 0, 1),
                Name = "\0",
                Position = UDim2New(0, -1, 0, 1),
                BorderColor3 = FromRGB(0, 0, 0),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })

            Items["MiscPixel2"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(1, 0),
                Name = "\0",
                Position = UDim2New(1, 1, 0, 1),
                Size = UDim2New(0, 1, 0, 1),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })

            if SubPage.Name then
                Items["Icon"] = Instances:Create("TextLabel", {
                    Parent = Items["Inactive"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(222, 222, 228),
                    TextTransparency = 0.3,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Text = SubPage.Name,
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(1, -6, 1, 0),
                    BorderSizePixel = 0,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = Items["Icon"].Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})
            else
                Items["Icon"] = Instances:Create("ImageLabel", {
                    Parent = Items["Inactive"].Instance,
                    ScaleType = Enum.ScaleType.Fit,
                    ImageTransparency = 0.3,
                    BorderColor3 = FromRGB(0, 0, 0),
                    Name = "\0",
                    AnchorPoint = Vector2New(0.5, 0.5),
                    Image = "rbxassetid://" .. (SubPage.Icon or "9080568477801"),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0.5, 0, 0.5, 0),
                    Size = UDim2New(0, 30, 0, 30),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})
            end

            Instances:Create("UIGradient", {
                Parent = Items["Inactive"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(138, 138, 138))}
            })

            Items["Subtab"] = Instances:Create("Frame", {
                Parent = SubPage.Page.Elements["Columns"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                Visible = false,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Subtab"].Instance,
                PaddingTop = UDimNew(0, 6),
                PaddingRight = UDimNew(0, 6),
                PaddingLeft = UDimNew(0, 6)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Subtab"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            Instances:Create("UIStroke", {
                Parent = Items["Subtab"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

            for Index = 1, SubPage.Columns do
                local NewColumn = Instances:Create("ScrollingFrame", {
                    Parent = Items["Subtab"].Instance,
                    ScrollBarImageColor3 = FromRGB(235, 157, 255),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 1,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 100, 0, 100),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})

                Instances:Create("UIPadding", {
                    Parent = NewColumn.Instance,
                    PaddingTop = UDimNew(0, 6),
                    PaddingBottom = UDimNew(0, 6),
                    PaddingRight = UDimNew(0, 6),
                    PaddingLeft = UDimNew(0, 6)
                })

                Instances:Create("UIListLayout", {
                    Parent = NewColumn.Instance,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                SubPage.ColumnsData[Index] = NewColumn
            end
        end

        local Debounce = false

        function SubPage:Turn(Bool)
            Bool = Bool == true
            if SubPage.Active == Bool then return end

            local FadeTime = SubPage.Window.FadeSpeed or Library.Tween.Time
            local TurnToken = Library:NextTurn(SubPage)

            SubPage.Active = Bool

            Library:CloseDropdowns()
            Library:CloseKeybinds()
            if Bool then Library:CloseColorpicker(true) end

            local Tint = SubPage.Name and "TextColor3" or "ImageColor3"
            local Fade = SubPage.Name and "TextTransparency" or "ImageTransparency"

            if Bool then
                Items["Subtab"].Instance.Visible = true

                Items["Icon"]:Tween(nil, {[Tint] = Library.Theme.Accent, [Fade] = 0})
                Items["Hide"].Instance.Visible = true

                Items["Icon"]:ChangeItemTheme({[Tint] = "Accent"})

                Items["Inactive"].Instance.Size = UDim2New(1, 0, 1, 1)
            else
                Items["Icon"]:Tween(nil, {[Tint] = Library.Theme.Text, [Fade] = 0.3})
                Items["Hide"].Instance.Visible = false

                Items["Icon"]:ChangeItemTheme({[Tint] = "Text"})
                Items["Inactive"].Instance.Size = UDim2New(1, 0, 1, -2)
            end

            Library:PlayFades(Items["Subtab"].Instance, Bool,
                TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

            if not Bool then
                Items["Subtab"].Instance.Visible = false
            end

        end

        SubPage.Page.SubPages = SubPage.Page.SubPages or { }

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for Index, Value in SubPage.Page.SubPages do
                Value:Turn(Value == SubPage)
            end
        end)

        SubPage.Elements = Items

        TableInsert(SubPage.Page.SubPages, SubPage)
        TableInsert(SubPage.Window.SubPages, SubPage)

        if #SubPage.Page.SubPages == 1 then
            SubPage:Turn(true)
        end
        return setmetatable(SubPage, Library.Pages)
    end

    Library.Pages.Section = function(self, Data)
        Data = Data or { }

        local Section = {
            Window = self.Window,
            Page = self,

            Name = Data.Name or Data.name or "Section",
            Side = Data.Side or Data.side or 1,

            Elements = { }
        }

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Section"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Section.Name,
                Name = "\0",
                Size = UDim2New(1, -12, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 4, 0, 2),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 21),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 1, -20),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        Section.Elements = Items

        return setmetatable(Section, Library.Sections)
    end

    Library.Pages.MultiSection = function(self, Data)
        local MultiSection = {
            Window = self.Window,
            Page = self,

            Sections = Data.Sections or Data.sections or { "Section 1", "Section 2", "Section 3" },
            Side = Data.Side or Data.side or 1,

            SectionContents = { },

            Elements = { }
        }

        local Items = { } do
            Items["MultiSection"] = Instances:Create("Frame", {
                Parent = MultiSection.Page.ColumnsData[MultiSection.Side].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["MultiSection"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["MultiSection"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["MultiSection"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Sections"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 9),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 0, 19),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Sections"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 35),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, -14, 1, -33),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })
        end

        for Index, Value in MultiSection.Sections do
            local NewSection = {
                Window = MultiSection.Window,
                Page = MultiSection.Page,
                MultiSection = MultiSection,

                Name = Value,

                Elements = { },

                Active = false,
            }

            local SubItems = { } do
                SubItems["Inactive"] = Instances:Create("TextButton", {
                    Parent = Items["Sections"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(10, 10, 10),
                    Text = "",
                    AutoButtonColor = false,
                    Name = "\0",
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(30, 30, 35)
                })  SubItems["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

                SubItems["Text"] = Instances:Create("TextLabel", {
                    Parent = SubItems["Inactive"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(215, 215, 215),
                    TextTransparency = 0.28,
                    Text = NewSection.Name,
                    Name = "\0",
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, -1),
                    BorderSizePixel = 0,
                    BorderColor3 = FromRGB(0, 0, 0),
                    TextSize = 12,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  SubItems["Text"]:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = SubItems["Text"].Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})

                SubItems["Hide"] = Instances:Create("Frame", {
                    Parent = SubItems["Inactive"].Instance,
                    Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    Name = "\0",
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 3),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(15, 15, 20)
                })  SubItems["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

                SubItems["MiscPixel1"] = Instances:Create("Frame", {
                    Parent = SubItems["Hide"].Instance,
                    Size = UDim2New(0, 1, 0, 1),
                    Name = "\0",
                    Position = UDim2New(0, -1, 0, 1),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 27, 32)
                })  SubItems["MiscPixel1"]:AddToTheme({BackgroundColor3 = "Outline"})

                SubItems["MiscPixel2"] = Instances:Create("Frame", {
                    Parent = SubItems["Hide"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Name = "\0",
                    Position = UDim2New(1, 1, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 27, 32)
                })  SubItems["MiscPixel2"]:AddToTheme({BackgroundColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = SubItems["Inactive"].Instance,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = "\0",
                    Color = FromRGB(27, 27, 32)
                }):AddToTheme({Color = "Outline"})

                Instances:Create("UIGradient", {
                    Parent = SubItems["Inactive"].Instance,
                    Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(108, 108, 108))}
                })

                SubItems["Content"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    Name = "\0",
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = SubItems["Content"].Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            local Debounce = false

            function NewSection:Turn(Bool)
                Bool = Bool == true
                if NewSection.Active == Bool then return end

                local FadeTime = MultiSection.Window.FadeSpeed or Library.Tween.Time
                local TurnToken = Library:NextTurn(NewSection)

                NewSection.Active = Bool

                Library:CloseDropdowns()
                Library:CloseKeybinds()
                if Bool then Library:CloseColorpicker(true) end

                if Bool then
                    SubItems["Content"].Instance.Visible = true

                    SubItems["Text"]:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})

                    SubItems["Text"]:ChangeItemTheme({TextColor3 = "Accent"})
                else
                    SubItems["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.3})

                    SubItems["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                end

                Library:PlayFades(SubItems["Content"].Instance, Bool,
                    TweenInfo.new(FadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))

                if not Bool then
                    SubItems["Content"].Instance.Visible = false
                end

            end

            SubItems["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in MultiSection.SectionContents do
                    Value:Turn(Value == NewSection)
                end
            end)

            if #MultiSection.SectionContents == 0 then
                NewSection:Turn(true)
            end

            NewSection.Elements = SubItems

            MultiSection.SectionContents[#MultiSection.SectionContents+1] = setmetatable(NewSection, Library.Sections)
        end

        MultiSection.SectionContents[1]:Turn(true)
        MultiSection.Window.Sections[#MultiSection.Window.Sections+1] = MultiSection
        return TableUnpack(MultiSection.SectionContents)
    end

    Library.Pages.ScrollableSection = function(self, Data)
        Data = Data or { }

        local Section = {
            Window = self.Window,
            Page = self,

            Name = Data.Name or Data.name or "Section",
            Side = Data.Side or Data.side or 1,
            Size = Data.Size or Data.size or 175,

            Elements = { }
        }

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, Section.Size),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Items["Fade"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 20),
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 0, 1, 2),
                BorderSizePixel = 0,
                ZIndex = 15,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["Fade"]:AddToTheme({BackgroundColor3 = "Inline"})

            Instances:Create("UIGradient", {
                Parent = Items["Fade"].Instance,
                Rotation = -90,
                Transparency = NumSequence{NumSequenceKeypoint(0, 0), NumSequenceKeypoint(0.718, 0.768750011920929), NumSequenceKeypoint(1, 1)}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Section"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Section.Name,
                Name = "\0",
                Size = UDim2New(1, -12, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 4, 0, 2),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                ScrollBarThickness = 3,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarImageColor3 = FromRGB(235, 157, 255),
                MidImage = Library:GetImage("Scrollbar"),
                TopImage = Library:GetImage("Scrollbar"),
                BottomImage = Library:GetImage("Scrollbar"),
                Active = true,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 21),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, -20),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIPadding", {
                Parent = Items["Content"].Instance,
                PaddingTop = UDimNew(0, 0),
                PaddingBottom = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 11),
                PaddingLeft = UDimNew(0, 8)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        Section.Elements = Items

        return setmetatable(Section, Library.Sections)
    end

    Library.Sections.Divider = function(self)
        local Divider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
        }

        local Items = { } do
            Items["Divider"] = Instances:Create("Frame", {
                Parent = Divider.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 10),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["RealDivider"] = Instances:Create("Frame", {
                Parent = Items["Divider"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                Name = "\0",
                Position = UDim2New(0, 0, 0.5, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 3),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["RealDivider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealDivider"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})
        end

        function Divider:SetVisibility(Bool)
            Items["Divider"].Instance.Visible = Bool
        end

        return Divider
    end

    Library.Sections.Toggle = function(self, Data)
        Data = Data or { }

        local Toggle = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Toggle",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or false,
            Callback = Data.Callback or Data.callback or function() end,

            Value = false,
            Class = "Toggle",

            Count = 0
        }

        local Items = { } do
            Items["Toggle"] = Instances:Create("TextButton", {
                Parent = Toggle.Section.Elements["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 11),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["Toggle"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(0, 10, 0, 10),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Indicator"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["Indicator"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Toggle"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.28,
                Text = Toggle.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                Position = UDim2New(0, 18, 0, -1),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Toggle"]:OnHover(function()
                if Toggle.Value then
                    return
                end

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Toggle"]:OnHoverLeave(function()
                if Toggle.Value then
                    return
                end

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Set(Bool)
            if Bool == nil then Toggle.Value = not Toggle.Value else Toggle.Value = Bool == true end

            Library.Flags[Toggle.Flag] = Toggle.Value

            local Pulse = TweenInfo.new(0.09, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local Settle = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

            if Toggle.Value then
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Accent"})

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                Items["Text"]:Tween(nil, {TextTransparency = 0})
            else
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element"})

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                Items["Text"]:Tween(nil, {TextTransparency = 0.28})
            end

            Items["Indicator"]:Tween(Pulse, {Size = UDim2New(0, 7, 0, 7)})
            task.delay(0.09, function()
                Items["Indicator"]:Tween(Settle, {Size = UDim2New(0, 10, 0, 10)})
            end)

            if Toggle.KeyPicker and Toggle.KeyPicker.OnOwnerChanged then
                Toggle.KeyPicker:OnOwnerChanged()
            end

            if Toggle.Callback then
                Library:SafeCall(Toggle.Callback, Toggle.Value)
            end
        end

        function Toggle:SetVisiblity(Bool)
            Items["Toggle"].Instance.Visible = Bool
        end

        function Toggle:Colorpicker(Data)
            Data = Data or { }

            local Colorpicker = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Toggle"],
                Name = Data.Name or Data.name or "Colorpicker",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or false,
                Count = Toggle.Count,

                FadeSpeed = self.Window.FadeSpeed
            }

            Toggle.Count += 1
            Colorpicker.Count = Toggle.Count

            local Extension = Library:CreateColorpicker(Colorpicker)
            Library.Flags[Colorpicker.Flag] = Extension
            Toggle.ColorPicker = Extension

            return Extension
        end

        function Toggle:Keybind(Data)
            Data = Data or { }

            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Toggle"],
                Owner = Toggle,
                Sync = Data.SyncToggleState or Data.sync or false,
                Name = Data.Name or Data.name or Toggle.Name,
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "MB2",
                Mode = Data.Mode or Data.mode or "Toggle",
                Callback = Data.Callback or Data.callback or function() end,
            }

            local Extension = Library:CreateKeybind(Keybind)
            Library.Flags[Keybind.Flag] = Extension
            Toggle.KeyPicker = Extension

            return Extension, Keybind
        end

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Toggle:Set()
        end)

        local Tip = Data.Tip or Data.tip or Data.Tooltip or Data.tooltip
        if Tip then
            Library:Tooltip(Items["Toggle"], Tip)
        end

        Toggle:Set(Toggle.Default)

        Library.SetFlags[Toggle.Flag] = function(Value)
            Toggle:Set(Value)
        end

        function Toggle:Settings() return Toggle.Section end

        return Toggle
    end

    Library.Sections.Button = function(self, Data)
        Data = Data or { }

        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name,
            Callback = Data.Callback or Data.callback or function() end,
        }

        local Items = { } do
            Items["Button"] = Instances:Create("TextButton", {
                Parent = Button.Section.Elements["Content"].Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AutoButtonColor = false,
                Text = "",
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 17),
                Selectable = false,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["Button"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Button"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Button"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Button.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Items["TextBorder"] = Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Button"]:OnHover(function()
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Button"]:OnHoverLeave(function()
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Button:Press()
            local Flash = TweenInfo.new(0.08, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
            local Back = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            Items["Text"]:ChangeItemTheme({TextColor3 = "Accent"})
            Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Accent"})

            Items["Text"]:Tween(Flash, {TextColor3 = Library.Theme.Accent})
            Items["Button"]:Tween(Flash, {BackgroundColor3 = Library.Theme.Accent})

            task.delay(0.1, function()
                Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element"})

                Items["Text"]:Tween(Back, {TextColor3 = Library.Theme.Text})
                Items["Button"]:Tween(Back, {BackgroundColor3 = Library.Theme.Element})
            end)

            Library:SafeCall(Button.Callback)
        end

        function Button:SetVisiblity(Bool)
            Items["Button"].Instance.Visible = Bool
        end

        Button.Frame = Items["Button"]

        Items["Button"]:Connect("MouseButton1Down", function()
            Button:Press()
        end)

        function Button:Settings() return Button.Section end

        return Button
    end

    Library.Sections.Slider = function(self, Data)
        Data = Data or { }

        local Slider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Slider",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Min = Data.Min or Data.min or 0,
            Default = Data.Default or Data.default or 0,
            Max = Data.Max or Data.max or 100,
            Suffix = Data.Suffix or Data.suffix or "",
            Decimals = Data.Decimals ~= nil and Data.Decimals or (Data.decimals ~= nil and Data.decimals or 1),
            Callback = Data.Callback or Data.callback or function() end,
            Compact = Data.Compact or Data.compact or false,

            Value = 0,
            Sliding = false,
            Class = "Slider",
        }

        local Items = { } do
            Items["Slider"] = Instances:Create("Frame", {
                Parent = Slider.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 27),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Slider"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Slider.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["RealSlider"] = Instances:Create("TextButton", {
                Parent = Items["Slider"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, 0, 0, 10),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealSlider"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["RealSlider"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["RealSlider"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0.5, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["Indicator"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Value"] = Instances:Create("TextLabel", {
                Parent = Items["RealSlider"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "50/100s",
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, -1),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Value"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            if Slider.Compact then
                Items["Value"]:Clean()
                Items["Value"] = nil

                Items["Slider"].Instance.Size = UDim2New(1,0,0,10)
                Items["Text"].Instance.Parent = Items["RealSlider"].Instance
                Items["Text"].Instance.Position = UDim2New(0,0,0,-2)
                Items["Text"].Instance.TextXAlignment = Enum.TextXAlignment.Center
            end

            Items["RealSlider"]:OnHover(function()
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["RealSlider"]:OnHoverLeave(function()
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Background"]})
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
            end)
        end

        function Slider:Set(Value)
            Value = tonumber(Value)
            if Value == nil or Value ~= Value then Value = Slider.Min end

            Slider.Value = MathClamp(Library:Round(Value, Slider.Decimals), Slider.Min, Slider.Max)
            if Slider.Value ~= Slider.Value then Slider.Value = Slider.Min end

            Library.Flags[Slider.Flag] = Slider.Value

            if Slider.Compact then
                Items["Text"].Instance.Text = `{Slider.Name}: {Slider.Value}{Slider.Suffix}`
            else
                Items["Value"].Instance.Text = `{Slider.Value}{Slider.Suffix}`
            end

            local Span = Slider.Max - Slider.Min
            local Ratio = Span ~= 0 and ((Slider.Value - Slider.Min) / Span) or 0
            if Ratio ~= Ratio then Ratio = 0 end
            local Fill = UDim2New(MathClamp(Ratio, 0, 1), 0, 1, 0)
            local Speed = Slider.Sliding and 0.06 or 0.2
            local Style = Slider.Sliding and Enum.EasingStyle.Linear or Enum.EasingStyle.Quart
            Items["Indicator"]:Tween(TweenInfo.new(Speed, Style, Enum.EasingDirection.Out), {Size = Fill})

            if Slider.Callback then
                Library:SafeCall(Slider.Callback, Slider.Value)
            end
        end

        function Slider:Get()
            return Slider.Value
        end

        function Slider:SetVisibility(Bool)
            Items["Slider"].Instance.Visible = Bool
        end

        local function ValueFromCursor()
            local Track = Items["RealSlider"].Instance
            local Width = Track.AbsoluteSize.X
            if Width <= 0 then return nil end

            local Cursor = UserInputService:GetMouseLocation()
            local Inset = Vector2New(0, 0)
            pcall(function() Inset = GuiService:GetGuiInset() end)

            local Offset = (Cursor.X - Inset.X) - Track.AbsolutePosition.X
            local Ratio = MathClamp(Offset / Width, 0, 1)
            if Ratio ~= Ratio then return nil end

            return Slider.Min + (Slider.Max - Slider.Min) * Ratio
        end

        Items["RealSlider"]:Connect("InputBegan", function(Input)
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            Slider.Sliding = true

            local Value = ValueFromCursor()
            if Value then Slider:Set(Value) end

            Library:Thread(function()
                while Slider.Sliding and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    local Live = ValueFromCursor()
                    if Live then Slider:Set(Live) end
                    RunService.RenderStepped:Wait()
                end
                Slider.Sliding = false
            end)
        end)

        Items["RealSlider"]:Connect("InputEnded", function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Slider.Sliding = false
            end
        end)



        Slider:Set(Slider.Default or Slider.Min)

        Library.SetFlags[Slider.Flag] = function(Value)
            Slider:Set(Value)
        end

        function Slider:Settings() return Slider.Section end

        return Slider
    end

    Library.Sections.Dropdown = function(self, Data)
        Data = Data or { }

        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Dropdown",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or { "One", "Two", "Three" },
            Default = Data.Default or Data.default or nil,
            DefaultIndex = tonumber(Data.Default or Data.default),
            Callback = Data.Callback or Data.callback or function() end,
            Multi = Data.Multi or Data.multi or false,

            Value = { },
            IsOpen = false,
            Options = { },
            Class = "Dropdown",
        }

        local Items = { } do
            Items["Dropdown"] = Instances:Create("Frame", {
                Parent = Dropdown.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 34),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Dropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Dropdown.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["RealDropdown"] = Instances:Create("Frame", {
                Parent = Items["Dropdown"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["RealDropdown"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["RealDropdown"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Open"] = Instances:Create("TextButton", {
                Parent = Items["RealDropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "+",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2New(0, -4, 0, -1),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Open"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Open"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Value"] = Instances:Create("TextLabel", {
                Parent = Items["RealDropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "--",
                Name = "\0",
                Size = UDim2New(1, -25, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 5, 0, -1),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Value"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["OptionHolder"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Visible = false,
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(0, 100, 0, 0),
                BorderSizePixel = 2,
                ZIndex = 500,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["OptionHolder"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIListLayout", {
                Parent = Items["OptionHolder"].Instance,
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["OptionHolder"].Instance,
                PaddingBottom = UDimNew(0, 2)
            })

            Items["RealDropdown"]:OnHover(function()
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["RealDropdown"]:OnHoverLeave(function()
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Background"]})
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
            end)
        end

        function Dropdown:Set(Option)
            if Dropdown.Multi then
                if type(Option) ~= "table" then
                    return
                end

                Dropdown.Value = Option

                for Index, Value in Option do
                    local OptionData = Dropdown.Options[Value]

                    if not OptionData then
                        return
                    end

                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end

                Library.Flags[Dropdown.Flag] = Dropdown.Value

                Items["Value"].Instance.Text = TableConcat(Option, ", ")
            else
                if not Dropdown.Options[Option] then
                    return
                end

                local OptionData = Dropdown.Options[Option]

                Dropdown.Value = OptionData.Name

                OptionData.Selected = true
                OptionData:Toggle("Active")

                for Index, Value in Dropdown.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    end
                end

                Library.Flags[Dropdown.Flag] = Dropdown.Value

                Items["Value"].Instance.Text = Option
            end

            if Dropdown.Callback then
                Library:SafeCall(Dropdown.Callback, Option)
            end
        end

        function Dropdown:Get()
            return Dropdown.Value
        end

        function Dropdown:SetVisibility(Bool)
            Items["Dropdown"].Instance.Visible = Bool

            if not Bool and Dropdown.IsOpen then
                Dropdown:SetOpen(false)
            end
        end

        function Dropdown:Destroy()
            if Dropdown.Follow then
                pcall(function() Dropdown.Follow:Disconnect() end)
                Dropdown.Follow = nil
            end

            Items["OptionHolder"]:Clean()
            Items["Dropdown"]:Clean()
        end

        function Dropdown:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["OptionHolder"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, 0, 0, 15),
                ZIndex = 5,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.28,
                Text = Option,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, 0),
                Position = UDim2New(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex = 5,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            OptionText:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = OptionText.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local OptionData = {
                Selected = false,
                Name = Option,
                Text = OptionText,
                Button = OptionButton
            }

            function OptionData:Toggle(State)
                if State == "Active" then
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Accent"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})
                else
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Text"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.28})
                end
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected

                if Dropdown.Multi then
                    local Index = TableFind(Dropdown.Value, OptionData.Name)

                    if Index then
                        TableRemove(Dropdown.Value, Index)
                    else
                        TableInsert(Dropdown.Value, OptionData.Name)
                    end

                    Library.Flags[Dropdown.Flag] = Dropdown.Value

                    OptionData:Toggle(Index and "Inactive" or "Active")

                    local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "--"

                    Items["Value"].Instance.Text = TextFormat
                else
                    if OptionData.Selected then
                        Dropdown.Value = OptionData.Name

                        Library.Flags[Dropdown.Flag] = Dropdown.Value

                        OptionData:Toggle("Active")
                        Items["Value"].Instance.Text = OptionData.Name

                        for Index, Value in Dropdown.Options do
                            if Value ~= OptionData then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                    else
                        Dropdown.Value = nil

                        OptionData:Toggle("Inactive")
                        Items["Value"].Instance.Text = "--"
                    end
                end

                if Dropdown.Callback then
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            OptionButton:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Dropdown.Options[Option] = OptionData
            return OptionData
        end

        function Dropdown:Remove(Option)
            local Data = Dropdown.Options[Option]
            if not Data then return false end

            pcall(function() Data.Button:Clean() end)
            Dropdown.Options[Option] = nil

            local Index = TableFind(Dropdown.Items, Option)
            if Index then TableRemove(Dropdown.Items, Index) end

            if Dropdown.Value == Option then
                Dropdown.Value = Dropdown.Multi and { } or nil
            end

            return true
        end

        function Dropdown:Refresh(List)
            local Names = { }
            for Key in Dropdown.Options do Names[#Names + 1] = Key end
            for _, Key in Names do Dropdown:Remove(Key) end

            Dropdown.Options = { }
            Dropdown.Items = { }

            local Kept = Dropdown.Value

            for _, Value in List or { } do
                Dropdown.Items[#Dropdown.Items + 1] = Value
                Dropdown:Add(Value)
            end

            if type(Kept) == "string" and Dropdown.Options[Kept] then
                Dropdown:Set(Kept)
            else
                Dropdown.Value = Dropdown.Multi and { } or nil
                Items["Value"].Instance.Text = "---"
            end

            if Dropdown.IsOpen then Dropdown:Reposition() end
        end

        function Dropdown:SetItems(List)
            return Dropdown:Refresh(List)
        end

        function Dropdown:SetValues(List)
            return Dropdown:Refresh(List)
        end

        local Debounce = false

        function Dropdown:Reposition()
            local Anchor = Items["RealDropdown"].Instance
            local Panel = Items["OptionHolder"].Instance

            local Spot = Anchor.AbsolutePosition
            local Size = Anchor.AbsoluteSize
            local Root = Library.Holder.Instance.AbsolutePosition

            local Left = Spot.X - Root.X
            local Below = Spot.Y - Root.Y + Size.Y + 4

            local Screen = Library.Holder.Instance.AbsoluteSize
            local Tall = Panel.AbsoluteSize.Y

            if Tall > 0 and Below + Tall > Screen.Y - 8 then
                local Above = Spot.Y - Root.Y - Tall - 4

                if Above >= 8 then
                    Below = Above
                else
                    Below = Screen.Y - 8 - Tall
                    if Below < 8 then Below = 8 end
                end
            end

            local Wide = Panel.AbsoluteSize.X
            if Wide > 0 and Left + Wide > Screen.X - 8 then
                Left = Screen.X - 8 - Wide
            end
            if Left < 8 then Left = 8 end

            Panel.Position = UDim2New(0, Left, 0, Below)

            if Panel.AutomaticSize == Enum.AutomaticSize.Y then
                Panel.Size = UDim2New(0, Size.X, 0, Panel.Size.Y.Offset)
            end
        end

        function Dropdown:SetOpen(Bool)
            local FadeTime = Dropdown.Window.FadeSpeed or Library.Tween.Time
            local TurnToken = Library:NextTurn(Dropdown)

            if Debounce and Bool and Dropdown.IsOpen then
                return
            end

            Dropdown.IsOpen = Bool

            if not Bool then
                Library.OpenDropdowns[Dropdown] = nil
            end

            Debounce = true

            local Layout = Items["OptionHolder"].Instance:FindFirstChildOfClass("UIListLayout")
            local Full = Layout and Layout.AbsoluteContentSize.Y or 0
            local SlideInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

            local Anchor = Items["RealDropdown"].Instance
            local Wide = Anchor.AbsoluteSize.X

            if Bool then
                Library.OpenDropdowns[Dropdown] = true
            else
                Library.OpenDropdowns[Dropdown] = nil
            end

            if Bool then
                Dropdown:Reposition()

                Items["OptionHolder"].Instance.Visible = true
                Items["OptionHolder"].Instance.AutomaticSize = Enum.AutomaticSize.None
                Items["OptionHolder"].Instance.Size = UDim2New(0, Wide, 0, 0)
                Items["OptionHolder"]:Tween(SlideInfo, {Size = UDim2New(0, Wide, 0, Full)})

                task.delay(0.2, function()
                    if Dropdown.IsOpen then
                        Items["OptionHolder"].Instance.AutomaticSize = Enum.AutomaticSize.Y
                    end
                end)

                if not Dropdown.Follow then
                    local WasX, WasY = -1, -1

                    Dropdown.Follow = Library:Connect(RunService.Heartbeat, function()
                        if not Dropdown.IsOpen then return end

                        local Spot = Items["RealDropdown"].Instance.AbsolutePosition
                        if Spot.X == WasX and Spot.Y == WasY then return end

                        WasX, WasY = Spot.X, Spot.Y
                        Dropdown:Reposition()
                    end)
                end

                Items["Open"].Instance.Text = "-"
                Items["Open"].Instance.Position = UDim2New(0, -5, 0, -1)
            else
                Items["OptionHolder"].Instance.AutomaticSize = Enum.AutomaticSize.None
                Items["OptionHolder"]:Tween(SlideInfo, {Size = UDim2New(0, Wide, 0, 0)})

                if Dropdown.Follow then
                    pcall(function() Dropdown.Follow:Disconnect() end)
                    Dropdown.Follow = nil
                end

                Items["Open"].Instance.Text = "+"
                Items["Open"].Instance.Position = UDim2New(0, -4, 0, -1)
            end

            local Descendants = Items["OptionHolder"].Instance:GetDescendants()
            TableInsert(Descendants, Items["OptionHolder"].Instance)

            local NewTween
            for Index, Value in Descendants do
                local ValueIndex = Library:GetTransparencyPropertyFromItem(Value)

                if not ValueIndex then
                    continue
                end

                if not StringFind(Value.ClassName, "UI") then
                    Value.ZIndex = Bool and 501 or 1
                end

                if type(ValueIndex) == "table" then
                    for _, Property in ValueIndex do
                        NewTween = Library:FadeItem(Value, Property, Bool, Dropdown.Window.FadeSpeed)
                    end
                else
                    NewTween = Library:FadeItem(Value, ValueIndex, Bool, Dropdown.Window.FadeSpeed)
                end
            end

            task.delay(FadeTime, function()
                Debounce = false
                if not Library:IsTurn(Dropdown, TurnToken) then return end
                Items["OptionHolder"].Instance.Visible = Dropdown.IsOpen
                Items["OptionHolder"].Instance.ZIndex = Dropdown.IsOpen and 500 or 1
            end)
        end

        for Index, Value in Dropdown.Items do
            Dropdown:Add(Value)
        end

        if Dropdown.DefaultIndex and Dropdown.Items[Dropdown.DefaultIndex] then
            Dropdown.Default = Dropdown.Items[Dropdown.DefaultIndex]
        end

        Items["Open"]:Connect("MouseButton1Down", function()
            Dropdown:SetOpen(not Dropdown.IsOpen)
        end)

        if Dropdown.Default then
            Dropdown:Set(Dropdown.Default)
        else
            if Library.Flags[Dropdown.Flag] == nil then
                Library.Flags[Dropdown.Flag] = Dropdown.Multi and {} or ""
            end
        end

        Library.SetFlags[Dropdown.Flag] = function(Value)
            Dropdown:Set(Value)
        end

        function Dropdown:Settings() return Dropdown.Section end

        return Dropdown
    end

    Library.Sections.Label = function(self, Data)
        Data = Data or { }

        local Label = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name,
            Alignment = Data.Alignment or Data.alignment or "Left",

            Count = 0
        }

        local Items = { } do
            Items["Label"] = Instances:Create("Frame", {
                Parent = Label.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 15),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Label"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Label.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment[Label.Alignment],
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
            }):AddToTheme({Color = "Text Border"})
        end

        function Label:Colorpicker(Data)
            Data = Data or { }

            local Colorpicker = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Label"],
                Name = Data.Name or Data.name or "Colorpicker",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or false,
                Count = Label.Count,
                FadeSpeed = self.Window.FadeSpeed
            }

            Label.Count += 1
            Colorpicker.Count = Label.Count

            local Extension = Library:CreateColorpicker(Colorpicker)

            return Colorpicker, Extension
        end

        function Label:Keybind(Data)
            Data = Data or { }

            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Label"],
                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "MB2",
                Mode = Data.Mode or Data.mode or "Toggle",
                Callback = Data.Callback or Data.callback or function() end,
            }

            local Extension = Library:CreateKeybind(Keybind)

            return Keybind, Extension
        end

        function Label:Settings() return Label.Section end

        return Label
    end

    Library.Sections.Textbox = function(self, Data)
        Data = Data or { }

        local Textbox = {
            Window = self.Window,
            Tab = self.Tab,
            Section = self,

            Name = Data.Name or Data.name or "Textbox",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Placeholder = Data.Placeholder or Data.placeholder or "...",
            Default = Data.Default or Data.default or "",
            Callback = Data.Callback or Data.callback or function() end,

            Value = "",
            Class = "Textbox"
        }

        local Items = { } do
            Items["Textbox"] = Instances:Create("Frame", {
                Parent = Textbox.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 34),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Textbox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Textbox.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Background"] = Instances:Create("Frame", {
                Parent = Items["Textbox"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["Background"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Background"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Inline"] = Instances:Create("TextBox", {
                Parent = Items["Background"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                BackgroundTransparency = 1,
                PlaceholderColor3 = FromRGB(178, 178, 178),
                TextXAlignment = Enum.TextXAlignment.Left,
                PlaceholderText = Textbox.Placeholder,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Inline"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIPadding", {
                Parent = Items["Inline"].Instance,
                PaddingBottom = UDimNew(0, 3),
                PaddingLeft = UDimNew(0, 5)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Inline"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Background"]:OnHover(function()
                Items["Background"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Background"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Background"]:OnHoverLeave(function()
                Items["Background"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Background"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Textbox:Get()
            return Textbox.Value
        end

        function Textbox:SetVisibility(Bool)
            Items["Textbox"].Instance.Visible = Bool
        end

        function Textbox:Set(Value)
            Textbox.Value = Value

            Items["Inline"].Instance.Text = Textbox.Value
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Text})
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Text"})

            Library.Flags[Textbox.Flag] = Textbox.Value

            if Textbox.Callback then
                Library:SafeCall(Textbox.Callback, Textbox.Value)
            end
        end

        Items["Inline"]:Connect("Focused", function()
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Accent"})
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
        end)

        Items["Inline"]:Connect("FocusLost", function()
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Text"})
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Text})

            Textbox:Set(Items["Inline"].Instance.Text)
        end)

        Textbox:Set(Textbox.Default or "")

        Library.SetFlags[Textbox.Flag] = function(Value)
            Textbox:Set(Value)
        end

        function Textbox:Settings() return Textbox.Section end

        return Textbox
    end

    Library.Sections.Listbox = function(self, Data)
        Data = Data or {}

        local Listbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Items = Data.Items or Data.items or { },
            Multi = Data.Multi or Data.multi or false,
            Default = Data.Default or Data.default or 1,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Callback = Data.Callback or Data.callback or function() end,
            Size = Data.Size or Data.size or 175,

            Value = { },
            Options = { },
            Class = "Listbox",
        }

        local Items = { } do
            Items["Listbox"] = Instances:Create("Frame", {
                Parent = Listbox.Section.Elements["Content"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, Listbox.Size),
                BorderColor3 = FromRGB(0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["RealListbox"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Listbox"].Instance,
                ScrollBarImageColor3 = FromRGB(235, 157, 255),
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 1,
                AnchorPoint = Vector2New(0, 1),
                Size = UDim2New(1, 0, 1, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BackgroundColor3 = FromRGB(15, 15, 20),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })  Items["RealListbox"]:AddToTheme({ScrollBarImageColor3 = "Accent", BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealListbox"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIListLayout", {
                Parent = Items["RealListbox"].Instance,
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["RealListbox"].Instance,
                PaddingBottom = UDimNew(0, 5),
                PaddingTop = UDimNew(0, 2)
            })
        end

        function Listbox:Set(Option)
            if Listbox.Multi then
                if type(Option) ~= "table" then
                    return
                end

                Listbox.Value = Option

                Library.Flags[Listbox.Flag] = Listbox.Value

                for Index, Value in Option do
                    local OptionData = Listbox.Options[Value]

                    if not OptionData then
                        return
                    end

                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end
            else
                if not Listbox.Options[Option] then
                    return
                end

                local OptionData = Listbox.Options[Option]

                Listbox.Value = OptionData.Name

                Library.Flags[Listbox.Flag] = Listbox.Value

                OptionData.Selected = true
                OptionData:Toggle("Active")

                for Index, Value in Listbox.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    end
                end
            end

            if Listbox.Callback then
                Library:SafeCall(Listbox.Callback, Option)
            end
        end

        function Listbox:Get()
            return Listbox.Value
        end

        function Listbox:SetVisibility(Bool)
            Items["Listbox"].Instance.Visible = Bool
        end

        function Listbox:Remove(Option)
            if Listbox.Options[Option] then
                Listbox.Options[Option].Button:Clean()
            end
        end

        function Listbox:Refresh(List)
            for Index, Value in Listbox.Options do
                Listbox:Remove(Value.Name)
            end

            for Index, Value in List do
                Listbox:Add(Value)
            end
        end

        function Listbox:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["RealListbox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, 0, 0, 15),
                ZIndex = 5,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.28,
                Text = Option,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, 0),
                Position = UDim2New(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                BorderSizePixel = 0,
                ZIndex = 5,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            OptionText:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = OptionText.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local OptionData = {
                Selected = false,
                Name = Option,
                Text = OptionText,
                Button = OptionButton
            }

            function OptionData:Toggle(State)
                if State == "Active" then
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Accent"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})
                else
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Text"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.28})
                end
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected

                if Listbox.Multi then
                    local Index = TableFind(Listbox.Value, OptionData.Name)

                    if Index then
                        TableRemove(Listbox.Value, Index)
                    else
                        TableInsert(Listbox.Value, OptionData.Name)
                    end

                    OptionData:Toggle(Index and "Inactive" or "Active")

                    local TextFormat = #Listbox.Value > 0 and TableConcat(Listbox.Value, ", ") or "--"
                else
                    if OptionData.Selected then
                        Listbox.Value = OptionData.Name

                        OptionData:Toggle("Active")

                        for Index, Value in Listbox.Options do
                            if Value ~= OptionData then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                    else
                        Listbox.Value = nil

                        OptionData:Toggle("Inactive")
                    end
                end

                if Listbox.Callback then
                    Library:SafeCall(Listbox.Callback, Listbox.Value)
                end
            end

            OptionButton:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Listbox.Options[Option] = OptionData
            return OptionData
        end

        for Index, Value in Listbox.Items do
            Listbox:Add(Value)
        end

        if Listbox.Default then
            Listbox:Set(Listbox.Default)
        else
            if Library.Flags[Listbox.Flag] == nil then
                Library.Flags[Listbox.Flag] = Listbox.Multi and {} or ""
            end
        end

        Library.SetFlags[Listbox.Flag] = function(Value)
            Listbox:Set(Value)
        end

        function Listbox:Settings() return Listbox.Section end

        return Listbox
    end
end

getgenv().Library = Library
return Library
