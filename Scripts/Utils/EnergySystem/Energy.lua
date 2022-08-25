---@class Energy : ShapeClass
---@field sv table
---@field cl table

Energy = class( nil )

function Energy:server_onCreate()
    if g_energyManager then
        sm.event.sendToScriptableObject(g_energyManager,"server_powerChanged",{ "Add", self.data.supply, self.data.demand, self.data.storage })
    end
end

function Energy:server_onDestroy()
    if g_energyManager then
        sm.event.sendToScriptableObject(g_energyManager,"server_powerChanged",{ "Subtract", self.data.supply, self.data.demand, self.data.storage })
    end
end

function Energy:server_changePower(Supply,Demand,Storage)
    if g_energyManager then
        local SupplyDif = Supply - (self.data.supply or 0)
        local DemandDif = Demand - (self.data.demand or 0)
        local StorageDif = Storage - (self.data.storage or 0)
	    sm.event.sendToScriptableObject(g_energyManager,"server_powerChanged",{ "Add", SupplyDif, DemandDif, StorageDif })
    end
end