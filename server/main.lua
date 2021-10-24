RDX = nil

TriggerEvent('rdx:getSharedObject', function(obj) RDX = obj end)

RegisterServerEvent('rdx_atm:deposit')
AddEventHandler('rdx_atm:deposit', function(amount)
	local _source = source
	local xPlayer = RDX.GetPlayerFromId(_source)
	amount = tonumber(amount)

	if not tonumber(amount) then return end
	amount = RDX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		TriggerClientEvent('rdx_banco:alert', source, 'Montante invalido')
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', amount)
		TriggerClientEvent('rdx_banco:alert', amount, 'Depositou')
	end
end)

RegisterServerEvent('rdx_atm:withdraw')
AddEventHandler('rdx_atm:withdraw', function(amount)
	local _source = source
	local xPlayer = RDX.GetPlayerFromId(_source)
	amount = tonumber(amount)
	local accountMoney = xPlayer.getAccount('bank').money

	if not tonumber(amount) then return end
	amount = RDX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > accountMoney then
		TriggerClientEvent('rdx_banco:alert', source, 'Montante invalido')
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
		TriggerClientEvent('rdx_banco:alert', amount, 'Retirou')
	end
end)
