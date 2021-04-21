# Resouce File - CarRadio
function getEntity(player)
	local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
	return entity
end

function GetInputMode()
	return Citizen.InvokeNative(0xA571D46727E2B718, 2) and "MouseAndKeyboard" or "GamePad"
end



function DrawSpecialText(m_text, showtime)
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end


local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
	
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
	
		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next
	
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds()
		return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
		return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function RotationToDirection(rotation)
	local retz = rotation.z * 0.0174532924
	local retx = rotation.x * 0.0174532924
	local absx = math.abs(math.cos(retx))

	return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

function OscillateEntity(entity, entityCoords, position, angleFreq, dampRatio)
	if entity ~= 0 and entity ~= nil then
		local direction = ((position - entityCoords) * (angleFreq * angleFreq)) - (2.0 * angleFreq * dampRatio * GetEntityVelocity(entity))
		ApplyForceToEntity(entity, 3, direction.x, direction.y, direction.z + 0.1, 0.0, 0.0, 0.0, false, false, true, true, false, true)
	end
end






if Config.AntiCheatCDOJRP then
	-- prevent infinite ammo, godmode, invisibility and ped speed hacks
Citizen.CreateThread(function()
    while true do
	Citizen.Wait(1)
	SetPedInfiniteAmmoClip(PlayerPedId(), false)
	SetEntityInvincible(PlayerPedId(), false)
	SetEntityCanBeDamaged(PlayerPedId(), true)
	ResetEntityAlpha(PlayerPedId())
	local fallin = IsPedFalling(PlayerPedId())
	local ragg = IsPedRagdoll(PlayerPedId())
	local parac = GetPedParachuteState(PlayerPedId())
	if parac >= 0 or ragg or fallin then
		SetEntityMaxSpeed(PlayerPedId(), 80.0)
	else
		SetEntityMaxSpeed(PlayerPedId(), 7.1)
	end
    end
end)
end

	-----Anti Ped Attack - Server Wide

		Citizen.CreateThread(function()
			while true do
				PedStatus = 0
				for ped in EnumeratePeds() do
					PedStatus = PedStatus + 1
					if not (IsPedAPlayer(ped))then
						RemoveAllPedWeapons(ped, true)
						DeleteEntity(ped)
					end
				end
				Citizen.Wait(1)
			end
		end)


--Super Jump Detection
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsPedJumping(PlayerPedId()) then
			local jumplength = 0
			repeat
				Wait(0)
				jumplength=jumplength+1
				local isStillJumping = IsPedJumping(PlayerPedId())
			until not isStillJumping
			if jumplength > 250 then
				TriggerServerEvent("CDOJRP:ViolationDetected", "🛡️ Super Jump " .. jumplength,true)
			end
		end
	end
end)


		Citizen.CreateThread(function()
			while true do
				 Citizen.Wait(30000)
					local curPed = PlayerPedId()
					local curHealth = GetEntityHealth( curPed )
					SetEntityHealth( curPed, curHealth-2)
					local curWait = math.random(10,150)
					Citizen.Wait(curWait)
					if not IsPlayerDead(PlayerId()) then
						if PlayerPedId() == curPed and GetEntityHealth(curPed) == curHealth and GetEntityHealth(curPed) ~= 0 then
							TriggerServerEvent("CDOJRP:ViolationDetected", "🛡️ Godmode",true)
						elseif GetEntityHealth(curPed) == curHealth-2 then
							SetEntityHealth(curPed, GetEntityHealth(curPed)+2)
						end
					end
					if GetEntityHealth(PlayerPedId()) > 200 then
						TriggerServerEvent("CDOJRP:ViolationDetected", "🛡️ Godmode",true)
					end
					if GetPedArmour(PlayerPedId()) < 200 then
						Wait(50)
						if GetPedArmour(PlayerPedId()) == 200 then
							TriggerServerEvent("CDOJRP:ViolationDetected", "🛡️ Godmode",true)
						end
				end
			end
		end)

--Additional God Mode Check
Citizen.CreateThread(function()
    local timesDetected = 0

    while true do

        if (timesDetected >= 10) then
            TriggerServerEvent("CDOJRP:ViolationDetected", "🛡️ Godmode",true)
        end

        if Config.AntiGodmodeCDOJRP then
            local playerId      = PlayerId()
            local playerPed     = GetPlayerPed(-1)
            local health        = GetEntityHealth(playerPed)

            SetPlayerHealthRechargeMultiplier(playerId, 0.0)
            SetEntityHealth(playerPed, health - 2)

            Citizen.Wait(50)

            if (GetEntityHealth(playerPed) > (health - 2)) then
                timesDetected = timesDetected + 1
            elseif(timesDetected > 0) then
                timesDetected = timesDetected - 1
            end

            SetEntityHealth(playerPed, GetEntityHealth(playerPed) + 2)
        else
            Citizen.Wait(1000)
        end
    end
end)


if Config.AntiSpectateCDOJRP then
	Citizen.CreateThread(function()
    	while true do
        	Citizen.Wait(1000)
			if NetworkIsInSpectatorMode() then
    			TriggerServerEvent("CDOJRP:spectate")
    		end
		end
	end)
end

