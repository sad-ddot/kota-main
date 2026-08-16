local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

local Library = {
  Registry = {};
  RegistryMap = {};

  HudRegistry = {};

  FontColor = Color3.fromRGB(255, 255, 255);
  MainColor = Color3.fromRGB(28, 28, 28);
  BackgroundColor = Color3.fromRGB(20, 20, 20);
  AccentColor = Color3.fromRGB(0, 85, 255);
  OutlineColor = Color3.fromRGB(50, 50, 50);
  RiskColor = Color3.fromRGB(255, 50, 50),

  Black = Color3.new(0, 0, 0);
  Font = Enum.Font.Code,

  OpenedFrames = {};
  DependencyBoxes = {};

  Signals = {};
  ScreenGui = ScreenGui;
};

local RainbowStep = 0
local Hue = 0

table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
  RainbowStep = RainbowStep + Delta

  if RainbowStep >= (1 / 60) then
    RainbowStep = 0

    Hue = Hue + (1 / 400);

    if Hue > 1 then
      Hue = 0;
    end;

    Library.CurrentRainbowHue = Hue;
    Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
  end
end))

local function GetPlayersString()
  local PlayerList = Players:GetPlayers();

  for i = 1, #PlayerList do
    PlayerList[i] = PlayerList[i].Name;
  end;

  table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

  return PlayerList;
end;

local function GetTeamsString()
  local TeamList = Teams:GetTeams();

  for i = 1, #TeamList do
    TeamList[i] = TeamList[i].Name;
  end;

  table.sort(TeamList, function(str1, str2) return str1 < str2 end);

  return TeamList;
end;

function Library:SafeCallback(f, ...)
  if (not f) then
    return;
  end;

  if not Library.NotifyOnError then
    return f(...);
  end;

  local success, event = pcall(f, ...);

  if not success then
    local _, i = event:find(":%d+: ");

    if not i then
      return Library:Notify(event);
    end;

    return Library:Notify(event:sub(i + 1), 3);
  end;
end;

function Library:AttemptSave()
  if Library.SaveManager then
    Library.SaveManager:Save();
  end;
end;

function Library:Create(Class, Properties)
  local _Instance = Class;

  if type(Class) == 'string' then
    _Instance = Instance.new(Class);
  end;

  for Property, Value in next, Properties do
    _Instance[Property] = Value;
  end;

  return _Instance;
end;

function Library:ApplyTextStroke(Inst)
  Inst.TextStrokeTransparency = 1;

  Library:Create('UIStroke', {
    Color = Color3.new(0, 0, 0);
    Thickness = 1;
    LineJoinMode = Enum.LineJoinMode.Miter;
    Parent = Inst;
  });
end;

function Library:CreateLabel(Properties, IsHud)
  local _Instance = Library:Create('TextLabel', {
    BackgroundTransparency = 1;
    Font = Library.Font;
    TextColor3 = Library.FontColor;
    TextSize = 16;
    TextStrokeTransparency = 0;
  });

  Library:ApplyTextStroke(_Instance);

  Library:AddToRegistry(_Instance, {
    TextColor3 = 'FontColor';
  }, IsHud);

  return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
  Instance.Active = true;

  Instance.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
      local ObjPos = Vector2.new(
        Mouse.X - Instance.AbsolutePosition.X,
        Mouse.Y - Instance.AbsolutePosition.Y
      );

      if ObjPos.Y > (Cutoff or 40) then
        return;
      end;

      while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
        Instance.Position = UDim2.new(
          0,
          Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
          0,
          Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
        );

        RenderStepped:Wait();
      end;
    end;
  end)
end;

function Library:AddToolTip(InfoStr, HoverInstance)
  local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
  local Tooltip = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor,
    BorderColor3 = Library.OutlineColor,

    Size = UDim2.fromOffset(X + 5, Y + 4),
    ZIndex = 100,
    Parent = Library.ScreenGui,

    Visible = false,
  })

  local Label = Library:CreateLabel({
    Position = UDim2.fromOffset(3, 1),
    Size = UDim2.fromOffset(X, Y);
    TextSize = 14;
    Text = InfoStr,
    TextColor3 = Library.FontColor,
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = Tooltip.ZIndex + 1,

    Parent = Tooltip;
  });

  Library:AddToRegistry(Tooltip, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
  });

  Library:AddToRegistry(Label, {
    TextColor3 = 'FontColor',
  });

  local IsHovering = false

  HoverInstance.MouseEnter:Connect(function()
    if Library:MouseIsOverOpenedFrame() then
      return
    end

    IsHovering = true

    Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
    Tooltip.Visible = true
    Library.OpenedFrames[Tooltip] = function()
      IsHovering = false
      Tooltip.Visible = false
    end

    while IsHovering do
      RunService.Heartbeat:Wait()
      Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
    end
  end)

  HoverInstance.MouseLeave:Connect(function()
    IsHovering = false
    Library.OpenedFrames[Tooltip] = nil
    Tooltip.Visible = false
  end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
  local function Apply(PropertiesMap)
    local Reg = Library.RegistryMap[Instance];
    local Goals = {};

    for Property, ColorIdx in next, PropertiesMap do
      local Value = Library[ColorIdx] or ColorIdx;

      if Property:sub(-6) == 'Color3' then
        Goals[Property] = Value;
      else
        Instance[Property] = Value;
      end;

      if Reg and Reg.Properties[Property] then
        Reg.Properties[Property] = ColorIdx;
      end;
    end;

    if next(Goals) then
      TweenService:Create(Instance, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Goals):Play();
    end;
  end;

  HighlightInstance.MouseEnter:Connect(function()
    Apply(Properties);
  end)

  HighlightInstance.MouseLeave:Connect(function()
    Apply(PropertiesDefault);
  end)
end;

function Library:ClosePopups(Except, Instant)
  local Frames = {};
  for Frame, Close in next, Library.OpenedFrames do
    if Frame ~= Except then
      Frames[#Frames + 1] = { Frame, Close };
    end;
  end;
  for _, Entry in next, Frames do
    local Frame, Close = Entry[1], Entry[2];
    Library.OpenedFrames[Frame] = nil;
    if type(Close) == 'function' then
      Close(Instant == true);
    elseif typeof(Frame) == 'Instance' then
      Frame.Visible = false;
    end;
  end;
end;

function Library:MouseIsOverOpenedFrame()
  for Frame, _ in next, Library.OpenedFrames do
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

    if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
      and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

      return true;
    end;
  end;
end;

function Library:IsMouseOverFrame(Frame)
  local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

  if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
    and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

    return true;
  end;
end;

function Library:UpdateDependencyBoxes()
  for _, Depbox in next, Library.DependencyBoxes do
    Depbox:Update();
  end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
  return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
  local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
  return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
  local H, S, V = Color3.toHSV(Color);
  return Color3.fromHSV(H, S, V / 1.5);
end;
Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

function Library:AddToRegistry(Instance, Properties, IsHud)
  local Idx = #Library.Registry + 1;
  local Data = {
    Instance = Instance;
    Properties = Properties;
    Idx = Idx;
  };

  table.insert(Library.Registry, Data);
  Library.RegistryMap[Instance] = Data;

  if IsHud then
    table.insert(Library.HudRegistry, Data);
  end;
end;

function Library:RemoveFromRegistry(Instance)
  local Data = Library.RegistryMap[Instance];

  if Data then
    for Idx = #Library.Registry, 1, -1 do
      if Library.Registry[Idx] == Data then
        table.remove(Library.Registry, Idx);
      end;
    end;

    for Idx = #Library.HudRegistry, 1, -1 do
      if Library.HudRegistry[Idx] == Data then
        table.remove(Library.HudRegistry, Idx);
      end;
    end;

    Library.RegistryMap[Instance] = nil;
  end;
end;

function Library:UpdateColorsUsingRegistry()










  for Idx, Object in next, Library.Registry do
    for Property, ColorIdx in next, Object.Properties do
      if type(ColorIdx) == 'string' then
        Object.Instance[Property] = Library[ColorIdx];
      elseif type(ColorIdx) == 'function' then
        Object.Instance[Property] = ColorIdx()
      end
    end;
  end;
end;

function Library:GiveSignal(Signal)

  table.insert(Library.Signals, Signal)
end

function Library:Unload()

  for Idx = #Library.Signals, 1, -1 do
    local Connection = table.remove(Library.Signals, Idx)
    Connection:Disconnect()
  end


  if Library.OnUnload then
    Library.OnUnload()
  end

  ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
  Library.OnUnload = Callback
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
  if Library.RegistryMap[Instance] then
    Library:RemoveFromRegistry(Instance);
  end;
end))

local BaseAddons = {};

