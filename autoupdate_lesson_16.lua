script_name('Autoupdate script')
script_author('FORMYS')
script_description('Autoupdate')
require "lib.moonloader"
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

local script_vers = 20
local script_vers_text = "2.0"

--------------------------------------------
local directIni = 'PrisonHelper\\PrisonHelper.ini'
local mainIni = inicfg.load({
    main = 
    {
        theme = 1,
        selectorg = 1

    },
    color = 
    {
        colornick = false,
        color1 = 1.0,
        color2 = 1.0,
        color3 = 0.0
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
        unblacklist = true,
        su = true
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
        dep1_tag1 = '���',
        dep1_tag2 = '����',
        dep1_tag3 = '����',
        dep1_tag4 = '����',
        dep1_tag5 = '����',
        dep1_tag6 = '���',
        dep1_tag7 = '���',
        dep1_tag8 = '���',        
        dep1_tag9 = '��',
        dep1_tag10 = '���'
    },
    tagdep2 = 
    {
        dep2_tag1 = '���',
        dep2_tag2 = '����',
        dep2_tag3 = '����',
        dep2_tag4 = '����',
        dep2_tag5 = '����',
        dep2_tag6 = '���',
        dep2_tag7 = '���',
        dep2_tag8 = '���',        
        dep2_tag9 = '��',
        dep2_tag10 = '���'
    },
    suspect = 
    {
        newsu = true,
        zapros = true,
        reason = true,
        level = true,
    }
}, directIni)
local stateIni = inicfg.save(mainIni, directIni)
local theme = imgui.ImInt(mainIni.main.theme)
--------------------------------------------------------------
local ignorechat = imgui.ImBool(false)
local noignore = {}
local inputignore = imgui.ImBuffer(32)
------------------------------------------------------
local colornick = imgui.ImBool(mainIni.color.colornick)
local textcolor = imgui.ImFloat3(mainIni.color.color1, mainIni.color.color2, mainIni.color.color3)
----------------------------------------------------------------
local su = {
    {
        thread = '����� 1. ���������.',
        text = {
            {
                name = '�� ��������� �� ����������� ����',
                statya = '1.1 ���',
                suspect = '3',
            },
            {
                name = '�� ��������� �� ���������� ������������������ �������',
                statya = '1.2 ���',
                suspect = '6',
            },
            {
                name = '��������, ���������� ��� ������ ���������� ����� �������� � ��������� ��������� �����',
                statya = '1.3 ���',
                suspect = '4'
            }
        }
    },
    {
        thread = '����� 2. ����������� ���������.',
        text = {
            {
                name = '�� ����������� ���������',
                statya = '2.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 3. ��������.',
        text = {
            {
                name = '�� ��������',
                statya = '3.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 4. ���� ������������� ��������.',
        text = {
            {
                name = '�� ������� ����� ���������������� ��� �������� ������������� ��������',
                statya = '4.1 ���',
                suspect = '2'
            },
            {
                name = '�� ���� ������������� ��������',
                statya = '4.2 ���',
                suspect = '4'
            },
        }
    },
    {
        thread = '����� 5. ������ � ��������.',
        text = {
            {
                name = '�� ���� ��� ������� ���� ������ ������������ ����',
                statya = '5.1 ���',
                suspect = '3'
            },
            {
                name = '�� ��������� ������ ����������� �����',
                statya = '5.2 ���',
                suspect = '5'
            },
            {
                name = '�� �������� �� ���������� ������������������ �������',
                statya = '5.3 ���',
                suspect = '2'
            },
        }
    },
    {
        thread = '����� 6. ������.',
        text = {
            {
                name = '�� ������� ������ � �������� ����',
                statya = '6.1 ���',
                suspect = '3'
            },
            {
                name = '�� ������� ������ ��� ��������',
                statya = '6.2 ���',
                suspect = '6'
            },
            {
                name = '�� ����������� �������/������� ������',
                statya = '6.3 ���',
                suspect = '6'
            },
            {
                name = '� ������ ����������� � ������������ ��������, � � ������ ���� � ���������� ���� �������� �� ������',
                statya = '6.4 ���',
                suspect = '3'
            },
        }
    },
    {
        thread = '����� 7. ������ � ���������.',
        text = {
            {
                name = '�� ������ ������ ��� ������ ����������',
                statya = '7.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 8. ������������.',
        text = {
            {
                name = '�� ������������ ���������� ������������������ �������, ������������ ��� ����������',
                statya = '8.1 ���',
                suspect = '4'
            },
            {
                name = '�� ������������ ���������� ������������������ ������� ��� ���������� �� � �����, � ��� �� ��� ���������� ����.��������',
                statya = '8.2 ���',
                suspect = '6'
            },
            {
                name = '�� ����� �������� �����',
                statya = '8.3 ���',
                suspect = '2'
            },
            {
                name = '�� ������� ��������/��������/����� ������ ���� �������, ������, ���������, ������������ ��������������, �������� ���������� ��� ����������\n��������',
                statya = '8.4 ���',
                suspect = '6'
            },
            {
                name = '�� ������� �������� �� ����������',
                statya = '8.5 ���',
                suspect = '3'
            },
        }
    },
    {
        thread = '����� 9. �������������.',
        text = {
            {
                name = '�� ������������� �� ���������� ������������������� �������� ����������',
                statya = '9.1 ���',
                suspect = '3'
            },
            {
                name = '�� ������������� �� ������� ���������� ��� ���������� ���������',
                statya = '9.2 ���',
                suspect = '2'
            },
            {
                name = '�� ������������� �� ���������� �������� ������� ����',
                statya = '9.3 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 10. ������������� ��������.',
        text = {
            {
                name = '�� �������� �/��� ��������� ������������� �������',
                statya = '10.1 ���',
                suspect = '5'
            },
            {
                name = '�� ���� � ������� ���������� ������������� ��������',
                statya = '10.2 ���',
                suspect = '6'
            },
            {
                name = '�� ������������ ������������� �������',
                statya = '10.3 ���',
                suspect = '6'
            },
            {
                name = '�� ������������ � �������� ������������� ������� ����������� ������������������ �������',
                statya = '10.4 ���',
                suspect = '6'
            },
            {
                name = '����� ��� ����������� ����������� � ������������ ��������, � ����� ��������������� ������ �������, ���� ��� ������ ��������,\n���������� ������������� ��������',
                statya = '10.5 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 11. ���������.',
        text = {
            {
                name = '�� ������������/���������� �������',
                statya = '11.1 ���',
                suspect = '6'
            },
            {
                name = '�� ���������� � ������� ��� ��� �������',
                statya = '11.2 ���',
                suspect = '6'
            },
            {
                name = '�� ���������� � ���������������� �����������',
                statya = '11.3 ���',
                suspect = '6'
            },
            {
                name = '�� �������� � ���������������� �����������',
                statya = '11.4 ���',
                suspect = '6'
            },
            {
                name = '�� ������/��������������/���������� �������',
                statya = '11.5 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 12. ���� ������ ���������.',
        text = {
            {
                name = '�� ���� ������ ��������� ����������� ������������������ �������',
                statya = '12.1 ���',
                suspect = '3'
            },
            {
                name = '�� ������������ ����� ����������� �������',
                statya = '12.2 ���',
                suspect = '2'
            },
        }
    },
    {
        thread = '����� 13. �����������',
        text = {
            {
                name = '�� ����������� � ������������ ��������� � ������������ ������, ����� ��������� ����������� ���, ��������������� �����������',
                statya = '13.1 ���',
                suspect = '2'
            },
        }
    },
    {
        thread = '����� 14. ������.',
        text = {
            {
                name = '�� ����������� �������, � ��� �� ������� � ������� �� ��������',
                statya = '14.1 ���',
                suspect = '6'
            },
            {
                name = '�� ������� � ������������������� �������',
                statya = '14.2 ���',
                suspect = '3'
            },
        }
    },
    {
        thread = '����� 16. ��������������.',
        text = {
            {
                name = '�� �������������� �������� �������, ������� �������������',
                statya = '16.1 ���',
                suspect = '4'
            },
            {
                name = '�� �������������� �������� �������, ������� ������������� ����������� �����',
                statya = '16.2 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 17. ������.',
        text = {
            {
                name = '�� ������ ���������� ������������������ �������, ������������ ��� ����������',
                statya = '17.1 ���',
                suspect = '3'
            },
            {
                name = '������������� � ������� ������������, �������� ����� ������������������ ������� ��� �������������������� ������������',
                statya = '17.2 ���',
                suspect = '4'
            },
        }
    },
    {
        thread = '����� 19. �����.',
        text = {
            {
                name = '�� ����� �������� ���������',
                statya = '19.1 ���',
                suspect = '4'
            },
            {
                name = '�� ����� ��������������� �������������, ������������� ���.�����������, ���������, ����������',
                statya = '19.2 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 20. ����� �� �������������� ����������.',
        text = {
            {
                name = '�� �����, ��������� ���������� �� �������������� ����������, �������������� �������� ���������� ������������������ �������',
                statya = '20.1 ���',
                suspect = '2'
            },
            {
                name = '�� �����, ��������� ���������� �� �������������� ����������, �������������� �������� ���������� ������������������ ������� � �������� ��\n��� ����.��������',
                statya = '20.2 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 21. ����� ������������ ���������.',
        text = {
            {
                name = '�� ����� ������������ ��������� �� ����������� ����',
                statya = '21.1 ���',
                suspect = '3'
            },
            {
                name = '�� ����� ������������ ��������� �� ���������� ������������������ �������',
                statya = '21.2 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 22. ����������� ����������� ������������������ �������.',
        text = {
            {
                name = '�� ����� ��� ����������� ���������� ������������������ ������� ��� ����������',
                statya = '22.1 ���',
                suspect = '3'
            },
            {
                name = '�� ������������ ��������� � ������� ���������� ��� ����������',
                statya = '22.2 ���',
                suspect = '3'
            },
            {
                name = '�� ����������',
                statya = '22.3 ���',
                suspect = '3'
            },
        }
    },
    {
        thread = '����� 23. �������������� ��� ���.����������� � ���.',
        text = {
            {
                name = '�� �������������� ��� ���.����������� � ����������� �������������� ������������',
                statya = '23.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 24. ��������� ���������������� ���������.',
        text = {
            {
                name = '�� ����� ���������������� ��������� (�������, ������ � �.�.) � ������� �������� � ������ ���������������� ��������',
                statya = '24.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 25. ���������� ����������� ����������.',
        text = {
            {
                name = '�� ���������� ����������� ���������� � ��������� �����',
                statya = '25.1 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 26. ����������.',
        text = {
            {
                name = '�� ������ � �����������',
                statya = '26.1 ���',
                suspect = '6'
            },
            {
                name = '�� ���������� �����������',
                statya = '26.2 ���',
                suspect = '6'
            },
            {
                name = '�� ���������� � �������������� �����������',
                statya = '26.3 ���',
                suspect = '6'
            },
            {
                name = '�� �������� � �������������� �����������',
                statya = '26.4 ���',
                suspect = '6'
            },
            {
                name = '�� ������/�������������� �������������� �����������',
                statya = '26.5 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 27. ������.',
        text = {
            {
                name = '�� ������ ���������� �����',
                statya = '27.1 ���',
                suspect = '3'
            },
            {
                name = '�� ������ ���������� ��� ����������',
                statya = '27.2 ���',
                suspect = '4'
            },
            {
                name = '�� ������ ������� ��������������� �����������',
                statya = '27.3 ���',
                suspect = '6'
            },
        }
    },
    {
        thread = '����� 28. ������.',
        text = {
            {
                name = '�� ������ � �������',
                statya = '28.1 ���',
                suspect = '4'
            },
            {
                name = '�� ���������� �������',
                statya = '28.2 ���',
                suspect = '4'
            },
        }
    },
    {
        thread = '����� 36. ���.',
        text = {
            {
                name = '��� � �������� �����',
                statya = '36.2 ���',
                suspect = '3'
            },
        }
    },
    {
        thread = '����� 39. ���������� ������� ��������� ������ �� ������ ��������, � ���������� ��������������� ��������������� �����������,\n������������������ �������.',
        text = {
            {
                name = '���������� ������� ��������� ������ �� ������� ��������, � ���������� ��������������� ��������������� �����������, ������������������ �������',
                statya = '39.1 ���',
                suspect = '5'
            },
        }
    },
    {
        thread = '����� 42. ����� ��-��� ������ ��� ������.',
        text = {
            {
                name = '�� ����� ��-��� ������ ��� ��-��� ������',
                statya = '42.1 ���',
                suspect = '6'
            },
        }
    },
}
local newsu = imgui.ImBool(mainIni.suspect.newsu)
local zapros = imgui.ImBool(mainIni.suspect.zapros)
local sureason = imgui.ImBool(mainIni.suspect.reason)
local sulevel = imgui.ImBool(mainIni.suspect.level)
local suid
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
--test
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
    {'unblacklist', mainIni.fastmenu.unblacklist},
    {'su', mainIni.fastmenu.su},
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
local licreason = '������ �������� ��� �������� �� ������� �����'
---------------------------------------------
update_state = false

local imguiWindows = {
    {'update', true, true}, -- ���� main � �������� � ������� ���������
    {'fastmenu', true, false}, -- ���� about � ��������, �� ��� ������
    {'main', true, false},
    {'news', true, false},
    {'dep', true, false},
    {'widget', false, false},
    {'su', true, false}-- ���� overlay ��� ������� � ��� ������
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
-------------------������-----------------------------
for i = 1, 9 do
    _G['kolvosotr_'..i] = imgui.ImInt(3)
    _G['premprice_'..i] = imgui.ImInt(100000)
end
local selectchet = imgui.ImBool(false)
-----------------------------------------------------------------------
-------------------------------------------
local news = {
    {'���������� 1.8', '������ ������ ��������� � ������ 1.8 - 2.0 ����� ����������� �����.', 492, 170, 'https://sun9-26.userapi.com/Op-FGERudzBRi7zDTVslI5dwtUrUDJRGZWLe9Q/OiGzClLsxNs.jpg', 484, 124, 'picnews6', ' 21.06.2020'},
    {'���������� 1.7', '- ��������� ��� � /unblacklist � ���� ��������������\n- ��������� ���� ������ (/prem). � ������� ����� �������������� ����������� ���-�� ����������� ������������� �����;', 492, 170, 'https://sun9-12.userapi.com/c857020/v857020852/11d7c5/rFSsZFf2Vso.jpg', 484, 124, 'picnews4', ' 16.06.2020'},
    {'���������� 1.6', '- �������� ������ ������� � ����������, ������ ��� �������� ����������, ������������ ��������� 3 �������;\n- ������ �� ����� ������� ��������� ���������. ������ ����� ������ ��� �������������;\n- ��������� ���� ��������������\n- �������� ��������� �������� �� ���-�� �������� � ����� ������� ����������/������� ������;\n- �������� �������� ����� ������������ � ����� ����������� (/update).', 492, 170, 'https://sun9-12.userapi.com/c857020/v857020852/11d7c5/rFSsZFf2Vso.jpg', 484, 124, 'picnews4', ' 10.06.2020'},
    {'���������� 1.5', '- ��������� �������������� ��� �������;\n- ��������� ����������� ������������� ���� �������������� (��������� �������� ��� ������)\n- �������� ����� "������� � ����������", � ������� ����� ������������� ��� ���������� � ������ �� �������� (� �������)\n- ��������� ���, ����� ��� ���� �� �����������;\n- �������� ����� ���� ����������.', 492, 170, 'https://sun9-14.userapi.com/c831209/v831209043/1ce490/cntbyVkMUZI.jpg', 484, 124, 'picnews3', ' 07.06.2020'},
    {'���������� 1.1', '- ��������� ���� ��������������: ����������� ������ �������, �������, �������� ����, ������ � ����� �������, ������ � ����� ���, ������� � ������� �� ��\n- ���������� ��������� ����.', 492, 170, 'https://sun9-69.userapi.com/jkoJW7hmpVzQMPVLTjRlLwYvGRKf4jvG1VPkMQ/E7noxvmYLM4.jpg', 484, 124, 'picnews2', ' 07.05.2020'},
    {'����� �������', '����� �������.', 492, 170, 'https://pp.userapi.com/fFhPPMps-mi4t0nrTd7oJY5hpJsFL-DWi2Hc0g/aI6-oujqBLE.jpg', 484, 124, 'picnews1', ' 01.05.2020'},
}
--------------------------------------------------
local fast_invite = imgui.ImBool(true)
local fast_uninvite = imgui.ImBool(true)
local fast_giverank = imgui.ImBool(true)
--------------------����������
local with4s = imgui.ImBool(false)
local reason4s = imgui.ImBuffer(32)
local reasonuval = {u8'�� �/�', u8'��������� ������', u8'����. �������������', u8'���� �������'}
local reasonuvalselect = imgui.ImInt(0)
local svoyauval = imgui.ImBuffer(64)

----------------------
local playerskin
-------------------------------------

local orgnamesrank = {
    {u8'1 | �����', u8'2 | ������ ������� 1 ��.', u8'3 | ������ ������� 2 ��.', u8'4 | ������', u8'5 | �������', u8'6 | ���������', u8'7 | �������', u8'8 | ��������� ����', u8'9 | ����������� ����'},
    {u8'1 | �����', u8'2 | ������ ������� 1 ��.', u8'3 | ������ ������� 2 ��.', u8'4 | ������', u8'5 | �������', u8'6 | ���������', u8'7 | �������', u8'8 | ��������� ����', u8'9 | ����������� ����'},
    {u8'1 | �����', u8'2 | ������ ������� 1 ��.', u8'3 | ������ ������� 2 ��.', u8'4 | ������', u8'5 | �������', u8'6 | ���������', u8'7 | �������', u8'8 | ��������� ����', u8'9 | ����������� ����'},
    {u8'1 | ������', u8'2 | �������� ������ 1 ��.', u8'3 | �������� ������ 2 ��.', u8'4 | ������', u8'5 | �������', u8'6 | ���������', u8'7 | �������', u8'8 | ��������� ������', u8'9 | ����������� ������'},
    {u8'1 | ������', u8'2 | ������� �����', u8'3 | �����', u8'4 | ����� OPR', u8'5 | ����� DEA', u8'6 | ����� CID', u8'7 | ����� DEA/CID/OPR', u8'8 | ���������', u8'9 | ����������� ���������'},
    {u8'1 | ��������', u8'2 | �������', u8'3 | ��������', u8'4 | ��. ��������', u8'5 | �����������', u8'6 | ��������� �����', u8'7 | ���������', u8'8 | ��������� ���������', u8'9 | ���.���������� ������'},
}
local orgnames = {u8'����', u8'����', u8'����', u8'����', u8'���', u8'���'}
local selectorg = imgui.ImInt(mainIni.main.selectorg)
-------------------��������� �����
local nameranks = {u8'1 | ��������', u8'2 | �������', u8'3 | ��������', u8'4 | ��. ��������', u8'5 | �����������', u8'6 | ��������� �����', u8'7 | ���������', u8'8 | ��������� ���������', u8'9 | ���. ���������� ������'}
local selectedrank = imgui.ImInt(1)
--------------------------------------
-------------------������ ��������----------
local reasonwarn = {u8'��������� ������', u8'������ �������� ���', u8'������ �����', u8'��������� �������������', u8'���� �������'}
local reasonwarnselect = imgui.ImInt(0)
local svoyawarn = imgui.ImBuffer(32)
-----------------------------------------
------------------������ ����
local reasonmute = {u8'������� �����', u8'���� �������'}
local selectedmute = imgui.ImInt(0)
local svoyamute = imgui.ImBuffer(32)
local timemute = imgui.ImInt(30)
-----------------------------------------

local update_url = "https://raw.githubusercontent.com/MatthewFox295/helper/master/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/MatthewFox295/helper/blob/master/autoupdate_lesson_16.lua?raw=true"
local script_path = thisScript().path

local vzID = 0

------------------------����-------------------------------
local tag = imgui.ImBool(mainIni.tags.tag)
local tagfind = imgui.ImBool(mainIni.tags.tagfind)
local nametag = imgui.ImBuffer(mainIni.tags.nametag, 24)
local statustag = '�� �������'
local orgtags = {u8'���', u8'����', u8'����', u8'����', u8'����', u8'���', u8'���', u8'���', u8'����', u8'����', u8'����', u8'��� ��', u8'��� ��', u8'��� ��', u8'���-��', u8'��', u8'���'}
local selecttag = imgui.ImInt(0)
-------------------------------------------------------------
local autosave = imgui.ImBool(mainIni.save.autosave)
local timersave = imgui.ImInt(mainIni.save.timersave)
-----------------------------------------------------------
local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
    if fa_font == nil then
        local font_config = imgui.ImFontConfig()
        font_config.MergeMode = true

        fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
    end
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    getSkin()
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
    sampRegisterChatCommand('statuslic', function()
        statuslic = not statuslic
    end)
    sampRegisterChatCommand('su', cmd_su)
    imgui.SwitchContext()
    themes.SwitchColorTheme(theme.v)
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    nick = sampGetPlayerNickname(id)
    imgui.Process = false
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("���� ����������! ������: " .. updateIni.info.vers_text, -1)
                IW_update.v = true
            end
            os.remove(update_path)
        end
    end)
    for k, v in pairs(news) do
        if not doesFileExist(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png') then
            downloadUrlToFile(v[5], getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png')
            wait(1000)
            print('�������� '..v[8]..'.png, ��� 1000 ��')
        end
        v[8] = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\picnews\\'..v[8]..'.png')
    end
    IW_widget.v = mainIni.widget.widget
    showCursor(false)
    if doesFileExist(bindfile1) then
        local fbind = io.open(bindfile1, "r")
        if fbind then
            lic = decodeJson(fbind:read("a*"))
            fbind:close()
            os.remove(bindfile1)
        end
    end
    getSkin()
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
                    sampAddChatMessage("������ ������� ��������!", -1)
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
	end
end

function imgui.OnDrawFrame()
    local sw, sh = getScreenResolution()
    _, wid = sampGetPlayerIdByCharHandle(PLAYER_PED) 
    local wname = sampGetPlayerNickname(wid)
    if IW_update.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'��������������',IW_update, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if tonumber(updateIni.info.vers) > script_vers then
                imgui.Text(u8'�������� ����� ����������!')
                imgui.Text(u8'������� ������ �������: '..script_vers_text)
                imgui.Text(u8'���������� ������ �������: '..updateIni.info.vers_text)
                if imgui.Button(u8'��������') then update_state = true end
            else
                imgui.Text(u8'����������� ���������� ������ �������!')
            end
        imgui.End()
    end
    if IW_main.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 500), imgui.Cond.FirstUseEver)
        imgui.Begin(fa.ICON_FA_LIST_UL..u8' �������� ����',IW_main, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)

        if imgui.Button(fa.ICON_FA_USER..u8' �������', imgui.ImVec2(227, 23)) then main = 1 end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_COGS..u8' ��������� � �������', imgui.ImVec2(228, 23)) then main = 2 end imgui.SameLine()
        if imgui.Button(fa.ICON_FA_SAVE..u8' ���������', imgui.ImVec2(227, 23)) then savesettings() end
        imgui.Separator()
        if main == 1 then
            imgui.SetCursorPosX(284)
            imgui.Image(playerskin, imgui.ImVec2(131, 131))
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
                imgui.TextUnformatted(u8'������� ����, ���� � ��� ����� �������')
                imgui.PopTextWrapPos()
                imgui.EndTooltip()
            end
            if imgui.IsItemClicked() then
                getSkin()
            end
            imgui.TextColoredRGB(u8'���: '..wname:gsub('_',' '), 2)
            imgui.TextColoredRGB(u8'���� �����������:' , 2)
            imgui.PushItemWidth(100)
            imgui.SetCursorPosX(300)
            imgui.Combo('##myorg', selectorg, orgnames, #orgnames)
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            if statuslic then
                imgui.TextColoredRGB(u8'��������: {00ff00}�������', 2)
                imgui.TextColoredRGB(u8'���� ��������: �� '..licdate, 2)
                imgui.NewLine()
                imgui.Separator()
                imgui.NewLine()
                imgui.TextColoredRGB(u8'�������-�������', 2)
                imadd.ToggleButton('##colornick', colornick) imgui.SameLine()
                imgui.TextColoredRGB(u8'������� ��� � /r, /rb, /d � ������� /members')
                if colornick.v then
                    imgui.PushItemWidth(200)
                    imgui.ColorEdit3('##textcolor', textcolor)
                    imgui.SameLine()
                    if imgui.Button(u8'�������� ���������') then 
                        textcolor.v[1], textcolor.v[2], textcolor.v[3] = 1.0, 1.0, 0.0 
                    end
                    imgui.TextColoredRGB(u8("{2DB043}[R] {"..('%06X'):format(join_argb(0, textcolor.v[1] * 255, textcolor.v[2] * 255, textcolor.v[3] * 255)).."}"..wname.."["..wid.."]: {2DB043}"..wname:match('.+_(.+)').." �� CONTROL. '99, ����������� � ��������������, ��������."))
                end
            elseif not statuslic then
                imgui.TextColoredRGB(u8'��������: {ff0000}���������', 2)
                if licreason == '������ �������� ��� �������� �� ������� �����' then imgui.TextColoredRGB(u8'{808080}������ �������� ��� �������� �� ������� �����', 2)
                elseif licreason == '����� ���� ��������' then imgui.TextColoredRGB(u8'{808080}����� ���� ��������', 2)
                elseif licreason == '����������� ��������' then imgui.TextColoredRGB(u8'{808080}����������� ��������', 2) end
                imgui.TextColoredRGB(u8'{808080}���� � ��� ������� ��������, �� ���������� ������������� ������ (CTRL + R)', 2)
            end
        end
        if main == 2 then
            imgui.BeginChild('##polo', imgui.ImVec2(200,440), true)
                if imgui.Selectable(u8'������') then menu = 1 end
                imgui.Separator()
                if imgui.Selectable(u8'���� ��������������') then menu = 2 end
                imgui.Separator()
                if imgui.Selectable(u8'������') then menu = 3 end
                imgui.Separator()
                if imgui.Selectable(u8'�������������� ��� /d') then menu = 4 end
                imgui.Separator()
                if imgui.Selectable(u8'�������� � �������� ��') then menu = 5 end
                imgui.Separator()
            imgui.EndChild()
            imgui.SameLine()
            if menu == 1 then
                imgui.BeginChild('##menu1', imgui.ImVec2(487, 440), true)
                    imadd.ToggleButton('##wdg', IW_widget) imgui.SameLine() imgui.Text(u8'�������� ������')
                    if imgui.Button(u8'������������� �������', imgui.ImVec2(479, 23)) then
                        IW_main.v = false
                        IW_widget.v = true
                        editposwdg = true
                    end
                    imgui.NewLine()
                    imgui.BeginChild('##cmn',imgui.ImVec2(479,182), true)
                        imgui.Columns(2, '##wdgcolumns')
                        imadd.ToggleButton('##wdg1', wdg_nick) imgui.SameLine() imgui.Text(u8'��� ��� � id')
                        imgui.NextColumn()
                        imgui.Text(wname..' ['..wid..']')
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg2', wdg_server) imgui.SameLine() imgui.Text(u8'�������� �������')
                        imgui.NextColumn()
                        imgui.Text(u8(sampGetCurrentServerName()))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg3', wdg_time) imgui.SameLine() imgui.Text(u8'����� (�� ����� ����������)')
                        imgui.NextColumn()
                        imgui.Text(os.date("%X",os.time()))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg4', wdg_ping) imgui.SameLine() imgui.Text(u8'��� ����')
                        imgui.NextColumn()
                        imgui.Text(tostring(sampGetPlayerPing(wid)))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg5', wdg_hpap) imgui.SameLine() imgui.Text(u8'�������� � �����')
                        imgui.NextColumn()
                        imgui.Text(sampGetPlayerHealth(wid)..' | '..sampGetPlayerArmor(wid))
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg6', wdg_fastplayer) imgui.SameLine() imgui.Text(u8'���������� �����')
                        imgui.NextColumn()
                        imgui.Text(sampGetPlayerNickname(vzID)..' ['..vzID..']')
                        imgui.NextColumn()
                        imgui.Separator()
                        imadd.ToggleButton('##wdg7', wdg_tag) imgui.SameLine() imgui.Text(u8'������� ����� �����')
                        imgui.NextColumn()
                        imgui.Text(u8'['..nametags1[selectedtag1.v+1]..'] - ['..nametags2[selectedtag2.v+1]..']')
                        imgui.Columns(1)
                    imgui.EndChild()
                imgui.EndChild()
            end
            if menu == 2 then
                imgui.BeginChild('##menu2', imgui.ImVec2(487, 440), true)
                    imadd.ToggleButton('##fm_fastmenu', fm_fastmenu)
                    imgui.SameLine()
                    imgui.Text(u8'�������� ���� ��������������')
                    imgui.NewLine()
                    imadd.ToggleButton('##fm1', fm_invite) imgui.SameLine() imgui.Text(u8'������� � �����������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm2', fm_uninvite) imgui.SameLine() imgui.Text(u8'������� �� �����������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm3', fm_giverank) imgui.SameLine() imgui.Text(u8'������ ���������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm4', fm_fwarn) imgui.SameLine() imgui.Text(u8'������ ������� ����������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm5', fm_unfwarn) imgui.SameLine() imgui.Text(u8'����� ������� ����������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm6', fm_fmute) imgui.SameLine() imgui.Text(u8'������ ��� �����')
                    imgui.Separator()
                    imadd.ToggleButton('##fm7', fm_unfmute) imgui.SameLine() imgui.Text(u8'����� ��� �����')
                    imgui.Separator()
                    imadd.ToggleButton('##fm8', fm_blacklist) imgui.SameLine() imgui.Text(u8'������� � ������ ������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm9', fm_unblacklist) imgui.SameLine() imgui.Text(u8'������� �� ������� ������')
                    imgui.Separator()
                    imadd.ToggleButton('##fm10', fm_su) imgui.SameLine() imgui.Text(u8'�������� � ������')
                imgui.EndChild()
            end
            if menu == 3 then
                imgui.BeginChild('##menu4', imgui.ImVec2(487, 440), true)
                    imgui.BeginChild('##menu41',imgui.ImVec2(479,284), true)
                        imgui.Columns(4, 'columns', true)
                        imgui.Text(u8'����')
                        imgui.NextColumn()
                        imgui.Text(u8'���-�� �����������')
                        imgui.NextColumn()
                        imgui.Text(u8'����� �������')
                        imgui.NextColumn()
                        imgui.Text(u8'�����')
                        imgui.Separator()
                        imgui.NextColumn()
                        for i = 1, 8 do
                            imgui.Text(tostring(i))
                            imgui.NextColumn()
                            imgui.InputInt('##ffesw'..i,_G['kolvosotr_'..i])
                            if _G['kolvosotr_'..i].v < 0 then _G['kolvosotr_'..i].v = 0 end
                            if _G['premprice_'..i].v < 0 then _G['premprice_'..i].v = 0 end
                            imgui.NextColumn()
                            imgui.PushItemWidth(110)
                            imgui.InputInt('##ffessss'..i,_G['premprice_'..i],10000)
                            imgui.NextColumn()
                            imgui.Text(tostring(_G['kolvosotr_'..i].v * _G['premprice_'..i].v))
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
                        imgui.Text(tostring(_G['kolvosotr_9'].v * _G['premprice_9'].v))
                        imgui.Columns(1)
                    imgui.EndChild()
                    imgui.NewLine()
                    imgui.Text(u8'����� �����������: '..kolvosotr_1.v + kolvosotr_2.v + kolvosotr_3.v + kolvosotr_4.v + kolvosotr_5.v + kolvosotr_6.v + kolvosotr_7.v + kolvosotr_8.v + kolvosotr_9.v)
                    imgui.Text(u8'����� ����� ���������: '..premprice_1.v * kolvosotr_1.v + premprice_2.v * kolvosotr_2.v + premprice_3.v * kolvosotr_3.v + premprice_4.v * kolvosotr_4.v + premprice_5.v * kolvosotr_5.v + premprice_6.v * kolvosotr_6.v + premprice_7.v * kolvosotr_7.v + premprice_8.v * kolvosotr_8.v + premprice_9.v * kolvosotr_9.v)
                    if imgui.Button(u8'��������� ������', imgui.ImVec2(479, 23)) then
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
                    imgui.BeginChild('##tegi',imgui.ImVec2(479,79), true)
                        imgui.PushItemWidth(80)
                        imgui.InputText(u8'�������', dusecmd)
                        imgui.SameLine()
                        showHelp('��� "/"\n����� ����� ������������� ������ (CTRL + R)')
                        imgui.PushItemWidth(50)
                        imgui.InputText(u8'������� �����', dcmd)
                        imgui.SameLine()
                        showHelp('��� "/"\n����� ����� ������������� ������ (CTRL + R)')
                        imgui.PushItemWidth(50)
                        imgui.InputText(u8'�������', dcmd)
                    imgui.EndChild()
                    imgui.BeginChild('##tabletag1', imgui.ImVec2(237, 349), true)
                        for k, v in pairs(tabletag1) do
                            imgui.Text(u8'������ ��� ����� �'..k)
                            imgui.SameLine()
                            showHelp('����� ��������� ������� "���������"')
                            imgui.InputText('##tabletag1'..k, _G['dep_'..v[1]])
                        end
                    imgui.EndChild()
                    imgui.SameLine()
                    imgui.BeginChild('##tabletag2', imgui.ImVec2(237, 349), true)
                    for k, v in pairs(tabletag2) do
                        imgui.Text(u8'������ ��� ����� �'..k)
                        imgui.SameLine()
                        showHelp('����� ��������� ������� "���������"')
                        imgui.InputText('##tabletag2'..k, _G['dep_'..v[1]])
                    end
                    imgui.EndChild()
                imgui.EndChild()
            end
            if menu == 5 then
                imgui.BeginChild('##menu5', imgui.ImVec2(487, 440), true)
                    imadd.ToggleButton('##ignorechat', ignorechat) imgui.SameLine() imgui.Text(u8'������������� ����') imgui.SameLine()
                    showHelp('������ ����� ��� ��������� ����, �� ����������� ���������, ���������� �������������� �����/����')
                    imgui.Separator()
                    imgui.Text(u8'�� ������������ (�������� �����/����):')
                    imgui.PushItemWidth(150)
                    imgui.InputText('##inputignore', inputignore) 
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_PLUS, imgui.ImVec2(62, 21)) then
                        if #inputignore.v > 0 then
                            noignore[#noignore+1] = {inputignore.v}
                            inputignore.v = ''
                        end
                    end
                    for k, v in pairs(noignore) do
                        imgui.BeginChild('##ign'..k, imgui.ImVec2(150, 23), true)
                        imgui.Text(tostring(v[1])) 
                        imgui.EndChild()
                        imgui.SameLine()
                        if imgui.Button(fa.ICON_FA_MINUS..'##delignore'..k, imgui.ImVec2(62, 21)) then
                            table.remove(noignore, k)
                        end
                    end
                imgui.EndChild()
            end
        end
        imgui.End()
    end
    if IW_su.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(1000, 600), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'����� ������ �������',IW_su, imgui.WindowFlags.NoCollapse)
        if imgui.CollapsingHeader(u8'��������� ������ �������') then
            imadd.ToggleButton('##newsu', newsu) imgui.SameLine()
            imgui.Text(u8'������������ ����� ������ �������')
            if newsu.v then
                imadd.ToggleButton('##zapros', zapros) imgui.SameLine()
                imgui.Text(u8'����������� ������ ������� ����� �����') imgui.SameLine() showHelp('��� ������� ������')
                if zapros.v then
                    imadd.ToggleButton('##sulevel', sulevel) imgui.SameLine()
                    imgui.Text(u8'������ ������� ������� ��� �������')
                    imadd.ToggleButton('##sureason', sureason) imgui.SameLine()
                    imgui.Text(u8'������ ������� ������� ��������� ���������� � �����')
                end
            end
        end
        imgui.Separator()
        for i, v in ipairs(su) do
            if imgui.CollapsingHeader(u8(v['thread'])) then
                for i2, v2 in ipairs(su[i]['text']) do
                    if imgui.Selectable(u8(v2['statya']..' | '..v2['name'])..' | '..v2['suspect']..fa.ICON_FA_STAR) then
                        if zapros.v then
                            if sulevel.v then
                                sampAddChatMessage('/r '..wname:gsub('_',' ')..' �� CONTROL. ����� �������� � ������ ���� N-'..suid..'.', -1)
                                sampAddChatMessage('/r ������� ������� - '..v2['statya']..', '..v2['suspect']..' �������.', -1)
                            else
                                sampAddChatMessage('/r '..wname:gsub('_',' ')..' �� CONTROL. ����� �������� � ������ ���� N-'..suid..'.', -1)
                                sampAddChatMessage('/r ������� ������� - '..v2['statya']..'.', -1)
                            end
                            if sureason.v then
                                sampAddChatMessage('/r '..v2['name']..'.', -1)
                            end
                        else
                            sampAddChatMessage('/su '..suid..' '..v2['suspect']..' '..v2['statya'], -1)
                        end
                        IW_su.v = false
                    end
                    if #su[i]['text'] > 1 then imgui.Separator() end
                end
            end
        end
        imgui.End()
    end
    if IW_dep.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(230, 150), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'�����������',IW_dep, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
        imgui.Columns(2, 'departcolumn', true)
        imgui.Text(u8'������ �����:')
        imgui.PushItemWidth(100)
        imgui.Combo(u8'##see', selectedtag1, nametags1, #nametags1)
        imgui.NextColumn()
        imgui.Text(u8'������ �����:')
        imgui.PushItemWidth(100)
        imgui.Combo('##see2', selectedtag2, nametags2, #nametags2)
        imgui.Columns(1)
        imgui.Text(u8'[ '..nametags1[selectedtag1.v+1]..' ] - [ '..nametags2[selectedtag2.v+1]..' ]')
        imadd.ToggleButton('##onofftag', tag) imgui.SameLine() imgui.Text(u8'�������� ����� ������������')
        imgui.End()
    end
    if IW_widget.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('##widget',IW_widget, imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
        imgui.SetMouseCursor(imgui.MouseCursor.None)
        if wdg_nick.v then imgui.Text(wname..' ['..wid..']') end
        if wdg_server.v then imgui.Text(u8(sampGetCurrentServerName())) end
        if wdg_time.v then imgui.Text(os.date("%X",os.time())) end
        if wdg_ping.v then imgui.Text(sampGetPlayerPing(wid)) end
        if wdg_hpap.v then imgui.Text(sampGetPlayerHealth(wid)..' | '..sampGetPlayerArmor(wid)) end
        if wdg_fastplayer.v then imgui.Text(sampGetPlayerNickname(vzID)..' ['..vzID..']') end
        if wdg_tag.v then imgui.Text(u8'['..nametags1[selectedtag1.v+1]..'] - ['..nametags2[selectedtag2.v+1]..']') end
        imgui.End()
    end
    if IW_news.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(513, 547), imgui.Cond.FirstUseEver)
        imgui.Begin(u8'������� � ����������',IW_news, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
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
                if imgui.Button(fa.ICON_FA_USER_PLUS..u8' ������� � �����������', imgui.ImVec2(335,20)) then 
                    sampSendChat('/invite '..vzID)
                    IW_fastmenu.v = false 
                end
            end
            if fm_uninvite.v then
                if imgui.Button(fa.ICON_FA_USER_MINUS..u8' ������� �� �����������', imgui.ImVec2(335,20)) then 
                    progress = 1 
                end
            end
            if fm_giverank.v then
                if imgui.Button(fa.ICON_FA_SORT_AMOUNT_UP..u8' ������ ���������', imgui.ImVec2(335,20)) then 
                    progress = 2 
                end
            end
            if fm_fwarn.v then
                if imgui.Button(fa.ICON_FA_THUMBS_DOWN..u8' ������ ������� ����������', imgui.ImVec2(335,20)) then 
                    progress = 3 
                end
            end
            if fm_unfwarn.v then
                if imgui.Button(fa.ICON_FA_THUMBS_UP..u8' ����� ������� ����������', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unfwarn '..vzID,-1) 
                end
            end
            if fm_fmute.v then
                if imgui.Button(fa.ICON_FA_MICROPHONE..u8' ������ ��� �����', imgui.ImVec2(335,20)) then 
                    progress = 4 
                end
            end
            if fm_unfmute.v then
                if imgui.Button(fa.ICON_FA_MICROPHONE_SLASH..u8' ����� ��� �����', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unfmute '..vzID,-1) 
                end
            end
            if fm_blacklist.v then
                if imgui.Button(fa.ICON_FA_USER_MINUS..u8' ������� � ������ ������', imgui.ImVec2(335,20)) then 
                    progress = 5 
                end
            end
            if fm_unblacklist.v then
                if imgui.Button(fa.ICON_FA_USER_PLUS..u8' ������� �� ������� ������', imgui.ImVec2(335,20)) then 
                    sampAddChatMessage('/unblacklist '..vzID,-1) 
                end
            end
            if fm_su.v then
                if imgui.Button(fa.ICON_FA_STAR..u8' �������� � ������', imgui.ImVec2(335, 20)) then
                    suid = vzID
                    IW_su.v = true
                    IW_fastmenu.v = false
                end
            end
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_EDIT..u8' �������������', imgui.ImVec2(335,20)) then progress = 6 end
        end
        if progress == 1 then
            imgui.Text(u8'������� � ������ ������') imgui.SameLine(310) imadd.ToggleButton('##chs',with4s)
            if with4s.v then 
                imgui.PushItemWidth(150)
                imgui.Text(u8'������� ������� ���������') imgui.SameLine(189) imgui.InputText('##ffwecff',reason4s) 
            end
            imgui.Separator()
            imgui.PushItemWidth(150)
            imgui.Text(u8'�������� ������� ����������') imgui.SameLine(189) imgui.Combo('##uvaaaa',reasonuvalselect, reasonuval, #reasonuval)
            if reasonuvalselect.v == 3 then 
                imgui.Text(u8'������� ������� ����������') imgui.SameLine(189) imgui.InputText('##efewg',svoyauval) 
            end
            imgui.Separator()
            if imgui.Button(u8'������� ������', imgui.ImVec2(335,20)) then
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
                        sampAddChatMessage('������� ���������� ������� (3+ �������)!',-1) 
                    end
                end
                if with4s.v then 
                    if string.len(reason4s.v) >= 3 then 
                        sampAddChatMessage(u8:decode('/blacklist '..vzID..' '..reason4s.v),-1) 
                        with4s.v = false
                        reasonuvalselect.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('������� ���������� ������� (3+ �������)!',-1)
                    end
                end
            end
            if imgui.Button(u8'�����', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'�������', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 2 then
            imgui.Text(u8'�������� ����') imgui.SameLine(115) imgui.Combo('##seselo', selectedrank, orgnamesrank[selectorg.v + 1], #orgnamesrank[selectorg.v + 1])
            imgui.Separator()
            if imgui.Button(u8'��������/�������� ������', imgui.ImVec2(335,20)) then sampAddChatMessage(u8:decode('/giverank id '..selectedrank.v + 1),-1) end
            if imgui.Button(u8'�����', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine() 
            if imgui.Button(u8'�������', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 3 then
            imgui.Text(u8'�������� �������') 
            imgui.SameLine(119) 
            imgui.PushItemWidth(220)
            imgui.Combo('##fghjrg',reasonwarnselect, reasonwarn, #reasonwarn)
            if reasonwarnselect.v == 4 then
                imgui.Text(u8'������� �������') imgui.SameLine(119) imgui.InputText('##qwegld', svoyawarn)
            end
            imgui.Separator()
            if imgui.Button(u8'������ ������� ����������', imgui.ImVec2(335,20)) then
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
                        sampAddChatMessage('������� ���������� ������� (3+ �������)!',-1)
                    end
                end
            end
            if imgui.Button(u8'�����', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'�������', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 4 then
            imgui.Text(u8'�������� �������') 
            imgui.SameLine() 
            imgui.PushItemWidth(220)
            imgui.Combo('##sesese',selectedmute, reasonmute, #reasonmute)
            if selectedmute.v == 1 then
                imgui.Text(u8'������� �������') imgui.SameLine(119) imgui.InputText('##lol', svoyamute)
            end
            imgui.Separator()
            imgui.Text(u8'����� ����') imgui.SameLine(119) imgui.DragInt('##sf', timemute, 1, 1, 180)
            if timemute.v > 180 then timemute.v = 180 end
            if timemute.v < 1 then timemute.v = 1 end
            imgui.Separator()
            if imgui.Button(u8'������ ���', imgui.ImVec2(335,20)) then
                if selectedmute.v == 1 then
                    if string.len(svoyamute.v) >= 3 then
                        sampAddChatMessage(u8:decode('/fmute '..vzID..' '..timemute.v..' '..svoyamute.v),-1)
                        svoyamute.v = ' '
                        selectedmute.v = 0
                        IW_fastmenu.v = false
                    else
                        sampAddChatMessage('������� ���������� ������� (3+ �������)!',-1)
                    end
                elseif selectedmute.v == 0 then
                    sampAddChatMessage(u8:decode('/fmute '..vzID..' '..timemute.v..' '..reasonmute[selectedmute.v + 1]),-1)
                    selectedmute.v = 0
                    IW_fastmenu.v = false
                end
            end
            if imgui.Button(u8'�����', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'�������', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 5 then
            imgui.Text(u8'������� ���������') 
            imgui.SameLine() 
            imgui.PushItemWidth(216)
            imgui.InputText('##a',reason4s)
            imgui.Separator()
            if imgui.Button(u8'������� � ��', imgui.ImVec2(335,20)) then
                if string.len(reason4s.v) >= 3 then
                    sampAddChatMessage(u8:decode('/blacklist '..vzID..' '..reason4s.v),-1)
                    reason4s.v = ' '
                    IW_fastmenu.v = false
                else
                    sampAddChatMessage('������� ���������� ������� (3+ �������)!',-1)
                end
            end
            if imgui.Button(u8'�����', imgui.ImVec2(165,20)) then progress = 0 end
            imgui.SameLine()
            if imgui.Button(u8'�������', imgui.ImVec2(165,20)) then IW_fastmenu.v = false end
        end
        if progress == 6 then
            imgui.Text(u8'��������� �������� ����:')
            imgui.Text(u8'������� � �����������') imgui.SameLine(180) imadd.ToggleButton('##inv1', fm_invite)
            imgui.Text(u8'������� �� �����������') imgui.SameLine(180) imadd.ToggleButton('##inv2', fm_uninvite)
            imgui.Text(u8'������ ���������') imgui.SameLine(180) imadd.ToggleButton('##inv3', fm_giverank)
            imgui.Text(u8'������ ������� ����������') imgui.SameLine(180) imadd.ToggleButton('##inv4', fm_fwarn)
            imgui.Text(u8'����� ������� ����������') imgui.SameLine(180) imadd.ToggleButton('##inv5', fm_unfwarn)
            imgui.Text(u8'������ ��� �����') imgui.SameLine(180) imadd.ToggleButton('##inv6', fm_fmute)
            imgui.Text(u8'����� ��� �����') imgui.SameLine(180) imadd.ToggleButton('##inv7', fm_unfmute)
            imgui.Text(u8'������� � ������ ������') imgui.SameLine(180) imadd.ToggleButton('##inv8', fm_blacklist)
            imgui.Text(u8'������� �� ������� ������') imgui.SameLine(180) imadd.ToggleButton('##inv9', fm_unblacklist)
            imgui.Text(u8'�������� � ������') imgui.SameLine(180) imadd.ToggleButton('##inv10', fm_su)
            imgui.Separator()
            if imgui.Button(fa.ICON_FA_SAVE..u8' ���������', imgui.ImVec2(203,20)) then
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
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local name = sampGetPlayerNickname(id)
    if dialogId == 5767 then
        for w in text:gmatch('[^\r\n]+') do
            if w:find(name..'%['..id..'%]') then
                return {'{'..('%06X'):format(join_argb(0, textcolor.v[1] * 255, textcolor.v[2] * 255, textcolor.v[3] * 255))..name..'['..id..']\t���(9)\t[���������:1 ]\t[����� ���: 5 ���.]\n'}
            end
        end
    end
end

function sampev.onServerMessage(color, text)
    local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
    local name = sampGetPlayerNickname(id)

    if ignorechat.v then
        for k, v in pairs(noignore) do
            if text:find(v[1]) then
                return true
            else
                return false
            end
        end
    end

    if text:find('%[R%] (.+) '..name..'%['..id..'%]: (.+)') then
        if colornick.v then
            local rank, msg = text:match('%[R%] (.+) '..name..'%['..id..'%]: (.+)')
            if rank and msg then
                text = '{2DB043}[R] '..rank..' {'..('%06X'):format(join_argb(0, textcolor.v[1] * 255, textcolor.v[2] * 255, textcolor.v[3] * 255))..'}'..name..'['..id..']: {2DB043}'..msg
                return {color, text}
                
            end
        end
    end
    if text:find('%[R%] (.+) '..name..'%['..id..'%]:%(%((.+)%)%)') then
        if colornick.v then
            local rank, msg = text:match('%[R%] (.+) '..name..'%['..id..'%]:%(%((.+)%)%)')
            if rank and msg then
                text = '{2DB043}[R] '..rank..' {'..('%06X'):format(join_argb(0, textcolor.v[1] * 255, textcolor.v[2] * 255, textcolor.v[3] * 255))..'}'..name..'['..id..']:{2DB043}(('..msg..'))'
                return {color, text}
                
            end
        end
    end
    if text:find('%[D%] (.+) '..name..'%['..id..'%]: (.+)') then
        if colornick.v then
            local rank, msg = text:match('%[D%] (.+) '..name..'%['..id..'%]: (.+)')
            if rank and msg then
                text = '{3399ff}[D] '..rank..' {'..('%06X'):format(join_argb(0, textcolor.v[1] * 255, textcolor.v[2] * 255, textcolor.v[3] * 255))..'}'..name..'['..id..']: {3399ff}'..msg
                return {color, text}
                
            end
        end
    end
end

function sampev.onSendCommand(command)
    if tag.v then
        if command:find('/'..dcmd.v..'%s%A+') then
            msgd = command:match('/'..dcmd.v..'%s(.+)')
            return {'/d ['..u8:decode(nametags1[selectedtag1.v+1])..'] - ['..u8:decode(nametags2[selectedtag2.v+1])..'] '..msgd}
        end
    end
end
function showHelp(param) -- "��������" ��� �������
    imgui.TextColoredRGB('{808080}'..fa.ICON_FA_QUESTION_CIRCLE)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(imgui.GetFontSize() * 35.0)
        imgui.TextUnformatted(u8(param))
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
function getSkin()
    lua_thread.create(function()
        if not doesFileExist(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png') then
            downloadUrlToFile('https://files.advance-rp.ru/media/skins/'..getCharModel(playerPed)..'.png', getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png')
            print('�������� '..getCharModel(playerPed)..'.png')
            wait(2000)
        end
    end)
    playerskin = imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\config\\PrisonHelper\\skins\\'..getCharModel(playerPed)..'.png')
end

function cmd_su(arg)
    if arg:find('%d+') then
        suid = arg
        IW_su.v = not IW_su.v
    end
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
                licreason = '����� ���� ��������'
            end
        else
            if licreason ~= '����� ���� ��������' then licreason = '����������� ��������' end
        end
    end
end
function mySort(a,b)
    if  a[2] < b [2] then
        return true
    end
    return false
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
    mainIni.fastmenu.su = fm_su.v
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
    mainIni.color.colornick = colornick.v
    mainIni.color.color1 = textcolor.v[1]
    mainIni.color.color2 = textcolor.v[2]
    mainIni.color.color3 = textcolor.v[3]
    mainIni.suspect.zapros = zapros.v
    mainIni.suspect.reason = sureason.v
    mainIni.suspect.level = sulevel.v
    mainIni.suspect.newsu = newsu.v

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
function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		showCursor(false)
		savesettings()
		if quitGame == false then
            sampAddChatMessage('[������] {ffffff}������ �������� ���� ������ �������������. ��� ��������� ���������.', 0x6495ED)
            sampAddChatMessage('[������] {ffffff}���������� ������������� ������ (CTRL + R)', 0x6495ED)
            print('{6495ED}[������] {ffffff}������ �������� ���� ������ �������������')
            print('{6495ED}[������] {ffffff}���������� ������������� ������ (CTRL + R)')
		end
	end
end