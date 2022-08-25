---@class EnergyManager : ScriptableObjectClass
---@field sv table
---@field cl table

--[[
	This can be used for any values really such as money system.
	If you are worried about performance you could combine this with the events system so only when the power changes do you call a update.
]]

EnergyManager = class( nil )
EnergyManager.DefaultSupply = 0
EnergyManager.DefaultDemand = 0
EnergyManager.DefaultStorage = 100
G_power = true

function EnergyManager:server_onCreate()
    self.sv = {}
    self.sv.power = {}
    self.sv.power.supply = EnergyManager.DefaultSupply
    self.sv.power.demand = EnergyManager.DefaultDemand
    self.sv.power.storage = EnergyManager.DefaultStorage
    self.sv.power.stored = 0
end

function EnergyManager:server_powerChanged(args)
    if args[1] == "Add" then
        self.sv.power.supply = self.sv.power.supply + (args[2] or 0)
        self.sv.power.demand = self.sv.power.demand + (args[3] or 0)
        self.sv.power.storage = self.sv.power.storage + (args[4] or 0)
    elseif args[1] == "Subtract" then
        self.sv.power.supply = self.sv.power.supply - (args[2] or 0)
        self.sv.power.demand = self.sv.power.demand - (args[3] or 0)
        self.sv.power.storage = self.sv.power.storage - (args[4] or 0)
    end
    self.network:setClientData(self.sv.power)
end

function EnergyManager:server_onFixedUpdate()
    local Usage = self.sv.power.supply - self.sv.power.demand
    if self.sv.power.stored < self.sv.power.storage or Usage < 0 then
        local Temp = self.sv.power.stored + Usage
        if Temp < 0 then
            Temp = 0
        elseif Temp > self.sv.power.storage and Usage > 0 then
            Temp = self.sv.power.storage
        end
        self.sv.power.stored = Temp
    end
    if self.sv.power.demand >= self.sv.power.supply and self.sv.power.stored < 1 then
        G_power = false
    else
        G_power = true
    end
end

function EnergyManager:client_onCreate()
    self.cl = {}
    self.cl.power = {}
    self.cl.power.supply = EnergyManager.DefaultSupply
    self.cl.power.demand = EnergyManager.DefaultDemand
    self.cl.power.storage = EnergyManager.DefaultStorage
    self.cl.power.stored = 0
end

function EnergyManager:client_onFixedUpdate()
    local Usage = self.cl.power.supply - self.cl.power.demand
    if self.cl.power.stored < self.cl.power.storage or Usage < 0 then
        local Temp = self.cl.power.stored + Usage
        if Temp < 0 then
            Temp = 0
        elseif Temp > self.cl.power.storage and Usage > 0 then
            Temp = self.cl.power.storage
        end
        self.cl.power.stored = Temp
    end
    sm.gui.displayAlertText(tostring(Usage).." "..tostring((self.cl.power.stored/self.cl.power.storage)*100).."%")
end

function EnergyManager:client_onClientDataUpdate( clientData )
    if clientData.supply and clientData.demand and clientData.storage and clientData.stored then
        self.cl.power = clientData
    end
end