do
  local Funcs = {};

  function Funcs:AddColorPicker(Idx, Info)
    local ToggleLabel = self.TextLabel;


    assert(Info.Default, 'AddColorPicker: Missing default value.');

    local ColorPicker = {
      Value = Info.Default;
      Transparency = Info.Transparency or 0;
      Type = 'ColorPicker';
      Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
      Callback = Info.Callback or function(Color) end;
    };

    function ColorPicker:SetHSVFromRGB(Color)
      local H, S, V = Color3.toHSV(Color);

      ColorPicker.Hue = H;
      ColorPicker.Sat = S;
      ColorPicker.Vib = V;
    end;

    ColorPicker:SetHSVFromRGB(ColorPicker.Value);

    local DisplayFrame = Library:Create('Frame', {
      BackgroundColor3 = ColorPicker.Value;
      BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(0, 28, 0, 14);
      ZIndex = 6;
      Parent = ToggleLabel;
    });


    local CheckerFrame = Library:Create('ImageLabel', {
      BorderSizePixel = 0;
      Size = UDim2.new(0, 27, 0, 13);
      ZIndex = 5;
      Image = 'http://www.roblox.com/asset/?id=12977615774';
      Visible = not not Info.Transparency;
      Parent = DisplayFrame;
    });






    local PickerSize = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
    local PickerFrameOuter = Library:Create('Frame', {
      Name = 'Color';
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderColor3 = Color3.new(0, 0, 0);
      Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
      Size = PickerSize;
      ClipsDescendants = true;
      Visible = false;
      ZIndex = 15;
      Parent = ScreenGui,
    });

    DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
      PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
    end)

    local PickerFrameInner = Library:Create('Frame', {
      BackgroundColor3 = Library.BackgroundColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 16;
      Parent = PickerFrameOuter;
    });

    local Highlight = Library:Create('Frame', {
      BackgroundColor3 = Library.AccentColor;
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 0, 2);
      ZIndex = 17;
      Parent = PickerFrameInner;
    });

    local SatVibMapOuter = Library:Create('Frame', {
      BorderColor3 = Color3.new(0, 0, 0);
      Position = UDim2.new(0, 4, 0, 25);
      Size = UDim2.new(0, 200, 0, 200);
      ZIndex = 17;
      Parent = PickerFrameInner;
    });

    local SatVibMapInner = Library:Create('Frame', {
      BackgroundColor3 = Library.BackgroundColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 18;
      Parent = SatVibMapOuter;
    });

    local SatVibMap = Library:Create('ImageLabel', {
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 18;
      Image = 'rbxassetid://4155801252';
      Parent = SatVibMapInner;
    });

    local CursorOuter = Library:Create('ImageLabel', {
      AnchorPoint = Vector2.new(0.5, 0.5);
      Size = UDim2.new(0, 6, 0, 6);
      BackgroundTransparency = 1;
      Image = 'http://www.roblox.com/asset/?id=9619665977';
      ImageColor3 = Color3.new(0, 0, 0);
      ZIndex = 19;
      Parent = SatVibMap;
    });

    local CursorInner = Library:Create('ImageLabel', {
      Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
      Position = UDim2.new(0, 1, 0, 1);
      BackgroundTransparency = 1;
      Image = 'http://www.roblox.com/asset/?id=9619665977';
      ZIndex = 20;
      Parent = CursorOuter;
    })

    local HueSelectorOuter = Library:Create('Frame', {
      BorderColor3 = Color3.new(0, 0, 0);
      Position = UDim2.new(0, 208, 0, 25);
      Size = UDim2.new(0, 15, 0, 200);
      ZIndex = 17;
      Parent = PickerFrameInner;
    });

    local HueSelectorInner = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(1, 1, 1);
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 18;
      Parent = HueSelectorOuter;
    });

    local HueCursor = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(1, 1, 1);
      AnchorPoint = Vector2.new(0, 0.5);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(1, 0, 0, 1);
      ZIndex = 18;
      Parent = HueSelectorInner;
    });

    local HueBoxOuter = Library:Create('Frame', {
      BorderColor3 = Color3.new(0, 0, 0);
      Position = UDim2.fromOffset(4, 228),
      Size = UDim2.new(0.5, -6, 0, 20),
      ZIndex = 18,
      Parent = PickerFrameInner;
    });

    local HueBoxInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 18,
      Parent = HueBoxOuter;
    });

    Library:Create('UIGradient', {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
      });
      Rotation = 90;
      Parent = HueBoxInner;
    });

    local HueBox = Library:Create('TextBox', {
      BackgroundTransparency = 1;
      Position = UDim2.new(0, 5, 0, 0);
      Size = UDim2.new(1, -5, 1, 0);
      Font = Library.Font;
      PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
      PlaceholderText = 'Hex color',
      Text = '#FFFFFF',
      TextColor3 = Library.FontColor;
      TextSize = 14;
      TextStrokeTransparency = 0;
      TextXAlignment = Enum.TextXAlignment.Left;
      ZIndex = 20,
      Parent = HueBoxInner;
    });

    Library:ApplyTextStroke(HueBox);

    local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
      Position = UDim2.new(0.5, 2, 0, 228),
      Size = UDim2.new(0.5, -6, 0, 20),
      Parent = PickerFrameInner
    });

    local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
      Text = '255, 255, 255',
      PlaceholderText = 'RGB color',
      TextColor3 = Library.FontColor
    });

    local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;

    if Info.Transparency then
      TransparencyBoxOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.fromOffset(4, 251);
        Size = UDim2.new(1, -8, 0, 15);
        ZIndex = 19;
        Parent = PickerFrameInner;
      });

      TransparencyBoxInner = Library:Create('Frame', {
        BackgroundColor3 = ColorPicker.Value;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 19;
        Parent = TransparencyBoxOuter;
      });

      Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

      Library:Create('ImageLabel', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, 0, 1, 0);
        Image = 'http://www.roblox.com/asset/?id=12978095818';
        ZIndex = 20;
        Parent = TransparencyBoxInner;
      });

      TransparencyCursor = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        AnchorPoint = Vector2.new(0.5, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(0, 1, 1, 0);
        ZIndex = 21;
        Parent = TransparencyBoxInner;
      });
    end;

    local DisplayLabel = Library:CreateLabel({
      Size = UDim2.new(1, 0, 0, 14);
      Position = UDim2.fromOffset(5, 5);
      TextXAlignment = Enum.TextXAlignment.Left;
      TextSize = 14;
      Text = ColorPicker.Title,
      TextWrapped = false;
      ZIndex = 16;
      Parent = PickerFrameInner;
    });


    local ContextMenu = {}
    do
      ContextMenu.Options = {}
      ContextMenu.Container = Library:Create('Frame', {
        BorderColor3 = Color3.new(),
        ZIndex = 14,

        Visible = false,
        Parent = ScreenGui
      })

      ContextMenu.Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.fromScale(1, 1);
        ZIndex = 15;
        Parent = ContextMenu.Container;
      });

      Library:Create('UIListLayout', {
        Name = 'Layout',
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = ContextMenu.Inner;
      });

      Library:Create('UIPadding', {
        Name = 'Padding',
        PaddingLeft = UDim.new(0, 4),
        Parent = ContextMenu.Inner,
      });

      local function updateMenuPosition()
        ContextMenu.Container.Position = UDim2.fromOffset(
          (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
          DisplayFrame.AbsolutePosition.Y + 1
        )
      end

      local function updateMenuSize()
        local menuWidth = 60
        for i, label in next, ContextMenu.Inner:GetChildren() do
          if label:IsA('TextLabel') then
            menuWidth = math.max(menuWidth, label.TextBounds.X)
          end
        end

        ContextMenu.Container.Size = UDim2.fromOffset(
          menuWidth + 8,
          ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
        )
      end

      DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
      ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

      task.spawn(updateMenuPosition)
      task.spawn(updateMenuSize)

      Library:AddToRegistry(ContextMenu.Inner, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
      });

      function ContextMenu:Show()
        Library:ClosePopups(self.Container, true)
        self.Container.Visible = true
        Library.OpenedFrames[self.Container] = function()
          self:Hide()
        end
      end

      function ContextMenu:Hide()
        Library.OpenedFrames[self.Container] = nil
        self.Container.Visible = false
      end

      function ContextMenu:AddOption(Str, Callback)
        if type(Callback) ~= 'function' then
          Callback = function() end
        end

        local Button = Library:CreateLabel({
          Active = false;
          Size = UDim2.new(1, 0, 0, 15);
          TextSize = 13;
          Text = Str;
          ZIndex = 16;
          Parent = self.Inner;
          TextXAlignment = Enum.TextXAlignment.Left,
        });

        Library:OnHighlight(Button, Button,
          { TextColor3 = 'AccentColor' },
          { TextColor3 = 'FontColor' }
        );

        Button.InputBegan:Connect(function(Input)
          if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
          end

          Callback()
        end)
      end

      ContextMenu:AddOption('Copy color', function()
        Library.ColorClipboard = ColorPicker.Value
        Library:Notify('Copied color!', 2)
      end)

      ContextMenu:AddOption('Paste color', function()
        if not Library.ColorClipboard then
          return Library:Notify('You have not copied a color!', 2)
        end
        ColorPicker:SetValueRGB(Library.ColorClipboard)
      end)


      ContextMenu:AddOption('Copy HEX', function()
        pcall(setclipboard, ColorPicker.Value:ToHex())
        Library:Notify('Copied hex code to clipboard!', 2)
      end)

      ContextMenu:AddOption('Copy RGB', function()
        pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
        Library:Notify('Copied RGB values to clipboard!', 2)
      end)

    end

    Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
    Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

    Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
    Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
    Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

    local SequenceTable = {};

    for Hue = 0, 1, 0.1 do
      table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
    end;

    local HueSelectorGradient = Library:Create('UIGradient', {
      Color = ColorSequence.new(SequenceTable);
      Rotation = 90;
      Parent = HueSelectorInner;
    });

    HueBox.FocusLost:Connect(function(enter)
      if enter then
        local success, result = pcall(Color3.fromHex, HueBox.Text)
        if success and typeof(result) == 'Color3' then
          ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
        end
      end

      ColorPicker:Display()
    end)

    RgbBox.FocusLost:Connect(function(enter)
      if enter then
        local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
        if r and g and b then
          ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
        end
      end

      ColorPicker:Display()
    end)

    function ColorPicker:Display()
      ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
      SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

      Library:Create(DisplayFrame, {
        BackgroundColor3 = ColorPicker.Value;
        BackgroundTransparency = ColorPicker.Transparency;
        BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
      });

      if TransparencyBoxInner then
        TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
        TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
      end;

      CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
      HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

      HueBox.Text = '#' .. ColorPicker.Value:ToHex()
      RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

      Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
      Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
    end;

    function ColorPicker:OnChanged(Func)
      ColorPicker.Changed = Func;
      Func(ColorPicker.Value)
    end;

    local PickerTween;
    local PickerOpen = false;

    function ColorPicker:Show()
      Library:ClosePopups(PickerFrameOuter, true)
      PickerOpen = true;
      PickerFrameOuter.Size = UDim2.fromOffset(PickerSize.X.Offset, 0);
      PickerFrameOuter.Visible = true;
      Library.OpenedFrames[PickerFrameOuter] = function(Instant)
        ColorPicker:Hide(Instant)
      end;

      if PickerTween then PickerTween:Cancel(); end;
      PickerTween = TweenService:Create(PickerFrameOuter, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = PickerSize });
      PickerTween:Play();
    end;

    function ColorPicker:Hide(Instant)
      PickerOpen = false;
      Library.OpenedFrames[PickerFrameOuter] = nil;
      if PickerTween then PickerTween:Cancel(); end;
      if Instant then
        PickerFrameOuter.Visible = false;
        PickerFrameOuter.Size = PickerSize;
        return;
      end;
      if not PickerFrameOuter.Visible then return; end;

      PickerTween = TweenService:Create(PickerFrameOuter, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(PickerSize.X.Offset, 0)
      });
      PickerTween:Play();

      task.delay(0.12, function()
        if PickerOpen then return; end;
        PickerFrameOuter.Visible = false;
        PickerFrameOuter.Size = PickerSize;
      end);
    end;

    function ColorPicker:SetValue(HSV, Transparency)
      local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

      ColorPicker.Transparency = Transparency or 0;
      ColorPicker:SetHSVFromRGB(Color);
      ColorPicker:Display();
    end;

    function ColorPicker:SetValueRGB(Color, Transparency)
      ColorPicker.Transparency = Transparency or 0;
      ColorPicker:SetHSVFromRGB(Color);
      ColorPicker:Display();
    end;

    SatVibMap.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
          local MinX = SatVibMap.AbsolutePosition.X;
          local MaxX = MinX + SatVibMap.AbsoluteSize.X;
          local MouseX = math.clamp(Mouse.X, MinX, MaxX);

          local MinY = SatVibMap.AbsolutePosition.Y;
          local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
          local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

          ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
          ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
          ColorPicker:Display();

          RenderStepped:Wait();
        end;

        Library:AttemptSave();
      end;
    end);

    HueSelectorInner.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
          local MinY = HueSelectorInner.AbsolutePosition.Y;
          local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
          local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

          ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
          ColorPicker:Display();

          RenderStepped:Wait();
        end;

        Library:AttemptSave();
      end;
    end);

    DisplayFrame.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
        if PickerFrameOuter.Visible then
          ColorPicker:Hide()
        else
          ContextMenu:Hide()
          ColorPicker:Show()
        end;
      elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
        ContextMenu:Show()
        ColorPicker:Hide()
      end
    end);

    if TransparencyBoxInner then
      TransparencyBoxInner.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
          while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
            local MinX = TransparencyBoxInner.AbsolutePosition.X;
            local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
            local MouseX = math.clamp(Mouse.X, MinX, MaxX);

            ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

            ColorPicker:Display();

            RenderStepped:Wait();
          end;

          Library:AttemptSave();
        end;
      end);
    end;

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

        if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
          or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

          ColorPicker:Hide();
        end;

        if not Library:IsMouseOverFrame(ContextMenu.Container) then
          ContextMenu:Hide()
        end
      end;

      if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
        if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
          ContextMenu:Hide()
        end
      end
    end))

    ColorPicker:Display();
    ColorPicker.DisplayFrame = DisplayFrame

    Options[Idx] = ColorPicker;

    return self;
  end;

  function Funcs:AddKeyPicker(Idx, Info)
    local ParentObj = self;
    local ToggleLabel = self.TextLabel;
    local Container = self.Container;

    assert(Info.Default, 'AddKeyPicker: Missing default value.');

    local KeyPicker = {
      Value = Info.Default;
      Toggled = false;
      Mode = Info.Mode or 'Toggle';
      Type = 'KeyPicker';
      Callback = Info.Callback or function(Value) end;
      ChangedCallback = Info.ChangedCallback or function(New) end;

      SyncToggleState = Info.SyncToggleState or false;
    };

    local PickOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(0, 28, 0, 15);
      ZIndex = 6;
      Parent = ToggleLabel;
    });

    local PickInner = Library:Create('Frame', {
      BackgroundColor3 = Library.BackgroundColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 7;
      Parent = PickOuter;
    });

    Library:AddToRegistry(PickInner, {
      BackgroundColor3 = 'BackgroundColor';
      BorderColor3 = 'OutlineColor';
    });

    local DisplayLabel = Library:CreateLabel({
      Size = UDim2.new(1, 0, 1, 0);
      TextSize = 13;
      Text = Info.Default;
      TextWrapped = true;
      ZIndex = 8;
      Parent = PickInner;
    });

    local ModeSize = UDim2.new(0, 60, 0, 47);
    local ModeSelectOuter = Library:Create('Frame', {
      BorderColor3 = Color3.new(0, 0, 0);
      Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
      Size = ModeSize;
      ClipsDescendants = true;
      Visible = false;
      ZIndex = 14;
      Parent = ScreenGui;
    });

    ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
      ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
    end);

    local ModeSelectInner = Library:Create('Frame', {
      BackgroundColor3 = Library.BackgroundColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 15;
      Parent = ModeSelectOuter;
    });

    Library:AddToRegistry(ModeSelectInner, {
      BackgroundColor3 = 'BackgroundColor';
      BorderColor3 = 'OutlineColor';
    });

    Library:Create('UIListLayout', {
      FillDirection = Enum.FillDirection.Vertical;
      SortOrder = Enum.SortOrder.LayoutOrder;
      Parent = ModeSelectInner;
    });

    local ModeTween;
    local ModeOpen = false;
    local CloseModeSelect;

    local function OpenModeSelect()
      Library:ClosePopups(ModeSelectOuter, true)
      ModeOpen = true;
      ModeSelectOuter.Size = UDim2.fromOffset(ModeSize.X.Offset, 0);
      ModeSelectOuter.Visible = true;
      Library.OpenedFrames[ModeSelectOuter] = function(Instant)
        CloseModeSelect(Instant)
      end

      if ModeTween then ModeTween:Cancel(); end;
      ModeTween = TweenService:Create(ModeSelectOuter, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = ModeSize });
      ModeTween:Play();
    end;

    CloseModeSelect = function(Instant)
      ModeOpen = false;
      Library.OpenedFrames[ModeSelectOuter] = nil;
      if ModeTween then ModeTween:Cancel(); end;
      if Instant then
        ModeSelectOuter.Visible = false;
        ModeSelectOuter.Size = ModeSize;
        return;
      end;
      if not ModeSelectOuter.Visible then return; end;

      ModeTween = TweenService:Create(ModeSelectOuter, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(ModeSize.X.Offset, 0)
      });
      ModeTween:Play();

      task.delay(0.1, function()
        if ModeOpen then return; end;
        ModeSelectOuter.Visible = false;
        ModeSelectOuter.Size = ModeSize;
      end);
    end;

    local ContainerLabel = Library:CreateLabel({
      TextXAlignment = Enum.TextXAlignment.Left;
      Size = UDim2.new(1, 0, 0, 18);
      TextSize = 13;
      Visible = false;
      ZIndex = 110;
      Parent = Library.KeybindContainer;
    },  true);

    local Modes = Info.Modes or { 'Toggle', 'Hold', 'Always' };
    local ModeButtons = {};
    KeyPicker.Modes = Modes;

    for Idx, Mode in next, Modes do
      local ModeButton = {};

      local Label = Library:CreateLabel({
        Active = false;
        Size = UDim2.new(1, 0, 0, 15);
        TextSize = 13;
        Text = Mode;
        ZIndex = 16;
        Parent = ModeSelectInner;
      });

      function ModeButton:Select()
        local Changed = KeyPicker.Mode ~= Mode;
        for _, Button in next, ModeButtons do
          Button:Deselect();
        end;

        KeyPicker.Mode = Mode;
        if Changed then KeyPicker.Toggled = false; end;

        Label.TextColor3 = Library.AccentColor;
        Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';
        if KeyPicker.Update then KeyPicker:Update(); end;

        CloseModeSelect();
      end;

      function ModeButton:Deselect()
        KeyPicker.Mode = nil;

        Label.TextColor3 = Library.FontColor;
        Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
      end;

      Label.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
          ModeButton:Select();
          Library:AttemptSave();
        end;
      end);

      if Mode == KeyPicker.Mode then
        ModeButton:Select();
      end;

      ModeButtons[Mode] = ModeButton;
    end;

    local StateTween;
    function KeyPicker:Update()
      if Info.NoUI then
        return;
      end;

      local State = KeyPicker:GetState();
      local Color = State and Library.AccentColor or Library.FontColor;
      local Assigned = KeyPicker.Value ~= nil and KeyPicker.Value ~= '' and KeyPicker.Value ~= 'None';
      local Enabled = KeyPicker:IsEnabled();

      ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);
      ContainerLabel.Visible = Enabled and Assigned and KeyPicker.Mode ~= nil;

      if StateTween then StateTween:Cancel(); end;
      StateTween = TweenService:Create(ContainerLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextColor3 = Color
      });
      StateTween:Play();

      Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

      local YSize = 0
      local XSize = 0

      for _, Label in next, Library.KeybindContainer:GetChildren() do
        if Label:IsA('TextLabel') and Label.Visible then
          YSize = YSize + 18;
          if (Label.TextBounds.X > XSize) then
            XSize = Label.TextBounds.X
          end
        end;
      end;

      Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 27)
    end;

    function KeyPicker:IsEnabled()
      return ParentObj.Type ~= 'Toggle' or ParentObj.Value == true;
    end;

    function KeyPicker:MatchesInput(Input)
      local Key = KeyPicker.Value;
      if Key == nil or Key == 'None' then return false; end;
      if Key == 'MB1' then return Input.UserInputType == Enum.UserInputType.MouseButton1; end;
      if Key == 'MB2' then return Input.UserInputType == Enum.UserInputType.MouseButton2; end;
      return Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Key;
    end;

    function KeyPicker:GetState()
      if not KeyPicker:IsEnabled() then return false; end;
      if KeyPicker.Mode == 'Always' then return true; end;
      return KeyPicker.Toggled;
    end;

    function KeyPicker:SetValue(Data)
      local Key, Mode = Data[1], Data[2];
      DisplayLabel.Text = Key;
      KeyPicker.Value = Key;
      ModeButtons[Mode]:Select();
      KeyPicker:Update();
    end;

    function KeyPicker:OnClick(Callback)
      KeyPicker.Clicked = Callback
    end

    function KeyPicker:OnChanged(Callback)
      KeyPicker.Changed = Callback
      Callback(KeyPicker.Value)
    end

    if ParentObj.Addons then
      table.insert(ParentObj.Addons, KeyPicker)
    end

    function KeyPicker:DoClick()
      if not KeyPicker:IsEnabled() then return; end;
      Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
      Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
    end

    local Picking = false;

    PickOuter.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
        Picking = true;

        DisplayLabel.Text = '';

        local Break;
        local Text = '';

        task.spawn(function()
          while (not Break) do
            if Text == '...' then
              Text = '';
            end;

            Text = Text .. '.';
            DisplayLabel.Text = Text;

            wait(0.4);
          end;
        end);

        wait(0.2);

        local Event;
        Event = InputService.InputBegan:Connect(function(Input)
          local Key;

          if Input.UserInputType == Enum.UserInputType.Keyboard then
            Key = Input.KeyCode.Name;
          elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Key = 'MB1';
          elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
            Key = 'MB2';
          end;

          Break = true;
          Picking = false;

          DisplayLabel.Text = Key;
          KeyPicker.Value = Key;
          KeyPicker:Update();

          Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
          Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

          Library:AttemptSave();

          Event:Disconnect();
        end);
      elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
        OpenModeSelect();
      end;
    end);

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
      if (not Picking) then
        if KeyPicker:IsEnabled() and KeyPicker:MatchesInput(Input) then
          if KeyPicker.Mode == 'Toggle' then
            KeyPicker.Toggled = not KeyPicker.Toggled;
            KeyPicker:DoClick();
          elseif KeyPicker.Mode == 'Hold' then
            KeyPicker.Toggled = true;
            KeyPicker:DoClick();
          end;
        end;

        KeyPicker:Update();
      end;

      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

        if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
          or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

          CloseModeSelect();
        end;
      end;
    end))

    Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
      if (not Picking) then
        if KeyPicker.Mode == 'Hold' and KeyPicker.Toggled and KeyPicker:MatchesInput(Input) then
          KeyPicker.Toggled = false;
          KeyPicker:DoClick();
        end;
        KeyPicker:Update();
      end;
    end))

    KeyPicker:Update();

    Options[Idx] = KeyPicker;

    return self;
  end;

  BaseAddons.__index = Funcs;
  BaseAddons.__namecall = function(Table, Key, ...)
    return Funcs[Key](...);
  end;
end;

local BaseGroupbox = {};

