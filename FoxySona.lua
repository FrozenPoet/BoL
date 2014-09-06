--Version 0.01 - Initial Release (Beta)
--Version 0.02 - Smart Recall Added [Now it won't interrupt recalling with W]
--Version 0.03 - Automatic Updater has been added [To update: Press F9 two times]
--Version 0.04 - Now Smart Recall works with the Recall Mastery too

if myHero.charName ~= "Sona" then return end
--[AutoUpdate]--
local version = 0.04
local AUTOUPDATE = true
local SCRIPT_NAME = "FoxySona"
--========--
local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

local script = string.dump(
    function()
        --Content
        print("Camouflaging Done.")
 
    end
)
 
buff=""
for v=1,string.len(script) do --Convert our string into a hex string.
    buff=buff..'\\'..string.byte(script,v)
end
 
file=io.open('encrypted.txt','w') --Output our bytecode into ascii format to encrypted.txt
file:write(buff)
file:flush()
file:close()

if FileExist(SOURCELIB_PATH) then
	require("SourceLib")
else
	DONLOADING_SOURCELIB = true
	DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
	 SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/FrozenPoet/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/FrozenPoet/BoL/master/version/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
RequireI:Add("vPrediction", "https://raw.github.com/Hellsing/BoL/master/common/VPrediction.lua")
RequireI:Add("SOW", "https://raw.github.com/Hellsing/BoL/master/common/SOW.lua")
RequireI:Add("AoE_Skillshot_Position", "https://gist.githubusercontent.com/FrozenPoet/d45be2dce4f448c78f65/raw/1ee37548baa0f547456388d5a7e921989639e997/AoE_Skillshot_Position.lua")
RequireI:Check()

if RequireI.downloadNeeded == true then return end
--========--
local checkMe = nil
local checkAllies = nil

function OnGainBuff(myHero, buff)
	checkMe = Menu.wheal.healme
	checkAllies = Menu.wheal.healallies
	if (buff.name:find("Recall") ~= nil) then
		Menu.wheal.healme = false
		Menu.wheal.healallies = false
	end
end

function OnLoseBuff(myHero, buff)
	if (buff.name:find("Recall") ~= nil) then
		if checkMe then Menu.wheal.healme = true end
		if checkAllies then Menu.wheal.healallies = true end
	end
end

--[OnLoad]--
function OnLoad()
	--[Target]--
	targetselq = TargetSelector(TARGET_LESS_CAST_PRIORITY, 650, DAMAGE_MAGIC)
	targetselr = TargetSelector(TARGET_LESS_CAST_PRIORITY, 900, DAMAGE_MAGIC)

	_scriptMenu()
	PrintChat("<font color=\"#00FF00\">Foxy Sona by Foxy (MScripting) v<b>"..version.."</b> loaded Successfully! Enjoy :) </font>")	
end

--[OnDraw]--
function OnDraw()
_draw()
end

-- [Skin Changer Thing] --

local LastSkin = 0

--[OnTick]--
function OnTick()
	if myHero.dead then return end
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	--[Target update]--
	if QREADY then targetselq:update() end
	if RREADY then targetselr:update() end

	if Menu.wheal.healme then
		_healme()
	end
	if Menu.wheal.healallies then
		_healallies()
	end
	if Menu.hotkeys.harass then
		_harass()
	end
	if Menu.harassconfig.autoQ then
		_autoharass()
	end
	if Menu.ult.autoult then
		_autoR(targetselr.target)
	end
	if Menu.hotkeys.combo then 
		_combo()
	end
	if RREADY and Menu.ult.useult then
	_comboR(targetselr.target)
	end
end

function _scriptMenu()
	Menu = scriptConfig("Foxy Sona by Foxy (MScripting)", "sona")
	--[Hotkeys]--
	Menu:addSubMenu("Foxy Hotkeys", "hotkeys")
	Menu.hotkeys:addParam("combo", "Combo Key (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, 84)
	Menu.hotkeys:addParam("harass", "Harass Key (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
	--[Combo settings]--
	Menu:addSubMenu("Combo settings", "comboconfig")
	Menu.comboconfig:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	--[Harass settings]--
	Menu:addSubMenu("Harass settings", "harassconfig")
	Menu.harassconfig:addParam("useQ2", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Menu.harassconfig:addParam("manaharass", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100) 
	Menu.harassconfig:addParam("autoQ", "Auto Harass Using Q (Toggle)", SCRIPT_PARAM_ONKEYTOGGLE, false, 83)
	Menu.harassconfig:addParam("manaQ", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100) 
	--[Ult Settings]--
	Menu:addSubMenu("Crescendo settings", "ult")
	Menu.ult:addParam("useult", "Use Ulti", SCRIPT_PARAM_ONOFF, true)
	Menu.ult:addParam("ultifx", "Use Ulti if it hits * Enemies:",
	SCRIPT_PARAM_SLICE, 2, 1, 5, 0)	
	
	Menu.ult:addParam("autouseult", "Auto use Ulti in Combo", SCRIPT_PARAM_ONOFF, true)
	Menu.ult:addParam("autoult","Auto use Ulti if it hits * Enemies",
	SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	--[Heal (W) Settings]--
	Menu:addSubMenu("Heal (W) settings", "wheal")
	Menu.wheal:addParam("healme", "Auto Heal Self", SCRIPT_PARAM_ONOFF, true)
	Menu.wheal:addParam("healratio", "Auto Heal Self (Heal at % HP)", SCRIPT_PARAM_SLICE, 0.15, 0 ,1 ,2)
	Menu.wheal:addParam("healallies", "Auto Heal Allies", SCRIPT_PARAM_ONOFF, true)
	Menu.wheal:addParam("healalliesratio", "Auto Heal Allies (Heal at % HP)", SCRIPT_PARAM_SLICE, 0.15, 0 ,1 ,2)	
	--[Drawings]--
	Menu:addSubMenu("Draw settings", "draws")
	Menu.draws:addParam("drw", "Always Draw All", SCRIPT_PARAM_ONOFF, false)
	Menu.draws:addParam("drawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, false)
	Menu.draws:addParam("drawW", "Draw W Range", SCRIPT_PARAM_ONOFF, false)
	Menu.draws:addParam("drawE", "Draw E Range", SCRIPT_PARAM_ONOFF, false)
	Menu.draws:addParam("drawR", "Draw R Range", SCRIPT_PARAM_ONOFF, false)
	--[VIP Settings]--
	Menu:addSubMenu("VIP Settings", "miscs")
	Menu.miscs:addParam("packt", "Use packets to cast spells", SCRIPT_PARAM_ONOFF, false)
  Menu.miscs:addSubMenu("Lag Free Circle", "lagfree")
	Menu.miscs.lagfree:addParam("LFC", "Use Lag Free Circles", SCRIPT_PARAM_ONOFF, false) 
	
	--[Orbwalking]--
	local VP
	VP = VPrediction()
	OW = SOW(VP)
	Menu:addSubMenu("Orbwalking", "Orbwalking")
	OW:LoadToMenu(Menu.Orbwalking)
	--[Perma show]--
	Menu.hotkeys:permaShow("combo")
	Menu.hotkeys:permaShow("harass")
	Menu.harassconfig:permaShow("autoQ")
	
end

function _draw()
	--[Range skils draw]--
	if Menu.draws.drw then
		DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x05E1FA)
		DrawCircle(myHero.x, myHero.y , myHero.z, 1000, 0x05FA36)
		DrawCircle(myHero.x, myHero.y, myHero.z, 360, 0xFA05FA)
		DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFFFB00)
	else
		if Menu.draws.drawQ then
			if myHero:CanUseSpell(_Q) == READY then
				DrawCircle(myHero.x, myHero.y, myHero.z, 650, 0x05E1FA)
			end
		end
	
		if Menu.draws.drawW then
			if myHero:CanUseSpell(_W) == READY then
				DrawCircle(myHero.x, myHero.y , myHero.z, 1000, 0x05FA36)
			end
		end
		if Menu.draws.drawE then
			if myHero:CanUseSpell(_E) == READY then
				DrawCircle(myHero.x, myHero.y, myHero.z, 360, 0xFA05FA)
			end
		end
	
		if Menu.draws.drawR then
			if myHero:CanUseSpell(_R) == READY then
				DrawCircle(myHero.x, myHero.y, myHero.z, 900, 0xFFFB00)
			end
		end	
	end
end
	
function _harass()
	if ValidTarget(targetselq.target) then
		if QREADY and Menu.harassconfig.useQ2 and GetDistance(targetselq.target) <= 650 and (player.mana / player.maxMana > Menu.harassconfig.manaharass) then
			if Menu.miscs.packt then
				Packet("S_CAST", {spellId = _Q}):send()
			else
				CastSpell(_Q)
			end
		end
	end			
end

function _autoharass() 
	if ValidTarget(targetselq.target) then
		if QREADY and GetDistance(targetselq.target) <= 650 and (player.mana / player.maxMana > Menu.harassconfig.manaQ) then
			if Menu.miscs.packt then
				Packet("S_CAST", {spellId = _Q}):send()
			else
				CastSpell(_Q)
			end
		end
	end	
end
function _combo()
	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)
		if ValidTarget(targetselr.target) then _comboR(targetselr.target)end
			if ValidTarget(target, 1100) then
				if GetDistance(target) <=650 then
					if QREADY and Menu.comboconfig.useQ then
						if Menu.miscs.packt then
							Packet("S_CAST", {spellId = _Q}):send()
						else
							CastSpell(_Q)
						end
					end
					end
					end
					end
					end

function _healme() 
		if WREADY and (player.health / player.maxHealth < Menu.wheal.healratio) then
			if Menu.miscs.packt then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end
		end
end

function _healallies()
	for h=1, heroManager.iCount do
		local allies = heroManager:getHero(h)
		if allies.team == myHero.team and allies.team ~= TEAM_ENEMY and WREADY and (allies.health / allies.maxHealth < Menu.wheal.healalliesratio) and GetDistance(myHero, allies) < 1000 and allies ~= nil then
			if Menu.miscs.packt then
				Packet("S_CAST", {spellId = _W}):send()
			else
				CastSpell(_W)
			end	
		end
	end
end



--[Functions relat. to ultimate]--
function CountEnemies(point, range)
        local ChampCount = 0
        for j = 1, heroManager.iCount, 1 do
                local enemyhero = heroManager:getHero(j)
                if myHero.team ~= enemyhero.team and ValidTarget(enemyhero, 900+150) then
                        if GetDistance(enemyhero, point) <= range then
                                ChampCount = ChampCount + 1
                        end
                end
        end            
        return ChampCount
end

function _autoR(target)
        if Menu.ult.autouseult and RREADY and ValidTarget(targetselr.target) then
                local ultPos = GetAoESpellPosition(240, target, 200)
                if ultPos and GetDistance(ultPos) <= 900-240    then
                        if CountEnemies(ultPos, 240) >= Menu.ult.autoult then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        end
end

function _comboR(target)
        if Menu.hotkeys.combo and RREADY and ValidTarget(targetselr.target) then
                local ultPos = GetAoESpellPosition(240, target, 200)
                if ultPos and GetDistance(ultPos) <= 900-240    then
                        if CountEnemies(ultPos, 240) >= Menu.ult.ultifx then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        end
end

function _enemisAround(range)
	local playersCount = 0
	for i=1, heroManager.iCount do
		local target = heroManager:GetHero(i)
		if ValidTarget(target, range) then
			playersCount = playersCount + 1
		end
	end
	return playersCount
end

--[Lag Free Circles (by barasia, vadash and viseversa)]--
function round(num) 
	if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
    radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
    local points = {}
    for theta = 0, 2 * math.pi + quality, quality do
        local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
        points[#points + 1] = D3DXVECTOR2(c.x, c.y)
    end
    DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
    local vPos1 = Vector(x, y, z)
    local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
    local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
    local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
    if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
        DrawCircleNextLvl(x, y, z, radius, 1, color, Menu.miscs.lagfree.CL) 
    end
end

function _checkLf()
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function _checkLftick()
	if not Menu.miscs.lagfree.LFC then 
		_G.DrawCircle = _G.oldDrawCircle 
	else
		_G.DrawCircle = DrawCircle2
	end
end
