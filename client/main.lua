RDX = nil

Citizen.CreateThread(function()
	while RDX == nil do
		TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)
		Citizen.Wait(100)
	end
end)

-- internal variables
local hasAlreadyEnteredMarker, isInATMMarker, menuIsShowed = false, false, false

RegisterNetEvent('rdx_atm:closeATM')
AddEventHandler('rdx_atm:closeATM', function()
	SetNuiFocus(false)
	menuIsShowed = false
	SendNUIMessage({
		hideAll = true
	})
end)

RegisterNUICallback('escape', function(data, cb)
	TriggerEvent('rdx_atm:closeATM')
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('rdx_atm:deposit', data.amount)
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('rdx_atm:withdraw', data.amount)
	cb('ok')
end)

Citizen.CreateThread(function()
    if not Config.EnableBlips then return end

	for _, ATMLocation in pairs(Config.ATMLocations) do
        local ATMLocation = N_0x554d9d53f696d002(1664425300, ATMLocation.x, ATMLocation.y, ATMLocation.z - Config.ZDiff)
        SetBlipSprite(ATMLocation, -1713383509, 1)
		SetBlipScale(ATMLocation, 0.2)
		Citizen.InvokeNative(0x9CB1A1623062F402, ATMLocation, "Banco")
    end  
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())
		local canSleep = true
		isInATMMarker = false

		for k,v in pairs(Config.ATMLocations) do
			if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.0 then
				isInATMMarker, canSleep = true, false
				break
			end
		end

		if isInATMMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			canSleep = false
		end
	
		if not isInATMMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			SetNuiFocus(false)
			menuIsShowed = false
			canSleep = false

			SendNUIMessage({
				hideAll = true
			})
		end

		if canSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Menu interactions
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
    if isInATMMarker and not menuIsShowed then
            DrawTxt("Press [~e~ALT~q~] para abrir o [~e~Banco~q~]", 0.50, 0.85, 0.7, 0.7, true, 255, 255, 255, 255, true)
            if IsControlJustReleased(0, 0xE8342FF2) and IsPedOnFoot(PlayerPedId()) then
				menuIsShowed = true
				RDX.TriggerServerCallback('rdx:getPlayerData', function(data)
					SendNUIMessage({
						showMenu = true,
						player = {
							money = data.money,
							accounts = data.accounts
						}
					})
				end)

				SetNuiFocus(true, true)
			end
        end
    end
end)

-- close the menu when script is stopping to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('rdx_atm:closeATM')
		end
	end
end)

function DrawTxt(str, x, y, w, h, enableShadow, col1, col2, col3, a, centre)
    local str = CreateVarString(10, "LITERAL_STRING", str, Citizen.ResultAsLong())
   SetTextScale(w, h)
   SetTextColor(math.floor(col1), math.floor(col2), math.floor(col3), math.floor(a))
   SetTextCentre(centre)
   if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
   Citizen.InvokeNative(0xADA9255D, 10);
   DisplayText(str, x, y)
end

RegisterNetEvent('rdx_banco:alert')	
AddEventHandler('rdx_banco:alert', function(txt)
    SetTextScale(0.5, 0.5)
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", txt, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xFA233F8FE190514C, str)
    Citizen.InvokeNative(0xE9990552DEC71600)
end)