do
  local Funcs = {};

  function Funcs:AddBlank(Size)
    local Groupbox = self;
    local Container = Groupbox.Container;

    Library:Create('Frame', {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 0, Size);
      ZIndex = 1;
      Parent = Container;
    });
  end;

  function Funcs:AddLabel(Text, DoesWrap)
    local Label = {};

    local Groupbox = self;
    local Container = Groupbox.Container;

    local TextLabel = Library:CreateLabel({
      Size = UDim2.new(1, -4, 0, 15);
      TextSize = 14;
      Text = Text;
      TextWrapped = DoesWrap or false,
      TextXAlignment = Enum.TextXAlignment.Left;
      ZIndex = 5;
      Parent = Container;
    });

    if DoesWrap then
      local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
      TextLabel.Size = UDim2.new(1, -4, 0, Y)
    else
      Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Right;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TextLabel;
      });
    end

    Label.TextLabel = TextLabel;
    Label.Container = Container;

    function Label:SetText(Text)
      TextLabel.Text = Text

      if DoesWrap then
        local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
        TextLabel.Size = UDim2.new(1, -4, 0, Y)
      end

      Groupbox:Resize();
    end

    if (not DoesWrap) then
      setmetatable(Label, BaseAddons);
    end

    Groupbox:AddBlank(5);
    Groupbox:Resize();

    return Label;
  end;

  function Funcs:AddButton(...)

    local Button = {};
    local function ProcessButtonParams(Class, Obj, ...)
      local Props = select(1, ...)
      if type(Props) == 'table' then
        Obj.Text = Props.Text
        Obj.Func = Props.Func
        Obj.DoubleClick = Props.DoubleClick
        Obj.Tooltip = Props.Tooltip
      else
        Obj.Text = select(1, ...)
        Obj.Func = select(2, ...)
      end

      assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
    end

    ProcessButtonParams('Button', Button, ...)

    local Groupbox = self;
    local Container = Groupbox.Container;

    local function CreateBaseButton(Button)
      local Outer = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(0, 0, 0);
        BorderColor3 = Color3.new(0, 0, 0);
        Size = UDim2.new(1, -4, 0, 20);
        ZIndex = 5;
      });

      local Inner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 6;
        Parent = Outer;
      });

      local Label = Library:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0);
        TextSize = 14;
        Text = Button.Text;
        ZIndex = 6;
        Parent = Inner;
      });

      Library:Create('UIGradient', {
        Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
        });
        Rotation = 90;
        Parent = Inner;
      });

      Library:AddToRegistry(Outer, {
        BorderColor3 = 'Black';
      });

      Library:AddToRegistry(Inner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
      });

      Library:OnHighlight(Outer, Outer,
        { BorderColor3 = 'AccentColor' },
        { BorderColor3 = 'Black' }
      );

      return Outer, Inner, Label
    end

    local function InitEvents(Button)
      local function WaitForEvent(event, timeout, validator)
        local bindable = Instance.new('BindableEvent')
        local connection = event:Once(function(...)

          if type(validator) == 'function' and validator(...) then
            bindable:Fire(true)
          else
            bindable:Fire(false)
          end
        end)
        task.delay(timeout, function()
          connection:disconnect()
          bindable:Fire(false)
        end)
        return bindable.Event:Wait()
      end

      local function ValidateClick(Input)
        if Library:MouseIsOverOpenedFrame() then
          return false
        end

        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
          return false
        end

        return true
      end

      Button.Outer.InputBegan:Connect(function(Input)
        if not ValidateClick(Input) then return end
        if Button.Locked then return end

        if Button.DoubleClick then
          Library:RemoveFromRegistry(Button.Label)
          Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

          Button.Label.TextColor3 = Library.AccentColor
          Button.Label.Text = 'Are you sure?'
          Button.Locked = true

          local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

          Library:RemoveFromRegistry(Button.Label)
          Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

          Button.Label.TextColor3 = Library.FontColor
          Button.Label.Text = Button.Text
          task.defer(rawset, Button, 'Locked', false)

          if clicked then
            Library:SafeCallback(Button.Func)
          end

          return
        end

        Library:SafeCallback(Button.Func);
      end)
    end

    Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
    Button.Outer.Parent = Container

    InitEvents(Button)

    function Button:AddTooltip(tooltip)
      if type(tooltip) == 'string' then
        Library:AddToolTip(tooltip, self.Outer)
      end
      return self
    end


    function Button:AddButton(...)
      local SubButton = {}

      ProcessButtonParams('SubButton', SubButton, ...)

      self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

      SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

      SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
      SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
      SubButton.Outer.Parent = self.Outer

      function SubButton:AddTooltip(tooltip)
        if type(tooltip) == 'string' then
          Library:AddToolTip(tooltip, self.Outer)
        end
        return SubButton
      end

      if type(SubButton.Tooltip) == 'string' then
        SubButton:AddTooltip(SubButton.Tooltip)
      end

      InitEvents(SubButton)
      return SubButton
    end

    if type(Button.Tooltip) == 'string' then
      Button:AddTooltip(Button.Tooltip)
    end

    Groupbox:AddBlank(5);
    Groupbox:Resize();

    return Button;
  end;

  function Funcs:AddDivider()
    local Groupbox = self;
    local Container = self.Container

    local Divider = {
      Type = 'Divider',
    }

    Groupbox:AddBlank(2);
    local DividerOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(1, -4, 0, 5);
      ZIndex = 5;
      Parent = Container;
    });

    local DividerInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 6;
      Parent = DividerOuter;
    });

    Library:AddToRegistry(DividerOuter, {
      BorderColor3 = 'Black';
    });

    Library:AddToRegistry(DividerInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    Groupbox:AddBlank(9);
    Groupbox:Resize();
  end

  function Funcs:AddInput(Idx, Info)
    assert(Info.Text, 'AddInput: Missing `Text` string.')

    local Textbox = {
      Value = Info.Default or '';
      Numeric = Info.Numeric or false;
      Finished = Info.Finished or false;
      Type = 'Input';
      Callback = Info.Callback or function(Value) end;
    };

    local Groupbox = self;
    local Container = Groupbox.Container;

    local InputLabel = Library:CreateLabel({
      Size = UDim2.new(1, 0, 0, 15);
      TextSize = 14;
      Text = Info.Text;
      TextXAlignment = Enum.TextXAlignment.Left;
      ZIndex = 5;
      Parent = Container;
    });

    Groupbox:AddBlank(1);

    local TextBoxOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(1, -4, 0, 20);
      ZIndex = 5;
      Parent = Container;
    });

    local TextBoxInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 6;
      Parent = TextBoxOuter;
    });

    Library:AddToRegistry(TextBoxInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    Library:OnHighlight(TextBoxOuter, TextBoxOuter,
      { BorderColor3 = 'AccentColor' },
      { BorderColor3 = 'Black' }
    );

    if type(Info.Tooltip) == 'string' then
      Library:AddToolTip(Info.Tooltip, TextBoxOuter)
    end

    Library:Create('UIGradient', {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
      });
      Rotation = 90;
      Parent = TextBoxInner;
    });

    local Container = Library:Create('Frame', {
      BackgroundTransparency = 1;
      ClipsDescendants = true;

      Position = UDim2.new(0, 5, 0, 0);
      Size = UDim2.new(1, -5, 1, 0);

      ZIndex = 7;
      Parent = TextBoxInner;
    })

    local Box = Library:Create('TextBox', {
      BackgroundTransparency = 1;

      Position = UDim2.fromOffset(0, 0),
      Size = UDim2.fromScale(5, 1),

      Font = Library.Font;
      PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
      PlaceholderText = Info.Placeholder or '';

      Text = Info.Default or '';
      TextColor3 = Library.FontColor;
      TextSize = 14;
      TextStrokeTransparency = 0;
      TextXAlignment = Enum.TextXAlignment.Left;

      ZIndex = 7;
      Parent = Container;
    });

    Library:ApplyTextStroke(Box);

    function Textbox:SetValue(Text)
      if Info.MaxLength and #Text > Info.MaxLength then
        Text = Text:sub(1, Info.MaxLength);
      end;

      if Textbox.Numeric then
        if (not tonumber(Text)) and Text:len() > 0 then
          Text = Textbox.Value
        end
      end

      Textbox.Value = Text;
      Box.Text = Text;

      Library:SafeCallback(Textbox.Callback, Textbox.Value);
      Library:SafeCallback(Textbox.Changed, Textbox.Value);
    end;

    if Textbox.Finished then
      Box.FocusLost:Connect(function(enter)
        if not enter then return end

        Textbox:SetValue(Box.Text);
        Library:AttemptSave();
      end)
    else
      Box:GetPropertyChangedSignal('Text'):Connect(function()
        Textbox:SetValue(Box.Text);
        Library:AttemptSave();
      end);
    end




    local function Update()
      local PADDING = 2
      local reveal = Container.AbsoluteSize.X

      if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then

        Box.Position = UDim2.new(0, PADDING, 0, 0)
      else

        local cursor = Box.CursorPosition
        if cursor ~= -1 then

          local subtext = string.sub(Box.Text, 1, cursor-1)
          local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X


          local currentCursorPos = Box.Position.X.Offset + width


          if currentCursorPos < PADDING then
            Box.Position = UDim2.fromOffset(PADDING-width, 0)
          elseif currentCursorPos > reveal - PADDING - 1 then
            Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
          end
        end
      end
    end

    task.spawn(Update)

    Box:GetPropertyChangedSignal('Text'):Connect(Update)
    Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
    Box.FocusLost:Connect(Update)
    Box.Focused:Connect(Update)

    Library:AddToRegistry(Box, {
      TextColor3 = 'FontColor';
    });

    function Textbox:OnChanged(Func)
      Textbox.Changed = Func;
      Func(Textbox.Value);
    end;

    Groupbox:AddBlank(5);
    Groupbox:Resize();

    Options[Idx] = Textbox;

    return Textbox;
  end;

  function Funcs:AddToggle(Idx, Info)
    assert(Info.Text, 'AddInput: Missing `Text` string.')

    local Toggle = {
      Value = Info.Default or false;
      Type = 'Toggle';

      Callback = Info.Callback or function(Value) end;
      Addons = {},
      Risky = Info.Risky,
    };

    local Groupbox = self;
    local Container = Groupbox.Container;

    local ToggleOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(0, 13, 0, 13);
      ZIndex = 5;
      Parent = Container;
    });

    Library:AddToRegistry(ToggleOuter, {
      BorderColor3 = 'Black';
    });

    local ToggleInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 6;
      Parent = ToggleOuter;
    });

    Library:AddToRegistry(ToggleInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    local ToggleLabel = Library:CreateLabel({
      Size = UDim2.new(0, 216, 1, 0);
      Position = UDim2.new(1, 6, 0, 0);
      TextSize = 14;
      Text = Info.Text;
      TextXAlignment = Enum.TextXAlignment.Left;
      ZIndex = 6;
      Parent = ToggleInner;
    });

    Library:Create('UIListLayout', {
      Padding = UDim.new(0, 4);
      FillDirection = Enum.FillDirection.Horizontal;
      HorizontalAlignment = Enum.HorizontalAlignment.Right;
      SortOrder = Enum.SortOrder.LayoutOrder;
      Parent = ToggleLabel;
    });

    local ToggleRegion = Library:Create('Frame', {
      BackgroundTransparency = 1;
      Size = UDim2.new(0, 170, 1, 0);
      ZIndex = 8;
      Parent = ToggleOuter;
    });

    Library:OnHighlight(ToggleRegion, ToggleOuter,
      { BorderColor3 = 'AccentColor' },
      { BorderColor3 = 'Black' }
    );

    function Toggle:UpdateColors()
      Toggle:Display();
    end;

    if type(Info.Tooltip) == 'string' then
      Library:AddToolTip(Info.Tooltip, ToggleRegion)
    end

    local DisplayTween;
    function Toggle:Display(Instant)
      local Background = Toggle.Value and Library.AccentColor or Library.MainColor;
      local Border = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

      if DisplayTween then
        DisplayTween:Cancel();
      end;

      if Instant then
        ToggleInner.BackgroundColor3 = Background;
        ToggleInner.BorderColor3 = Border;
      else
        DisplayTween = TweenService:Create(ToggleInner, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
          BackgroundColor3 = Background;
          BorderColor3 = Border;
        });
        DisplayTween:Play();
      end;

      Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
      Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
    end;

    function Toggle:OnChanged(Func)
      Toggle.Changed = Func;
      Func(Toggle.Value);
    end;

    function Toggle:SetValue(Bool)
      Bool = (not not Bool);

      Toggle.Value = Bool;
      Toggle:Display();

      for _, Addon in next, Toggle.Addons do
        if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
          if not Bool then Addon.Toggled = false; end;
          Addon:Update()
        end
      end

      Library:SafeCallback(Toggle.Callback, Toggle.Value);
      Library:SafeCallback(Toggle.Changed, Toggle.Value);
      Library:UpdateDependencyBoxes();
    end;

    ToggleRegion.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
        Toggle:SetValue(not Toggle.Value)
        Library:AttemptSave();
      end;
    end);

    if Toggle.Risky then
      Library:RemoveFromRegistry(ToggleLabel)
      ToggleLabel.TextColor3 = Library.RiskColor
      Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
    end

    Toggle:Display(true);
    Groupbox:AddBlank(Info.BlankSize or 5 + 2);
    Groupbox:Resize();

    Toggle.TextLabel = ToggleLabel;
    Toggle.Container = Container;
    setmetatable(Toggle, BaseAddons);

    Toggles[Idx] = Toggle;

    Library:UpdateDependencyBoxes();

    return Toggle;
  end;

  function Funcs:AddSlider(Idx, Info)
    assert(Info.Default ~= nil, 'AddSlider: Missing default value.');
    assert(Info.Text, 'AddSlider: Missing slider text.');
    assert(Info.Min, 'AddSlider: Missing minimum value.');
    assert(Info.Max, 'AddSlider: Missing maximum value.');
    assert(Info.Rounding ~= nil, 'AddSlider: Missing rounding value.');

    local Slider = {
      Value = Info.Default;
      Min = Info.Min;
      Max = Info.Max;
      Rounding = Info.Rounding;
      MaxSize = 232;
      Type = 'Slider';
      Callback = Info.Callback or function(Value) end;
    };

    local Groupbox = self;
    local Container = Groupbox.Container;

    if not Info.Compact then
      Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 10);
        TextSize = 14;
        Text = Info.Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Bottom;
        ZIndex = 5;
        Parent = Container;
      });

      Groupbox:AddBlank(3);
    end

    local SliderOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(1, -4, 0, 13);
      ZIndex = 5;
      Parent = Container;
    });

    Library:AddToRegistry(SliderOuter, {
      BorderColor3 = 'Black';
    });

    local SliderInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 6;
      Parent = SliderOuter;
    });

    Library:AddToRegistry(SliderInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    local Fill = Library:Create('Frame', {
      BackgroundColor3 = Library.AccentColor;
      BorderColor3 = Library.AccentColorDark;
      Size = UDim2.new(0, 0, 1, 0);
      ZIndex = 7;
      Parent = SliderInner;
    });

    Library:AddToRegistry(Fill, {
      BackgroundColor3 = 'AccentColor';
      BorderColor3 = 'AccentColorDark';
    });

    local HideBorderRight = Library:Create('Frame', {
      BackgroundColor3 = Library.AccentColor;
      BorderSizePixel = 0;
      Position = UDim2.new(1, 0, 0, 0);
      Size = UDim2.new(0, 1, 1, 0);
      ZIndex = 8;
      Parent = Fill;
    });

    Library:AddToRegistry(HideBorderRight, {
      BackgroundColor3 = 'AccentColor';
    });

    local DisplayLabel = Library:CreateLabel({
      Size = UDim2.new(1, 0, 1, 0);
      TextSize = 14;
      Text = 'Infinite';
      ZIndex = 9;
      Parent = SliderInner;
    });

    Library:OnHighlight(SliderOuter, SliderOuter,
      { BorderColor3 = 'AccentColor' },
      { BorderColor3 = 'Black' }
    );

    if type(Info.Tooltip) == 'string' then
      Library:AddToolTip(Info.Tooltip, SliderOuter)
    end

    function Slider:UpdateColors()
      Fill.BackgroundColor3 = Library.AccentColor;
      Fill.BorderColor3 = Library.AccentColorDark;
    end;

    local FillTween;
    function Slider:Display(Instant)
      local Suffix = Info.Suffix or '';

      if Info.Compact then
        DisplayLabel.Text = Info.Text .. ': ' .. Slider.Value .. Suffix
      elseif Info.HideMax then
        DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
      else
        DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);
      end

      local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
      local Size = UDim2.new(0, X, 1, 0);

      if FillTween then
        FillTween:Cancel();
      end;

      if Instant then
        Fill.Size = Size;
      else
        FillTween = TweenService:Create(Fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Size });
        FillTween:Play();
      end;

      HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
    end;

    function Slider:OnChanged(Func)
      Slider.Changed = Func;
      Func(Slider.Value);
    end;

    local function Round(Value)
      local Precision = tonumber(Slider.Rounding) or 0;
      if Precision % 1 ~= 0 then
        local Fraction = tostring(Precision):match('%.(%d+)');
        Precision = Fraction and #Fraction or 0;
      end;
      Precision = math.clamp(math.floor(Precision), 0, 6);
      if Precision == 0 then
        return math.floor(Value);
      end;
      return tonumber(string.format('%.' .. Precision .. 'f', Value))
    end;

    function Slider:GetValueFromXOffset(X)
      return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
    end;

    function Slider:SetValue(Str)
      local Num = tonumber(Str);

      if (not Num) then
        return;
      end;

      Num = math.clamp(Num, Slider.Min, Slider.Max);

      Slider.Value = Num;
      Slider:Display();

      Library:SafeCallback(Slider.Callback, Slider.Value);
      Library:SafeCallback(Slider.Changed, Slider.Value);
    end;

    SliderInner.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
        local mPos = Mouse.X;
        local gPos = Fill.Size.X.Offset;
        local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
          local nMPos = Mouse.X;
          local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

          local nValue = Slider:GetValueFromXOffset(nX);
          local OldValue = Slider.Value;
          Slider.Value = nValue;

          Slider:Display();

          if nValue ~= OldValue then
            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
          end;

          RenderStepped:Wait();
        end;

        Library:AttemptSave();
      end;
    end);

    Slider:Display(true);
    Groupbox:AddBlank(Info.BlankSize or 6);
    Groupbox:Resize();

    Options[Idx] = Slider;

    return Slider;
  end;

  function Funcs:AddDropdown(Idx, Info)
    if Info.SpecialType == 'Player' then
      Info.Values = GetPlayersString();
      Info.AllowNull = true;
    elseif Info.SpecialType == 'Team' then
      Info.Values = GetTeamsString();
      Info.AllowNull = true;
    end;

    assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
    assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

    if (not Info.Text) then
      Info.Compact = true;
    end;

    local Dropdown = {
      Values = Info.Values;
      Value = Info.Multi and {};
      Multi = Info.Multi;
      Type = 'Dropdown';
      SpecialType = Info.SpecialType;
      Open = false;
      Callback = Info.Callback or function(Value) end;
    };

    local Groupbox = self;
    local Container = Groupbox.Container;

    local RelativeOffset = 0;

    if not Info.Compact then
      local DropdownLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 10);
        TextSize = 14;
        Text = Info.Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextYAlignment = Enum.TextYAlignment.Bottom;
        ZIndex = 5;
        Parent = Container;
      });

      Groupbox:AddBlank(3);
    end

    for _, Element in next, Container:GetChildren() do
      if not Element:IsA('UIListLayout') then
        RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
      end;
    end;

    local DropdownOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      Size = UDim2.new(1, -4, 0, 20);
      ZIndex = 5;
      Parent = Container;
    });

    Library:AddToRegistry(DropdownOuter, {
      BorderColor3 = 'Black';
    });

    local DropdownInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 6;
      Parent = DropdownOuter;
    });

    Library:AddToRegistry(DropdownInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    Library:Create('UIGradient', {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
      });
      Rotation = 90;
      Parent = DropdownInner;
    });

    local DropdownArrow = Library:Create('ImageLabel', {
      AnchorPoint = Vector2.new(0, 0.5);
      BackgroundTransparency = 1;
      Position = UDim2.new(1, -16, 0.5, 0);
      Size = UDim2.new(0, 12, 0, 12);
      Image = 'http://www.roblox.com/asset/?id=6282522798';
      ZIndex = 8;
      Parent = DropdownInner;
    });

    local ItemList = Library:CreateLabel({
      Position = UDim2.new(0, 5, 0, 0);
      Size = UDim2.new(1, -5, 1, 0);
      TextSize = 14;
      Text = '--';
      TextXAlignment = Enum.TextXAlignment.Left;
      TextWrapped = true;
      ZIndex = 7;
      Parent = DropdownInner;
    });

    Library:OnHighlight(DropdownOuter, DropdownOuter,
      { BorderColor3 = 'AccentColor' },
      { BorderColor3 = 'Black' }
    );

    if type(Info.Tooltip) == 'string' then
      Library:AddToolTip(Info.Tooltip, DropdownOuter)
    end

    local MAX_DROPDOWN_ITEMS = 8;

    local ListOuter = Library:Create('Frame', {
      BackgroundColor3 = Color3.new(0, 0, 0);
      BorderColor3 = Color3.new(0, 0, 0);
      ClipsDescendants = true;
      ZIndex = 20;
      Visible = false;
      Parent = ScreenGui;
    });

    local function RecalculateListPosition()
      ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
    end;

    local ListHeight = MAX_DROPDOWN_ITEMS * 20 + 2;
    local ListTween;
    local ArrowTween;

    local function RecalculateListSize(YSize)
      ListHeight = YSize or ListHeight;
      local Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight);

      if Dropdown.Open then
        if ListTween then ListTween:Cancel(); end;
        ListTween = TweenService:Create(ListOuter, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = Size });
        ListTween:Play();
      else
        ListOuter.Size = Size;
      end;
    end;

    RecalculateListPosition();
    RecalculateListSize();

    DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

    local ListInner = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderColor3 = Library.OutlineColor;
      BorderMode = Enum.BorderMode.Inset;
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 21;
      Parent = ListOuter;
    });

    Library:AddToRegistry(ListInner, {
      BackgroundColor3 = 'MainColor';
      BorderColor3 = 'OutlineColor';
    });

    local Scrolling = Library:Create('ScrollingFrame', {
      BackgroundTransparency = 1;
      BorderSizePixel = 0;
      CanvasSize = UDim2.new(0, 0, 0, 0);
      Size = UDim2.new(1, 0, 1, 0);
      ZIndex = 21;
      Parent = ListInner;

      TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
      BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

      ScrollBarThickness = 3,
      ScrollBarImageColor3 = Library.AccentColor,
    });

    Library:AddToRegistry(Scrolling, {
      ScrollBarImageColor3 = 'AccentColor'
    })

    Library:Create('UIListLayout', {
      Padding = UDim.new(0, 0);
      FillDirection = Enum.FillDirection.Vertical;
      SortOrder = Enum.SortOrder.LayoutOrder;
      Parent = Scrolling;
    });

    function Dropdown:Display()
      local Values = Dropdown.Values;
      local Str = '';

      if Info.Multi then
        for Idx, Value in next, Values do
          if Dropdown.Value[Value] then
            Str = Str .. Value .. ', ';
          end;
        end;

        Str = Str:sub(1, #Str - 2);
      else
        Str = Dropdown.Value or '';
      end;

      ItemList.Text = (Str == '' and '--' or Str);
    end;

    function Dropdown:GetActiveValues()
      if Info.Multi then
        local T = {};

        for Value, Bool in next, Dropdown.Value do
          table.insert(T, Value);
        end;

        return T;
      else
        return Dropdown.Value and 1 or 0;
      end;
    end;

    function Dropdown:BuildDropdownList()
      local Values = Dropdown.Values;
      local Buttons = {};

      for _, Element in next, Scrolling:GetChildren() do
        if not Element:IsA('UIListLayout') then
          Element:Destroy();
        end;
      end;

      local Count = 0;

      for Idx, Value in next, Values do
        local Table = {};

        Count = Count + 1;

        local Button = Library:Create('Frame', {
          BackgroundColor3 = Library.MainColor;
          BorderColor3 = Library.OutlineColor;
          BorderMode = Enum.BorderMode.Middle;
          Size = UDim2.new(1, -1, 0, 20);
          ZIndex = 23;
          Active = true,
          Parent = Scrolling;
        });

        Library:AddToRegistry(Button, {
          BackgroundColor3 = 'MainColor';
          BorderColor3 = 'OutlineColor';
        });

        local ButtonLabel = Library:CreateLabel({
          Active = false;
          Size = UDim2.new(1, -6, 1, 0);
          Position = UDim2.new(0, 6, 0, 0);
          TextSize = 14;
          Text = Value;
          TextXAlignment = Enum.TextXAlignment.Left;
          ZIndex = 25;
          Parent = Button;
        });

        Library:OnHighlight(Button, Button,
          { BorderColor3 = 'AccentColor', ZIndex = 24 },
          { BorderColor3 = 'OutlineColor', ZIndex = 23 }
        );

        local Selected;

        if Info.Multi then
          Selected = Dropdown.Value[Value];
        else
          Selected = Dropdown.Value == Value;
        end;

        function Table:UpdateButton()
          if Info.Multi then
            Selected = Dropdown.Value[Value];
          else
            Selected = Dropdown.Value == Value;
          end;

          ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
          Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
        end;

        ButtonLabel.InputBegan:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local Try = not Selected;

            if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
            else
              if Info.Multi then
                Selected = Try;

                if Selected then
                  Dropdown.Value[Value] = true;
                else
                  Dropdown.Value[Value] = nil;
                end;
              else
                Selected = Try;

                if Selected then
                  Dropdown.Value = Value;
                else
                  Dropdown.Value = nil;
                end;

                for _, OtherButton in next, Buttons do
                  OtherButton:UpdateButton();
                end;
              end;

              Table:UpdateButton();
              Dropdown:Display();

              Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
              Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

              Library:AttemptSave();
            end;
          end;
        end);

        Table:UpdateButton();
        Dropdown:Display();

        Buttons[Button] = Table;
      end;

      Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

      local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
      RecalculateListSize(Y);
    end;

    function Dropdown:SetValues(NewValues)
      if NewValues then
        Dropdown.Values = NewValues;
      end;

      Dropdown:BuildDropdownList();
    end;

    function Dropdown:OpenDropdown()
      Library:ClosePopups(ListOuter, true)
      Dropdown.Open = true;
      ListOuter.Visible = true;
      ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, 0);
      Library.OpenedFrames[ListOuter] = function(Instant)
        Dropdown:CloseDropdown(Instant)
      end;

      if ListTween then ListTween:Cancel(); end;
      if ArrowTween then ArrowTween:Cancel(); end;

      ListTween = TweenService:Create(ListOuter, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight)
      });
      ArrowTween = TweenService:Create(DropdownArrow, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Rotation = 180
      });
      ListTween:Play();
      ArrowTween:Play();
    end;

    function Dropdown:CloseDropdown(Instant)
      Dropdown.Open = false;
      Library.OpenedFrames[ListOuter] = nil;

      if ListTween then ListTween:Cancel(); end;
      if ArrowTween then ArrowTween:Cancel(); end;
      if Instant then
        ListOuter.Visible = false;
        ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight);
        DropdownArrow.Rotation = 0;
        return;
      end;
      if not ListOuter.Visible then return; end;

      ListTween = TweenService:Create(ListOuter, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, 0)
      });
      ArrowTween = TweenService:Create(DropdownArrow, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Rotation = 0
      });
      ListTween:Play();
      ArrowTween:Play();

      task.delay(0.12, function()
        if Dropdown.Open then return; end;
        ListOuter.Visible = false;
        ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, ListHeight);
      end);
    end;

    function Dropdown:OnChanged(Func)
      Dropdown.Changed = Func;
      Func(Dropdown.Value);
    end;

    function Dropdown:SetValue(Val)
      if Dropdown.Multi then
        local nTable = {};

        for Value, Bool in next, Val do
          if table.find(Dropdown.Values, Value) then
            nTable[Value] = true
          end;
        end;

        Dropdown.Value = nTable;
      else
        if (not Val) then
          Dropdown.Value = nil;
        elseif table.find(Dropdown.Values, Val) then
          Dropdown.Value = Val;
        end;
      end;

      Dropdown:BuildDropdownList();

      Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
      Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
    end;

    DropdownOuter.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
        if ListOuter.Visible then
          Dropdown:CloseDropdown();
        else
          Dropdown:OpenDropdown();
        end;
      end;
    end);

    InputService.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

        if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
          or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

          Dropdown:CloseDropdown();
        end;
      end;
    end);

    Dropdown:BuildDropdownList();
    Dropdown:Display();

    local Defaults = {}

    if type(Info.Default) == 'string' then
      local Idx = table.find(Dropdown.Values, Info.Default)
      if Idx then
        table.insert(Defaults, Idx)
      end
    elseif type(Info.Default) == 'table' then
      for _, Value in next, Info.Default do
        local Idx = table.find(Dropdown.Values, Value)
        if Idx then
          table.insert(Defaults, Idx)
        end
      end
    elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
      table.insert(Defaults, Info.Default)
    end

    if next(Defaults) then
      for i = 1, #Defaults do
        local Index = Defaults[i]
        if Info.Multi then
          Dropdown.Value[Dropdown.Values[Index]] = true
        else
          Dropdown.Value = Dropdown.Values[Index];
        end

        if (not Info.Multi) then break end
      end

      Dropdown:BuildDropdownList();
      Dropdown:Display();
    end

    Groupbox:AddBlank(Info.BlankSize or 5);
    Groupbox:Resize();

    Options[Idx] = Dropdown;

    return Dropdown;
  end;

  function Funcs:AddDependencyBox()
    local Depbox = {
      Dependencies = {};
    };

    local Groupbox = self;
    local Container = Groupbox.Container;

    local Holder = Library:Create('Frame', {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 0, 0);
      Visible = false;
      Parent = Container;
    });

    local Frame = Library:Create('Frame', {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 1, 0);
      Visible = true;
      Parent = Holder;
    });

    local Layout = Library:Create('UIListLayout', {
      FillDirection = Enum.FillDirection.Vertical;
      SortOrder = Enum.SortOrder.LayoutOrder;
      Parent = Frame;
    });

    function Depbox:Resize()
      Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
      Groupbox:Resize();
    end;

    Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
      Depbox:Resize();
    end);

    Holder:GetPropertyChangedSignal('Visible'):Connect(function()
      Depbox:Resize();
    end);

    function Depbox:Update()
      for _, Dependency in next, Depbox.Dependencies do
        local Elem = Dependency[1];
        local Value = Dependency[2];

        if Elem.Type == 'Toggle' and Elem.Value ~= Value then
          Holder.Visible = false;
          Depbox:Resize();
          return;
        end;
      end;

      Holder.Visible = true;
      Depbox:Resize();
    end;

    function Depbox:SetupDependencies(Dependencies)
      for _, Dependency in next, Dependencies do
        assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
        assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
        assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
      end;

      Depbox.Dependencies = Dependencies;
      Depbox:Update();
    end;

    Depbox.Container = Frame;

    setmetatable(Depbox, BaseGroupbox);

    table.insert(Library.DependencyBoxes, Depbox);

    return Depbox;
  end;

  BaseGroupbox.__index = Funcs;
  BaseGroupbox.__namecall = function(Table, Key, ...)
    return Funcs[Key](...);
  end;
