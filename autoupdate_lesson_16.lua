script_name('Autoupdate script') -- название скрипта
script_author('FORMYS') -- автор скрипта
script_description('Autoupdate') -- описание скрипта

require "lib.moonloader" -- подключение библиотеки
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'
local key = require "vkeys"
local imgui = require 'imgui'
local sampev = require "lib.samp.events"
local encoding = require 'encoding'
local imadd = require 'imgui_addons'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local themes = import "resource/imgui_themes.lua"
local fa = require 'fAwesome5'

local script_vers = 19
local script_vers_text = "1.8"

--------------------------------------------
local directIni = 'moonloader\\config\\PrisonHelper.ini'
local mainIni = inicfg.load({
    main = 
    {
        theme = 1,
        selectorg = 1

    },
    fastmenu =
    {
        fastmenu = true,
        invite = true,
        uninvite = true,
        giverank = true,
        fwarn = true,
        unfwarn = true,
        fmute = true,
        unfmute = true,
        blacklist = true,
        unblacklist = true
    },
    tags = 
    {
        tag = true,
        tagfind = true,
        nametag = '',
        dusecmd = 'dep',
        dcmd = 'd',
    },
    widget = 
    {  
        widget = true,
        nick = true,
        time = true,
        server = true,
        hpap = true,
        ping = true,
        fastplayer = true,
        tag = true,
    },
    tagdep1 = 
    {
        dep1_tag1 = 'ФБР',
        dep1_tag2 = 'ЛСПД',
        dep1_tag3 = 'СФПД',
        dep1_tag4 = 'РКШД',
        dep1_tag5 = 'ЛВПД',
        dep1_tag6 = 'ТСР',
        dep1_tag7 = 'ЛСа',
        dep1_tag8 = 'СФа',        
        dep1_tag9 = 'ЦБ',
        dep1_tag10 = 'ГЦЛ'
    },
    tagdep2 = 
    {
        dep2_tag1 = 'ФБР',
        dep2_tag2 = 'ЛСПД',
        dep2_tag3 = 'СФПД',
        dep2_tag4 = 'РКШД',
        dep2_tag5 = 'ЛВПД',
        dep2_tag6 = 'ТСР',
        dep2_tag7 = 'ЛСа',
        dep2_tag8 = 'СФа',        
        dep2_tag9 = 'ЦБ',
        dep2_tag10 = 'ГЦЛ'
    },
    save = 
    {
        autosave = true,
        timersave = 300
    }
}, directIni)
local stateIni = inicfg.save(mainIni, directIni)
local theme = imgui.ImInt(mainIni.main.theme)
--------------------------------------------------------------
local tabletag1 = {
    {'tag11', mainIni.tagdep1.dep1_tag1},
    {'tag12', mainIni.tagdep1.dep1_tag2},
    {'tag13', mainIni.tagdep1.dep1_tag3},
    {'tag14', mainIni.tagdep1.dep1_tag4},
    {'tag15', mainIni.tagdep1.dep1_tag5},
    {'tag16', mainIni.tagdep1.dep1_tag6},
    {'tag17', mainIni.tagdep1.dep1_tag7},
    {'tag18', mainIni.tagdep1.dep1_tag8},
    {'tag19', mainIni.tagdep1.dep1_tag9},
    {'tag110', mainIni.tagdep1.dep1_tag10},
}

local tabletag2 = {
    {'tag21', mainIni.tagdep2.dep2_tag1},
    {'tag22', mainIni.tagdep2.dep2_tag2},
    {'tag23', mainIni.tagdep2.dep2_tag3},
    {'tag24', mainIni.tagdep2.dep2_tag4},
    {'tag25', mainIni.tagdep2.dep2_tag5},
    {'tag26', mainIni.tagdep2.dep2_tag6},
    {'tag27', mainIni.tagdep2.dep2_tag7},
    {'tag28', mainIni.tagdep2.dep2_tag8},
    {'tag29', mainIni.tagdep2.dep2_tag9},
    {'tag210', mainIni.tagdep2.dep2_tag10},
}
local nametags1 = {}
local nametags2 = {}

for k, v in pairs(tabletag1) do
    _G['dep_'..v[1]] = imgui.ImBuffer(u8(v[2]), 32)
    if #_G['dep_'..v[1]].v > 0 then table.insert(nametags1, _G['dep_'..v[1]].v) end
end 
for k, v in pairs(tabletag2) do
    _G['dep_'..v[1]] = imgui.ImBuffer(u8(v[2]), 32)
    if #_G['dep_'..v[1]].v > 0 then table.insert(nametags2, _G['dep_'..v[1]].v) end
end 
local dcmd = imgui.ImBuffer(mainIni.tags.dcmd, 16)
local dusecmd = imgui.ImBuffer(mainIni.tags.dusecmd, 16)
local selectedtag1 = imgui.ImInt(0)
local selectedtag2 = imgui.ImInt(0)
--------------------------------------------------------------
local fmenu = {
    {'fastmenu', mainIni.fastmenu.fastmenu},
    {'invite', mainIni.fastmenu.invite},
    {'uninvite', mainIni.fastmenu.uninvite},
    {'giverank', mainIni.fastmenu.giverank},
    {'fwarn', mainIni.fastmenu.fwarn},
    {'unfwarn', mainIni.fastmenu.unfwarn},
    {'fmute', mainIni.fastmenu.fmute},
    {'unfmute', mainIni.fastmenu.unfmute},
    {'blacklist', mainIni.fastmenu.blacklist},
    {'unblacklist', mainIni.fastmenu.unblacklist}
}
local wdg_widget = imgui.ImBool(true)
for k, v in pairs(fmenu) do
    _G['fm_'..v[1]] = imgui.ImBool(v[2])
end
---------------------------------------------
local bindfile1 = getWorkingDirectory() .. '\\config\\PrisonHelper\\lic.bind'
local lic = {}
local statuslic = false
local licdate = 'xx.xx.xxxx'
local licreason = 'Ошибка проверки или проблемы на стороне хоста'
---------------------------------------------
update_state = false

local imguiWindows = {
    {'update', true, true}, -- окно main с курсором и морозом персонажа
    {'fastmenu', true, false}, -- окно about с курсором, но без мороза
    {'main', true, false},
    {'news', true, false},
    {'dep', true, false},
    {'widget', false, false}-- окно overlay без курсора и без мороза
}
for k, v in pairs(imguiWindows) do
    _G['IW_'..v[1]] = imgui.ImBool(false)
end
-----------------------------------------------------
local widget = {
    {'nick', mainIni.widget.nick},
    {'server', mainIni.widget.server},
    {'time', mainIni.widget.time},
    {'ping', mainIni.widget.ping},
    {'hpap', mainIni.widget.hpap},
    {'fastplayer', mainIni.widget.fastplayer},
    {'tag', mainIni.widget.tag}
}
for k, v in pairs(widget) do
    _G['wdg_'..v[1]] = imgui.ImBool(v[2])
