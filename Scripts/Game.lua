dofile("$CONTENT_DATA/Scripts/Utils/NetworkSystem/Network.lua")
dofile("$CONTENT_DATA/Scripts/Utils/EventsSystem/Events.lua")

--[[
	Remember that all class functions are callable by network, so be careful how you program. (Except class callbacks)
]]

Game = class( nil )

-- [[ Server Functions ]] --

function Game:server_onCreate()
	print("Game.server_onCreate")
    self.sv = {}
	self.sv.saved = self.storage:load()
    if self.sv.saved == nil then
		self.sv.saved = {}
		self.sv.saved.world = sm.world.createWorld( "$CONTENT_DATA/Scripts/World.lua", "World" )
		self.storage:save( self.sv.saved )
	end
end

function Game:server_onRefresh()
    print("server_onRefresh")
    self.network:sendToClients("client_test","yes")
end

function Game:server_onFixedUpdate()
    FireEvent("GameTick",sm.game.getCurrentTick()) -- should be on server events.
end

function Game:server_onPlayerJoined( player, isNewPlayer )
    print("Game.server_onPlayerJoined")
    if isNewPlayer then
        if not sm.exists( self.sv.saved.world ) then
            sm.world.loadWorld( self.sv.saved.world )
        end
        self.sv.saved.world:loadCell( 0, 0, player, "sv_createPlayerCharacter" )
    end
end

function Game:sv_createPlayerCharacter( world, x, y, player, params ) -- would be considered unsecure, but because mutiple arguments are required its kinda secured?
    local character = sm.character.createCharacter( player, world, sm.vec3.new( 32, 32, 5 ), 0, 0 )
	player:setCharacter( character )
end

function Game:server_test( args, player )
    if not VaildateNetwork("server_test",{player=player},{server=true,auth=true}) then return end
    print("You passed server checks!")
end

-- [[ Client Functions ]] --

function Game:client_onFixedUpdate()
    FireEvent("GameTick",sm.game.getCurrentTick()) -- should be on client events.
end

function Game:client_test( args, player )
    if not VaildateNetwork("client_test",{player=player},{server=false}) then return end
    print("You passed client checks!")
end

function Game:client_onRefresh()
    local function DelayedAction()
        print("EventFired")
        self.network:sendToServer("server_test","no")
    end
    print("PlacedEvent")
    Event("GameTick",DelayedAction,false,sm.game.getCurrentTick()+40)
end