end;


do
  Library.NotificationArea = Library:Create('Frame', {
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 0, 0, 40);
    Size = UDim2.new(0, 300, 0, 200);
    ZIndex = 100;
    Parent = ScreenGui;
  });

  Library:Create('UIListLayout', {
    Padding = UDim.new(0, 4);
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = Library.NotificationArea;
  });

  local WatermarkOuter = Library:Create('Frame', {
    BackgroundColor3 = Color3.new(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.new(0, 12, 0, 12);
    Size = UDim2.new(0, 260, 0, 22);
    ZIndex = 200;
    Visible = false;
    Parent = ScreenGui;
  });

  local WatermarkInner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.OutlineColor;
    BorderMode = Enum.BorderMode.Inset;
    Position = UDim2.new(0, 1, 0, 1);
    Size = UDim2.new(1, -2, 1, -2);
    ZIndex = 201;
    Parent = WatermarkOuter;
  });

  Library:AddToRegistry(WatermarkInner, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
  });

  local Gradient = Library:Create('UIGradient', {
    Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
      ColorSequenceKeypoint.new(1, Color3.fromRGB(218, 218, 218)),
    });
    Rotation = 90;
    Parent = WatermarkInner;
  });

  local WatermarkAccent = Library:Create('Frame', {
    BackgroundColor3 = Library.AccentColor;
    BorderSizePixel = 0;
    Size = UDim2.new(1, 0, 0, 1);
    ZIndex = 203;
    Parent = WatermarkInner;
  });

  Library:AddToRegistry(WatermarkAccent, {
    BackgroundColor3 = 'AccentColor';
  });

  local WatermarkLabel = Library:CreateLabel({
    Position = UDim2.new(0, 6, 0, 1);
    Size = UDim2.new(1, -12, 1, -1);
    TextSize = 13;
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 204;
    Parent = WatermarkInner;
  });

  Library.Watermark = WatermarkOuter;
  Library.WatermarkText = WatermarkLabel;
  Library:MakeDraggable(Library.Watermark);



  local KeybindOuter = Library:Create('Frame', {
    AnchorPoint = Vector2.new(0, 0.5);
    BorderColor3 = Color3.new(0, 0, 0);
    Position = UDim2.new(0, 10, 0.5, 0);
    Size = UDim2.new(0, 210, 0, 27);
    Visible = false;
    ZIndex = 100;
    Parent = ScreenGui;
  });

  local KeybindInner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.OutlineColor;
    BorderMode = Enum.BorderMode.Inset;
    Size = UDim2.new(1, 0, 1, 0);
    ZIndex = 101;
    Parent = KeybindOuter;
  });

  Library:AddToRegistry(KeybindInner, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
  }, true);

  local ColorFrame = Library:Create('Frame', {
    BackgroundColor3 = Library.AccentColor;
    BorderSizePixel = 0;
    Size = UDim2.new(1, 0, 0, 1);
    ZIndex = 102;
    Parent = KeybindInner;
  });

  Library:AddToRegistry(ColorFrame, {
    BackgroundColor3 = 'AccentColor';
  }, true);

  local KeybindLabel = Library:CreateLabel({
    Size = UDim2.new(1, -8, 0, 18);
    Position = UDim2.new(0, 4, 0, 3);
    TextSize = 14;
    TextXAlignment = Enum.TextXAlignment.Center;
    Text = 'keybinds';
    ZIndex = 104;
    Parent = KeybindInner;
  });

  local KeybindDivider = Library:Create('Frame', {
    BackgroundColor3 = Library.OutlineColor;
    BorderSizePixel = 0;
    Size = UDim2.new(1, -2, 0, 1);
    Position = UDim2.new(0, 1, 0, 23);
    ZIndex = 103;
    Parent = KeybindInner;
  });

  Library:AddToRegistry(KeybindDivider, {
    BackgroundColor3 = 'OutlineColor';
  }, true);

  local KeybindContainer = Library:Create('Frame', {
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 1, -25);
    Position = UDim2.new(0, 0, 0, 25);
    ZIndex = 1;
    Parent = KeybindInner;
  });

  Library:Create('UIListLayout', {
    FillDirection = Enum.FillDirection.Vertical;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = KeybindContainer;
  });

  Library:Create('UIPadding', {
    PaddingLeft = UDim.new(0, 5),
    Parent = KeybindContainer,
  })

  Library.KeybindFrame = KeybindOuter;
  Library.KeybindContainer = KeybindContainer;
  Library:MakeDraggable(KeybindOuter);
end;

function Library:SetWatermarkVisibility(Bool)
  Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
  local X = Library:GetTextBounds(Text, Library.Font, 13);
  Library.Watermark.Size = UDim2.new(0, X + 16, 0, 22);
  Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
  local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

  YSize = YSize + 7

  local NotifyOuter = Library:Create('Frame', {
    BorderColor3 = Color3.new(0, 0, 0);
    Position = UDim2.new(0, 100, 0, 10);
    Size = UDim2.new(0, 0, 0, YSize);
    ClipsDescendants = true;
    ZIndex = 100;
    Parent = Library.NotificationArea;
  });

  local NotifyInner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.OutlineColor;
    BorderMode = Enum.BorderMode.Inset;
    Size = UDim2.new(1, 0, 1, 0);
    ZIndex = 101;
    Parent = NotifyOuter;
  });

  Library:AddToRegistry(NotifyInner, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
  }, true);

  local InnerFrame = Library:Create('Frame', {
    BackgroundColor3 = Color3.new(1, 1, 1);
    BorderSizePixel = 0;
    Position = UDim2.new(0, 1, 0, 1);
    Size = UDim2.new(1, -2, 1, -2);
    ZIndex = 102;
    Parent = NotifyInner;
  });

  local Gradient = Library:Create('UIGradient', {
    Color = ColorSequence.new({
      ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
      ColorSequenceKeypoint.new(1, Library.MainColor),
    });
    Rotation = -90;
    Parent = InnerFrame;
  });

  Library:AddToRegistry(Gradient, {
    Color = function()
      return ColorSequence.new({
        ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
        ColorSequenceKeypoint.new(1, Library.MainColor),
      });
    end
  });

  local NotifyLabel = Library:CreateLabel({
    Position = UDim2.new(0, 4, 0, 0);
    Size = UDim2.new(1, -4, 1, 0);
    Text = Text;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextSize = 14;
    ZIndex = 103;
    Parent = InnerFrame;
  });

  local LeftColor = Library:Create('Frame', {
    BackgroundColor3 = Library.AccentColor;
    BorderSizePixel = 0;
    Position = UDim2.new(0, -1, 0, -1);
    Size = UDim2.new(0, 3, 1, 2);
    ZIndex = 104;
    Parent = NotifyOuter;
  });

  Library:AddToRegistry(LeftColor, {
    BackgroundColor3 = 'AccentColor';
  }, true);

  pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

  task.spawn(function()
    wait(Time or 5);

    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

    wait(0.4);

    NotifyOuter:Destroy();
  end);
end;