end
-------------------премии-----------------------------
for i = 1, 9 do
    _G['kolvosotr_'..i] = imgui.ImInt(3)
    _G['premprice_'..i] = imgui.ImInt(100000)
end
local selectchet = imgui.ImBool(false)
-----------------------------------------------------------------------
-------------------------------------------
local news = {
    {'Обновление 1.8', 'Полный список изменений в версии 1.8 - 2.0 будет опубликован позже.', 492, 170, 'https://sun9-26.userapi.com/Op-FGERudzBRi7zDTVslI5dwtUrUDJRGZWLe9Q/OiGzClLsxNs.jpg', 484, 124, 'picnews6', ' 21.06.2020'},
    {'ОБНОВЛЕНИЕ 1.7', '- Исправлен баг с /unblacklist в меню взаимодействия\n- Добавлено меню премий (/prem). В будущем будет автоматическое определение кол-во сотрудников определенного ранга;', 492, 170, 'https://sun9-12.userapi.com/c857020/v857020852/11d7c5/rFSsZFf2Vso.jpg', 484, 124, 'picnews4', ' 16.06.2020'},
    {'ОБНОВЛЕНИЕ 1.6', '- Обновлен раздел Новости и обновления, теперь все выглядит эстетичнее, одновременно вмещаются 3 новости;\n- Теперь не нужно вручную сохранять изменения. Скрипт будет делать это автоматически;\n- Обновлено меню взаимодействия\n- Временно отключена проверка на кол-во символов в своей причине увольнения/черного списка;\n- Временно отключен показ нововведений в новых обновлениях (/update).', 492, 170, 'https://sun9-12.userapi.com/c857020/v857020852/11d7c5/rFSsZFf2Vso.jpg', 484, 124, 'picnews4', ' 10.06.2020'},
    {'ОБНОВЛЕНИЕ 1.5', '- Добавлено автообновление для скрипта;\n- Добавлена возможность редактировать меню взаимодействия (выключать ненужные Вам пункты)\n- Добавлен пункт "Новости и обновления", в котором будет публиковаться лог разработки и скидки на подписку (в будущем)\n- Исправлен баг, когда это окно не закрывалось;\n- Добавлен выбор темы интерфейса.', 492, 170, 'https://sun9-14.userapi.com/c831209/v831209043/1ce490/cntbyVkMUZI.jpg', 484, 124, 'picnews3', ' 07.06.2020'},
    {'ОБНОВЛЕНИЕ 1.1', '- Добавлено меню взаимодействия: возможность быстро принять, уволить, повысить ранг, выдать и снять выговор, выдать и снять мут, занести и вынести из ЧС\n- Исправлены некоторые баги.', 492, 170, 'https://sun9-69.userapi.com/jkoJW7hmpVzQMPVLTjRlLwYvGRKf4jvG1VPkMQ/E7noxvmYLM4.jpg', 484, 124, 'picnews2', ' 07.05.2020'},
    {'РЕЛИЗ СКРИПТА', 'Релиз скрипта.', 492, 170, 'https://pp.userapi.com/fFhPPMps-mi4t0nrTd7oJY5hpJsFL-DWi2Hc0g/aI6-oujqBLE.jpg', 484, 124, 'picnews1', ' 01.05.2020'},
}
--------------------------------------------------
local fast_invite = imgui.ImBool(true)
local fast_uninvite = imgui.ImBool(true)
local fast_giverank = imgui.ImBool(true)
--------------------увольнение
local with4s = imgui.ImBool(false)
local reason4s = imgui.ImBuffer(32)
local reasonuval = {u8'по с/ж', u8'нарушение устава', u8'проф. непригодность', u8'своя причина'}
local reasonuvalselect = imgui.ImInt(0)
local svoyauval = imgui.ImBuffer(64)

----------------------
local playerskin
-------------------------------------

local orgnamesrank = {
    {u8'1 | Кадет', u8'2 | Офицер полиции 1 ст.', u8'3 | Офицер полиции 2 ст.', u8'4 | Капрал', u8'5 | Сержант', u8'6 | Лейтенант', u8'7 | Капитан', u8'8 | Ассистент шефа', u8'9 | Заместитель шефа'},
    {u8'1 | Кадет', u8'2 | Офицер полиции 1 ст.', u8'3 | Офицер полиции 2 ст.', u8'4 | Капрал', u8'5 | Сержант', u8'6 | Лейтенант', u8'7 | Капитан', u8'8 | Ассистент шефа', u8'9 | Заместитель шефа'},
    {u8'1 | Кадет', u8'2 | Офицер полиции 1 ст.', u8'3 | Офицер полиции 2 ст.', u8'4 | Капрал', u8'5 | Сержант', u8'6 | Лейтенант', u8'7 | Капитан', u8'8 | Ассистент шефа', u8'9 | Заместитель шефа'},
    {u8'1 | Стажер', u8'2 | Помощник шерифа 1 ст.', u8'3 | Помощник шерифа 2 ст.', u8'4 | Капрал', u8'5 | Сержант', u8'6 | Лейтенант', u8'7 | Капитан', u8'8 | Ассистент шерифа', u8'9 | Заместитель шерифа'},
    {u8'1 | Стажер', u8'2 | Младший Агент', u8'3 | Агент', u8'4 | Агент OPR', u8'5 | Агент DEA', u8'6 | Агент CID', u8'7 | Глава DEA/CID/OPR', u8'8 | Инспектор', u8'9 | Заместитель Директора'},
    {u8'1 | Охранник', u8'2 | Конвоир', u8'3 | Дежурный', u8'4 | Ст. Дежурный', u8'5 | Надзиратель', u8'6 | Начальник блока', u8'7 | Инспектор', u8'8 | Начальник инспекции', u8'9 | Зам.начальника тюрьмы'},
}
local orgnames = {u8'ЛСПД', u8'СФПД', u8'ЛВПД', u8'РКШД', u8'ФБР', u8'ТСР'}
local selectorg = imgui.ImInt(mainIni.main.selectorg)
-------------------повышение ранга
local nameranks = {u8'1 | Охранник', u8'2 | Конвоир', u8'3 | Дежурный', u8'4 | Ст. дежурный', u8'5 | Надзиратель', u8'6 | Начальник блока', u8'7 | Инспектор', u8'8 | Начальник инспекции', u8'9 | Зам. начальника тюрьмы'}
local selectedrank = imgui.ImInt(1)
--------------------------------------
-------------------выдача выговора----------
local reasonwarn = {u8'нарушение устава', u8'прогул рабочего дня', u8'прогул строя', u8'нарушение суббординации', u8'своя причина'}
local reasonwarnselect = imgui.ImInt(0)
local svoyawarn = imgui.ImBuffer(32)
-----------------------------------------
------------------выдача мута
local reasonmute = {u8'поломка рации', u8'своя причина'}
local selectedmute = imgui.ImInt(0)
local svoyamute = imgui.ImBuffer(32)
local timemute = imgui.ImInt(30)
-----------------------------------------

