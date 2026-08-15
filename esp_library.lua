local esp = {}
esp.__index = esp

local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local Workspace  = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function get_camera()
    local current = Workspace.CurrentCamera
    if current then Camera = current end
    return Camera
end

local function wtvp(pos)
    local cam = get_camera()
    if not cam then return Vector3.new(0, 0, -1), false end
    return cam:WorldToViewportPoint(pos)
end

local function get_hum_hrp(model)
    if not model or not model.Parent then return nil, nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return nil, nil end
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    return hum, hrp
end

local function new_drawing(kind, props)
    local d = Drawing.new(kind)
    if props then
        for k, v in pairs(props) do d[k] = v end
    end
    return d
end

local function destroy_all(objs)
    for k, d in pairs(objs) do
        if d then d:Remove() end
        objs[k] = nil
    end
end

local skeleton_bones = {
    { "Head", "UpperTorso" },
    { "UpperTorso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
    { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
    { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
}

local BODY_PARTS = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
    "RightUpperLeg", "RightLowerLeg", "RightFoot",
}

local HP_SEGMENTS = 12

local DEFAULT_STYLE = {
    enabled = true,
    max_distance = 3000,

    include_ai = true,
    death_fade_time = 1.5,

    box = { enabled = true, type = "Default", thickness = 1, color = Color3.fromRGB(255,255,255), transparency = 1 },
    box_outline = { enabled = true, thickness = 3, color = Color3.fromRGB(0,0,0), transparency = 1 },
    box_fill = { enabled = false, color = Color3.fromRGB(0,0,0), transparency = 0.35 },

    name = { enabled = true, size = 13, font = 2, color = Color3.fromRGB(255,255,255), outline = true, outline_color = Color3.fromRGB(0,0,0), slot = "top-center" },
    displayname = { enabled = false, size = 12, font = 2, color = Color3.fromRGB(200,200,200), outline = true, outline_color = Color3.fromRGB(0,0,0), slot = "top-center" },
    distance = { enabled = true, size = 12, font = 2, color = Color3.fromRGB(200,200,200), outline = true, outline_color = Color3.fromRGB(0,0,0), suffix = "m", slot = "bottom-center" },
    weapon = { enabled = false, size = 12, font = 2, color = Color3.fromRGB(200,200,200), outline = true, outline_color = Color3.fromRGB(0,0,0), slot = "bottom-center" },
    weapon_icon = { enabled = false, size = 22, slot = "bottom-center" },
    kd = { enabled = false, size = 12, font = 2, color = Color3.fromRGB(200, 200, 200), outline = true, outline_color = Color3.fromRGB(0, 0, 0), slot = "right-top", order = 6 },

    health = {
        enabled = true,
        thickness = 3,
        outline_thickness = 1,
        outline_color = Color3.fromRGB(0,0,0),
        color_top = Color3.fromRGB(90, 220, 90),
        color_bot = Color3.fromRGB(220, 90, 90),
        show_text = false,
        text_size = 11,
        text_font = 2,
    },

    skeleton = { enabled = false, color = Color3.fromRGB(255,255,255), thickness = 1 },

    chams = {
        enabled = false,
        hidden_color = Color3.fromRGB(152, 188, 255),
        hidden_transparency = 0.5,
        visible_color = Color3.fromRGB(152, 188, 255),
    },

    visible_color = nil,
    hitscan_color = nil,

    off_screen_arrow = {
        enabled = false,
        size = 20,
        color = Color3.fromRGB(255, 200, 80),
        radius = 200,
        fade_time = 0.18,
    },

    loot = {
        enabled = false,
        max_distance = 250,
        scan_interval = 0.25,
        color = Color3.fromRGB(255, 220, 80),
        text_size = 12,
        text_font = 2,
        outline = true,
        outline_color = Color3.fromRGB(0, 0, 0),
        show_name = true,
        show_distance = true,
        min_worth = 0,
        box = false,
        box_type = "Default",
        box_thickness = 1,
        box_outline = true,
        chams = false,
        chams_transparency = 0.65,
    },

    trail = {
        enabled = false,
        color = Color3.fromRGB(255, 255, 255),
        segment_life = 3.0,
        max_segments = 40,
        thickness = 2,
        transparency = 0.4,
    },
}

local PROFILE_STYLES = {
    project_delta = {},
    rost_alpha = {
        include_ai = false,
        max_distance = 1500,
        loot = {
            max_distance = 2000,
            scan_interval = 0.25,
            min_worth = 0,
        },
    },
}

local function deep_merge(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" and type(dst[k]) == "table" then
            deep_merge(dst[k], v)
        else
            dst[k] = v
        end
    end
end

function esp.new(config)
    local self = setmetatable({}, esp)
    local profile = config and config.profile or "project_delta"
    self.profile = PROFILE_STYLES[profile] and profile or "project_delta"
    self.style = {}
    deep_merge(self.style, DEFAULT_STYLE)
    deep_merge(self.style, PROFILE_STYLES[self.profile])
    if config then deep_merge(self.style, config) end

    self._entries = {}
    self._loot_entries = {}
    self._trail_data = {}
    self._connections = {}
    self._is_target_fn = nil
    self._visible_check_fn = nil
    self._hitscan_check_fn = nil
    self._weapon_getter = nil
    self._weapon_icon_getter = nil
    self._weapon_icon_fallback = nil
    self._loot_root_getter = nil
    self._loot_worth_getter = nil
    self._loot_provider = nil
    self._loot_anchor_getter = nil
    self._last_loot_scan = 0
    self._kd_cache = setmetatable({}, {__mode = "k"})

    local gui_parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "_ei"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 9998
    gui.Parent = gui_parent
    self._icon_gui = gui

    return self
end

function esp:SetTargetFilter(fn) self._is_target_fn = fn end
function esp:SetVisibleCheck(fn) self._visible_check_fn = fn end
function esp:SetHitscanCheck(fn) self._hitscan_check_fn = fn end
function esp:SetWeaponGetter(fn) self._weapon_getter = fn end
function esp:SetWeaponIconGetter(fn) self._weapon_icon_getter = fn end
function esp:SetWeaponIconFallback(fn) self._weapon_icon_fallback = fn end
function esp:SetLootRoot(fn) self._loot_root_getter = fn end
function esp:SetLootWorth(fn) self._loot_worth_getter = fn end
function esp:SetLootProvider(fn) self._loot_provider = fn end
function esp:SetLootAnchor(fn) self._loot_anchor_getter = fn end
function esp:SetProfile(name)
    local patch = PROFILE_STYLES[tostring(name)]
    if not patch then return false end
    self.profile = tostring(name)
    deep_merge(self.style, patch)
    return true
end

function esp:_should_track(subject, is_npc)
    if is_npc then return self.style.include_ai end
    if subject == LocalPlayer then return false end
    if self._is_target_fn then
        local ok, r = pcall(self._is_target_fn, subject, is_npc)
        if ok then return r == true end
    end
    return true
end

function esp:_get_model(subject, is_npc)
    if is_npc then return subject end
    return subject.Character
end

function esp:_create_entry(subject, is_npc)
    local entry = {
        subject = subject,
        is_npc = is_npc,
        objs = {
            box         = new_drawing("Square", { Filled = false, Thickness = 1, Visible = false, ZIndex = 3 }),
            box_outline = new_drawing("Square", { Filled = false, Thickness = 3, Visible = false, ZIndex = 2 }),
            box_fill    = new_drawing("Square", { Filled = true,  Visible = false, ZIndex = 1 }),
            name        = new_drawing("Text", { Center = true, Visible = false, ZIndex = 4 }),
            displayname = new_drawing("Text", { Center = true, Visible = false, ZIndex = 4 }),
            distance    = new_drawing("Text", { Center = true, Visible = false, ZIndex = 4 }),
            weapon      = new_drawing("Text", { Center = true, Visible = false, ZIndex = 4 }),
            kd          = new_drawing("Text", { Center = false, Visible = false, ZIndex = 4 }),
            hp_outline  = new_drawing("Line", { Visible = false, ZIndex = 2 }),
            hp_text     = new_drawing("Text", { Center = false, Visible = false, ZIndex = 4 }),
            arrow       = new_drawing("Triangle", { Filled = true, Visible = false, ZIndex = 3, Transparency = 0 }),
        },
        hp_segments = {},
        skel_lines = {},
        box_lines = {},
        adornments = {},
        chams_model = nil,
        chams_conns = nil,
        arrow_alpha = 0,
        death_at = nil,
        last_hp = 100,
        last_max_hp = 100,
    }
    for i = 1, HP_SEGMENTS do
        entry.hp_segments[i] = new_drawing("Line", { Visible = false, ZIndex = 3 })
    end

    local icon_holder = Instance.new("Frame")
    icon_holder.Name = "_ih"
    icon_holder.BackgroundTransparency = 1
    icon_holder.BorderSizePixel = 0
    icon_holder.AnchorPoint = Vector2.new(0.5, 0.5)
    icon_holder.Size = UDim2.fromOffset(22, 22)
    icon_holder.Visible = false
    icon_holder.Parent = self._icon_gui
    local icon_img = Instance.new("ImageLabel")
    icon_img.Name = "img"
    icon_img.BackgroundTransparency = 1
    icon_img.BorderSizePixel = 0
    icon_img.Size = UDim2.new(1, 0, 1, 0)
    icon_img.ScaleType = Enum.ScaleType.Fit
    icon_img.Visible = false
    icon_img.Parent = icon_holder
    entry.icon = {
        holder = icon_holder,
        img = icon_img,
        current_key = nil,
    }
    return entry
end

function esp:_destroy_entry(entry)
    destroy_all(entry.objs)
    for _, ln in pairs(entry.skel_lines) do
        if ln then ln:Remove() end
    end
    entry.skel_lines = {}
    for _, ln in pairs(entry.hp_segments) do
        if ln then ln:Remove() end
    end
    entry.hp_segments = {}
    for _, ln in pairs(entry.box_lines) do
        if ln then ln:Remove() end
    end
    entry.box_lines = {}
    if entry.icon and entry.icon.holder then
        entry.icon.holder:Destroy()
        entry.icon = nil
    end
    self:_clear_chams(entry)
end

function esp:_ensure_skel(entry)
    if not self.style.skeleton.enabled then
        for _, ln in pairs(entry.skel_lines) do ln.Visible = false end
        return
    end
    if next(entry.skel_lines) == nil then
        for i = 1, #skeleton_bones do
            entry.skel_lines[i] = new_drawing("Line", { Visible = false, ZIndex = 3 })
        end
    end
end



local function is_body_part(inst)
    if not (inst and inst:IsA("BasePart")) then return false end
    if inst.Name == "HumanoidRootPart" then return false end
    if inst:GetAttribute("PDIgnoreChams") == true then return false end
    local nm = string.lower(inst.Name or "")
    if nm == "ignoreme" or nm == "pdserverpositionclone" then return false end
    if nm == "facehitbox" or nm == "headtophitbox" then return false end
    if nm:find("lagcham", 1, true) then return false end
    if nm:find("fakecham", 1, true) then return false end
    return true
end

function esp:_ensure_part_adorns(entry, part, glow_target, main_color, main_trans)
    local is_head = (part.Name == "Head") or (part.Name == "FakeHead")
    local pair = entry.adornments[part]
    local glow_ad = pair and pair[1]
    local main_ad = pair and pair[2]

    if typeof(glow_ad) ~= "Instance" or glow_ad.Parent ~= part then
        glow_ad = Instance.new("BoxHandleAdornment")
        glow_ad.Name = "_g"
        glow_ad.AlwaysOnTop = true
        glow_ad.ZIndex = is_head and 10 or 9
        glow_ad.Adornee = part
        glow_ad.Size = part.Size + Vector3.new(0.03, 0.03, 0.03)
        glow_ad.Color3 = glow_target
        glow_ad.Transparency = -1
        pcall(function() glow_ad.Shading = Enum.AdornShading.XRayShaded end)
        glow_ad.Parent = part
    end
    if typeof(main_ad) ~= "Instance" or main_ad.Parent ~= part then
        main_ad = Instance.new("BoxHandleAdornment")
        main_ad.Name = "_m"
        main_ad.AlwaysOnTop = true
        main_ad.ZIndex = 10
        main_ad.Adornee = part
        main_ad.Size = part.Size + Vector3.new(0.02, 0.02, 0.02)
        main_ad.Color3 = main_color
        main_ad.Transparency = main_trans
        main_ad.Parent = part
    end
    glow_ad.Color3 = glow_target
    glow_ad.Transparency = -1
    glow_ad.Size = part.Size + Vector3.new(0.03, 0.03, 0.03)
    main_ad.Color3 = main_color
    main_ad.Transparency = main_trans
    main_ad.Size = part.Size + Vector3.new(0.02, 0.02, 0.02)

    entry.adornments[part] = { glow_ad, main_ad }
end

function esp:_clear_chams(entry)
    if entry.chams_conns then
        for _, c in ipairs(entry.chams_conns) do if c then c:Disconnect() end end
        entry.chams_conns = nil
    end
    entry.chams_model = nil
    if entry.adornments then
        for _, pair in pairs(entry.adornments) do
            for _, a in ipairs(pair) do
                if a and a.Parent then a:Destroy() end
            end
        end
    end
    entry.adornments = {}
end

function esp:_apply_chams(entry, model)
    local ch = self.style.chams
    if not ch.enabled then
        self:_clear_chams(entry)
        return
    end
    entry.adornments = entry.adornments or {}
    local main_color = ch.hidden_color
    local glow_color = ch.visible_color
    local main_trans = ch.hidden_transparency
    local glow_target = Color3.new(glow_color.R * 5, glow_color.G * 5, glow_color.B * 5)

    if entry.chams_model ~= model then
        if entry.chams_conns then
            for _, c in ipairs(entry.chams_conns) do if c then c:Disconnect() end end
        end
        entry.chams_conns = {}
        for part, pair in pairs(entry.adornments) do
            for _, a in ipairs(pair) do
                if a and a.Parent then a:Destroy() end
            end
            entry.adornments[part] = nil
        end
        entry.chams_model = model

        local this = self
        local function on_added(d)
            if is_body_part(d) then
                this:_ensure_part_adorns(entry, d, glow_target, main_color, main_trans)
            end
        end
        local function on_removed(d)
            local pair = entry.adornments[d]
            if pair then
                for _, a in ipairs(pair) do
                    if a and a.Parent then a:Destroy() end
                end
                entry.adornments[d] = nil
            end
        end
        entry.chams_conns[#entry.chams_conns + 1] = model.DescendantAdded:Connect(on_added)
        entry.chams_conns[#entry.chams_conns + 1] = model.DescendantRemoving:Connect(on_removed)
    end

    for _, d in ipairs(model:GetDescendants()) do
        if is_body_part(d) then
            self:_ensure_part_adorns(entry, d, glow_target, main_color, main_trans)
        end
    end

    for part, pair in pairs(entry.adornments) do
        if not part.Parent or not part:IsDescendantOf(model) then
            for _, a in ipairs(pair) do
                if a and a.Parent then a:Destroy() end
            end
            entry.adornments[part] = nil
        end
    end
end

function esp:_get_color(base_color, is_visible, is_hitscan)
    if is_hitscan and self.style.hitscan_color then return self.style.hitscan_color end
    if is_visible and self.style.visible_color then return self.style.visible_color end
    return base_color
end

function esp:_project_corners(cf, size)
    local cam = get_camera()
    if not cam then return nil end
    local xs, ys, zs = size.X * 0.5, size.Y * 0.5, size.Z * 0.5
    local corners = {
        cf * Vector3.new(-xs, -ys, -zs),
        cf * Vector3.new( xs, -ys, -zs),
        cf * Vector3.new(-xs,  ys, -zs),
        cf * Vector3.new( xs,  ys, -zs),
        cf * Vector3.new(-xs, -ys,  zs),
        cf * Vector3.new( xs, -ys,  zs),
        cf * Vector3.new(-xs,  ys,  zs),
        cf * Vector3.new( xs,  ys,  zs),
    }
    local min_x, min_y, max_x, max_y = math.huge, math.huge, -math.huge, -math.huge
    local front_count = 0
    local any_on = false
    for i = 1, 8 do
        local sp, on = wtvp(corners[i])
        if sp.Z > 0.05 then
            front_count = front_count + 1
            if on then any_on = true end
            if sp.X < min_x then min_x = sp.X end
            if sp.Y < min_y then min_y = sp.Y end
            if sp.X > max_x then max_x = sp.X end
            if sp.Y > max_y then max_y = sp.Y end
        end
    end
    if front_count == 0 or not any_on then return nil end
    local vp = cam.ViewportSize
    local margin = 64
    min_x = math.clamp(min_x, -margin, vp.X + margin)
    min_y = math.clamp(min_y, -margin, vp.Y + margin)
    max_x = math.clamp(max_x, -margin, vp.X + margin)
    max_y = math.clamp(max_y, -margin, vp.Y + margin)
    local width = max_x - min_x
    local height = max_y - min_y
    if width < 1 or height < 1 then return nil end
    if width > vp.X * 1.35 or height > vp.Y * 1.35 then return nil end

    local depth = 0
    pcall(function() depth = (cf.Position - cam.CFrame.Position).Magnitude end)
    depth = math.max(depth, 1)
    local min_width = math.clamp(320 / depth, 4, 10)
    local min_height = math.clamp(900 / depth, 10, 22)
    local center_x = (min_x + max_x) * 0.5
    local center_y = (min_y + max_y) * 0.5
    if width < min_width then
        width = min_width
        min_x = center_x - width * 0.5
    end
    if height < min_height then
        height = min_height
        min_y = center_y - height * 0.5
    end
    return Vector2.new(min_x, min_y), Vector2.new(width, height)
end

local function lerp_color(c1, c2, t)
    return Color3.new(c1.R + (c2.R - c1.R) * t, c1.G + (c2.G - c1.G) * t, c1.B + (c2.B - c1.B) * t)
end

function esp:_draw_hp(entry, pos, sz, hp, max_hp, alpha)
    local h = self.style.health
    if not h.enabled or max_hp <= 0 then
        for _, ln in ipairs(entry.hp_segments) do ln.Visible = false end
        entry.objs.hp_outline.Visible = false
        entry.objs.hp_text.Visible = false
        return
    end
    local ratio = math.clamp(hp / max_hp, 0, 1)
    local bar_h = sz.Y
    local x = math.floor(pos.X - 4 - h.thickness * 0.5)
    local top_y = math.floor(pos.Y)
    local bot_y = math.floor(pos.Y + bar_h)
    local fill_top_y = math.floor(pos.Y + bar_h * (1 - ratio))
    local trans_a = alpha or 1

    local ob = entry.objs.hp_outline
    ob.From = Vector2.new(x, top_y - 1)
    ob.To = Vector2.new(x, bot_y + 1)
    ob.Thickness = h.thickness + h.outline_thickness * 2
    ob.Color = h.outline_color
    ob.Transparency = trans_a
    ob.Visible = true

    local seg_count = HP_SEGMENTS
    local seg_h = bar_h / seg_count
    for i = 1, seg_count do
        local seg = entry.hp_segments[i]
        local sy0 = top_y + math.floor(seg_h * (i - 1))
        local sy1 = top_y + math.floor(seg_h * i)
        if sy1 <= fill_top_y then
            seg.Visible = false
        else
            local draw_from = math.max(sy0, fill_top_y)
            local draw_to = sy1
            if draw_to - draw_from < 1 then
                seg.Visible = false
            else
                local mid = (sy0 + sy1) * 0.5
                local rel = math.clamp((mid - top_y) / bar_h, 0, 1)
                seg.From = Vector2.new(x, draw_from)
                seg.To = Vector2.new(x, draw_to + 1)
                seg.Thickness = h.thickness
                seg.Color = lerp_color(h.color_top, h.color_bot, rel)
                seg.Transparency = trans_a
                seg.Visible = true
            end
        end
    end

    if h.show_text then
        local tx = entry.objs.hp_text
        tx.Text = tostring(math.floor(hp)) .. "/" .. tostring(math.floor(max_hp))
        tx.Size = h.text_size
        tx.Font = h.text_font
        tx.Color = Color3.new(1,1,1)
        tx.Outline = true
        tx.OutlineColor = Color3.new(0,0,0)
        tx.Transparency = trans_a
        tx.Position = Vector2.new(x - 2, fill_top_y - h.text_size / 2)
        tx.Visible = true
    else
        entry.objs.hp_text.Visible = false
    end
end

local SLOTS = {
    ["top-left"] = true, ["top-center"] = true, ["top-right"] = true,
    ["bottom-left"] = true, ["bottom-center"] = true, ["bottom-right"] = true,
    ["left-top"] = true, ["left-bottom"] = true,
    ["right-top"] = true, ["right-bottom"] = true,
}
local function valid_slot(s, default)
    if type(s) == "string" and SLOTS[s] then return s end
    return default or "top-center"
end

function esp:_get_kd(subject)
    if not subject or typeof(subject) ~= "Instance" or not subject:IsA("Player" ) then
        return "KD 0.0"
    end
    local now = os.clock()
    local cached = self._kd_cache[subject]
    if cached and now - cached.t < 1.5 then
        return cached.text
    end

    local text_value = "KD 0.0"
    pcall(function()
        local players_folder = ReplicatedStorage:FindFirstChild("Players")
        local player_folder = players_folder and players_folder:FindFirstChild(subject.Name)
        local stats = player_folder and (player_folder:FindFirstChild("WipeStatistics", true)
            or player_folder:FindFirstChild("Statistics", true))
        if stats then
            local kills = tonumber(stats:GetAttribute("Kills")) or 0
            local deaths = tonumber(stats:GetAttribute("Deaths")) or 0
            local ratio = deaths > 0 and (kills / deaths) or kills
            if math.abs(ratio - math.floor(ratio + 0.00001)) < 0.00001 then
                text_value = string.format("KD %d", math.floor(ratio))
            else
                text_value = string.format("KD %.1f", ratio)
            end
        end
    end)
    self._kd_cache[subject] = {t = now, text = text_value}
    return text_value
end

function esp:_draw_text_stack(entry, pos, sz, model, hum, dist, is_visible, alpha)
    local trans = alpha or 1
    local groups = {}
    local function push(slot_id, obj)
        groups[slot_id] = groups[slot_id] or {}
        local g = groups[slot_id]
        g[#g + 1] = obj
    end

    if self.style.name.enabled then
        local n = entry.objs.name
        n.Text = entry.is_npc and model.Name or entry.subject.Name
        n.Size = self.style.name.size
        n.Font = self.style.name.font
        n.Color = self:_get_color(self.style.name.color, is_visible, false)
        n.Outline = self.style.name.outline
        n.OutlineColor = self.style.name.outline_color
        n.Transparency = trans
        push(valid_slot(self.style.name.slot, "top-center"), { kind = "text", d = n, w = 0, h = n.Size, ord = self.style.name.order or 1 })
    else
        entry.objs.name.Visible = false
    end

    if self.style.displayname.enabled and not entry.is_npc then
        local d = entry.objs.displayname
        d.Text = entry.subject.DisplayName
        d.Size = self.style.displayname.size
        d.Font = self.style.displayname.font
        d.Color = self.style.displayname.color
        d.Outline = self.style.displayname.outline
        d.OutlineColor = self.style.displayname.outline_color
        d.Transparency = trans
        push(valid_slot(self.style.displayname.slot, "top-center"), { kind = "text", d = d, w = 0, h = d.Size, ord = self.style.displayname.order or 2 })
    else
        entry.objs.displayname.Visible = false
    end

    if self.style.distance.enabled then
        local ds = entry.objs.distance
        ds.Text = tostring(math.floor(dist)) .. (self.style.distance.suffix or "")
        ds.Size = self.style.distance.size
        ds.Font = self.style.distance.font
        ds.Color = self.style.distance.color
        ds.Outline = self.style.distance.outline
        ds.OutlineColor = self.style.distance.outline_color
        ds.Transparency = trans
        push(valid_slot(self.style.distance.slot, "bottom-center"), { kind = "text", d = ds, w = 0, h = ds.Size, ord = self.style.distance.order or 3 })
    else
        entry.objs.distance.Visible = false
    end

    if self.style.weapon.enabled then
        local w = entry.objs.weapon
        local wname = ""
        if self._weapon_getter then
            local ok, r = pcall(self._weapon_getter, entry.subject, model)
            if ok and r then wname = tostring(r) end
        end
        w.Text = wname
        w.Size = self.style.weapon.size
        w.Font = self.style.weapon.font
        w.Color = self.style.weapon.color
        w.Outline = self.style.weapon.outline
        w.OutlineColor = self.style.weapon.outline_color
        w.Transparency = trans
        if wname ~= "" then
            push(valid_slot(self.style.weapon.slot, "bottom-center"), { kind = "text", d = w, w = 0, h = w.Size, ord = self.style.weapon.order or 4 })
        else
            w.Visible = false
        end
    else
        entry.objs.weapon.Visible = false
    end

    if self.style.kd and self.style.kd.enabled and not entry.is_npc then
        local kd = entry.objs.kd
        kd.Text = self:_get_kd(entry.subject)
        kd.Size = self.style.kd.size or 12
        kd.Font = self.style.kd.font or 2
        kd.Color = self.style.kd.color or Color3.fromRGB(200, 200, 200)
        kd.Outline = self.style.kd.outline ~= false
        kd.OutlineColor = self.style.kd.outline_color or Color3.new(0, 0, 0)
        kd.Transparency = trans
        push(valid_slot(self.style.kd.slot, "right-top"), { kind = "text", d = kd, w = 0, h = kd.Size, ord = self.style.kd.order or 6 })
    else
        entry.objs.kd.Visible = false
    end

    local wic = self.style.weapon_icon
    local wi_slot = wic and wic.slot and valid_slot(wic.slot, nil)
    if wic and wic.enabled and wi_slot and entry.icon then
        local key
        if self._weapon_getter then
            local ok, r = pcall(self._weapon_getter, entry.subject, model)
            if ok and r and r ~= "" and r ~= "None" then key = tostring(r) end
        end
        local asset
        if key then
            local registered = false
            if self._weapon_icon_getter then
                local ok, a, reg = pcall(self._weapon_icon_getter, key)
                if ok then if a then asset = a end; if reg then registered = true end end
            end
            if not asset and not registered and self._weapon_icon_fallback then
                local ok, r = pcall(self._weapon_icon_fallback, key, entry.subject, model)
                if ok and r then asset = r end
            end
        end
        local ic = entry.icon
        if asset then
            if key ~= ic.current_key or ic.img.Image ~= asset then
                ic.current_key = key
                ic.img.Image = asset
            end
            local sz_i = math.clamp(tonumber(wic.size) or 22, 10, 32)
            ic.img.Visible = true
            ic.holder.Size = UDim2.fromOffset(sz_i, sz_i)
            ic.img.ImageTransparency = 1 - (alpha or 1)
            local function set_pos(base_x, base_y, align_x)
                local px = base_x
                if align_x == "left" then px = base_x + sz_i * 0.5
                elseif align_x == "right" then px = base_x - sz_i * 0.5 end
                ic.holder.Position = UDim2.fromOffset(px, base_y)
                ic.holder.Visible = true
            end
            entry._icon_slot_active = true
            push(wi_slot, { kind = "icon", set_pos = set_pos, w = sz_i, h = sz_i, ord = wic.order or 5 })
        else
            ic.holder.Visible = false
            ic.current_key = nil
            entry._icon_slot_active = true
        end
    else
        entry._icon_slot_active = false
    end

    for _, items in pairs(groups) do
        table.sort(items, function(a, b) return (a.ord or 99) < (b.ord or 99) end)
    end

    self:_layout_slots(pos, sz, groups)
end

function esp:_layout_slots(pos, sz, groups)
    local left = pos.X
    local right = pos.X + sz.X
    local top = pos.Y
    local bot = pos.Y + sz.Y
    local center_x = pos.X + sz.X * 0.5
    local center_y = pos.Y + sz.Y * 0.5
    local pad = 2

    local function place_vertical(items, base_x, base_y, dir, align_x)
        local y = base_y + (dir < 0 and -pad or pad)
        if dir < 0 then
            for i = #items, 1, -1 do
                local it = items[i]
                y = y - it.h - 1
                if it.kind == "text" then
                    if align_x == "left" then
                        it.d.Center = false
                        it.d.Position = Vector2.new(base_x, y)
                    elseif align_x == "right" then
                        local w = it.d.TextBounds and it.d.TextBounds.X or 0
                        it.d.Center = false
                        it.d.Position = Vector2.new(base_x - w, y)
                    else
                        it.d.Center = true
                        it.d.Position = Vector2.new(base_x, y)
                    end
                    it.d.Visible = true
                elseif it.kind == "icon" then
                    it.set_pos(base_x, y + it.h * 0.5, align_x)
                end
            end
        else
            for _, it in ipairs(items) do
                if it.kind == "text" then
                    if align_x == "left" then
                        it.d.Center = false
                        it.d.Position = Vector2.new(base_x, y)
                    elseif align_x == "right" then
                        local w = it.d.TextBounds and it.d.TextBounds.X or 0
                        it.d.Center = false
                        it.d.Position = Vector2.new(base_x - w, y)
                    else
                        it.d.Center = true
                        it.d.Position = Vector2.new(base_x, y)
                    end
                    it.d.Visible = true
                elseif it.kind == "icon" then
                    it.set_pos(base_x, y + it.h * 0.5, align_x)
                end
                y = y + it.h + 1
            end
        end
    end

    local function place_side_down(items, base_x, base_y, align_x)
        local y = base_y
        for _, it in ipairs(items) do
            if it.kind == "text" then
                if align_x == "left" then
                    it.d.Center = false
                    it.d.Position = Vector2.new(base_x, y)
                else
                    local w = it.d.TextBounds and it.d.TextBounds.X or 0
                    it.d.Center = false
                    it.d.Position = Vector2.new(base_x - w, y)
                end
                it.d.Visible = true
            elseif it.kind == "icon" then
                it.set_pos(base_x, y + it.h * 0.5, align_x)
            end
            y = y + it.h + 1
        end
    end

    local function place_side_up(items, base_x, base_y, align_x)
        local y = base_y
        for i = #items, 1, -1 do
            local it = items[i]
            y = y - it.h - 1
            if it.kind == "text" then
                if align_x == "left" then
                    it.d.Center = false
                    it.d.Position = Vector2.new(base_x, y)
                else
                    local w = it.d.TextBounds and it.d.TextBounds.X or 0
                    it.d.Center = false
                    it.d.Position = Vector2.new(base_x - w, y)
                end
                it.d.Visible = true
            elseif it.kind == "icon" then
                it.set_pos(base_x, y + it.h * 0.5, align_x)
            end
        end
    end

    for slot_id, items in pairs(groups) do
        if slot_id == "top-left" then
            place_vertical(items, left, top, -1, "left")
        elseif slot_id == "top-center" then
            place_vertical(items, center_x, top, -1, "center")
        elseif slot_id == "top-right" then
            place_vertical(items, right, top, -1, "right")
        elseif slot_id == "bottom-left" then
            place_vertical(items, left, bot, 1, "left")
        elseif slot_id == "bottom-center" then
            place_vertical(items, center_x, bot, 1, "center")
        elseif slot_id == "bottom-right" then
            place_vertical(items, right, bot, 1, "right")
        elseif slot_id == "left-top" then
            place_side_down(items, left - 6, top, "right")
        elseif slot_id == "left-bottom" then
            place_side_up(items, left - 6, bot, "right")
        elseif slot_id == "right-top" then
            place_side_down(items, right + 6, top, "left")
        elseif slot_id == "right-bottom" then
            place_side_up(items, right + 6, bot, "left")
        end
    end
end

function esp:_ensure_box_lines(entry, count)
    while #entry.box_lines < count do
        entry.box_lines[#entry.box_lines + 1] = new_drawing("Line", { Visible = false, ZIndex = 3 })
    end
    for i = count + 1, #entry.box_lines do entry.box_lines[i].Visible = false end
end

function esp:_draw_box(entry, pos, sz, is_visible, alpha, model)
    local a = alpha or 1
    local box_type = tostring(self.style.box.type or "Default"):lower()
    for _, line in ipairs(entry.box_lines) do line.Visible = false end
    if not self.style.box.enabled and not self.style.box_outline.enabled and not self.style.box_fill.enabled then
        entry.objs.box.Visible = false
        entry.objs.box_outline.Visible = false
        entry.objs.box_fill.Visible = false
        return
    end
    if self.style.box_fill.enabled and (box_type == "default" or box_type == "corner") then
        local fill = entry.objs.box_fill
        fill.Size = sz
        fill.Position = pos
        fill.Color = self.style.box_fill.color
        fill.Transparency = self.style.box_fill.transparency * a
        fill.Visible = true
    else
        entry.objs.box_fill.Visible = false
    end
    if box_type == "corner" and self.style.box.enabled then
        entry.objs.box.Visible = false
        entry.objs.box_outline.Visible = false
        self:_ensure_box_lines(entry, 8)
        local left, top = pos.X, pos.Y
        local right, bottom = left + sz.X, top + sz.Y
        local cut_x, cut_y = math.max(sz.X * 0.25, 4), math.max(sz.Y * 0.2, 4)
        local segments = {
            {Vector2.new(left, top), Vector2.new(left + cut_x, top)}, {Vector2.new(left, top), Vector2.new(left, top + cut_y)},
            {Vector2.new(right, top), Vector2.new(right - cut_x, top)}, {Vector2.new(right, top), Vector2.new(right, top + cut_y)},
            {Vector2.new(left, bottom), Vector2.new(left + cut_x, bottom)}, {Vector2.new(left, bottom), Vector2.new(left, bottom - cut_y)},
            {Vector2.new(right, bottom), Vector2.new(right - cut_x, bottom)}, {Vector2.new(right, bottom), Vector2.new(right, bottom - cut_y)},
        }
        local color = self:_get_color(self.style.box.color, is_visible, false)
        for i, segment in ipairs(segments) do
            local line = entry.box_lines[i]
            line.From = segment[1]
            line.To = segment[2]
            line.Color = color
            line.Thickness = self.style.box.thickness
            line.Transparency = self.style.box.transparency * a
            line.Visible = true
        end
        return
    end
    if box_type == "3d" and self.style.box.enabled and model then
        entry.objs.box.Visible = false
        entry.objs.box_outline.Visible = false
        self:_ensure_box_lines(entry, 12)
        local ok, cf, size = pcall(model.GetBoundingBox, model)
        if not ok or not size then return end
        local half = size * 0.5
        local offsets = {
            Vector3.new(half.X, half.Y, half.Z), Vector3.new(-half.X, half.Y, half.Z),
            Vector3.new(-half.X, half.Y, -half.Z), Vector3.new(half.X, half.Y, -half.Z),
            Vector3.new(half.X, -half.Y, half.Z), Vector3.new(-half.X, -half.Y, half.Z),
            Vector3.new(-half.X, -half.Y, -half.Z), Vector3.new(half.X, -half.Y, -half.Z),
        }
        local points = {}
        for i, offset in ipairs(offsets) do
            local point, on = wtvp((cf * CFrame.new(offset)).Position)
            points[i] = on and Vector2.new(point.X, point.Y) or nil
        end
        local links = { {1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8} }
        local color = self:_get_color(self.style.box.color, is_visible, false)
        for i, link in ipairs(links) do
            local line = entry.box_lines[i]
            local from, to = points[link[1]], points[link[2]]
            if from and to then
                line.From = from
                line.To = to
                line.Color = color
                line.Thickness = self.style.box.thickness
                line.Transparency = self.style.box.transparency * a
                line.Visible = true
            end
        end
        return
    end
    if self.style.box_outline.enabled and self.style.box.enabled then
        local outline = entry.objs.box_outline
        outline.Size = sz
        outline.Position = pos
        outline.Thickness = self.style.box_outline.thickness
        outline.Color = self.style.box_outline.color
        outline.Transparency = self.style.box_outline.transparency * a
        outline.Visible = true
    else
        entry.objs.box_outline.Visible = false
    end
    if self.style.box.enabled then
        local box = entry.objs.box
        box.Size = sz
        box.Position = pos
        box.Thickness = self.style.box.thickness
        box.Color = self:_get_color(self.style.box.color, is_visible, false)
        box.Transparency = self.style.box.transparency * a
        box.Visible = true
    else
        entry.objs.box.Visible = false
    end
end

function esp:_draw_skeleton(entry, model, alpha)
    self:_ensure_skel(entry)
    if not self.style.skeleton.enabled then return end
    local trans = 1 - (alpha or 1)
    for i, pair in ipairs(skeleton_bones) do
        local ln = entry.skel_lines[i]
        if ln then
            local a = model:FindFirstChild(pair[1])
            local b = model:FindFirstChild(pair[2])
            if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
                local sa, oa = wtvp(a.Position)
                local sb, ob = wtvp(b.Position)
                if oa and ob then
                    ln.From = Vector2.new(sa.X, sa.Y)
                    ln.To = Vector2.new(sb.X, sb.Y)
                    ln.Thickness = self.style.skeleton.thickness
                    ln.Color = self.style.skeleton.color
                    ln.Transparency = 1 - (alpha or 1)
                    ln.Visible = true
                else
                    ln.Visible = false
                end
            else
                ln.Visible = false
            end
        end
    end
end

function esp:_draw_arrow(entry, model, dt)
    local a = self.style.off_screen_arrow
    local hum, hrp = get_hum_hrp(model)
    local want = false
    local px, py, angle
    if a.enabled and hrp then
        local sp, on = wtvp(hrp.Position)
        if not on then
            local vp = Camera.ViewportSize
            local cx, cy = vp.X * 0.5, vp.Y * 0.5
            local dx, dy = sp.X - cx, sp.Y - cy
            if sp.Z < 0 then dx, dy = -dx, -dy end
            angle = math.atan2(dy, dx)
            px = cx + math.cos(angle) * a.radius
            py = cy + math.sin(angle) * a.radius
            want = true
        end
    end

    local fade = a.fade_time or 0.18
    local step = dt / math.max(fade, 0.01)
    if want then
        entry.arrow_alpha = math.min(1, (entry.arrow_alpha or 0) + step)
    else
        entry.arrow_alpha = math.max(0, (entry.arrow_alpha or 0) - step)
    end

    if entry.arrow_alpha <= 0 or not want and entry.arrow_alpha < 0.02 then
        entry.objs.arrow.Visible = false
        return
    end

    if want then
        local sz = a.size
        local tri = entry.objs.arrow
        tri.PointA = Vector2.new(px + math.cos(angle) * sz, py + math.sin(angle) * sz)
        tri.PointB = Vector2.new(px + math.cos(angle + 2.6) * sz * 0.6, py + math.sin(angle + 2.6) * sz * 0.6)
        tri.PointC = Vector2.new(px + math.cos(angle - 2.6) * sz * 0.6, py + math.sin(angle - 2.6) * sz * 0.6)
        tri.Color = a.color
        tri.Transparency = entry.arrow_alpha
        tri.Visible = true
    else
        entry.objs.arrow.Transparency = entry.arrow_alpha
    end
end

function esp:_draw_weapon_icon(entry, pos, sz, model, alpha)
    local ic = entry.icon
    if not ic then return end
    local cfg = self.style.weapon_icon
    if not cfg.enabled then
        ic.holder.Visible = false
        ic.current_key = nil
        return
    end
    if entry._icon_slot_active then return end
    local key
    if self._weapon_getter then
        local ok, r = pcall(self._weapon_getter, entry.subject, model)
        if ok and r and r ~= "" and r ~= "None" then key = tostring(r) end
    end
    if not key then
        ic.holder.Visible = false
        ic.current_key = nil
        return
    end

    local asset
    local registered = false
    if self._weapon_icon_getter then
        local ok, a, reg = pcall(self._weapon_icon_getter, key)
        if ok then
            if a then asset = a end
            if reg then registered = true end
        end
    end
    if not asset and not registered and self._weapon_icon_fallback then
        local ok, r = pcall(self._weapon_icon_fallback, key, entry.subject, model)
        if ok and r then asset = r end
    end

    if not asset then
        ic.holder.Visible = false
        return
    end

    if key ~= ic.current_key or ic.img.Image ~= asset then
        ic.current_key = key
        ic.img.Image = asset
        ic.img.Visible = true
    end

    local a = alpha or 1
    local icon_size = math.clamp(tonumber(cfg.size) or 22, 10, 32)
    ic.holder.Size = UDim2.fromOffset(icon_size, icon_size)
    local cx = pos.X + sz.X * 0.5
    local mode = cfg.position or "below_box"
    local y
    if mode == "above_box" or mode == "above_bar" or mode == "above_name" then
        y = pos.Y - icon_size * 0.5 - 6
    else
        y = pos.Y + sz.Y + icon_size * 0.5 + 6
    end
    ic.holder.Position = UDim2.fromOffset(cx, y)
    ic.holder.Visible = true
    ic.img.ImageTransparency = 1 - a
end

function esp:_hide_entry(entry)
    for _, obj in pairs(entry.objs) do obj.Visible = false end
    for _, ln in pairs(entry.skel_lines) do ln.Visible = false end
    for _, ln in pairs(entry.hp_segments) do ln.Visible = false end
    for _, ln in pairs(entry.box_lines) do ln.Visible = false end
    if entry.icon and entry.icon.holder then entry.icon.holder.Visible = false end
    self:_clear_chams(entry)
end

function esp:_update_entry(entry, dt)
    if not self.style.enabled or not self:_should_track(entry.subject, entry.is_npc) then
        self:_hide_entry(entry)
        return
    end
    local model = self:_get_model(entry.subject, entry.is_npc)
    if not model then self:_hide_entry(entry); return end
    local hum, hrp = get_hum_hrp(model)

    local now = tick()
    local alive = hum and hum.Health > 0

    if alive then
        entry.death_at = nil
        entry.last_hp = hum.Health
        entry.last_max_hp = hum.MaxHealth
        entry.last_hrp = hrp
    else
        if not entry.death_at then entry.death_at = now end
    end

    local alpha = 1
    if not alive then
        local elapsed = now - (entry.death_at or now)
        local dur = self.style.death_fade_time or 1.5
        if elapsed >= dur then
            self:_hide_entry(entry)
            return
        end
        alpha = 1 - (elapsed / dur)
        hrp = entry.last_hrp
        if not hrp or not hrp.Parent then self:_hide_entry(entry); return end
        hum = { Health = entry.last_hp, MaxHealth = entry.last_max_hp }
    end

    local lp_char = LocalPlayer.Character
    local lp_hrp = lp_char and lp_char:FindFirstChild("HumanoidRootPart")
    local dist = lp_hrp and (lp_hrp.Position - hrp.Position).Magnitude or 0
    if dist > self.style.max_distance then
        self:_hide_entry(entry)
        return
    end

    local ok, cf, size = pcall(model.GetBoundingBox, model)
    if not ok or not size then self:_hide_entry(entry); return end
    local pos, sz = self:_project_corners(cf, size)
    if not pos then
        self:_hide_entry(entry)
        self:_draw_arrow(entry, model, dt)
        return
    end

    local is_visible = false
    if self._visible_check_fn and alive then
        local ok2, vis = pcall(self._visible_check_fn, entry.subject, model, hrp.Position)
        if ok2 then is_visible = vis == true end
    end
    local is_hitscan = false
    if self._hitscan_check_fn and alive then
        local ok3, hs = pcall(self._hitscan_check_fn, entry.subject, model, hrp.Position)
        if ok3 then is_hitscan = hs == true end
    end

    if alive then
        self:_apply_chams(entry, model)
    else
        self:_clear_chams(entry)
    end
    self:_draw_box(entry, pos, sz, is_visible, alpha, model)
    self:_draw_hp(entry, pos, sz, hum.Health, hum.MaxHealth, alpha)
    self:_draw_text_stack(entry, pos, sz, model, hum, dist, is_visible, alpha)
    self:_draw_weapon_icon(entry, pos, sz, model, alpha)
    if alive then
        self:_draw_skeleton(entry, model, alpha)
    else
        for _, ln in pairs(entry.skel_lines) do ln.Visible = false end
    end
    self:_draw_arrow(entry, model, dt)
end

function esp:Add(subject, is_npc)
    if not subject then return end
    if self._entries[subject] then return self._entries[subject] end
    if not self:_should_track(subject, is_npc) then return end
    local entry = self:_create_entry(subject, is_npc)
    self._entries[subject] = entry
    return entry
end

function esp:Remove(subject)
    local entry = self._entries[subject]
    if not entry then return end
    self:_destroy_entry(entry)
    self._entries[subject] = nil
end

function esp:GetEntry(subject) return self._entries[subject] end

function esp:UpdateStyle(patch)
    if not patch then return end
    deep_merge(self.style, patch)
    if patch.chams and patch.chams.enabled == false then
        for _, entry in pairs(self._entries) do
            self:_clear_chams(entry)
        end
    end
end

function esp:Set(path, value)
    local parts = {}
    for p in string.gmatch(path, "[^%.]+") do parts[#parts + 1] = p end
    local node = self.style
    for i = 1, #parts - 1 do
        node = node[parts[i]]
        if type(node) ~= "table" then return end
    end
    node[parts[#parts]] = value
end

function esp:_hide_loot_entry(entry)
    if not entry then return end
    if entry.text then entry.text.Visible = false end
    if entry.box then entry.box.Visible = false end
    if entry.box_outline then entry.box_outline.Visible = false end
    for _, line in ipairs(entry.lines or {}) do line.Visible = false end
    if entry.highlight then entry.highlight.Enabled = false end
end

function esp:_destroy_loot_entry(entry)
    if not entry then return end
    if entry.text then entry.text:Remove() end
    if entry.box then entry.box:Remove() end
    if entry.box_outline then entry.box_outline:Remove() end
    for _, line in ipairs(entry.lines or {}) do line:Remove() end
    if entry.highlight then entry.highlight:Destroy() end
end

function esp:_create_loot_entry(inst, data)
    local l = self.style.loot
    return {
        inst = inst,
        data = data or {},
        name = tostring((data and data.name) or inst.Name),
        worth = 0,
        lines = {},
        text = new_drawing("Text", {
            Center = true,
            Visible = false,
            Size = l.text_size,
            Font = l.text_font,
            Color = l.color,
            Outline = l.outline,
            OutlineColor = l.outline_color,
        }),
        box = new_drawing("Square", { Filled = false, Visible = false, Thickness = l.box_thickness, ZIndex = 3 }),
        box_outline = new_drawing("Square", { Filled = false, Visible = false, Thickness = l.box_thickness + 2, Color = l.outline_color, ZIndex = 2 }),
    }
end

function esp:_get_loot_anchor(inst, data)
    if data and data.anchor and data.anchor.Parent then return data.anchor end
    if self._loot_anchor_getter then
        local ok, anchor = pcall(self._loot_anchor_getter, inst, data)
        if ok and anchor then return anchor end
    end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Model") then return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true) end
end

function esp:_ensure_loot_lines(entry, count)
    while #entry.lines < count do
        entry.lines[#entry.lines + 1] = new_drawing("Line", { Visible = false, Thickness = 1 })
    end
    for i = count + 1, #entry.lines do entry.lines[i].Visible = false end
end

function esp:_draw_loot_box(entry, anchor, screen, size, color, box_type, thickness, outline)
    entry.box.Visible = false
    entry.box_outline.Visible = false
    for _, line in ipairs(entry.lines) do line.Visible = false end
    box_type = tostring(box_type or "Default"):lower()
    if box_type == "3d" and anchor:IsA("BasePart") then
        self:_ensure_loot_lines(entry, 12)
        local half = anchor.Size * 0.5
        local offsets = {
            Vector3.new(half.X, half.Y, half.Z), Vector3.new(-half.X, half.Y, half.Z),
            Vector3.new(-half.X, half.Y, -half.Z), Vector3.new(half.X, half.Y, -half.Z),
            Vector3.new(half.X, -half.Y, half.Z), Vector3.new(-half.X, -half.Y, half.Z),
            Vector3.new(-half.X, -half.Y, -half.Z), Vector3.new(half.X, -half.Y, -half.Z),
        }
        local points = {}
        for i, offset in ipairs(offsets) do
            local point, on = wtvp((anchor.CFrame * CFrame.new(offset)).Position)
            points[i] = on and Vector2.new(point.X, point.Y) or nil
        end
        local links = { {1,2}, {2,3}, {3,4}, {4,1}, {5,6}, {6,7}, {7,8}, {8,5}, {1,5}, {2,6}, {3,7}, {4,8} }
        for i, link in ipairs(links) do
            local line = entry.lines[i]
            local a, b = points[link[1]], points[link[2]]
            if line and a and b then
                line.From = a
                line.To = b
                line.Color = color
                line.Thickness = thickness
                line.Visible = true
            end
        end
        return
    end
    if box_type == "corner" then
        self:_ensure_loot_lines(entry, 8)
        local left, top = screen.X - size * 0.5, screen.Y - size * 0.5
        local right, bottom = left + size, top + size
        local cut = math.max(size * 0.3, 4)
        local segments = {
            {Vector2.new(left, top), Vector2.new(left + cut, top)}, {Vector2.new(left, top), Vector2.new(left, top + cut)},
            {Vector2.new(right, top), Vector2.new(right - cut, top)}, {Vector2.new(right, top), Vector2.new(right, top + cut)},
            {Vector2.new(left, bottom), Vector2.new(left + cut, bottom)}, {Vector2.new(left, bottom), Vector2.new(left, bottom - cut)},
            {Vector2.new(right, bottom), Vector2.new(right - cut, bottom)}, {Vector2.new(right, bottom), Vector2.new(right, bottom - cut)},
        }
        for i, segment in ipairs(segments) do
            local line = entry.lines[i]
            line.From = segment[1]
            line.To = segment[2]
            line.Color = color
            line.Thickness = thickness
            line.Visible = true
        end
        return
    end
    local position = Vector2.new(screen.X - size * 0.5, screen.Y - size * 0.5)
    if outline then
        entry.box_outline.Position = position
        entry.box_outline.Size = Vector2.new(size, size)
        entry.box_outline.Thickness = thickness + 2
        entry.box_outline.Color = Color3.new(0, 0, 0)
        entry.box_outline.Visible = true
    end
    entry.box.Position = position
    entry.box.Size = Vector2.new(size, size)
    entry.box.Color = color
    entry.box.Thickness = thickness
    entry.box.Visible = true
end

function esp:_scan_loot(now)
    local l = self.style.loot
    if not l.enabled then
        for _, entry in pairs(self._loot_entries) do self:_hide_loot_entry(entry) end
        return
    end
    if now - self._last_loot_scan < (l.scan_interval or 0.25) then return end
    self._last_loot_scan = now
    local supplied = {}
    if self._loot_provider then
        local ok, values = pcall(self._loot_provider)
        if ok and type(values) == "table" then supplied = values end
    else
        local root
        if self._loot_root_getter then
            local ok, value = pcall(self._loot_root_getter)
            if ok then root = value end
        else
            root = Workspace:FindFirstChild("Items") or Workspace:FindFirstChild("Drops") or Workspace:FindFirstChild("Loot")
        end
        if root then
            for _, inst in ipairs(root:GetChildren()) do supplied[#supplied + 1] = inst end
        end
    end
    local seen = {}
    for _, value in pairs(supplied) do
        local data = type(value) == "table" and value or {}
        local inst = data.instance or data.Instance or value
        if typeof(inst) == "Instance" and inst.Parent and (inst:IsA("Model") or inst:IsA("BasePart")) then
            seen[inst] = data
        end
    end
    for inst, entry in pairs(self._loot_entries) do
        if not seen[inst] then
            self:_destroy_loot_entry(entry)
            self._loot_entries[inst] = nil
        end
    end
    for inst, data in pairs(seen) do
        local entry = self._loot_entries[inst]
        if not entry then
            entry = self:_create_loot_entry(inst, data)
            self._loot_entries[inst] = entry
        end
        entry.data = data
        entry.name = tostring(data.name or inst.Name)
    end
end

function esp:_render_loot()
    local l = self.style.loot
    if not l.enabled then return end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local local_position = root and root.Position
    for inst, entry in pairs(self._loot_entries) do
        local data = entry.data or {}
        local anchor = self:_get_loot_anchor(inst, data)
        if data.enabled == false or not anchor or not anchor.Parent then
            self:_hide_loot_entry(entry)
        else
            local distance = local_position and (anchor.Position - local_position).Magnitude or 0
            local max_distance = tonumber(data.max_distance) or l.max_distance
            if distance > max_distance then
                self:_hide_loot_entry(entry)
            else
                if self._loot_worth_getter then
                    local ok, worth = pcall(self._loot_worth_getter, inst, data)
                    if ok then entry.worth = tonumber(worth) or 0 end
                end
                if l.min_worth > 0 and entry.worth < l.min_worth then
                    self:_hide_loot_entry(entry)
                else
                    local projected, on_screen = wtvp(anchor.Position)
                    if not on_screen then
                        self:_hide_loot_entry(entry)
                    else
                        local color = data.color or l.color
                        local show_name = data.show_name
                        if show_name == nil then show_name = l.show_name end
                        local show_distance = data.show_distance
                        if show_distance == nil then show_distance = l.show_distance end
                        local text = show_name and entry.name or ""
                        if show_distance then
                            local distance_text = "[" .. math.floor(distance) .. "m]"
                            text = text ~= "" and (text .. " " .. distance_text) or distance_text
                        end
                        if entry.worth > 0 then text = text .. " $" .. entry.worth end
                        entry.text.Text = text
                        entry.text.Color = color
                        entry.text.Size = tonumber(data.text_size) or l.text_size
                        entry.text.Position = Vector2.new(projected.X, projected.Y)
                        entry.text.Visible = text ~= ""
                        local show_box = data.box
                        if show_box == nil then show_box = l.box end
                        if show_box then
                            local box_size = math.clamp(1800 / math.max(distance, 1), 8, 60)
                            self:_draw_loot_box(entry, anchor, projected, box_size, color, data.box_type or l.box_type, tonumber(data.box_thickness) or l.box_thickness, data.box_outline ~= false and l.box_outline ~= false)
                        else
                            entry.box.Visible = false
                            entry.box_outline.Visible = false
                            for _, line in ipairs(entry.lines) do line.Visible = false end
                        end
                        local show_chams = data.chams
                        if show_chams == nil then show_chams = l.chams end
                        if show_chams then
                            if not entry.highlight then
                                entry.highlight = Instance.new("Highlight")
                                entry.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                entry.highlight.Parent = self._icon_gui
                            end
                            entry.highlight.Adornee = inst
                            entry.highlight.FillColor = color
                            entry.highlight.OutlineColor = color
                            entry.highlight.FillTransparency = tonumber(data.chams_transparency) or l.chams_transparency
                            entry.highlight.OutlineTransparency = 0
                            entry.highlight.Enabled = true
                        elseif entry.highlight then
                            entry.highlight.Enabled = false
                        end
                    end
                end
            end
        end
    end
end

function esp:_update_trails(now)
    local tr = self.style.trail
    if not tr.enabled then
        for _, td in pairs(self._trail_data) do
            for _, ln in ipairs(td.lines) do ln.Visible = false end
        end
        return
    end
    for subject, entry in pairs(self._entries) do
        local model = self:_get_model(subject, entry.is_npc)
        if model then
            local _, hrp = get_hum_hrp(model)
            if hrp then
                local pos = hrp.Position
                local td = self._trail_data[subject]
                if not td then
                    td = { points = {}, lines = {} }
                    self._trail_data[subject] = td
                end
                td.points[#td.points + 1] = { pos = pos, t = now }
                while #td.points > tr.max_segments do table.remove(td.points, 1) end
                while td.points[1] and (now - td.points[1].t) > tr.segment_life do
                    table.remove(td.points, 1)
                end
                while #td.lines < #td.points - 1 do
                    td.lines[#td.lines + 1] = new_drawing("Line", { Visible = false, Thickness = tr.thickness, Color = tr.color, Transparency = 1 - tr.transparency })
                end
                while #td.lines > #td.points - 1 do
                    local ln = table.remove(td.lines)
                    if ln then ln:Remove() end
                end
                for i = 1, #td.points - 1 do
                    local sp1, o1 = wtvp(td.points[i].pos)
                    local sp2, o2 = wtvp(td.points[i + 1].pos)
                    local ln = td.lines[i]
                    if ln and o1 and o2 then
                        ln.From = Vector2.new(sp1.X, sp1.Y)
                        ln.To = Vector2.new(sp2.X, sp2.Y)
                        ln.Color = tr.color
                        ln.Thickness = tr.thickness
                        ln.Transparency = 1 - tr.transparency
                        ln.Visible = true
                    elseif ln then
                        ln.Visible = false
                    end
                end
            end
        end
    end
    for subject, td in pairs(self._trail_data) do
        if not self._entries[subject] then
            for _, ln in ipairs(td.lines) do
                if ln then ln:Remove() end
            end
            self._trail_data[subject] = nil
        end
    end
end

function esp:Start()
    if self._running then return end
    self._running = true

    local pa = Players.PlayerAdded:Connect(function(p) self:Add(p, false) end)
    local pr = Players.PlayerRemoving:Connect(function(p) self:Remove(p) end)
    self._connections[#self._connections + 1] = pa
    self._connections[#self._connections + 1] = pr
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then self:Add(p, false) end
    end

    local ai_folder = Workspace:FindFirstChild("AiZones") or Workspace:FindFirstChild("AI")
    if ai_folder then
        for _, m in ipairs(ai_folder:GetDescendants()) do
            if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then
                self:Add(m, true)
            end
        end
        local aa = ai_folder.DescendantAdded:Connect(function(m)
            if m:IsA("Model") and m:FindFirstChildOfClass("Humanoid") then self:Add(m, true) end
        end)
        local ar = ai_folder.DescendantRemoving:Connect(function(m)
            if self._entries[m] then self:Remove(m) end
        end)
        self._connections[#self._connections + 1] = aa
        self._connections[#self._connections + 1] = ar
    end

    local rs = RunService.RenderStepped:Connect(function(dt)
        local now = tick()
        for _, entry in pairs(self._entries) do
            self:_update_entry(entry, dt)
        end
        self:_scan_loot(now)
        self:_render_loot()
        self:_update_trails(now)
    end)
    self._connections[#self._connections + 1] = rs
end

function esp:Stop()
    self._running = false
    for _, c in ipairs(self._connections) do
        c:Disconnect()
    end
    self._connections = {}
    for subject, e in pairs(self._entries) do
        self:_destroy_entry(e)
        self._entries[subject] = nil
    end
    for _, entry in pairs(self._loot_entries) do
        self:_destroy_loot_entry(entry)
    end
    self._loot_entries = {}
    for _, td in pairs(self._trail_data) do
        for _, ln in ipairs(td.lines) do
            if ln then ln:Remove() end
        end
    end
    self._trail_data = {}
    if self._icon_gui then
        self._icon_gui:Destroy()
        self._icon_gui = nil
    end
end

return esp