function Library:CreateWindow(...)
  local Arguments = { ... }
  local Config = { AnchorPoint = Vector2.zero }

  if type(...) == 'table' then
    Config = ...;
  else
    Config.Title = Arguments[1]
    Config.AutoShow = Arguments[2] or false;
  end

  if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
  if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
  if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

  if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
  if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end

  if Config.Center then
    Config.AnchorPoint = Vector2.new(0.5, 0.5)
    Config.Position = UDim2.fromScale(0.5, 0.5)
  end

  local Window = {
    Tabs = {};
  };

  local Outer = Library:Create('Frame', {
    AnchorPoint = Config.AnchorPoint,
    BackgroundColor3 = Color3.new(0, 0, 0);
    BorderSizePixel = 0;
    Position = Config.Position,
    Size = Config.Size,
    Visible = false;
    ZIndex = 1;
    Parent = ScreenGui;
  });

  Library:MakeDraggable(Outer, 25);

  local Inner = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.AccentColor;
    BorderMode = Enum.BorderMode.Inset;
    Position = UDim2.new(0, 1, 0, 1);
    Size = UDim2.new(1, -2, 1, -2);
    ZIndex = 1;
    Parent = Outer;
  });

  Library:AddToRegistry(Inner, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'AccentColor';
  });

  local WindowLabel = Library:CreateLabel({
    Position = UDim2.new(0, 7, 0, 0);
    Size = UDim2.new(0, 0, 0, 25);
    Text = Config.Title or '';
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 1;
    Parent = Inner;
  });

  local MainSectionOuter = Library:Create('Frame', {
    BackgroundColor3 = Library.BackgroundColor;
    BorderColor3 = Library.OutlineColor;
    Position = UDim2.new(0, 8, 0, 25);
    Size = UDim2.new(1, -16, 1, -33);
    ZIndex = 1;
    Parent = Inner;
  });

  Library:AddToRegistry(MainSectionOuter, {
    BackgroundColor3 = 'BackgroundColor';
    BorderColor3 = 'OutlineColor';
  });

  local MainSectionInner = Library:Create('Frame', {
    BackgroundColor3 = Library.BackgroundColor;
    BorderColor3 = Color3.new(0, 0, 0);
    BorderMode = Enum.BorderMode.Inset;
    Position = UDim2.new(0, 0, 0, 0);
    Size = UDim2.new(1, 0, 1, 0);
    ZIndex = 1;
    Parent = MainSectionOuter;
  });

  Library:AddToRegistry(MainSectionInner, {
    BackgroundColor3 = 'BackgroundColor';
  });

  local TabArea = Library:Create('Frame', {
    BackgroundTransparency = 1;
    Position = UDim2.new(0, 8, 0, 8);
    Size = UDim2.new(1, -16, 0, 21);
    ZIndex = 1;
    Parent = MainSectionInner;
  });

  local TabListLayout = Library:Create('UIListLayout', {
    Padding = UDim.new(0, Config.TabPadding);
    FillDirection = Enum.FillDirection.Horizontal;
    SortOrder = Enum.SortOrder.LayoutOrder;
    Parent = TabArea;
  });

  local TabContainer = Library:Create('Frame', {
    BackgroundColor3 = Library.MainColor;
    BorderColor3 = Library.OutlineColor;
    Position = UDim2.new(0, 8, 0, 30);
    Size = UDim2.new(1, -16, 1, -38);
    ZIndex = 2;
    Parent = MainSectionInner;
  });


  Library:AddToRegistry(TabContainer, {
    BackgroundColor3 = 'MainColor';
    BorderColor3 = 'OutlineColor';
  });

  local TransitionCache = {};
  local TransitionPositions = {};
  local TransitionTweens = {};

  local function AnimateContainer(Container)
    local Position = TransitionPositions[Container];
    if not Position then
      Position = Container.Position;
      TransitionPositions[Container] = Position;
    end;

    local PositionTween = TransitionTweens[Container];
    if PositionTween then PositionTween:Cancel(); end;

    Container.Position = UDim2.new(Position.X.Scale, Position.X.Offset + 4, Position.Y.Scale, Position.Y.Offset);
    PositionTween = TweenService:Create(Container, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
      Position = Position
    });
    TransitionTweens[Container] = PositionTween;
    PositionTween:Play();

    for _, Desc in next, Container:GetDescendants() do
      local Properties = {};

      if Desc:IsA('ImageLabel') then
        table.insert(Properties, 'ImageTransparency');
        table.insert(Properties, 'BackgroundTransparency');
      elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
        table.insert(Properties, 'TextTransparency');
      elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
        table.insert(Properties, 'BackgroundTransparency');
      elseif Desc:IsA('UIStroke') then
        table.insert(Properties, 'Transparency');
      end;

      if #Properties > 0 then
        local Cache = TransitionCache[Desc];
        if not Cache then
          Cache = {};
          TransitionCache[Desc] = Cache;
        end;

        local Goals = {};
        for _, Property in next, Properties do
          if Cache[Property] == nil then
            Cache[Property] = Desc[Property] or 0;
          end;
          Desc[Property] = 1;
          Goals[Property] = Cache[Property];
        end;

        local Tween = TransitionTweens[Desc];
        if Tween then Tween:Cancel(); end;
        Tween = TweenService:Create(Desc, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), Goals);
        TransitionTweens[Desc] = Tween;
        Tween:Play();
      end;
    end;
  end;

  function Window:SetWindowTitle(Title)
    WindowLabel.Text = Title;
  end;

  function Window:AddTab(Name)
    local Tab = {
      Groupboxes = {};
      Tabboxes = {};
    };

    local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16);

    local TabButton = Library:Create('Frame', {
      BackgroundColor3 = Library.BackgroundColor;
      BorderColor3 = Library.OutlineColor;
      Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
      ZIndex = 1;
      Parent = TabArea;
    });

    Library:AddToRegistry(TabButton, {
      BackgroundColor3 = 'BackgroundColor';
      BorderColor3 = 'OutlineColor';
    });

    local TabButtonLabel = Library:CreateLabel({
      Position = UDim2.new(0, 0, 0, 0);
      Size = UDim2.new(1, 0, 1, -1);
      Text = Name;
      ZIndex = 1;
      Parent = TabButton;
    });

    local Blocker = Library:Create('Frame', {
      BackgroundColor3 = Library.MainColor;
      BorderSizePixel = 0;
      Position = UDim2.new(0, 0, 1, 0);
      Size = UDim2.new(1, 0, 0, 1);
      BackgroundTransparency = 1;
      ZIndex = 3;
      Parent = TabButton;
    });

    Library:AddToRegistry(Blocker, {
      BackgroundColor3 = 'MainColor';
    });

    local TabFrame = Library:Create('Frame', {
      Name = 'TabFrame',
      BackgroundTransparency = 1;
      Position = UDim2.new(0, 0, 0, 0);
      Size = UDim2.new(1, 0, 1, 0);
      Visible = false;
      ZIndex = 2;
      Parent = TabContainer;
    });

    local LeftSide = Library:Create('ScrollingFrame', {
      BackgroundTransparency = 1;
      BorderSizePixel = 0;
      Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
      Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
      CanvasSize = UDim2.new(0, 0, 0, 0);
      BottomImage = '';
      TopImage = '';
      ScrollBarThickness = 0;
      ZIndex = 2;
      Parent = TabFrame;
    });

    local RightSide = Library:Create('ScrollingFrame', {
      BackgroundTransparency = 1;
      BorderSizePixel = 0;
      Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
      Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
      CanvasSize = UDim2.new(0, 0, 0, 0);
      BottomImage = '';
      TopImage = '';
      ScrollBarThickness = 0;
      ZIndex = 2;
      Parent = TabFrame;
    });

    Library:Create('UIListLayout', {
      Padding = UDim.new(0, 8);
      FillDirection = Enum.FillDirection.Vertical;
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      Parent = LeftSide;
    });

    Library:Create('UIListLayout', {
      Padding = UDim.new(0, 8);
      FillDirection = Enum.FillDirection.Vertical;
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      Parent = RightSide;
    });

    for _, Side in next, { LeftSide, RightSide } do
      Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
      end);
    end;

    function Tab:ShowTab()
      for _, Tab in next, Window.Tabs do
        Tab:HideTab();
      end;

      TabFrame.Visible = true;
      Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
      TweenService:Create(Blocker, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0
      }):Play();
      TweenService:Create(TabButton, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Library.MainColor
      }):Play();
      AnimateContainer(TabFrame);
    end;

    function Tab:HideTab()
      Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
      TweenService:Create(Blocker, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
      }):Play();
      TweenService:Create(TabButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundColor3 = Library.BackgroundColor
      }):Play();
      TabFrame.Visible = false;
    end;

    function Tab:SetLayoutOrder(Position)
      TabButton.LayoutOrder = Position;
      TabListLayout:ApplyLayout();
    end;

    function Tab:AddGroupbox(Info)
      local Groupbox = {};

      local BoxOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 0, 507 + 2);
        ZIndex = 2;
        Parent = Info.Side == 1 and LeftSide or RightSide;
      });

      Library:AddToRegistry(BoxOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
      });

      local BoxInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);

        Size = UDim2.new(1, -2, 1, -2);
        Position = UDim2.new(0, 1, 0, 1);
        ZIndex = 4;
        Parent = BoxOuter;
      });

      Library:AddToRegistry(BoxInner, {
        BackgroundColor3 = 'BackgroundColor';
      });

      local Highlight = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 5;
        Parent = BoxInner;
      });

      Library:AddToRegistry(Highlight, {
        BackgroundColor3 = 'AccentColor';
      });

      local GroupboxLabel = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 18);
        Position = UDim2.new(0, 4, 0, 2);
        TextSize = 14;
        Text = Info.Name;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 5;
        Parent = BoxInner;
      });

      local Container = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 4, 0, 20);
        Size = UDim2.new(1, -4, 1, -20);
        ZIndex = 1;
        Parent = BoxInner;
      });

      Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Container;
      });

      function Groupbox:Resize()
        local Size = 0;

        for _, Element in next, Groupbox.Container:GetChildren() do
          if (not Element:IsA('UIListLayout')) and Element.Visible then
            Size = Size + Element.Size.Y.Offset;
          end;
        end;

        BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
      end;

      Groupbox.Container = Container;
      setmetatable(Groupbox, BaseGroupbox);

      Groupbox:AddBlank(3);
      Groupbox:Resize();

      Tab.Groupboxes[Info.Name] = Groupbox;

      return Groupbox;
    end;

    function Tab:AddLeftGroupbox(Name)
      return Tab:AddGroupbox({ Side = 1; Name = Name; });
    end;

    function Tab:AddRightGroupbox(Name)
      return Tab:AddGroupbox({ Side = 2; Name = Name; });
    end;

    function Tab:AddTabbox(Info)
      local Tabbox = {
        Tabs = {};
      };

      local BoxOuter = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 0, 0);
        ZIndex = 2;
        Parent = Info.Side == 1 and LeftSide or RightSide;
      });

      Library:AddToRegistry(BoxOuter, {
        BackgroundColor3 = 'BackgroundColor';
        BorderColor3 = 'OutlineColor';
      });

      local BoxInner = Library:Create('Frame', {
        BackgroundColor3 = Library.BackgroundColor;
        BorderColor3 = Color3.new(0, 0, 0);

        Size = UDim2.new(1, -2, 1, -2);
        Position = UDim2.new(0, 1, 0, 1);
        ZIndex = 4;
        Parent = BoxOuter;
      });

      Library:AddToRegistry(BoxInner, {
        BackgroundColor3 = 'BackgroundColor';
      });

      local Highlight = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 0, 2);
        ZIndex = 10;
        Parent = BoxInner;
      });

      Library:AddToRegistry(Highlight, {
        BackgroundColor3 = 'AccentColor';
      });

      local TabboxButtons = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 1);
        Size = UDim2.new(1, 0, 0, 18);
        ZIndex = 5;
        Parent = BoxInner;
      });

      Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Left;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabboxButtons;
      });

      function Tabbox:AddTab(Name)
        local Tab = {};

        local Button = Library:Create('Frame', {
          BackgroundColor3 = Library.MainColor;
          BorderColor3 = Color3.new(0, 0, 0);
          Size = UDim2.new(0.5, 0, 1, 0);
          ZIndex = 6;
          Parent = TabboxButtons;
        });

        Library:AddToRegistry(Button, {
          BackgroundColor3 = 'MainColor';
        });

        local ButtonLabel = Library:CreateLabel({
          Size = UDim2.new(1, 0, 1, 0);
          TextSize = 14;
          Text = Name;
          TextXAlignment = Enum.TextXAlignment.Center;
          ZIndex = 7;
          Parent = Button;
        });

        local Block = Library:Create('Frame', {
          BackgroundColor3 = Library.BackgroundColor;
          BorderSizePixel = 0;
          Position = UDim2.new(0, 0, 1, 0);
          Size = UDim2.new(1, 0, 0, 1);
          Visible = false;
          ZIndex = 9;
          Parent = Button;
        });

        Library:AddToRegistry(Block, {
          BackgroundColor3 = 'BackgroundColor';
        });

        local Container = Library:Create('Frame', {
          BackgroundTransparency = 1;
          Position = UDim2.new(0, 4, 0, 20);
          Size = UDim2.new(1, -4, 1, -20);
          ZIndex = 1;
          Visible = false;
          Parent = BoxInner;
        });

        Library:Create('UIListLayout', {
          FillDirection = Enum.FillDirection.Vertical;
          SortOrder = Enum.SortOrder.LayoutOrder;
          Parent = Container;
        });

        function Tab:Show()
          for _, Tab in next, Tabbox.Tabs do
            Tab:Hide();
          end;

          Container.Visible = true;
          Block.Visible = true;
          Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';
          TweenService:Create(Button, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Library.BackgroundColor
          }):Play();
          AnimateContainer(Container);
          Tab:Resize();
        end;

        function Tab:Hide()
          Container.Visible = false;
          Block.Visible = false;
          Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
          TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = Library.MainColor
          }):Play();
        end;

        function Tab:Resize()
          local TabCount = 0;

          for _, Tab in next, Tabbox.Tabs do
            TabCount = TabCount + 1;
          end;

          for _, Button in next, TabboxButtons:GetChildren() do
            if not Button:IsA('UIListLayout') then
              Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
            end;
          end;

          if (not Container.Visible) then
            return;
          end;

          local Size = 0;

          for _, Element in next, Tab.Container:GetChildren() do
            if (not Element:IsA('UIListLayout')) and Element.Visible then
              Size = Size + Element.Size.Y.Offset;
            end;
          end;

          BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
        end;

        Button.InputBegan:Connect(function(Input)
          if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
            Tab:Show();
            Tab:Resize();
          end;
        end);

        Tab.Container = Container;
        Tabbox.Tabs[Name] = Tab;

        setmetatable(Tab, BaseGroupbox);

        Tab:AddBlank(3);
        Tab:Resize();


        if #TabboxButtons:GetChildren() == 2 then
          Tab:Show();
        end;

        return Tab;
      end;

      Tab.Tabboxes[Info.Name or ''] = Tabbox;

      return Tabbox;
    end;

    function Tab:AddLeftTabbox(Name)
      return Tab:AddTabbox({ Name = Name, Side = 1; });
    end;

    function Tab:AddRightTabbox(Name)
      return Tab:AddTabbox({ Name = Name, Side = 2; });
    end;

    TabButton.InputBegan:Connect(function(Input)
      if Input.UserInputType == Enum.UserInputType.MouseButton1 then
        Tab:ShowTab();
      end;
    end);


    if #TabContainer:GetChildren() == 1 then
      Tab:ShowTab();
    end;

    Window.Tabs[Name] = Tab;
    return Tab;
  end;

  local ModalElement = Library:Create('TextButton', {
    BackgroundTransparency = 1;
    Size = UDim2.new(0, 0, 0, 0);
    Visible = true;
    Text = '';
    Modal = false;
    Parent = ScreenGui;
  });

  local TransparencyCache = {};
  local Toggled = false;
  local Fading = false;
  Library.MenuVisible = false;

  function Library:Toggle()
    if Fading then
      return;
    end;

    local FadeTime = Config.MenuFadeTime;
    Fading = true;
    Toggled = (not Toggled);
    if not Toggled then
      Library:ClosePopups(nil, true);
    end;
    Library.MenuVisible = Toggled;
    ModalElement.Modal = Toggled;
    for _, widget in ipairs(Library.PlayerListWidgets or {}) do
      widget:_sync_menu()
    end;

    if Toggled then

      Outer.Visible = true;

      task.spawn(function()

        local State = InputService.MouseIconEnabled;

        local Cursor = Drawing.new('Triangle');
        Cursor.Thickness = 1;
        Cursor.Filled = true;
        Cursor.Visible = true;

        local CursorOutline = Drawing.new('Triangle');
        CursorOutline.Thickness = 1;
        CursorOutline.Filled = false;
        CursorOutline.Color = Color3.new(0, 0, 0);
        CursorOutline.Visible = true;

        while Toggled and ScreenGui.Parent do
          InputService.MouseIconEnabled = false;

          local mPos = InputService:GetMouseLocation();

          Cursor.Color = Library.AccentColor;

          Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
          Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
          Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);

          CursorOutline.PointA = Cursor.PointA;
          CursorOutline.PointB = Cursor.PointB;
          CursorOutline.PointC = Cursor.PointC;

          RenderStepped:Wait();
        end;

        InputService.MouseIconEnabled = State;

        Cursor:Remove();
        CursorOutline:Remove();
      end);
    end;

    for _, Desc in next, Outer:GetDescendants() do
      local Properties = {};

      if Desc:IsA('ImageLabel') then
        table.insert(Properties, 'ImageTransparency');
        table.insert(Properties, 'BackgroundTransparency');
      elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
        table.insert(Properties, 'TextTransparency');
      elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
        table.insert(Properties, 'BackgroundTransparency');
      elseif Desc:IsA('UIStroke') then
        table.insert(Properties, 'Transparency');
      end;

      local Cache = TransparencyCache[Desc];

      if (not Cache) then
        Cache = {};
        TransparencyCache[Desc] = Cache;
      end;

      for _, Prop in next, Properties do
        if not Cache[Prop] then
          Cache[Prop] = Desc[Prop];
        end;

        if Cache[Prop] == 1 then
          continue;
        end;

        TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
      end;
    end;

    task.wait(FadeTime);

    Outer.Visible = Toggled;

    Fading = false;
  end

  Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
    if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
      if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
        task.spawn(Library.Toggle)
      end
    elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
      task.spawn(Library.Toggle)
    end
  end))

  if Config.AutoShow then task.spawn(Library.Toggle) end

  Window.Holder = Outer;

  return Window;
end;

local function OnPlayerChange()
  local PlayerList = GetPlayersString();

  for _, Value in next, Options do
    if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
      Value:SetValues(PlayerList);
    end;
  end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);

