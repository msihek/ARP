script_name('Auto RP')
script_authors('msihek', 'revavi')
script_version('4.0')
script_version_number(4)

local encoding = require 'encoding'
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local imgui = require 'mimgui'
local ffi = require 'ffi'

encoding.default = 'CP1251'
u8 = encoding.UTF8

local this = thisScript()

local ImVec2, ImVec4, new = imgui.ImVec2, imgui.ImVec4, imgui.new
local menu = new.bool(false)

local id, name = '', ''
local gun, lastgun = 0, 0

local cfg = inicfg.load({
    rp = {
        usedrugs = true,
        mask = true,
        armor = true,
        weapon = true
    },
    bind = {
        armor = true,
        usedrugs = true,
        mask = true,
    }
}, 'AutoRP by msihek.ini')

local cfg_ = {
    usedrugs = new.bool(cfg.rp.usedrugs),
    weapon = new.bool(cfg.rp.weapon),
    mask = new.bool(cfg.rp.mask),
    armor = new.bool(cfg.rp.armor),
    bindarmour = new.bool(cfg.bind.armor),
    bindusedrugs = new.bool(cfg.bind.usedrugs),
    bindmask = new.bool(cfg.bind.mask)
}

local cPos = {x = 0, y = 0}

local gun_ids = {[23]="Пистолет с глушителем", [24]="пистолет Desert Eagle", [25]="Дробовик", [26]="Обрез", [27]="Скорострельный дробовик",
    [28]="ПП Micro-UZI", [29]="карабин MP-5", [30]="карабин AK-47", [31]="карабин M4", [33]="Охотничье ружье", [34]="Снайперскую винтовку"}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	repeat wait(0) until isSampAvailable()
    
    sampRegisterChatCommand('arp', function() menu[0] = not menu[0] end)
	sampAddChatMessage("["..this.name.."] {64fadc}Authors: "..table.concat(this.authors, "; " )..".".. " {fc031c}Open Menu: /arp", 0x2986cc)
	repeat wait(200) until sampIsLocalPlayerSpawned()
	id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	name = sampGetPlayerNickname(id)
	while true do wait(0)
        if not sampIsChatInputActive() and not isPauseMenuActive() and not isGamePaused() then
            if isKeyJustPressed(0x33) and cfg.bind.mask then sampSendChat("/mask") end
			if isKeyJustPressed(0x32) and cfg.bind.armor then sampSendChat("/armour") end
			if isKeyJustPressed(0x31) and cfg.bind.usedrugs then sampSendChat("/usedrugs 3") end
		end
        if lastgun ~= getCurrentCharWeapon(PLAYER_PED) then
            if cfg.rp.weapon then
                local gun = getCurrentCharWeapon(PLAYER_PED)
                for k, v in pairs(gun_ids) do
                    if gun == 0 and lastgun == k then sampSendChat("/me убрал оружие в спортивную сумку") break
                    elseif gun == k then sampSendChat('/me достал из спортивной сумки '..v) break end
                end lastgun = gun
            end
        end
    end
end

function sampev.onServerMessage(color, text)
    if text == " "..name.." принимает дозу наркотиков" and cfg.rp.usedrugs then lua_thread.create(function() wait(350) sampSendChat("/me достал пачку с таблетками от аллергии, после чего положил несколько в рот") end) end
    if text == name.."["..id.. "] надел бронежилет." and cfg.rp.armor then lua_thread.create(function() wait(350) sampSendChat("/me достал из спортивной сумки бронепластину, после чего заменил её в бронежилете") end) end
    if text == name.."["..id.. "] снял бронежилет." and cfg.rp.armor then lua_thread.create(function() wait(350) sampSendChat("/me достал старую бронепластину из бронежилета, после чего сложил в спортивную сумку") end) end
    if text == "[Информация] {FFFFFF}Вы успешно надели маску." and cfg.rp.mask then lua_thread.create(function() wait(350) sampSendChat("/me взял из сумки балаклаву и накинул на голову") end) end
    if text == "[Информация] {FFFFFF}Вы успешно выкинули маску." and cfg.rp.mask then lua_thread.create(function() wait(350) sampSendChat("/me скинул из себя балаклаву и выкинул всторону") end) end
end

local mainWin = imgui.OnFrame(function() return menu[0] and not isPauseMenuActive() and not isGamePaused() end,
function(self)
	imgui.SetNextWindowPos(ImVec2(select(1, getScreenResolution())/2-200, select(2, getScreenResolution())/2-125), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowSize(ImVec2(400, 280), 1)
	imgui.Begin(this.name..'|| Authors: '..table.concat(this.authors, "; "), menu, imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoResize)
        if imgui.CollapsingHeader(u8'Клавиши биндера') then
            imgui.Text(u8'1 = /usedrugs 3')
            imgui.Text(u8'2 = /armour')
            imgui.Text(u8'3 = /mask')
            imgui.Separator()
        end
        cPos = imgui.GetCursorPos()
        imgui.Text(u8'Авто-отыгровка:')
        if imgui.Checkbox(u8'/usedrugs', cfg_.usedrugs) then cfg.rp.usedrugs = not cfg.rp.usedrugs; inicfg.save(cfg, 'AutoRP by msihek.ini') end
        if imgui.Checkbox(u8'Оружие', cfg_.weapon) then cfg.rp.weapon = not cfg.rp.weapon; inicfg.save(cfg, 'AutoRP by msihek.ini') end
        if imgui.Checkbox(u8'/armor', cfg_.armor) then cfg.rp.armor = not cfg.rp.armor; inicfg.save(cfg, 'AutoRP by msihek.ini') end
        if imgui.Checkbox(u8'/mask', cfg_.mask) then cfg.rp.mask = not cfg.rp.mask; inicfg.save(cfg, 'AutoRP by msihek.ini') end
        imgui.Text(os.date("%H:%M:%S"))
        imgui.SetCursorPos(ImVec2(imgui.GetWindowWidth()/2, cPos.y))
        imgui.BeginChild('Binder', ImVec2((imgui.GetWindowWidth()/2)-20, imgui.GetWindowHeight()-cPos.y-20), false)
            imgui.Text(u8"Биндер:")
            if imgui.Checkbox(u8'/armor', cfg_.bindarmour) then cfg.bind.armor = not cfg.bind.armor; inicfg.save(cfg, 'AutoRP by msihek.ini') end
            if imgui.Checkbox(u8'/drugs', cfg_.bindusedrugs) then cfg.bind.usedrugs = not cfg.bind.usedrugs; inicfg.save(cfg, 'AutoRP by msihek.ini') end
            if imgui.Checkbox(u8'/mask', cfg_.bindmask) then cfg.bind.mask = not cfg.bind.mask; inicfg.save(cfg, 'AutoRP by msihek.ini') end
        imgui.EndChild()
        imgui.SetCursorPos(ImVec2(5, imgui.GetWindowHeight()-28))
        if imgui.Button(u8'Перезагрузить скрипт') then thisScript():reload() end imgui.SameLine()
        if imgui.Button(u8'Выключить скрипт') then
            thisScript():unload() 
            sampAddChatMessage("["..this.name.."] {fc031c}Off!", 0x2986cc)
        end      
    imgui.End()
end)


function theme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

imgui.OnInitialize(function()
	theme()
end)