local update_url = "https://raw.githubusercontent.com/MatthewFox295/helper/master/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "https://github.com/MatthewFox295/helper/blob/master/autoupdate_lesson_16.lua?raw=true" -- тут свою ссылку
local script_path = thisScript().path

local vzID = 0
------------------------ТЕГИ-------------------------------
local tag = imgui.ImBool(mainIni.tags.tag)
local tagfind = imgui.ImBool(mainIni.tags.tagfind)
local nametag = imgui.ImBuffer(mainIni.tags.nametag, 24)
local statustag = 'Не найдено'
local orgtags = {u8'ФБР', u8'ЛСПД', u8'СФПД', u8'ЛВПД', u8'РКШД', u8'ТСР', u8'ЛСа', u8'СФа', u8'ЛСМЦ', u8'СФМЦ', u8'ЛВМЦ', u8'СМИ ЛС', u8'СМИ СФ', u8'СМИ ЛВ', u8'Пра-во', u8'ЦБ', u8'ГЦЛ'}
local selecttag = imgui.ImInt(0)
-------------------------------------------------------------
local autosave = imgui.ImBool(mainIni.save.autosave)
local timersave = imgui.ImInt(mainIni.save.timersave)
-----------------------------------------------------------
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    downloadUrlToFile('https://gitlab.com/snippets/1988656/raw', getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\lic.bind')
    wait(2000)
    sampRegisterChatCommand("update", function()
        IW_update.v = not IW_update.v
    end)
    sampRegisterChatCommand('fastmenu', function()
        IW_fastmenu.v = not IW_fastmenu.v
        progress = 0
    end)
    sampRegisterChatCommand('imgui', function()
        IW_main.v = not IW_main.v
        getSkin()
    end)
    sampRegisterChatCommand('news', function()
        IW_news.v = not IW_news.v
    end)
    sampRegisterChatCommand('wdg', function()
        IW_widget.v = not IW_widget.v 
    end)
    sampRegisterChatCommand(dusecmd.v, function()
        IW_dep.v = not IW_dep.v
    end)
    sampRegisterChatCommand('checklic', function()
        checkLic()
    end)
    imgui.SwitchContext()
    themes.SwitchColorTheme(theme.v)
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)
    imgui.Process = false
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                --update_state = true
                IW_update.v = true
            end
            os.remove(update_path)
        end
    end)
    --org = 'Не удалось проверить'
    for k, v in pairs(news) do
        if not doesFileExist(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png') then
            downloadUrlToFile(v[5], getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png')
            wait(1000)
            print('Загружаю '..v[8]..'.png, жду 1000 мс')
        end
        v[8] = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png')
    end
    --[[if autosave.v then
        for i = 1, 999 do 
            if autosave.v then
                savesettings()
            end
            wait(timersave.v * 10)
        end
    end--]]
    IW_widget.v = mainIni.widget.widget
    showCursor(false)
    if doesFileExist(bindfile1) then
        local fbind = io.open(bindfile1, "r")
        if fbind then
            lic = decodeJson(fbind:read("a*"))
            fbind:close()
        end
    end
    --getSkin()
    checkLic()
    main = 1
	while true do
        wait(0)
        local imguiStatus = {false, false, false}
        for k, v in pairs(imguiWindows) do
            if _G['IW_'..v[1]].v then
                imguiStatus[1] = true
                if v[2] then imguiStatus[2] = true end
                if v[3] then imguiStatus[3] = true end
            end
        end
        imgui.Process = imguiStatus[1]
        imgui.ShowCursor = imguiStatus[2]
        imgui.LockPlayer = imguiStatus[3]
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
            break
        end
        if isKeyJustPressed(VK_Q) then
            if fm_fastmenu.v then
                local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
                if valid and doesCharExist(ped) then
                    local result, id = sampGetPlayerIdByCharHandle(ped) 
                    if result then 
                        IW_fastmenu.v = true
                        vzID = id
                        progress = 0
                    end
                end
            end
        end
        --if statuslic then sampAddChatMessage('true', -1) else sampAddChatMessage('false', -1) end
	end
end

function imgui.OnDrawFrame()
    local sw, sh = getScreenResolution()
    _, wid = sampGetPlayerIdByCharHandle(PLAYER_PED) 
    local wname = sampGetPlayerNickname(wid)
    if IW_update.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'Автообновление',IW_update, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if tonumber(updateIni.info.vers) > script_vers then
                imgui.Text(u8'Доступно новое обновление!')
                imgui.Text(u8'Текущая версия скрипта: '..script_vers_text)
                imgui.Text(u8'Актуальная версия скрипта: '..updateIni.info.vers_text)
                if imgui.Button(u8'Обновить') then update_state = true end
            else
                imgui.Text(u8'Установлена актуальная версия скрипта!')
            end
        imgui.End()
    end
    if IW_main.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.ICON_FA_LIST_UL..u8' Основное меню',IW_main, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(fa.ICON_FA_USER..u8' Профиль', imgui.ImVec2(227, 23)) then main = 1 end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_COGS..u8' Настройки и функции', imgui.ImVec2(228, 23)) then main = 2 end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_SAVE..u8' Сохранить', imgui.ImVec2(227, 23)) then savesettings() end
        imgui.Separator()
        if main == 1 then
            --[[imgui.Combo(u8'Ваша организация', selectorg, orgnames, #orgnames)
            imgui.Combo(u8'Ранги ['..orgnames[selectorg.v + 1]..']', selectedrank, orgnamesrank[selectorg.v + 1], #orgnamesrank[selectorg.v + 1])--]]
            imgui.SetCursorPosX(284)
            imgui.Image(playerskin, imgui.ImVec2(131, 131))
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
                imgui.TextUnformatted(getCharModel(playerPed))
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            imgui.TextColoredRGB(u8'Ник: '..wname:gsub('_',' '), 2)
            imgui.TextColoredRGB(u8'Ваша организация:' , 2)
            imgui.PushItemWidth(100)
            imgui.SetCursorPosX(300)
            imgui.Combo('##myorg', selectorg, orgnames, #orgnames)
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            if statuslic then
                imgui.TextColoredRGB(u8'Подписка: {00ff00}активна', 2)
                imgui.TextColoredRGB(u8'Срок действия до: '..licdate, 2)
            elseif not statuslic then
                imgui.TextColoredRGB(u8'Подписка: {ff0000}неактивна', 2)
                if licreason == 'Ошибка проверки или проблемы на стороне хоста' then imgui.TextColoredRGB(u8'{808080}Ошибка проверки или проблемы на стороне хоста', 2)
                elseif licreason == 'Истек срок действия' then imgui.TextColoredRGB(u8'{808080}Истек срок действия', 2)
                elseif licreason == 'Отсутствует подписка' then imgui.TextColoredRGB(u8'{808080}Отсутствует подписка', 2) end
                imgui.TextColoredRGB(u8'{808080}Если у вас активна подписка, то попробуйте перезапустить скрипт (CTRL + R)', 2)
            end
        end
        if main == 2 then
            imgui.BeginChild('##polo', imgui.ImVec2(200,440), true)
                if imgui.Selectable(u8'Виджет') then menu = 1 end
                imgui.Separator()
                if imgui.Selectable(u8'Меню взаимодействия') then menu = 2 end
                imgui.Separator()
                if imgui.Selectable(u8'Премии') then menu = 3 end
                imgui.Separator()
                if imgui.Selectable(u8'Автоматический тег /d') then menu = 4 end
                imgui.Separator()
            imgui.EndChild()
            imgui.SameLine()
            if menu == 1 then
                imgui.BeginChild('##menu1', imgui.ImVec2(487, 440), true)
                    imadd.ToggleButton('##wdg', IW_widget) imgui.SameLine() imgui.Text(u8'Включить виджет')
                    if imgui.Button(u8'Редакировать позицию', imgui.ImVec2(479, 23)) then
                        IW_main.v = false
                        IW_widget.v = true
                        editposwdg = true
                    end
                    imgui.NewLine()
                    imgui.BeginChild('##cmn',imgui.ImVec2(479,182), true)
                        imgui.Columns(2, '##wdgcolumns')
                        imadd.ToggleButton('##wdg1', wdg_nick) imgui.SameLine() imgui.Text(u8'Ваш ник и id')
                        imgui.NextColumn()
                        imgui.Text(wname..' ['..wid..']')
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg2', wdg_server) imgui.SameLine() imgui.Text(u8'Название сервера')
                        imgui.NextColumn()
                        imgui.Text(u8(sampGetCurrentServerName()))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg3', wdg_time) imgui.SameLine() imgui.Text(u8'Время (на вашем компьютере)')
                        imgui.NextColumn()
                        imgui.Text(os.date("%X",os.time()))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg4', wdg_ping) imgui.SameLine() imgui.Text(u8'Ваш пинг')
                        imgui.NextColumn()
                        imgui.Text(sampGetPlayerPing())
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg5', wdg_hpap) imgui.SameLine() imgui.Text(u8'Здоровье и броня')
                        imgui.NextColumn()
                        imgui.Text(sampGetPlayerHealth(wid)..' | '..sampGetPlayerArmor(wid))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg6', wdg_fastplayer) imgui.SameLine() imgui.Text(u8'Выделенный игрок')
                        imgui.NextColumn()
                        imgui.Text(sampGetPlayerNickname(vzID)..' ['..vzID..']')
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg7', wdg_tag) imgui.SameLine() imgui.Text(u8'Текущий канал связи')
                        imgui.NextColumn()
                        imgui.Text(u8'['..nametags1[selectedtag1.v+1]..'] - ['..nametags2[selectedtag2.v+1]..']')
                        imgui.Columns(1)
                    imgui.EndChild()
                imgui.EndChild()
            end
    --[[if wdg_time.v then imgui.Text(os.date("%X",os.time())) end
    if wdg_ping.v then imgui.Text(sampGetPlayerPing()) end
    if wdg_hpap.v then imgui.Text(sampGetPlayerHealth(wid)..' | '..sampGetPlayerArmor(wid)) end
    if wdg_fastplayer.v then imgui.Text(sampGetPlayerNickname(vzID)..' ['..vzID..']') end
    if wdg_tag.v then imgui.Text(u8'['..nametags1[selectedtag1.v+1]..'] - ['..nametags2[selectedtag2.v+1]..']') end--]]
            if menu == 2 then
                imgui.BeginChild('##menu2', imgui.ImVec2(487, 440), true)
                    imadd.ToggleButton('##fm_fastmenu', fm_fastmenu)
                    imgui.SameLine()
                    imgui.Text(u8'Включить меню взаимодействия')
                    imgui.NewLine()
                    imadd.ToggleButton('##fm1', fm_invite) imgui.SameLine() imgui.Text(u8'Принять в организацию')
                    imgui.Separator()
                    imadd.ToggleButton('##fm2', fm_uninvite) imgui.SameLine() imgui.Text(u8'Уволить из организации')
                    imgui.Separator()
                    imadd.ToggleButton('##fm3', fm_giverank) imgui.SameLine() imgui.Text(u8'Выдать повышение')
                    imgui.Separator()
                    imadd.ToggleButton('##fm4', fm_fwarn) imgui.SameLine() imgui.Text(u8'Выдать выговор сотруднику')
                    imgui.Separator()
                    imadd.ToggleButton('##fm5', fm_unfwarn) imgui.SameLine() imgui.Text(u8'Снять выговор сотруднику')
                    imgui.Separator()
                    imadd.ToggleButton('##fm6', fm_fmute) imgui.SameLine() imgui.Text(u8'Выдать мут рации')
                    imgui.Separator()
                    imadd.ToggleButton('##fm7', fm_unfmute) imgui.SameLine() imgui.Text(u8'Снять мут рации')
                    imgui.Separator()
                    imadd.ToggleButton('##fm8', fm_blacklist) imgui.SameLine() imgui.Text(u8'Занести в черный список')
                    imgui.Separator()
                    imadd.ToggleButton('##fm9', fm_unblacklist) imgui.SameLine() imgui.Text(u8'Вынести из черного списка')
                imgui.EndChild()
            end
            if menu == 3 then
                imgui.BeginChild('##menu4', imgui.ImVec2(487, 440), true)
                    imgui.BeginChild('##menu41',imgui.ImVec2(479,284), true)
                        imgui.Columns(4, 'columns', true)
                        imgui.Text(u8'Ранг')
                        imgui.NextColumn()
                        imgui.Text(u8'Кол-во сотрудников')
                        imgui.NextColumn()
                        imgui.Text(u8'Сумма каждому')
                        imgui.NextColumn()
                        imgui.Text(u8'Всего')
                        imgui.Separator()
                        imgui.NextColumn()
                        for i = 1, 8 do
                            imgui.Text(i)
                            imgui.NextColumn()
                            imgui.InputInt('##ffesw'..i,_G['kolvosotr_'..i])
                            if _G['kolvosotr_'..i].v < 0 then _G['kolvosotr_'..i].v = 0 end
                            if _G['premprice_'..i].v < 0 then _G['premprice_'..i].v = 0 end
                            imgui.NextColumn()
                            imgui.PushItemWidth(110)
                            imgui.InputInt('##ffessss'..i,_G['premprice_'..i],10000)
                            imgui.NextColumn()
                            imgui.Text(_G['kolvosotr_'..i].v * _G['premprice_'..i].v)
                            imgui.NextColumn()
                            imgui.Separator()
                        end
                        imgui.Text('9')
                        imgui.NextColumn()
                        imgui.InputInt('##ffesw9',_G['kolvosotr_9'])
                        if _G['kolvosotr_9'].v < 0 then _G['kolvosotr_9'].v = 0 end
                        if _G['premprice_9'].v < 0 then _G['premprice_9'].v = 0 end
                        imgui.NextColumn()
                        imgui.PushItemWidth(110)
                        imgui.InputInt('##ffessss9',_G['premprice_9'],10000)
                        imgui.NextColumn()
                        imgui.Text(_G['kolvosotr_9'].v * _G['premprice_9'].v)
                        imgui.Columns(1)
                    imgui.EndChild()
                    imgui.NewLine()
                    imgui.Text(u8'Всего сотрудников: '..kolvosotr_1.v + kolvosotr_2.v + kolvosotr_3.v + kolvosotr_4.v + kolvosotr_5.v + kolvosotr_6.v + kolvosotr_7.v + kolvosotr_8.v + kolvosotr_9.v)
                    imgui.Text(u8'Всего будет выплачено: '..premprice_1.v * kolvosotr_1.v + premprice_2.v * kolvosotr_2.v + premprice_3.v * kolvosotr_3.v + premprice_4.v * kolvosotr_4.v + premprice_5.v * kolvosotr_5.v + premprice_6.v * kolvosotr_6.v + premprice_7.v * kolvosotr_7.v + premprice_8.v * kolvosotr_8.v + premprice_9.v * kolvosotr_9.v)
                    if imgui.Button(u8'Выплатить премию', imgui.ImVec2(479, 23)) then
                        for i = 1, 9 do
                            if _G['kolvosotr_'..i].v > 0 and _G['premprice_'..i].v > 0 then 
                                local selectschet
                                if selectchet.v then selectschet = 0 else selectschet = 1 end
                                sampAddChatMessage('/premium '..i..' '.._G['kolvosotr_'..i].v * _G['premprice_'..i].v..' '..selectschet,-1) 
                                IW_main.v = false
                            end
                        end
                    end
                    imgui.EndChild()
            end
            if menu == 4 then
                imgui.BeginChild('##menu4', imgui.ImVec2(487, 440), true)
                    --[[imadd.ToggleButton('##tags', tag)
                    imgui.SameLine()
                    imgui.Text(u8'Автоматически ставить тег своей организации в /d')
                    imadd.ToggleButton('##tagfind', tagfind)
                    imgui.SameLine()
                    imgui.Text(u8'Автоматически искать в чате тег организации')
                    imgui.Text(u8'Введите тег своей организации (без [ ])')
                    imgui.SameLine()
                    imgui.PushItemWidth(50)
                    imgui.InputText('##nametag', nametag)--]]
                    imgui.BeginChild('##tegi',imgui.ImVec2(479,79), true)
                        imgui.PushItemWidth(80)
                        imgui.InputText(u8'Команда', dusecmd)
                        imgui.SameLine()
                        showHelp('Без "/"\nПосле смены перезагрузите скрипт (CTRL + R)')
                        imgui.PushItemWidth(50)
                        imgui.InputText(u8'Команда рации', dcmd)
                        imgui.SameLine()
                        showHelp('Без "/"\nПосле смены перезагрузите скрипт (CTRL + R)')
                        imgui.PushItemWidth(50)
                        imgui.InputText(u8'Клавиша', dcmd)
                    imgui.EndChild()
                    imgui.BeginChild('##tabletag1', imgui.ImVec2(237, 349), true)
                        for k, v in pairs(tabletag1) do
                            imgui.Text(u8'Первый тег рации №'..k)
                            imgui.SameLine()
                            showHelp('После изменения нажмите "Сохранить"')
                            imgui.InputText('##tabletag1'..k, _G['dep_'..v[1]])
                        end
                    imgui.EndChild()
                    imgui.SameLine()
                    imgui.BeginChild('##tabletag2', imgui.ImVec2(237, 349), true)
                    for k, v in pairs(tabletag2) do
                        imgui.Text(u8'Второй тег рации №'..k)
                        imgui.SameLine()
                        showHelp('После изменения нажмите "Сохранить"')
                        imgui.InputText('##tabletag2'..k, _G['dep_'..v[1]])
                    end
                    imgui.EndChild()
                imgui.EndChild()
            end
        end
        imgui.End()
    end
    if IW_dep.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(230, 150), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Департамент',IW_dep, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        imgui.Columns(2, 'departcolumn', true)
        imgui.Text(u8'Первый канал:')
        imgui.PushItemWidth(100)
        imgui.Combo(u8'##see', selectedtag1, nametags1, #nametags1)
        imgui.NextColumn()
        imgui.Text(u8'Второй канал:')
        imgui.PushItemWidth(100)
        imgui.Combo('##see2', selectedtag2, nametags2, #nametags2)
        imgui.Columns(1)
        imgui.Text(u8'[ '..nametags1[selectedtag1.v+1]..' ] - [ '..nametags2[selectedtag2.v+1]..' ]')
        imadd.ToggleButton('##onofftag', tag) imgui.SameLine() imgui.Text(u8'Включить рацию департамента')
        imgui.End()
    end
    if IW_widget.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('##widget',IW_widget, imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
        imgui.SetMouseCursor(imgui.MouseCursor.None)
        if wdg_nick.v then imgui.Text(wname..' ['..wid..']') end
        if wdg_server.v then imgui.Text(u8(sampGetCurrentServerName())) end
        if wdg_time.v then imgui.Text(os.date("%X",os.time())) end
        if wdg_ping.v then imgui.Text(sampGetPlayerPing()) end
        if wdg_hpap.v then imgui.Text(sampGetPlayerHealth(wid)..' | '..sampGetPlayerArmor(wid)) end
        if wdg_fastplayer.v then imgui.Text(sampGetPlayerNickname(vzID)..' ['..vzID..']') end
        if wdg_tag.v then imgui.Text(u8'['..nametags1[selectedtag1.v+1]..'] - ['..nametags2[selectedtag2.v+1]..']') end
        imgui.End()
    end
    if IW_news.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(513, 547), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'Новости и обновления',IW_news, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            for k, v in ipairs(news) do
                imgui.BeginChild('##'..k,imgui.ImVec2(v[3],v[4]), true)
                imgui.Image(v[8], imgui.ImVec2(v[6], v[7]))
                imgui.TextColoredRGB(u8(v[1]), 2)
                imgui.TextColoredRGB('{808080}'..fa.ICON_FA_CALENDAR_ALT..u8(v[9]), 2)
                imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
                imgui.TextColoredRGB(u8(v[2]), 0)
                imgui.PopTextWrapPos()
                imgui.EndChild()
            end
        imgui.End()
    end
    if IW_fastmenu.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(5, 3))
        local vzNAME = sampGetPlayerNickname(vzID)
        imgui.Begin(fa.ICON_FA_USER..' '..vzNAME..'['..vzID..']',IW_fastmenu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize)
        if progress == 0 then
            if fm_invite.v then
                if imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(335,20)) then 
                    sampSendChat('/invite '..vzID)
                    IW_fastmenu.v = false 
                end
            end
            if fm_uninvite.v then
                if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(335,20)) then 
                    progress = 1 
                end
            end
            if fm_giverank.v then
                if imgui.Button(fa.ICON_FA_SORT_AMOUNT_UP..u8' Выдать повышение', imgui.ImVec2(335,20)) then 
                    progress = 2 
                end
            end
            if fm_fwarn.v then
                if imgui.Button(fa.ICON_FA_THUMBS_DOWN..u8' Выдать выговор сотруднику', imgui.ImVec2(335,20)) then 
                    progress = 3 
                end
            end
            if fm_unfwarn.v then
                if imgui.Button(fa.ICON_FA_THUMBS_UP..u8' Снять выговор сотруднику', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unfwarn '..vzID,-1) 
                end
            end
            if fm_fmute.v then
                if imgui.Button(fa.ICON_FA_MICROPHONE..u8' Выдать мут рации', imgui.ImVec2(335,20)) then 
                    progress = 4 
                end
            end
            if fm_unfmute.v then
                if imgui.Button(fa.ICON_FA_MICROPHONE_SLASH..u8' Снять мут рации', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unfmute '..vzID,-1) 
                end
            end
            if fm_blacklist.v then
                if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Занести в черный список', imgui.ImVec2(335,20)) then 
                    progress = 5 
                end
            end
            if fm_unblacklist.v then
                if imgui.Button(fa.ICON_FA_USER_PLUS..u8' Вынести из черного списка', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unblacklist '..vzID,-1) 
                end
            end
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EDIT..u8' Редактировать', imgui.ImVec2(335,20)) then progress = 6 end
        end
        if progress == 1 then
            imgui.Text(u8'Занести в черный список') imgui.SameLine(310) imadd.ToggleButton('##chs',with4s)
            if with4s.v then 
                imgui.PushItemWidth(150)
                imgui.Text(u8'Введите причину занесения') imgui.SameLine(189) imgui.InputText('##ffwecff',reason4s) 
            end
            imgui.Separator()
            imgui.PushItemWidth(150)
            imgui.Text(u8'Выберите причину увольнения') imgui.SameLine(189) imgui.Combo('##uvaaaa',reasonuvalselect, reasonuval, #reasonuval)
            if reasonuvalselect.v == 3 then 
                imgui.Text(u8'Введите причину увольнения') imgui.SameLine(189) imgui.InputText('##efewg',svoyauval) 
            end
            imgui.Separator()
            if imgui.Button(u8'Уволить игрока', imgui.ImVec2(335,20)) then
                if reasonuvalselect.v ~= 3 then
                    sampAddChatMessage(u8:decode('/uninvite '..vzID..' '..reasonuval[reasonuvalselect.v + 1]),-1)
                    with4s.v = false
                    reasonuvalselect.v = 0
                    IW_fastmenu.v = false
                elseif reasonuvalselect.v == 3 then
                    if string.len(svoyauval.v) >= 3 then 
                        sampAddChatMessage(u8:decode('/uninvite '..vzID..' '..svoyauval.v),-1)
                        with4s.v = false
                        reasonuvalselect.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('Введите корректную причину (3+ символа)!',-1) 
                    end
                end
                if with4s.v then 
                    if string.len(reason4s.v) >= 3 then 
                        sampAddChatMessage(u8:decode('/blacklist '..vzID..' '..reason4s.v),-1) 
                        with4s.v = false
                        reasonuvalselect.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('Введите корректную причину (3+ символа)!',-1)
                    end
                end
            end
            if imgui.Button(u8'Назад', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'Закрыть', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 2 then
            imgui.Text(u8'Выберите ранг') imgui.SameLine(115) imgui.Combo('##seselo', selectedrank, orgnamesrank[selectorg.v + 1], #orgnamesrank[selectorg.v + 1])
            imgui.Separator()
            if imgui.Button(u8'Повысить/понизить игрока', imgui.ImVec2(335,20)) then sampAddChatMessage(u8:decode('/giverank id '..selectedrank.v + 1),-1) end
            if imgui.Button(u8'Назад', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine() 
            if imgui.Button(u8'Закрыть', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 3 then
            imgui.Text(u8'Выберите причину') 
            imgui.SameLine(119) 
            imgui.PushItemWidth(220)
            imgui.Combo('##fghjrg',reasonwarnselect, reasonwarn, #reasonwarn)
            if reasonwarnselect.v == 4 then
                imgui.Text(u8'Введите причину') imgui.SameLine(119) imgui.InputText('##qwegld', svoyawarn)
            end
            imgui.Separator()
            if imgui.Button(u8'Выдать выговор сотруднику', imgui.ImVec2(335,20)) then
                if reasonwarnselect.v ~= 4 then
                    sampAddChatMessage(u8:decode('/fwarn '..vzID..' '..reasonwarn[reasonwarnselect.v + 1]),-1)
                    with4s.v = false
                        reasonwarnselect.v = 0
                        IW_fastmenu.v = false
                else
                    if string.len(svoyawarn.v) >= 3 then
                        sampAddChatMessage(u8:decode('/fwarn '..vzID..' '..svoyawarn.v),-1)
                        reasonwarnselect.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('Введите корректную причину (3+ символа)!',-1)
                    end
                end
            end
            if imgui.Button(u8'Назад', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'Закрыть', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 4 then
            imgui.Text(u8'Выберите причину') 
            imgui.SameLine() 
            imgui.PushItemWidth(220)
            imgui.Combo('##sesese',selectedmute, reasonmute, #reasonmute)
            if selectedmute.v == 1 then
                imgui.Text(u8'Введите причину') imgui.SameLine(119) imgui.InputText('##lol', svoyamute)
            end
            imgui.Separator()
            imgui.Text(u8'Время мута') imgui.SameLine(119) imgui.DragInt('##sf', timemute, 1, 1, 180)
            if timemute.v > 180 then timemute.v = 180 end
            if timemute.v < 1 then timemute.v = 1 end
            imgui.Separator()
            if imgui.Button(u8'Выдать мут', imgui.ImVec2(335,20)) then
                if selectedmute.v == 1 then
                    if string.len(svoyamute.v) >= 3 then
                        sampAddChatMessage(u8:decode('/fmute '..vzID..' '..timemute.v..' '..svoyamute.v),-1)
                        svoyamute.v = ' '
                        selectedmute.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('Введите корректную причину (3+ символа)!',-1)
                    end
                elseif selectedmute.v == 0 then
                    sampAddChatMessage(u8:decode('/fmute '..vzID..' '..timemute.v..' '..reasonmute[selectedmute.v + 1]),-1)
                    selectedmute.v = 0
                    IW_fastmenu.v = false
                end
            end
            if imgui.Button(u8'Назад', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'Закрыть', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 5 then
            imgui.Text(u8'Причина занесения') 
            imgui.SameLine() 
            imgui.PushItemWidth(216)
            imgui.InputText('##a',reason4s)
            imgui.Separator()
            if imgui.Button(u8'Занести в ЧС', imgui.ImVec2(335,20)) then
                if string.len(reason4s.v) >= 3 then
                    sampAddChatMessage(u8:decode('/blacklist '..vzID..' '..reason4s.v),-1)
                    reason4s.v = ' '
                    IW_fastmenu.v = false
                else
                    sampAddChatMessage('Введите корректную причину (3+ символа)!',-1)
                end
            end
            if imgui.Button(u8'Назад', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'Закрыть', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 6 then
            imgui.Text(u8'Настройки быстрого меню:')
            imgui.Text(u8'Принять в организацию') imgui.SameLine(180) imadd.ToggleButton('##inv1', fm_invite)
            imgui.Text(u8'Уволить из организации') imgui.SameLine(180) imadd.ToggleButton('##inv2', fm_uninvite)
            imgui.Text(u8'Выдать повышение') imgui.SameLine(180) imadd.ToggleButton('##inv3', fm_giverank)
            imgui.Text(u8'Выдать выговор сотруднику') imgui.SameLine(180) imadd.ToggleButton('##inv4', fm_fwarn)
            imgui.Text(u8'Снять выговор сотруднику') imgui.SameLine(180) imadd.ToggleButton('##inv5', fm_unfwarn)
            imgui.Text(u8'Выдать мут рации') imgui.SameLine(180) imadd.ToggleButton('##inv6', fm_fmute)
            imgui.Text(u8'Снять мут рации') imgui.SameLine(180) imadd.ToggleButton('##inv7', fm_unfmute)
            imgui.Text(u8'Занести в черный список') imgui.SameLine(180) imadd.ToggleButton('##inv8', fm_blacklist)
            imgui.Text(u8'Вынести из черного списка') imgui.SameLine(180) imadd.ToggleButton('##inv9', fm_unblacklist)
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_SAVE..u8' Сохранить', imgui.ImVec2(203,20)) then
                progress = 0
                savesettings()
            end
        end
        imgui.End()
    end
end
function imgui.TextColoredRGB(text, render_text)
    local max_float = imgui.GetWindowWidth()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end

            local length = imgui.CalcTextSize(w)
            if render_text == 2 then
                imgui.NewLine()
                imgui.SameLine(max_float / 2 - ( length.x / 2 ))
            elseif render_text == 3 then
                imgui.NewLine()
                imgui.SameLine(max_float - length.x - 5 )
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end


        end
    end

    render_text(text)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    --sampAddChatMessage(text,-1)
end

--[[
{FFFFFF}Имя: {FFD700}Matthew_Fox   
{FFFFFF}Лет в штате: {FFD700}80
{FFFFFF}Серия: {FFD700}3550
{FFFFFF}Номер: {FFD700}268995
{FFFFFF}За  

{FFFFFF}Имя: Matthew_Fox   
{FFFFFF}Лет в штате: 80
{FFFFFF}Серия: 3550
{FFFFFF}Номер: 268995
{FFFFFF}Законопослушность: 100/100
{FFFFFF}Семейное положение: [ Женат(а) на Anthony_Anderson ]
{FFFFFF}Прописка: [ Дом номер 741 ]
{FFFFFF}Прописка: [ Дом номер 1029 ]


{FFFFFF}Работа: Адвокат
{FFFFFF}Благотворительность: 114000000$
{FFFFFF}Военный билет:  [ Есть ]

Лечился в Психиатрической больнице: 2 раз (Необходимо обновить мед. карту)--]]


--[[function checkrank() Лечился в Психиатрической больнице: 2 раз (Необходимо обновить мед. карту)
    if org == 'Не имеется' then 
        return true 
    elseif org == 'Не удалось проверить' then
        return false
    end
end--]]

--[[function sampev.onServerMessage(color, text)
    if tagfind.v then
        if text:find('%[D%].+%[%A+%].+%['..u8:decode(nametag.v)..'%]') then 
            statustag = text:match('%[D%].+%[(%A+)%].+%[')
            sampAddChatMessage(statustag,-1)
        end
    end
    if text:find('%[D%].+%[A+%].+%['..u8:decode(nametag.v)..'%]') then sampAddChatMessage('aaaa',-1) end
    if text:find('%[D%]%s%A+%s%a+%p%a+%[%d+%]%p%s%[%A+%].+%['..u8:decode(nametag.v)..'%]') then sampAddChatMessage('aaaaa',-1) end
    if tagfind.v then
        if text:find('[D]') then
            text:match
        end
    end
    if string.find(text, '[D].+', 1, true) then sampAddChatMessage('lalala',-1) end
    if text:find('[D]%s%a+%s%A+%p%A+%[%d+%]%p%s%[%a+%]%s%p%s%[%a+%]%p.+') then sampAddChatMessage('lalala',-1) end
end]]

function sampev.onSendCommand(command)
    if tag.v then
        if command:find('/'..dcmd.v..'%s%A+') then
            msgd = command:match('/'..dcmd.v..'%s(.+)')
            sampAddChatMessage('/d ['..u8:decode(nametags1[selectedtag1.v+1])..'] - ['..u8:decode(nametags2[selectedtag2.v+1])..'] '..msgd, -1)
            --return {'/d ['..nametags1[selectedtag1.v]..'] - ['..nametags2[selectedtag2.v]..'] '..msgd}
        end
    end
end
function showHelp(param) -- "вопросик" для скрипта
    imgui.TextColoredRGB('{808080}'..fa.ICON_FA_QUESTION_CIRCLE)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(u8(param))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
function getSkin()
    lua_thread.create(function()
        if not doesFileExist(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png') then
            downloadUrlToFile('https://files.advance-rp.ru/media/skins/'..getCharModel(playerPed)..'.png', getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png')
            wait(2000)
        end
    end)
    playerskin = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png')
end

function checkLic()
    _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    cnick = sampGetPlayerNickname(id)
    for k, v in pairs(lic) do
        if v.nick == cnick then
            local d, m, y = v.date:match('(%d+)%.(%d+)%.(%d+)')
            datetime = { 
                year = y,
                month = m,
                day = d,
            }
            seconds_since_epoch = os.time(datetime)
            if seconds_since_epoch > os.time() then
                sampAddChatMessage(v.nick, -1)
                statuslic = true
                licdate = v.date
            else
                licreason = 'Истек срок действия'
            end
        else
            if licreason ~= 'Истек срок действия' then licreason = 'Отсутствует подписка' end
        end
    end
end

function savesettings()
    mainIni.main.theme = theme.v
    mainIni.main.selectorg = selectorg.v
    mainIni.fastmenu.invite = fm_invite.v
    mainIni.fastmenu.uninvite = fm_uninvite.v
    mainIni.fastmenu.giverank = fm_giverank.v
    mainIni.fastmenu.fwarn = fm_fwarn.v
    mainIni.fastmenu.unfwarn = fm_unfwarn.v
    mainIni.fastmenu.fmute = fm_fmute.v
    mainIni.fastmenu.unfmute = fm_unfmute.v
    mainIni.fastmenu.blacklist = fm_blacklist.v
    mainIni.fastmenu.unblacklist = fm_unblacklist.v
    mainIni.tags.tag = tag.v
    mainIni.tags.tagfind = tagfind.v
    mainIni.tags.nametag = nametag.v
    mainIni.tags.dusecmd = dusecmd.v
    mainIni.tags.dcmd = dcmd.v
    mainIni.widget.widget = IW_widget.v
    mainIni.widget.nick = wdg_nick.v
    mainIni.widget.time = wdg_time.v
    mainIni.widget.server = wdg_server.v
    mainIni.widget.hpap = wdg_hpap.v
    mainIni.widget.ping = wdg_ping.v
    mainIni.widget.fastplayer = wdg_fastplayer.v
    mainIni.widget.tag = wdg_tag.v

    mainIni.tagdep1.dep1_tag1 = u8:decode(dep_tag11.v)
    mainIni.tagdep1.dep1_tag2 = u8:decode(dep_tag12.v)
    mainIni.tagdep1.dep1_tag3 = u8:decode(dep_tag13.v)
    mainIni.tagdep1.dep1_tag4 = u8:decode(dep_tag14.v)
    mainIni.tagdep1.dep1_tag5 = u8:decode(dep_tag15.v)
    mainIni.tagdep1.dep1_tag6 = u8:decode(dep_tag16.v)
    mainIni.tagdep1.dep1_tag7 = u8:decode(dep_tag17.v)
    mainIni.tagdep1.dep1_tag8 = u8:decode(dep_tag18.v)
    mainIni.tagdep1.dep1_tag9 = u8:decode(dep_tag19.v)
    mainIni.tagdep1.dep1_tag10 = u8:decode(dep_tag110.v)

    mainIni.tagdep2.dep2_tag1 = u8:decode(dep_tag21.v)
    mainIni.tagdep2.dep2_tag2 = u8:decode(dep_tag22.v)
    mainIni.tagdep2.dep2_tag3 = u8:decode(dep_tag23.v)
    mainIni.tagdep2.dep2_tag4 = u8:decode(dep_tag24.v)
    mainIni.tagdep2.dep2_tag5 = u8:decode(dep_tag25.v)
    mainIni.tagdep2.dep2_tag6 = u8:decode(dep_tag26.v)
    mainIni.tagdep2.dep2_tag7 = u8:decode(dep_tag27.v)
    mainIni.tagdep2.dep2_tag8 = u8:decode(dep_tag28.v)
    mainIni.tagdep2.dep2_tag9 = u8:decode(dep_tag29.v)
    mainIni.tagdep2.dep2_tag10 = u8:decode(dep_tag210.v)
    nametags1 = {}
    nametags2 = {}
    for k, v in pairs(tabletag1) do
        if #_G['dep_'..v[1]].v > 0 then table.insert(nametags1, _G['dep_'..v[1]].v) end
    end 
    for k, v in pairs(tabletag2) do
        if #_G['dep_'..v[1]].v > 0 then table.insert(nametags2, _G['dep_'..v[1]].v) end
    end 

    mainIni.save.autosave = autosave.v
    mainIni.save.timersave = timersave.v
    --[[mainIni.tagdep1.tag1_1 = tag1_1.v
    mainIni.tagdep1.tag1_2 = tag1_2.v
    mainIni.tagdep1.tag1_3 = tag1_3.v
    mainIni.tagdep1.tag1_4 = tag1_4.v
    mainIni.tagdep1.tag1_5 = tag1_5.v
    mainIni.tagdep1.tag1_6 = tag1_6.v
    mainIni.tagdep1.tag1_7 = tag1_7.v
    mainIni.tagdep1.tag1_8 = tag1_8.v
    mainIni.tagdep1.tag1_9 = tag1_9.v
    mainIni.tagdep1.tag1_10 = tag1_10.v

    mainIni.tagdep2.tag2_1 = tag2_1.v
    mainIni.tagdep2.tag2_2 = tag2_2.v
    mainIni.tagdep2.tag2_3 = tag2_3.v
    mainIni.tagdep2.tag2_4 = tag2_4.v
    mainIni.tagdep2.tag2_5 = tag2_5.v
    mainIni.tagdep2.tag2_6 = tag2_6.v
    mainIni.tagdep2.tag2_7 = tag2_7.v
    mainIni.tagdep2.tag2_8 = tag2_8.v
    mainIni.tagdep2.tag2_9 = tag2_9.v
    mainIni.tagdep2.tag2_10 = tag2_10.v--]]
    --[[for i = 1, 10 do
        _G['mainIni.tagdep1.tag1_'..i] = _G['tag1_'..i..'.v']
    end
    for i = 1, 10 do
        _G['mainIni.tagdep2.tag2_'..i] = _G['tag2_'..i..'.v']
    end--]]
    inicfg.save(mainIni, directIni)
    print('theme = '..theme.v)
    for k, v in pairs(fmenu) do
        print('fm_'..v[1]..': '..tostring(v[2]))
    end
    print('tag = '..tostring(tag.v))
    print('tagfind = '..tostring(tagfind.v))
    print('nametag = '..tostring(u8:decode(nametag.v)))
    print('widget = '..tostring(wdg_widget.v))
    for k, v in pairs(widget) do
        print('wdg_'..v[1]..': '..tostring(v[2]))
    end
    print('dusecmd = '..dusecmd.v)
    print('dcmd = '..dcmd.v)
end