getgenv().Library = Library
do
  local tween_service = game:GetService("TweenService")
  local http_service = game:GetService("HttpService")
  local players_service = game:GetService("Players")
  local run_service = game:GetService("RunService")
  local widget_cache = {}
  local widget_states = {}

  local get_widget_identity = getthreadidentity or getidentity or getthreadcontext
  local set_widget_identity = setthreadidentity or setidentity or setthreadcontext

  local function with_widget_access(callback)
    local previous
    if get_widget_identity and set_widget_identity then
      local ok, value = pcall(get_widget_identity)
      if ok then
        previous = value
        pcall(set_widget_identity, 8)
      end
    end
    local ok = pcall(callback)
    if previous ~= nil then pcall(set_widget_identity, previous) end
    return ok
  end

  local function set_widget_visible(root, visible)
    visible = visible == true
    local state = widget_states[root]
    if not state then
      state = {token = 0, tweens = {}, visible = false}
      widget_states[root] = state
    end
    if state.visible == visible then return end
    state.visible = visible
    state.token = state.token + 1
    local token = state.token

    local ok = with_widget_access(function()
      local objects = {root}
      for _, object in ipairs(root:GetDescendants()) do
        objects[#objects + 1] = object
      end

      if visible then root.Visible = true end

      for _, object in ipairs(objects) do
        local properties = {}
        if object:IsA("ImageLabel") or object:IsA("ImageButton") then
          properties = {"ImageTransparency", "BackgroundTransparency"}
        elseif object:IsA("TextLabel") or object:IsA("TextBox") or object:IsA("TextButton") then
          properties = {"TextTransparency"}
        elseif object:IsA("Frame") or object:IsA("ScrollingFrame") then
          properties = {"BackgroundTransparency"}
        elseif object:IsA("UIStroke") then
          properties = {"Transparency"}
        end

        if #properties > 0 then
          local cache = widget_cache[object]
          if not cache then
            cache = {}
            widget_cache[object] = cache
          end

          local goals = {}
          for _, property in ipairs(properties) do
            if cache[property] == nil then cache[property] = object[property] or 0 end
            if visible then object[property] = 1 end
            goals[property] = visible and cache[property] or 1
          end

          local tween = state.tweens[object]
          if tween then tween:Cancel() end
          tween = tween_service:Create(object, TweenInfo.new(0.14, Enum.EasingStyle.Quad, visible and Enum.EasingDirection.Out or Enum.EasingDirection.In), goals)
          state.tweens[object] = tween
          tween:Play()
        end
      end

      if not visible then
        task.delay(0.14, function()
          if state.token ~= token then return end
          with_widget_access(function()
            root.Visible = false
            for object, cache in pairs(widget_cache) do
              if object == root or object:IsDescendantOf(root) then
                for property, value in pairs(cache) do object[property] = value end
              end
            end
          end)
        end)
      end
    end)
    if not ok then state.visible = not visible end
  end

  Library.AccentColor = Color3.fromRGB(166, 178, 220)
  Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor)
  Library.MainColor = Color3.fromRGB(24, 24, 26)
  Library.BackgroundColor = Color3.fromRGB(16, 16, 18)
  Library.OutlineColor = Color3.fromRGB(42, 42, 48)

  Library.Flags = {}
  Library.SetFlags = {}
  Library.Scale = 1
  Library.AspectRatio = Vector2.new(16, 9)
  Library.AspectEnabled = false
  Library.Theme = {
    Accent = Library.AccentColor,
    Risky = Color3.fromRGB(220, 80, 85),
    RiskyText = Color3.fromRGB(255, 60, 60),
    UnstableText = Color3.fromRGB(255, 210, 70),
  }
  Library:UpdateColorsUsingRegistry()

  function Library:ChangeTheme(key, color)
    if typeof(color) ~= "Color3" then return end
    if key == "Accent" then
      Library.AccentColor = color
      Library.AccentColorDark = Library:GetDarkerColor(color)
      Library.Theme.Accent = color
    elseif key == "Background" then
      Library.BackgroundColor = color
    elseif key == "Section" or key == "Element" then
      Library.MainColor = color
    elseif key == "Text" then
      Library.FontColor = color
    elseif key == "Outline" then
      Library.OutlineColor = color
    end
    Library:UpdateColorsUsingRegistry()
    for _, obj in ipairs(Library.ScreenGui:GetDescendants()) do
      if obj:IsA("Frame") and obj:GetAttribute("CatAccent") then
        obj.BackgroundColor3 = Library.AccentColor
      end
    end
  end
  Library.SetFlags["ui_accent"] = function(v) Library:ChangeTheme("Accent", v) end

  local PRESETS = {
    Default = Color3.fromRGB(166, 178, 220),
    Blue = Color3.fromRGB(0, 85, 255),
    Red = Color3.fromRGB(255, 60, 60),
    Green = Color3.fromRGB(60, 220, 110),
    Purple = Color3.fromRGB(170, 110, 255),
    Orange = Color3.fromRGB(255, 140, 40),
    Pink = Color3.fromRGB(255, 90, 160),
    White = Color3.fromRGB(235, 235, 235),
  }
  function Library:ApplyThemePreset(name)
    local c = PRESETS[tostring(name)]
    if c then Library:ChangeTheme("Accent", c) end
  end

  function Library:SetScale(v) Library.Scale = v or 1 end
  function Library:SetAspectRatio(v, enabled)
    Library.AspectRatio = v or Vector2.new(16, 9)
    if enabled ~= nil then Library.AspectEnabled = enabled end
  end
  function Library:SetAspectRatioEnabled(en) Library.AspectEnabled = en end

  function Library:Notification(msg, dur, col)
    pcall(function() Library:Notify(tostring(msg), dur or 3) end)
  end

  function Library:BindActive(toggle_state, keybind_flag)
    if not toggle_state then return false end
    if not keybind_flag then return true end
    local kb = Library.Flags[keybind_flag]
    if not kb then return true end
    if kb.Mode == "Always" then return true end
    if kb.Value == nil or kb.Value == "None" then return false end
    if kb.Mode == "Hold" then return kb:GetState() == true end
    return kb.Toggled == true
  end

  function Library:CreateWatermark(info)
    local widget = {}
    local name = info and info.Name or "kota.tech"
    local frames = 0
    local last_update = os.clock()
    local fps = 0

    local function update()
      local ping = 0
      local player = players_service.LocalPlayer
      if player then
        local ok, value = pcall(player.GetNetworkPing, player)
        if ok and value then ping = math.floor(value * 1000 + 0.5) end
      end
      local realtime = os.date("%H:%M:%S")
      if DateTime then
        local local_time = DateTime.now():ToLocalTime()
        realtime = string.format("%02d:%02d:%02d", local_time.Hour, local_time.Minute, local_time.Second)
      end
      Library:SetWatermark(string.format("%s | %d fps | %d ms | %s", name, fps, ping, realtime))
    end

    run_service.RenderStepped:Connect(function()
      frames = frames + 1
      local now = os.clock()
      local elapsed = now - last_update
      if elapsed < 0.5 then return end
      fps = math.floor(frames / elapsed + 0.5)
      frames = 0
      last_update = now
      update()
    end)

    function widget:SetVisibility(visible)
      set_widget_visible(Library.Watermark, visible)
    end

    update()
    return widget
  end

  function Library:KeybindList()
    return {
      SetVisibility = function(_, visible)
        if Library.KeybindFrame then set_widget_visible(Library.KeybindFrame, visible) end
      end,
    }
  end

  local control_seq = 0
  local function control_id(info)
    if info.Flag then return info.Flag end
    control_seq = control_seq + 1
    local base = tostring(info.Name or "el"):gsub("[^%w_]", "_"):lower()
    return "ch_" .. base .. "_" .. control_seq
  end

  local function attach_control(group, control, info)
    Library.SetFlags[control_id(info)] = function(v)
      if control.SetValue then control:SetValue(v) end
    end
    control.Keybind = function(_, kb)
      control:AddKeyPicker(kb.Flag, {
        Text = info.Name or kb.Name or "Keybind",
        Default = kb.Default or "None",
        Mode = kb.Mode or "Toggle",
        SyncToggleState = true,
      })
      local picker = Options[kb.Flag]
      Library.Flags[kb.Flag] = picker
      Library.SetFlags[kb.Flag] = function(v)
        picker.Toggled = control.Value == true and not not v or false
        if picker.Update then picker:Update() end
      end
      if kb.Callback then picker:OnChanged(function(v) pcall(kb.Callback, v) end) end
      return picker
    end
    control.Colorpicker = function(_, cp)
      local idx = control_id(cp)
      control:AddColorPicker(idx, {
        Text = cp.Name or info.Name or "Color",
        Default = cp.Default or Color3.new(1, 1, 1),
        Transparency = cp.Alpha or 0,
      })
      local picker = Options[idx]
      if not picker then return control end
      Library.SetFlags[idx] = function(v) picker:SetValueRGB(v) end
      if cp.Callback then
        picker:OnChanged(function(v) pcall(cp.Callback, v, picker.Transparency) end)
      end
      return picker
    end
    control.Settings = function() return group end
    return control
  end

  local function augment_group(group)
    if group._cat_augmented then return group end
    group._cat_augmented = true

    function group:Toggle(info)
      local idx = control_id(info)
      local control = self:AddToggle(idx, {
        Text = info.Name or "",
        Default = info.Default or false,
        Risky = info.Risky or false,
      })
      if info.Callback then control:OnChanged(function(v) pcall(info.Callback, v) end) end
      return attach_control(self, control, info)
    end

    function group:Slider(info)
      local idx = control_id(info)
      local control = self:AddSlider(idx, {
        Text = info.Name or "",
        Default = info.Default or 0,
        Min = info.Min or 0,
        Max = info.Max or 100,
        Rounding = info.Decimals or 1,
      })
      if info.Callback then control:OnChanged(function(v) pcall(info.Callback, v) end) end
      return attach_control(self, control, info)
    end

    function group:Dropdown(info)
      local idx = control_id(info)
      local values = info.Items or {}
      local default = info.Default
      if type(default) == "number" then default = values[default] end
      local control = self:AddDropdown(idx, {
        Text = info.Name or "",
        Values = values,
        Default = default,
        Multi = info.Multi or false,
        AllowNull = default == nil,
      })
      function control:SetItems(items)
        control:SetValues(items or {})
      end
      function control:Refresh(items)
        control:SetValues(items or control.Values or {})
      end
      if info.Callback then control:OnChanged(function(v) pcall(info.Callback, v) end) end
      return attach_control(self, control, info)
    end

    function group:Colorpicker(info)
      local idx = control_id(info)
      local label = self:AddLabel(info.Name or "Color")
      label:AddColorPicker(idx, {
        Text = info.Name or "Color",
        Default = info.Default or Color3.new(1, 1, 1),
        Transparency = info.Alpha or 0,
      })
      local picker = Options[idx]
      if not picker then return label end
      Library.SetFlags[idx] = function(v) picker:SetValueRGB(v) end
      if info.Callback then
        picker:OnChanged(function(v) pcall(info.Callback, v, picker.Transparency) end)
      end
      return picker
    end

    function group:Button(info)
      self:AddButton({ Text = info.Name or "", Func = info.Callback or function() end })
    end

    function group:Label(info)
      local label = self:AddLabel(info.Name or "")
      return attach_control(self, label, info)
    end

    function group:Textbox(info)
      local idx = control_id(info)
      local control = self:AddInput(idx, {
        Text = info.Name or "",
        Default = info.Default or "",
        Placeholder = info.Placeholder or "",
      })
      if info.Callback then control:OnChanged(function(v) pcall(info.Callback, v) end) end
      return attach_control(self, control, info)
    end

    return group
  end

  Library.Game = "project_delta"
  local orig_create_window = Library.CreateWindow
  function Library:CreateWindow(...)
    local info = select(1, ...)
    if type(info) == "table" and info.Game then
      Library.Game = tostring(info.Game)
    end
    local window = orig_create_window(self, ...)
    Library.MainWindowHolder = window.Holder
    local orig_add_tab = window.AddTab
    function window:AddTab(name)
      local tab = orig_add_tab(self, name)
      local orig_left = tab.AddLeftTabbox
      local orig_right = tab.AddRightTabbox
      local function wrap_tabbox(box)
        local orig_box_tab = box.AddTab
        function box:AddTab(tab_name)
          return augment_group(orig_box_tab(self, tab_name))
        end
        return box
      end
      function tab:AddLeftTabbox(box_name) return wrap_tabbox(orig_left(self, box_name)) end
      function tab:AddRightTabbox(box_name) return wrap_tabbox(orig_right(self, box_name)) end
      return tab
    end
    return window
  end
  local function norm_color(c)
    if typeof(c) == "Color3" then return c end
    if type(c) == "table" then
      local r, g, b = c[1], c[2], c[3]
      if type(r) == "number" and type(g) == "number" and type(b) == "number" then
        if r <= 1 and g <= 1 and b <= 1 then
          return Color3.new(r, g, b)
        end
        return Color3.fromRGB(r, g, b)
      end
    end
    return Library.AccentColor
  end

  local function create_compact_target_indicator()
    local hud = {
      _statuses = {},
      _target = nil,
      _visible = false,
    }
    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderColor3 = Library.Black,
      BorderSizePixel = 1,
      Size = UDim2.new(0, 270, 0, 100),
      Position = UDim2.new(1, -12, 0, 12),
      AnchorPoint = Vector2.new(1, 0),
      Visible = false,
      ZIndex = 59,
      Parent = Library.ScreenGui,
    })
    Library:AddToRegistry(outer, {
      BackgroundColor3 = "Black",
      BorderColor3 = "Black",
    })
    Library:MakeDraggable(outer, 24)

    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      ZIndex = 60,
      Parent = outer,
    })
    Library:AddToRegistry(frame, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })

    local accent = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 1),
      ZIndex = 63,
      Parent = frame,
    })
    Library:AddToRegistry(accent, {BackgroundColor3 = "AccentColor"})

    local avatar = Library:Create("ImageLabel", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(0, 64, 0, 64),
      Position = UDim2.new(0, 7, 0, 9),
      Image = "rbxassetid://0",
      ScaleType = Enum.ScaleType.Crop,
      ZIndex = 62,
      Parent = frame,
    })
    Library:AddToRegistry(avatar, {
      BackgroundColor3 = "BackgroundColor",
      BorderColor3 = "OutlineColor",
    })

    local function add_row(name, y)
      Library:CreateLabel({
        Size = UDim2.new(0, 72, 0, 15),
        Position = UDim2.new(0, 79, 0, y),
        TextSize = 12,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 62,
        Parent = frame,
      })
      return Library:CreateLabel({
        Size = UDim2.new(1, -158, 0, 15),
        Position = UDim2.new(0, 151, 0, y),
        TextSize = 12,
        Text = "--",
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 62,
        Parent = frame,
      })
    end

    local user_value = add_row("user", 9)
    local weapon_value = add_row("holding", 27)
    local status_value = add_row("status", 45)
    local status_order = {"Manipulated", "Manipulating", "Visible", "Unvisible"}

    local hp_track = Library:Create("Frame", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -84, 0, 12),
      Position = UDim2.new(0, 78, 0, 71),
      ClipsDescendants = true,
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(hp_track, {
      BackgroundColor3 = "BackgroundColor",
      BorderColor3 = "OutlineColor",
    })

    local hp_fill = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 0, 1, 0),
      ZIndex = 62,
      Parent = hp_track,
    })
    Library:AddToRegistry(hp_fill, {BackgroundColor3 = "AccentColor"})

    local hp_value = Library:CreateLabel({
      Size = UDim2.new(1, -4, 1, 0),
      Position = UDim2.new(0, 2, 0, 0),
      TextSize = 10,
      Text = "",
      TextXAlignment = Enum.TextXAlignment.Right,
      TextYAlignment = Enum.TextYAlignment.Center,
      ZIndex = 63,
      Parent = hp_track,
    })

    local function get_player(target)
      if typeof(target) ~= "Instance" then return nil end
      if target:IsA("Player") then return target end
      return players_service:GetPlayerFromCharacter(target)
    end

    local function get_character(target)
      if typeof(target) ~= "Instance" then return nil end
      if target:IsA("Player") then return target.Character end
      return target
    end

    local function refresh_status()
      for _, name in ipairs(status_order) do
        local data = hud._statuses[name]
        if data and data.on then
          status_value.Text = name:lower()
          status_value.TextColor3 = data.color or Library.AccentColor
          Library.RegistryMap[status_value].Properties.TextColor3 = data.color or "AccentColor"
          return
        end
      end
      status_value.Text = "--"
      status_value.TextColor3 = Library.FontColor
      Library.RegistryMap[status_value].Properties.TextColor3 = "FontColor"
    end

    run_service.Heartbeat:Connect(function()
      if not hud._visible then return end
      local char = get_character(hud._target)
      local hum = char and char:FindFirstChildOfClass("Humanoid")
      if not hum then
        hp_fill.Size = UDim2.new(0, 0, 1, 0)
        hp_value.Text = ""
        return
      end
      local hp = hum.Health
      local max_hp = hum.MaxHealth
      local value = max_hp > 0 and math.clamp(hp / max_hp, 0, 1) or 0
      hp_fill.Size = UDim2.new(value, 0, 1, 0)
      hp_value.Text = string.format("%d/%d", math.floor(hp + 0.5), math.floor(max_hp + 0.5))
    end)

    function hud:SetTarget(target)
      if hud._target == target then return end
      hud._target = target
      avatar.Image = "rbxassetid://0"
      local player = get_player(target)
      if not player then
        user_value.Text = typeof(target) == "Instance" and target.Name or "--"
        return
      end
      user_value.Text = player.Name
      local user_id = player.UserId
      task.spawn(function()
        local ok, image = pcall(function()
          return players_service:GetUserThumbnailAsync(user_id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and image and hud._target == target then avatar.Image = image end
      end)
    end

    function hud:SetWeapon(weapon)
      local value = tostring(weapon or "")
      weapon_value.Text = value ~= "" and value or "--"
    end

    function hud:SetDistance(distance)
    end

    function hud:SetStatus(name, enabled, color)
      if not name then return end
      hud._statuses[tostring(name)] = {on = enabled == true, color = color}
      refresh_status()
    end

    function hud:HideAllStatuses()
      for _, data in pairs(hud._statuses) do data.on = false end
      refresh_status()
    end

    function hud:SetVisibility(visible)
      hud._visible = visible == true
      set_widget_visible(outer, hud._visible)
    end

    return hud
  end

  function Library:TargetIndicator(info)
    info = info or {}
    local profile = info.Profile or (Library.Game == "rost_alpha" and "compact" or "default")
    if profile == "compact" then
      return create_compact_target_indicator()
    end
    local hud = {
      _statuses = {},
      _target = nil,
      _visible = false,
      _weapon = "",
      _dist = 0,
    }
    local replicated_storage = game:GetService("ReplicatedStorage")

    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderColor3 = Library.Black,
      BorderSizePixel = 1,
      Size = UDim2.new(0, 300, 0, 116),
      Position = UDim2.new(1, -12, 0, 12),
      AnchorPoint = Vector2.new(1, 0),
      Visible = false,
      ZIndex = 59,
      Parent = Library.ScreenGui,
    })
    Library:AddToRegistry(outer, {
      BackgroundColor3 = "Black",
      BorderColor3 = "Black",
    })
    Library:MakeDraggable(outer, 24)

    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      ZIndex = 60,
      Parent = outer,
    })
    Library:AddToRegistry(frame, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })

    local accent = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 1),
      ZIndex = 63,
      Parent = frame,
    })
    Library:AddToRegistry(accent, { BackgroundColor3 = "AccentColor" })

    local avatar_border = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 82, 0, 82),
      Position = UDim2.new(0, 6, 0, 9),
      ZIndex = 61,
      Parent = frame,
    })

    local avatar = Library:Create("ImageLabel", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      Image = "rbxassetid://0",
      ScaleType = Enum.ScaleType.Crop,
      ZIndex = 62,
      Parent = avatar_border,
    })
    Library:AddToRegistry(avatar, {
      BackgroundColor3 = "BackgroundColor",
      BorderColor3 = "OutlineColor",
    })

    local function add_row(name, y)
      Library:CreateLabel({
        Size = UDim2.new(0, 88, 0, 14),
        Position = UDim2.new(0, 93, 0, y),
        TextSize = 12,
        Font = Library.Font,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 62,
        Parent = frame,
      })
      return Library:CreateLabel({
        Size = UDim2.new(0, 108, 0, 14),
        Position = UDim2.new(1, -116, 0, y),
        TextSize = 12,
        Font = Library.Font,
        Text = "--",
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 62,
        Parent = frame,
      })
    end

    local user_value = add_row("user", 7)
    local kd_value = add_row("kd", 21)
    local time_value = add_row("played hours", 35)
    local tool_value = add_row("weapon", 49)
    local status_value = add_row("status", 63)
    local status_order = { "Manipulated", "Manipulating", "Visible", "Unvisible" }

    local hp_outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -101, 0, 11),
      Position = UDim2.new(0, 93, 0, 90),
      ZIndex = 61,
      Parent = frame,
    })

    local hp_track = Library:Create("Frame", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      ClipsDescendants = true,
      ZIndex = 62,
      Parent = hp_outer,
    })
    Library:AddToRegistry(hp_track, { BackgroundColor3 = "BackgroundColor" })

    local hp_fill = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 0, 1, 0),
      ZIndex = 63,
      Parent = hp_track,
    })
    Library:AddToRegistry(hp_fill, { BackgroundColor3 = "AccentColor" })

    local hp_value = Library:CreateLabel({
      Size = UDim2.new(1, -4, 1, 0),
      Position = UDim2.new(0, 2, 0, 0),
      TextSize = 10,
      Font = Library.Font,
      Text = "",
      TextXAlignment = Enum.TextXAlignment.Right,
      TextYAlignment = Enum.TextYAlignment.Center,
      ZIndex = 64,
      Parent = hp_track,
    })

    local function get_player(target)
      if typeof(target) ~= "Instance" then return nil end
      if target:IsA("Player") then return target end
      return players_service:GetPlayerFromCharacter(target)
    end

    local function get_character(target)
      if typeof(target) ~= "Instance" then return nil end
      if target:IsA("Player") then return target.Character end
      return target
    end

    local function read_stats(player)
      if not player then return "--", "--" end
      local players = replicated_storage:FindFirstChild("Players")
      local data = players and players:FindFirstChild(player.Name)
      local status = data and data:FindFirstChild("Status")
      local journey = status and status:FindFirstChild("Journey")
      local stats = journey and journey:FindFirstChild("Statistics")
      if not stats then return "--", "--" end

      local kills = tonumber(stats:GetAttribute("Kills"))
      local deaths = tonumber(stats:GetAttribute("Deaths"))
      local played = tonumber(stats:GetAttribute("TimePlayed"))
      if kills == nil and deaths == nil and played == nil then return "--", "--" end

      kills = math.max(math.floor((kills or 0) + 0.5), 0)
      deaths = math.max(math.floor((deaths or 0) + 0.5), 0)
      played = math.max(played or 0, 0)
      local ratio = deaths > 0 and kills / deaths or kills
      return string.format("%.2f (%d/%d)", ratio, kills, deaths), string.format("%.2fh", played / 3600)
    end

    local function clear_health()
      hp_fill.Size = UDim2.new(0, 0, 1, 0)
      hp_value.Text = ""
    end

    local function refresh_status()
      local active
      for _, name in ipairs(status_order) do
        local data = hud._statuses[name]
        if data and data.on then
          active = {name = name, color = data.color}
          break
        end
      end
      if active then
        status_value.Text = active.name:lower()
        status_value.TextColor3 = active.color or Library.AccentColor
        Library.RegistryMap[status_value].Properties.TextColor3 = active.color or "AccentColor"
      else
        status_value.Text = "--"
        status_value.TextColor3 = Library.FontColor
        Library.RegistryMap[status_value].Properties.TextColor3 = "FontColor"
      end
    end

    local last_stats = 0
    run_service.Heartbeat:Connect(function()
      if not hud._visible then return end
      local char = get_character(hud._target)
      local hum = char and char:FindFirstChildOfClass("Humanoid")
      if hum then
        local hp = hum.Health
        local max_hp = hum.MaxHealth
        local value = max_hp > 0 and math.clamp(hp / max_hp, 0, 1) or 0
        hp_fill.Size = UDim2.new(value, 0, 1, 0)
        hp_value.Text = string.format("%d/%d", math.floor(hp + 0.5), math.floor(max_hp + 0.5))
      else
        clear_health()
      end

      if tick() - last_stats < 0.25 then return end
      last_stats = tick()
      local kd, play_time = read_stats(get_player(hud._target))
      kd_value.Text = kd
      time_value.Text = play_time
    end)

    function hud:SetTarget(target)
      if hud._target == target then return end
      hud._target = target
      avatar.Image = "rbxassetid://0"
      kd_value.Text = "--"
      time_value.Text = "--"
      clear_health()

      if typeof(target) ~= "Instance" then
        user_value.Text = "--"
        hud._weapon = ""
        hud._dist = 0
        tool_value.Text = "--"
        return
      end

      local player = get_player(target)
      user_value.Text = player and player.Name or target.Name
      local kd, play_time = read_stats(player)
      kd_value.Text = kd
      time_value.Text = play_time
      if not player then return end

      local user_id = player.UserId
      task.spawn(function()
        local ok, image = pcall(function()
          return players_service:GetUserThumbnailAsync(user_id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and image and hud._target == target then avatar.Image = image end
      end)
    end

    function hud:SetWeapon(weapon)
      hud._weapon = tostring(weapon or "")
      tool_value.Text = hud._weapon ~= "" and hud._weapon or "--"
    end

    function hud:SetDistance(distance)
      hud._dist = tonumber(distance) or 0
    end

    function hud:SetStatus(name, enabled, color)
      if not name then return end
      hud._statuses[tostring(name)] = {
        on = enabled == true,
        color = color,
      }
      refresh_status()
    end

    function hud:HideAllStatuses()
      for _, data in pairs(hud._statuses) do data.on = false end
      refresh_status()
    end

    function hud:SetVisibility(visible)
      hud._visible = visible == true
      set_widget_visible(outer, hud._visible)
    end

    return hud
  end

  function Library:InventoryViewer(info)
    info = info or {}
    local viewer = {
      _target = "",
      _summary = "",
    }

    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderColor3 = Library.Black,
      BorderSizePixel = 1,
      Size = UDim2.new(0, 210, 0, 58),
      Position = UDim2.new(0, 12, 0, 120),
      AnchorPoint = Vector2.new(0, 0),
      Visible = false,
      ZIndex = 59,
      Parent = Library.ScreenGui,
    })
    Library:AddToRegistry(outer, {
      BackgroundColor3 = "Black",
      BorderColor3 = "Black",
    })
    Library:MakeDraggable(outer, 24)

    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      ZIndex = 60,
      Parent = outer,
    })
    Library:AddToRegistry(frame, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })

    local accent = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 1),
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(accent, { BackgroundColor3 = "AccentColor" })

    local title = Library:CreateLabel({
      Size = UDim2.new(1, -8, 0, 18),
      Position = UDim2.new(0, 4, 0, 3),
      TextSize = 14,
      Font = Library.Font,
      Text = "Inventory",
      TextXAlignment = Enum.TextXAlignment.Center,
      ZIndex = 61,
      Parent = frame,
    })

    local summary = Library:CreateLabel({
      Size = UDim2.new(1, -8, 0, 16),
      Position = UDim2.new(0, 4, 0, 21),
      TextSize = 12,
      Font = Library.Font,
      Text = "",
      TextXAlignment = Enum.TextXAlignment.Center,
      Visible = false,
      ZIndex = 61,
      Parent = frame,
    })

    local divider = Library:Create("Frame", {
      BackgroundColor3 = Library.OutlineColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -2, 0, 1),
      Position = UDim2.new(0, 1, 0, 23),
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(divider, { BackgroundColor3 = "OutlineColor" })

    local body = Library:Create("ScrollingFrame", {
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -10, 1, -30),
      Position = UDim2.new(0, 5, 0, 27),
      CanvasSize = UDim2.new(0, 0, 0, 0),
      AutomaticCanvasSize = Enum.AutomaticSize.Y,
      ScrollBarThickness = 2,
      ScrollBarImageColor3 = Library.AccentColor,
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(body, { ScrollBarImageColor3 = "AccentColor" })

    Library:Create("UIListLayout", {
      Padding = UDim.new(0, 0),
      SortOrder = Enum.SortOrder.LayoutOrder,
      Parent = body,
    })

    local rows = {}
    local header_height = 27
    local size_tween

    local function update_header()
      local has_summary = viewer._summary ~= ""
      summary.Visible = has_summary
      summary.Text = viewer._summary
      header_height = has_summary and 44 or 27
      divider.Position = UDim2.new(0, 1, 0, has_summary and 40 or 23)
      body.Position = UDim2.new(0, 5, 0, header_height)
      body.Size = UDim2.new(1, -10, 1, -(header_height + 3))
    end

    local function resize()
      local longest = Library:GetTextBounds(title.Text, Library.Font, 14)
      if viewer._summary ~= "" then
        local summary_width = Library:GetTextBounds(viewer._summary, Library.Font, 12)
        if summary_width > longest then longest = summary_width end
      end
      for _, row in ipairs(rows) do
        local row_width = Library:GetTextBounds(row.Text, Library.Font, 13)
        if row_width > longest then longest = row_width end
      end
      local panel_width = math.clamp(math.ceil(longest) + 26, 210, 340)
      local content_height = #rows * 16
      local panel_height = math.clamp(content_height + header_height + 7, header_height + 33, 520)
      local target_size = UDim2.new(0, panel_width, 0, panel_height)
      if size_tween then size_tween:Cancel() end
      size_tween = tween_service:Create(outer, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = target_size,
      })
      size_tween:Play()
      body.CanvasSize = UDim2.new(0, 0, 0, content_height)
    end

    local function make_row(text, child, header)
      local row = Library:CreateLabel({
        Size = UDim2.new(1, -4, 0, 16),
        TextSize = 13,
        Font = Library.Font,
        Text = (child and "    -" or "") .. text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 62,
        Parent = body,
      })
      if header then
        row.TextColor3 = Library.AccentColor
        Library.RegistryMap[row].Properties.TextColor3 = "AccentColor"
      end
      row.LayoutOrder = #rows + 1
      rows[#rows + 1] = row
    end

    function viewer:Clear()
      for _, row in ipairs(rows) do
        Library:RemoveFromRegistry(row)
        row:Destroy()
      end
      rows = {}
      resize()
    end

    function viewer:SetTarget(name)
      viewer._target = tostring(name or "")
      if viewer._target == "" then
        title.Text = "Inventory"
      else
        title.Text = viewer._target .. "'s Inventory"
      end
      resize()
    end

    function viewer:SetSummary(text)
      viewer._summary = tostring(text or "")
      update_header()
      resize()
    end

    function viewer:SetSections(sections)
      viewer:Clear()
      if type(sections) ~= "table" then return end
      for _, section in ipairs(sections) do
        local entries = section.Entries
        if type(entries) == "table" and #entries > 0 then
          make_row(tostring(section.Name or "Inventory"), false, true)
          for _, entry in ipairs(entries) do
            local name = tostring(entry.Name or "")
            local count = math.max(math.floor(tonumber(entry.Count) or 1), 1)
            local amount = math.max(math.floor(tonumber(entry.Amount) or 0), 0)
            if name:lower() == "rubles" and amount > 1 then
              count = amount
              amount = 0
            end
            local prefix = count > 1 and ("[" .. count .. "x] ") or ""
            local suffix = amount > 1 and (" (" .. amount .. "x)") or ""
            make_row(prefix .. name .. suffix, true, false)
          end
        end
      end
      resize()
    end

    function viewer:SetItems(entries)
      viewer:Clear()
      if type(entries) ~= "table" then return end
      for _, entry in ipairs(entries) do
        local name = tostring(entry.Name or "")
        local count = math.max(math.floor(tonumber(entry.Count) or 1), 1)
        local amount = math.max(math.floor(tonumber(entry.Amount) or 0), 0)
        local prefix = count > 1 and ("[" .. count .. "x] ") or ""
        local suffix = amount > 1 and (" (" .. amount .. "x)") or ""
        make_row(prefix .. name .. suffix, false, false)
      end
      resize()
    end

    function viewer:SetVisibility(visible)
      set_widget_visible(outer, visible)
    end

    return viewer
  end

  function Library:PlayerList()
    local widget = {
      _visible = false,
      _requested = false,
      _selected = nil,
    }
    local replicated_storage = game:GetService("ReplicatedStorage")
    local rows = {}

    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 440, 0, 400),
      Position = UDim2.new(0.5, -220, 0.5, -200),
      Visible = false,
      ZIndex = 70,
      Parent = Library.ScreenGui,
    })
    Library:MakeDraggable(outer, 24)

    local function dock()
      local holder = Library.MainWindowHolder
      if not holder then return end
      local x = holder.AbsolutePosition.X - outer.Size.X.Offset - 10
      local y = holder.AbsolutePosition.Y + 8
      outer.AnchorPoint = Vector2.new(0, 0)
      outer.Position = UDim2.fromOffset(math.max(8, math.floor(x)), math.max(8, math.floor(y)))
    end

    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      ZIndex = 71,
      Parent = outer,
    })
    Library:AddToRegistry(frame, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })
    local accent = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 1),
      ZIndex = 74,
      Parent = frame,
    })
    Library:AddToRegistry(accent, { BackgroundColor3 = "AccentColor" })

    Library:CreateLabel({
      Size = UDim2.new(1, -8, 0, 18),
      Position = UDim2.new(0, 4, 0, 3),
      TextSize = 14,
      Font = Library.Font,
      Text = "player list",
      TextXAlignment = Enum.TextXAlignment.Center,
      ZIndex = 74,
      Parent = frame,
    })

    local divider = Library:Create("Frame", {
      BackgroundColor3 = Library.OutlineColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -2, 0, 1),
      Position = UDim2.new(0, 1, 0, 23),
      ZIndex = 73,
      Parent = frame,
    })
    Library:AddToRegistry(divider, { BackgroundColor3 = "OutlineColor" })

    local list_outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -16, 0, 204),
      Position = UDim2.new(0, 8, 0, 30),
      ZIndex = 72,
      Parent = frame,
    })

    local list = Library:Create("ScrollingFrame", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderColor3 = Library.OutlineColor,
      BorderMode = Enum.BorderMode.Inset,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.new(0, 1, 0, 1),
      CanvasSize = UDim2.new(0, 0, 0, 0),
      ScrollBarThickness = 2,
      ScrollBarImageColor3 = Library.AccentColor,
      ZIndex = 73,
      Parent = list_outer,
    })
    Library:AddToRegistry(list, {
      BackgroundColor3 = "BackgroundColor",
      BorderColor3 = "OutlineColor",
      ScrollBarImageColor3 = "AccentColor",
    })

    local row_holder = Library:Create("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -4, 0, 0),
      Position = UDim2.new(0, 2, 0, 2),
      ZIndex = 74,
      Parent = list,
    })
    Library:Create("UIListLayout", {
      Padding = UDim.new(0, 2),
      SortOrder = Enum.SortOrder.LayoutOrder,
      Parent = row_holder,
    })

    local search_outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderColor3 = Library.Black,
      Size = UDim2.new(1, -16, 0, 20),
      Position = UDim2.new(0, 8, 0, 243),
      ZIndex = 72,
      Parent = frame,
    })
    local search_inner = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderMode = Enum.BorderMode.Inset,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 73,
      Parent = search_outer,
    })
    Library:Create("UIGradient", {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
      }),
      Rotation = 90,
      Parent = search_inner,
    })
    local search = Library:Create("TextBox", {
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -8, 1, 0),
      Position = UDim2.new(0, 4, 0, 0),
      Font = Library.Font,
      TextColor3 = Library.FontColor,
      PlaceholderColor3 = Library.FontColor,
      PlaceholderText = "search players...",
      Text = "",
      TextSize = 12,
      TextXAlignment = Enum.TextXAlignment.Center,
      ClearTextOnFocus = false,
      ZIndex = 74,
      Parent = search_inner,
    })
    Library:ApplyTextStroke(search)
    Library:AddToRegistry(search_outer, { BorderColor3 = "Black" })
    Library:AddToRegistry(search_inner, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })
    Library:AddToRegistry(search, {
      TextColor3 = "FontColor",
      PlaceholderColor3 = "FontColor",
    })
    Library:OnHighlight(
      search_outer,
      search_outer,
      { BorderColor3 = "AccentColor" },
      { BorderColor3 = "Black" }
    )

    local detail = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderMode = Enum.BorderMode.Inset,
      BorderSizePixel = 1,
      Size = UDim2.new(1, -16, 0, 88),
      Position = UDim2.new(0, 8, 0, 272),
      ZIndex = 72,
      Parent = frame,
    })
    Library:AddToRegistry(detail, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })
    Library:Create("UIGradient", {
      Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
      }),
      Rotation = 90,
      Parent = detail,
    })

    local function add_detail(name, y)
      Library:CreateLabel({
        Size = UDim2.new(0, 100, 0, 16),
        Position = UDim2.new(0, 8, 0, y),
        TextSize = 12,
        Font = Library.Font,
        Text = name,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 73,
        Parent = detail,
      })
      return Library:CreateLabel({
        Size = UDim2.new(1, -120, 0, 16),
        Position = UDim2.new(0, 112, 0, y),
        TextSize = 12,
        Font = Library.Font,
        Text = "--",
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 73,
        Parent = detail,
      })
    end

    local user_value = add_detail("user", 5)
    local id_value = add_detail("user id", 23)
    local kd_value = add_detail("kd", 41)
    local hours_value = add_detail("played hours", 59)

    local function add_button(text, x_scale, x_offset, callback)
      local outer_button = Library:Create("Frame", {
        BackgroundColor3 = Library.Black,
        BorderColor3 = Library.Black,
        Size = UDim2.new(0.5, -12, 0, 20),
        Position = UDim2.new(x_scale, x_offset, 0, 368),
        ZIndex = 73,
        Parent = frame,
      })
      local inner_button = Library:Create("Frame", {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        BorderMode = Enum.BorderMode.Inset,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 74,
        Parent = outer_button,
      })
      Library:CreateLabel({
        Size = UDim2.new(1, 0, 1, 0),
        TextSize = 14,
        Text = text,
        ZIndex = 75,
        Parent = inner_button,
      })
      Library:Create("UIGradient", {
        Color = ColorSequence.new({
          ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
          ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
        }),
        Rotation = 90,
        Parent = inner_button,
      })
      Library:AddToRegistry(outer_button, { BorderColor3 = "Black" })
      Library:AddToRegistry(inner_button, {
        BackgroundColor3 = "MainColor",
        BorderColor3 = "OutlineColor",
      })
      Library:OnHighlight(
        outer_button,
        outer_button,
        { BorderColor3 = "AccentColor" },
        { BorderColor3 = "Black" }
      )
      outer_button.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if Library:MouseIsOverOpenedFrame() then return end
        Library:SafeCallback(callback)
      end)
      return outer_button
    end

    local function read_stats(player)
      if not player then return "--", "--" end
      local players = replicated_storage:FindFirstChild("Players")
      local data = players and players:FindFirstChild(player.Name)
      local status = data and data:FindFirstChild("Status")
      local journey = status and status:FindFirstChild("Journey")
      local stats = journey and journey:FindFirstChild("Statistics")
      if not stats then return "--", "--" end
      local kills = tonumber(stats:GetAttribute("Kills")) or 0
      local deaths = tonumber(stats:GetAttribute("Deaths")) or 0
      local played = tonumber(stats:GetAttribute("TimePlayed")) or 0
      kills = math.max(math.floor(kills + 0.5), 0)
      deaths = math.max(math.floor(deaths + 0.5), 0)
      played = math.max(played, 0)
      local ratio = deaths > 0 and kills / deaths or kills
      return string.format("%.2f (%d/%d)", ratio, kills, deaths), string.format("%.2fh", played / 3600)
    end

    local function update_detail()
      local player = widget._selected
      if not player or not player.Parent then
        widget._selected = nil
        user_value.Text = "--"
        id_value.Text = "--"
        kd_value.Text = "--"
        hours_value.Text = "--"
        return
      end
      local kd, hours = read_stats(player)
      user_value.Text = player.Name
      id_value.Text = tostring(player.UserId)
      kd_value.Text = kd
      hours_value.Text = hours
    end

    local function update_row(row)
      local active = row.hovered or row.player == widget._selected
      row.frame.BorderColor3 = active and Library.AccentColor or Library.Black
      Library.RegistryMap[row.frame].Properties.BorderColor3 = active and "AccentColor" or "Black"
    end

    local function update_selection()
      for _, row in ipairs(rows) do update_row(row) end
    end

    local function clear_rows()
      for _, row in ipairs(rows) do
        Library:RemoveFromRegistry(row.frame)
        Library:RemoveFromRegistry(row.inner)
        Library:RemoveFromRegistry(row.name)
        Library:RemoveFromRegistry(row.state)
        row.frame:Destroy()
      end
      rows = {}
    end

    local function relation(player)
      if player == players_service.LocalPlayer then return "LocalPlayer" end
      local team = player.Team
      return team and team.Name or "Neutral"
    end

    local function refresh()
      clear_rows()
      local query = search.Text:lower()
      local players = players_service:GetPlayers()
      table.sort(players, function(a, b)
        if a == players_service.LocalPlayer then return true end
        if b == players_service.LocalPlayer then return false end
        return a.Name:lower() < b.Name:lower()
      end)
      for _, player in ipairs(players) do
        if query == "" or player.Name:lower():find(query, 1, true) then
          local row = {player = player, hovered = false}
          row.frame = Library:Create("Frame", {
            BackgroundColor3 = Library.Black,
            BorderColor3 = Library.Black,
            BorderSizePixel = 1,
            Size = UDim2.new(1, -4, 0, 22),
            ZIndex = 74,
            Parent = row_holder,
          })
          Library:AddToRegistry(row.frame, {
            BackgroundColor3 = "Black",
            BorderColor3 = "Black",
          })
          row.inner = Library:Create("Frame", {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,
            BorderMode = Enum.BorderMode.Inset,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 75,
            Parent = row.frame,
          })
          Library:AddToRegistry(row.inner, {
            BackgroundColor3 = "MainColor",
            BorderColor3 = "OutlineColor",
          })
          Library:Create("UIGradient", {
            Color = ColorSequence.new({
              ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
              ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212)),
            }),
            Rotation = 90,
            Parent = row.inner,
          })
          row.name = Library:CreateLabel({
            Size = UDim2.new(0.55, -12, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            TextSize = 12,
            Font = Library.Font,
            Text = player.Name,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 76,
            Parent = row.inner,
          })
          row.state = Library:CreateLabel({
            Size = UDim2.new(0.45, -12, 1, 0),
            Position = UDim2.new(0.55, 4, 0, 0),
            TextSize = 12,
            Font = Library.Font,
            Text = relation(player),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 76,
            Parent = row.inner,
          })
          if player == players_service.LocalPlayer then
            row.state.TextColor3 = Library.AccentColor
            Library.RegistryMap[row.state].Properties.TextColor3 = "AccentColor"
          end
          local hitbox = Library:Create("TextButton", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 77,
            Parent = row.frame,
          })
          hitbox.MouseEnter:Connect(function()
            row.hovered = true
            update_row(row)
          end)
          hitbox.MouseLeave:Connect(function()
            row.hovered = false
            update_row(row)
          end)
          hitbox.MouseButton1Click:Connect(function()
            widget._selected = player
            update_selection()
            update_detail()
          end)
          rows[#rows + 1] = row
        end
      end
      local height = #rows > 0 and (#rows * 24 - 2) or 0
      row_holder.Size = UDim2.new(1, -4, 0, height)
      list.CanvasSize = UDim2.new(0, 0, 0, height + 4)
      update_selection()
      update_detail()
    end

    local function copy_value(value)
      if not value then return end
      local clipboard = setclipboard or toclipboard
      if clipboard then pcall(clipboard, tostring(value)) end
    end

    add_button("copy username", 0, 8, function()
      local player = widget._selected
      copy_value(player and player.Name)
    end)
    add_button("copy user id", 0.5, 4, function()
      local player = widget._selected
      copy_value(player and player.UserId)
    end)

    search:GetPropertyChangedSignal("Text"):Connect(refresh)
    players_service.PlayerAdded:Connect(refresh)
    players_service.PlayerRemoving:Connect(function(player)
      if widget._selected == player then widget._selected = nil end
      refresh()
    end)

    local last_update = 0
    run_service.Heartbeat:Connect(function()
      local now = os.clock()
      if not widget._visible or now - last_update < 1 then return end
      last_update = now
      update_detail()
    end)

    function widget:_sync_menu()
      local visible = widget._requested and Library.MenuVisible == true
      if widget._visible == visible then return end
      widget._visible = visible
      set_widget_visible(outer, visible)
      if visible then
        dock()
        task.defer(dock)
        refresh()
      end
    end

    function widget:SetVisibility(visible)
      widget._requested = visible == true
      widget:_sync_menu()
    end

    function widget:Refresh()
      refresh()
    end

    function widget:GetSelected()
      return widget._selected
    end

    Library.PlayerListWidgets = Library.PlayerListWidgets or {}
    table.insert(Library.PlayerListWidgets, widget)
    refresh()
    return widget
  end

  function Library:EspPreview(info)
    local prev = {}
    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.BackgroundColor,
      BorderColor3 = Library.OutlineColor,
      Size = UDim2.new(0, 150, 0, 230),
      Position = UDim2.new(0, 10, 0, 10),
      Visible = false,
      ZIndex = 60,
      Parent = Library.ScreenGui,
    })
    Library:AddToRegistry(frame, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:MakeDraggable(frame)

    local title = Library:CreateLabel({
      Size = UDim2.new(1, -12, 0, 18),
      Position = UDim2.new(0, 6, 0, 4),
      TextSize = 13,
      Font = Enum.Font.Code,
      Text = info and info.Name or "ESP Preview",
      TextXAlignment = Enum.TextXAlignment.Left,
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(title, { TextColor3 = "FontColor" })

    local name_lbl = Library:CreateLabel({
      Size = UDim2.new(1, -12, 0, 16),
      Position = UDim2.new(0, 6, 0, 24),
      TextSize = 12,
      Font = Enum.Font.Code,
      Text = "Enemy",
      TextXAlignment = Enum.TextXAlignment.Center,
      Visible = false,
      ZIndex = 61,
      Parent = frame,
    })
    Library:AddToRegistry(name_lbl, { TextColor3 = "FontColor" })

    local box = Library:Create("Frame", {
      BackgroundColor3 = Color3.fromRGB(255, 255, 255),
      BorderSizePixel = 1,
      BorderColor3 = Color3.new(0, 0, 0),
      Size = UDim2.new(0, 72, 0, 120),
      Position = UDim2.new(0.5, -36, 0, 48),
      Visible = false,
      ZIndex = 61,
      Parent = frame,
    })

    local hp_bg = Library:Create("Frame", {
      BackgroundColor3 = Color3.new(0, 0, 0),
      BackgroundTransparency = 0.4,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 76, 0, 8),
      Position = UDim2.new(0.5, -38, 0, 176),
      Visible = false,
      ZIndex = 61,
      Parent = frame,
    })
    local hp_fill = Library:Create("Frame", {
      BackgroundColor3 = Color3.fromRGB(90, 220, 90),
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 1, 0),
      ZIndex = 62,
      Parent = hp_bg,
    })

    function prev:SetSettings(es)
      if not es then return end
      box.Visible = not not es.box
      if es.box then box.BackgroundColor3 = norm_color(es.box_color) end
      name_lbl.Visible = not not es.realname
      if es.realname then
        name_lbl.Text = tostring(es.realname_text or "Enemy")
        name_lbl.TextColor3 = norm_color(es.realname_color)
      end
      hp_bg.Visible = not not es.health
      if es.health then
        local top = norm_color(es.health_color_top)
        local bot = norm_color(es.health_color_bottom)
        hp_fill.BackgroundColor3 = top:Lerp(bot, 0.35)
      end
    end

    function prev:SetOnChange(fn)
      prev._onchange = fn
    end

    function prev:SetVisibility(visible)
      set_widget_visible(frame, visible)
    end

    return prev
  end

  function Library:Loader(info)
    info = info or {}
    local loader = {}
    local width = info.Width or 260
    local base_title = info.Title or "loader"

    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(0, width + 2, 0, 120),
      Position = UDim2.new(0.5, -(width + 2) / 2, 0.5, -60),
      ZIndex = 1,
      Parent = Library.ScreenGui,
    })
    Library:MakeDraggable(outer)

    local frame = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderMode = Enum.BorderMode.Inset,
      Size = UDim2.new(1, -2, 1, -2),
      Position = UDim2.fromOffset(1, 1),
      ZIndex = 2,
      Parent = outer,
    })
    Library:AddToRegistry(frame, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor" })

    local accent = Library:Create("Frame", {
      BackgroundColor3 = Library.AccentColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, 0, 0, 1),
      ZIndex = 4,
      Parent = frame,
    })
    Library:AddToRegistry(accent, { BackgroundColor3 = "AccentColor" })

    local title = Library:CreateLabel({
      Size = UDim2.new(1, -10, 0, 20),
      Position = UDim2.new(0, 5, 0, 3),
      TextSize = 14,
      Text = base_title,
      TextXAlignment = Enum.TextXAlignment.Center,
      ZIndex = 4,
      Parent = frame,
    })
    Library:AddToRegistry(title, { TextColor3 = "FontColor" })

    local divider = Library:Create("Frame", {
      BackgroundColor3 = Library.OutlineColor,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -10, 0, 1),
      Position = UDim2.new(0, 5, 0, 25),
      ZIndex = 4,
      Parent = frame,
    })
    Library:AddToRegistry(divider, { BackgroundColor3 = "OutlineColor" })

    local container = Library:Create("Frame", {
      BackgroundTransparency = 1,
      Size = UDim2.new(1, -16, 0, 0),
      Position = UDim2.new(0, 8, 0, 30),
      ZIndex = 1,
      Parent = frame,
    })

    local layout = Library:Create("UIListLayout", {
      FillDirection = Enum.FillDirection.Vertical,
      SortOrder = Enum.SortOrder.LayoutOrder,
      Parent = container,
    })

    loader.Container = container
    for key, fn in pairs(BaseGroupbox.__index) do
      loader[key] = fn
    end

    local function content_height()
      local total = 0
      for _, element in ipairs(container:GetChildren()) do
        if not element:IsA("UIListLayout") and element.Visible then
          total = total + element.Size.Y.Offset
        end
      end
      return total
    end

    local function fit()
      for _, element in ipairs(container:GetChildren()) do
        if
          element:IsA("Frame")
          and element.BackgroundTransparency == 1
          and #element:GetChildren() == 0
          and element.Size.Y.Offset > 1
          and element.Size.Y.Offset ~= 8
        then
          element.Size = UDim2.new(element.Size.X.Scale, element.Size.X.Offset, 0, 8)
        end
      end
      local total = content_height()
      container.Size = UDim2.new(1, -16, 0, total)
      outer.Size = UDim2.new(0, width + 2, 0, total + 38)
    end

    function loader:Resize()
      fit()
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fit)

    local reset_token = 0

    function loader:Status(text, hold)
      title.Text = tostring(text or base_title)
      reset_token = reset_token + 1
      local token = reset_token
      if hold and hold > 0 then
        task.delay(hold, function()
          if token == reset_token then
            title.Text = base_title
          end
        end)
      end
    end

    function loader:ResetStatus()
      reset_token = reset_token + 1
      title.Text = base_title
    end

    function loader:SetVisibility(visible)
      outer.Visible = visible == true
    end

    function loader:Destroy()
      outer:Destroy()
    end

    outer.Visible = true
    loader:Resize()
    return loader
  end

  function Library:ReloadBar(duration, color, text)
    local bar = {}
    local outer = Library:Create("Frame", {
      BackgroundColor3 = Library.Black,
      BorderSizePixel = 0,
      Size = UDim2.new(0, 300, 0, 6),
      Position = UDim2.new(0.5, -150, 1, -44),
      Visible = true,
      ZIndex = 80,
      Parent = Library.ScreenGui,
    })
    local inner = Library:Create("Frame", {
      BackgroundColor3 = Library.MainColor,
      BorderColor3 = Library.OutlineColor,
      BorderMode = Enum.BorderMode.Inset,
      Position = UDim2.new(0, 1, 0, 1),
      Size = UDim2.new(1, -2, 1, -2),
      ZIndex = 81,
      Parent = outer,
    })
    local fill = Library:Create("Frame", {
      BackgroundColor3 = color or Library.AccentColor,
      BorderSizePixel = 0,
      Position = UDim2.new(0, 1, 0, 1),
      Size = UDim2.new(0, 0, 1, -2),
      ZIndex = 82,
      Parent = inner,
    })
    Library:AddToRegistry(outer, { BackgroundColor3 = "Black" })
    Library:AddToRegistry(inner, {
      BackgroundColor3 = "MainColor",
      BorderColor3 = "OutlineColor",
    })

    local tween
    local token = 0
    local closed = false

    local function close()
      if closed then return end
      closed = true
      token = token + 1
      if tween then tween:Cancel() end
      Library:RemoveFromRegistry(outer)
      Library:RemoveFromRegistry(inner)
      outer:Destroy()
    end

    local function start(value)
      if closed then return end
      token = token + 1
      local current = token
      local seconds = math.max(tonumber(value) or 1, 0.05)
      if tween then tween:Cancel() end
      fill.Size = UDim2.new(0, 0, 1, -2)
      tween = tween_service:Create(fill, TweenInfo.new(seconds, Enum.EasingStyle.Linear), {
        Size = UDim2.new(1, -2, 1, -2),
      })
      tween:Play()
      task.delay(seconds + 0.1, function()
        if token == current then close() end
      end)
    end

    function bar:SetDuration(value) start(value) end
    function bar:SetText(value) end
    function bar:Finish()
      if closed then return end
      token = token + 1
      local current = token
      if tween then tween:Cancel() end
      fill.Size = UDim2.new(1, -2, 1, -2)
      task.delay(0.08, function()
        if token == current then close() end
      end)
    end
    function bar:Cancel() close() end

    start(duration or 1)
    return bar
  end

  function Library:WeaponSkinGrid(info)
    local grid = {}
    local section = info and info.Section
    local container = section and (section.Container or (section._group and section._group.Container))
    if not container then return grid end

    local holder = Library:Create("Frame", {
      BackgroundTransparency = 1,
      BorderSizePixel = 0,
      Size = UDim2.new(1, -12, 0, 10),
      Parent = container,
    })
    Library:Create("UIListLayout", {
      Padding = UDim.new(0, 8),
      SortOrder = Enum.SortOrder.LayoutOrder,
      Parent = holder,
    })

    local function btn_for(item, skin_name, row_holder)
      local label = tostring(skin_name or "Default")
      local x = Library:GetTextBounds(label, Library.Font, 11)
      local btn = Library:Create("TextButton", {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.new(0, math.clamp(x + 14, 46, 110), 0, 22),
        Text = label,
        TextSize = 11,
        Font = Library.Font,
        AutoButtonColor = false,
        ZIndex = 62,
        Parent = row_holder,
      })
      Library:AddToRegistry(btn, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor", TextColor3 = "FontColor" })
      btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Library.AccentColor:Lerp(Library.MainColor, 0.75)
      end)
      btn.MouseLeave:Connect(function()
        local selected = info.GetSelected and info.GetSelected(nil, item.Name) or "Default"
        btn.BackgroundColor3 = selected == skin_name and Library.AccentColor or Library.MainColor
      end)
      btn.MouseButton1Click:Connect(function()
        if info.OnSelect then pcall(info.OnSelect, nil, item.Name, skin_name, item) end
        grid:SetRows(grid._rows or {})
      end)
      return btn
    end

    local function row_title(text)
      local lbl = Library:CreateLabel({
        Size = UDim2.new(1, 0, 0, 16),
        TextSize = 12,
        Font = Library.Font,
        Text = tostring(text or ""),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 62,
        Parent = holder,
      })
      lbl.TextColor3 = Library.AccentColor
      return lbl
    end

    local function row_holder()
      local rh = Library:Create("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        Parent = holder,
      })
      Library:Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = rh,
      })
      return rh
    end

    local function rebuild(rows)
      for _, child in ipairs(holder:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
          pcall(function() child:Destroy() end)
        end
      end
      local total_h = 0
      for _, row in ipairs(rows or {}) do
        row_title(row.Title)
        total_h = total_h + 16
        local rh = row_holder()
        for _, item in ipairs(row.Items or {}) do
          local selected = info.GetSelected and info.GetSelected(nil, item.Name) or "Default"
          local default_btn = btn_for(item, "Default", rh)
          if selected == "Default" or selected == nil then
            default_btn.BackgroundColor3 = Library.AccentColor
          end
          for _, skin in ipairs(item.Skins or {}) do
            local b = btn_for(item, skin.Name, rh)
            if selected == skin.Name then
              b.BackgroundColor3 = Library.AccentColor
            end
          end
        end
        total_h = total_h + 26 + 8
      end
      holder.Size = UDim2.new(1, -12, 0, total_h + 4)
    end

    function grid:SetRows(rows)
      grid._rows = rows
      rebuild(rows or {})
    end

    grid:SetRows(info.Rows or {})
    return grid
  end

  local function game_folder()
    if Library.Game == "rost_alpha" then
      return "kota/rostalpha"
    end
    return "kota/projectdelta"
  end
  local function cfg_dir()
    return game_folder() .. "/configs"
  end
  local function ensure_cfg_root()
    if type(makefolder) ~= "function" or type(isfolder) ~= "function" then return end
    pcall(function()
      if not isfolder("kota") then makefolder("kota") end
      local base = game_folder()
      if not isfolder(base) then makefolder(base) end
      local dir = cfg_dir()
      if not isfolder(dir) then makefolder(dir) end
      local assets = base .. "/assets"
      if not isfolder(assets) then makefolder(assets) end
    end)
  end
  local function cfg_path(name)
    return cfg_dir() .. "/" .. tostring(name) .. ".json"
  end
  function Library:GetFolder()
    ensure_cfg_root()
    return game_folder()
  end
  function Library:GetAssetsFolder()
    ensure_cfg_root()
    return game_folder() .. "/assets"
  end

  local function cfg_encode()
    local Tg = getgenv().Toggles or {}
    local Op = getgenv().Options or {}
    local data = { Toggles = {}, Options = {}, Flags = {} }
    for k, v in pairs(Tg) do
      data.Toggles[k] = v.Value
    end
    for k, v in pairs(Op) do
      if v.Type == "KeyPicker" then
        data.Options[k] = { T = "K", Value = v.Value, Mode = v.Mode, Toggled = v.Toggled }
      elseif v.Type == "Colorpicker" then
        local c = v.Value
        data.Options[k] = { T = "C", R = c.R, G = c.G, B = c.B }
      elseif v.Type == "Slider" then
        data.Options[k] = { T = "S", Value = v.Value }
      elseif v.Type == "Dropdown" then
        data.Options[k] = { T = "D", Value = v.Value }
      elseif v.Type == "Textbox" then
        data.Options[k] = { T = "T", Value = v.Value }
      end
    end
    for k, v in pairs(Library.Flags) do
      data.Flags[k] = v
    end
    return http_service:JSONEncode(data)
  end

  local function cfg_decode(json)
    local ok, data = pcall(function() return http_service:JSONDecode(json) end)
    if not ok or type(data) ~= "table" then return false end
    local Tg = getgenv().Toggles or {}
    local Op = getgenv().Options or {}
    if type(data.Toggles) == "table" then
      for k, v in pairs(data.Toggles) do
        local obj = Tg[k]
        if obj and obj.SetValue then pcall(function() obj:SetValue(v) end) end
      end
    end
    if type(data.Options) == "table" then
      for k, v in pairs(data.Options) do
        local obj = Op[k]
        if obj then
          if v.T == "K" then
            pcall(function() obj:SetValue({ v.Value, v.Mode }) end)
            if v.Toggled then obj.Toggled = true end
          elseif v.T == "C" then
            pcall(function() obj:SetValueRGB(Color3.new(v.R, v.G, v.B)) end)
          elseif obj.SetValue then
            pcall(function() obj:SetValue(v.Value) end)
          end
        end
      end
    end
    if type(data.Flags) == "table" then
      for k, v in pairs(data.Flags) do
        local setter = Library.SetFlags[k]
        if setter then
          pcall(setter, v, false)
        else
          Library.Flags[k] = v
        end
      end
    end
    return true
  end

  function Library:GetConfigs()
    ensure_cfg_root()
    local out = {}
    local ok, files = pcall(listfiles, cfg_dir())
    if ok and type(files) == "table" then
      for _, f in ipairs(files) do
        local n = tostring(f):match("([^/\\]+)%.json$")
        if n then out[#out + 1] = n end
      end
    end
    table.sort(out)
    return out
  end

  function Library:SaveConfig(name)
    if not name then return false end
    ensure_cfg_root()
    local ok = pcall(function() writefile(cfg_path(name), cfg_encode()) end)
    return ok
  end

  function Library:LoadConfigFromFile(name)
    if not isfile or not isfile(cfg_path(name)) then return false end
    local ok, json = pcall(readfile, cfg_path(name))
    if not ok then return false end
    return cfg_decode(json)
  end

  function Library:DeleteConfig(name)
    if not delfile then return false end
    local ok = pcall(delfile, cfg_path(name))
    return ok
  end
end
return Library