BlacklistedCmdsxd = {"hi","brutan","panic","desudo","ham","hammafia","hamhaxia","redstonia","hyra","hydro", "vibes",
"chocolate",
"pk",
"haha",
"lol",
"panickey",
"killmenu",
"panik",
"ssssss",
"brutan",
"panic",
"brutanpremium",
"hammafia",
"purgemenu",
"hamhaxia",
"redstonia",
"hoax",
"desudo",
"jd",
"ham",
"lua options",
"God Mode",
"Maestro",
"FunCtionOk",
"lynx9_fixed",
"Fucked",
"injected",
"vRP",
"deleted due to u being a nigger",
"Dopamine injected successfully",
"parent menu doesn",
"www.d0pamine.xyz",
"d0pamine v1.1 by Nertigel",
"d0pamine",
"lynx",
"FOriv gay",
"TiagoModz#1478",
"WarMenu",
"tiago",
"TiagoModz",
"dopamine",
"dopamina",
"Nertigel: This server is protected and the menu is not gonna work here.", 
"Information",
"[dopamine]",
"KP",
"opk",
"jolmany",
"SovietH4X"}

if Config.AntiBlacklistedCmds then
Citizen.CreateThread(function()
    while true do
		Citizen.Wait(1000)
		for _, bcmd in ipairs(GetRegisteredCommands()) do
		for _, bcmds in ipairs(BlacklistedCmdsxd) do
				if bcmd.name == bcmds then
					TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Injection detected!",true)
			end
		end
		end
	end
end)
end

if Config.AntiBlipsCDOJRP then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			local blipcount = 0
			local playerlist = GetActivePlayers()
				for i = 1, #playerlist do
					if i ~= PlayerId() then
					if DoesBlipExist(GetBlipFromEntity(GetPlayerPed(i))) then
						blipcount = blipcount + 1
					end
				end
					if blipcount > 0 then
						TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Player Blips Violation",true)
					end
				end
		end
	end)
end

if Config.AntiBlacklistedWeapons then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			for _,theWeapon in ipairs(Config.BlacklistedWeapons) do
				Wait(1)
				if HasPedGotWeapon(PlayerPedId(),GetHashKey(theWeapon),false) == 1 then
						RemoveWeaponFromPed(PlayerPedId(),GetHashKey(theWeapon))
						TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ BlacklistedWeapon: "..theWeapon,Config.AntiBlacklistedWeaponsKick)
				end
			end
		end
	end)
end
	
local isInvincible = false
local isAdmin = false

Citizen.CreateThread(function()
    while true do
        isInvincible = GetPlayerInvincible(PlayerId())
        isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
        Citizen.Wait(500)
    end
end)

function DrawLabel(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

CDOJRP("sendAcePermissionToClient")
AddEventHandler("sendAcePermissionToClient", function(state)
    isAdmin = state
end)

---Upgrading Player Protection
if Config.PlayerProtectionX2 then
    Citizen.CreateThread(
        function()
            while true do
                local cj = GetPlayerPed(-1)
                SetExplosiveAmmoThisFrame(cj, 0)
                SetExplosiveMeleeThisFrame(cj, 0)
                SetFireAmmoThisFrame(cj, 0)
                SetEntityProofs(GetPlayerPed(-1), false, true, true, false, false, false, false, false)
                Citizen.Wait(0)
            end
        end
    )
end

if Config.AntiCarDetroy then
    Citizen.CreateThread(
        function()
            while true do
                Citizen.Wait(30000)
                for bd in EnumerateVehicles() do
                    if GetEntityHealth(bd) == 0 then
                        SetEntityAsMissionEntity(bd, false, false)
                        DeleteEntity(bd)
                    end
                end
            end
        end
    )
end



if Config.AntiResourceStartCheck then
---Resource stopping detection - Client Side
AddEventHandler('onClientResourceStop', function (resourceName)
	TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Resource Stopped: " .. resourceName, true)
  end)

--Resource stopping detection - Server side
AddEventHandler("onResourceStop",function(resourceName)
        if resourceName == GetCurrentResourceName() then
			TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Resource Stopped: " ..resourceName, true)
        end
    end)
--Resource Cleint Started
    AddEventHandler("onClientResourceStart",function(resourceName)
            local cL = {"easy"}
            for ap = 1, #cL do
                if cK == cL[ap] then
                    print("onClientResourceStart: " .. cL[ap] .. " has been omitted")
                    return
                end
            end
            local cM = string.len(cK)
            local cN = string.sub(cK, 1, 1)
            if cM >= 30 and cN == "_" then
				TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Resource Start: " ..resourceName, true)
            end
        end
    )
end

if Config.AntiSpeedHack then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			local speed = GetEntitySpeed(PlayerPedId())
			if not IsPedInAnyVehicle(GetPlayerPed(-1), 0) then
			if speed > 80 then
				TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Speed Hack",true)
			end
		end
		end
	end)
end

if Config.AntiKey then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if Config.AntiKeyInsert then
				if IsControlJustReleased(0, 121) then
					TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Insert Blacklisted Key",true)
				end
			end
			if Config.AntiKeyTabQ then
				if IsDisabledControlPressed(0, 37) and IsDisabledControlPressed(0, 44) then
					TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Tab+Q Blacklisted Key",true)
				end
			end
			if Config.AntiKeyShiftG then
				if IsDisabledControlPressed(0, 47) and IsDisabledControlPressed(0, 21) then
					TriggerServerEvent("CDOJRP:ViolationDetected","🛡️ Shift+G Blacklisted Key",true)
				end
			end
		end
	end)
end
