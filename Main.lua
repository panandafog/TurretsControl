
local GUI = require("GUI")
local system = require("System")
local screen = require("screen")
local component = require("component")

local screen_width, screen_height = screen.getResolution()

local turrets = {}
for address, name in component.list("turret", false) do
  table.insert(turrets, component.proxy(address))
end

local columns = 8
local rows = 2

local turrets_count = #turrets

if turrets_count < 8 then
	rows = 1
elseif turrets_count < 17 then
	rows = 2
else 
	rows = 3
end;

local workspace, window = system.addWindow(GUI.filledWindow(1, 1, screen_width, screen_height, 0x000000))

local panels_layout = window:addChild(GUI.layout(0, 2, window.width, window.height, columns, rows))
local layout = window:addChild(GUI.layout(0, 2, window.width, window.height, columns, rows))

window.actionButtons.close.onTouch = function()
    window:remove()
    workspace:draw()
end

window.actionButtons.maximize.onTouch = function()
	window:resize(workspace.width, workspace.height)
	workspace:draw()
end

local attacksMobsSwitches = {}
local attacksNeutralsSwitches = {}
local attacksPlayersSwitches = {}

local panel_width = screen_width / columns - 2
local panel_height = screen_height / rows - 5

local panel = panels_layout:setPosition(1, 1, panels_layout:addChild(GUI.panel(1, 1, panel_width, panel_height, 0x272727)))
local internal_layout = layout:setPosition(1, 1, layout:addChild(GUI.layout(1, 1, panel_width, panel_height, 1, 4)))

internal_layout:setPosition(1, 1, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, tostring("all"))))
local toggleAttacksMobsButton = internal_layout:setPosition(1, 2, internal_layout:addChild(GUI.button(1, 1, 36, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "Attack mobs")))
local toggleAttacksNeutralsButton = internal_layout:setPosition(1, 3, internal_layout:addChild(GUI.button(1, 1, 36, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "Attack neutrals")))
local toggleAttacksPlayersButton = internal_layout:setPosition(1, 4, internal_layout:addChild(GUI.button(1, 1, 36, 3, 0xB4B4B4, 0xFFFFFF, 0x969696, 0xB4B4B4, "Attack players")))


if #turrets > 0 then
  for i = 0, #turrets - 1, 1 do
    local turret = turrets[i + 1]
	
	local col = math.fmod(i + 1, columns) + 1
	local row = math.floor((i + 1) / columns + 1)
	
	layout:setFitting(col, row, false, false, 0, 0)
	local panel = panels_layout:setPosition(col, row, panels_layout:addChild(GUI.panel(1, 1, panel_width, panel_height, 0x262626)))
	local internal_layout = layout:setPosition(col, row, layout:addChild(GUI.layout(1, 1, panel_width, panel_height, 2, 4)))
	
	internal_layout:setPosition(1, 1, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, tostring("owner: "))))
	internal_layout:setPosition(2, 1, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, tostring(turret.getOwner()))))
	
	internal_layout:setPosition(1, 2, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, "mobs")))
	local attacksMobsSwitch = internal_layout:setPosition(2, 2, internal_layout:addChild(GUI.switch(1, 1, 6, 0x66DB80, 0x1D1D1D, 0xEEEEEE, turret.isAttacksMobs())))
	table.insert(attacksMobsSwitches, attacksMobsSwitch)
	attacksMobsSwitch.onStateChanged = function(state)
	  turret.setAttacksMobs(not turret.isAttacksMobs())
	end
	
	internal_layout:setPosition(1, 3, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, "neutrals")))
    local attacksNeutralsSwitch = internal_layout:setPosition(2, 3, internal_layout:addChild(GUI.switch(1, 1, 6, 0x66DB80, 0x1D1D1D, 0xEEEEEE, turret.isAttacksNeutrals())))
	table.insert(attacksNeutralsSwitches, attacksNeutralsSwitch)
	attacksNeutralsSwitch.onStateChanged = function(state)
	  turret.setAttacksNeutrals(not turret.isAttacksNeutrals())
	end
	
	internal_layout:setPosition(1, 4, internal_layout:addChild(GUI.text(1, 1, 0xFFFFFF, "players")))
    local attacksPlayersSwitch = internal_layout:setPosition(2, 4, internal_layout:addChild(GUI.switch(1, 1, 6, 0x66DB80, 0x1D1D1D, 0xEEEEEE, turret.isAttacksPlayers())))
	table.insert(attacksPlayersSwitches, attacksPlayersSwitch)
	attacksPlayersSwitch.onStateChanged = function(state)
	  turret.setAttacksPlayers(not turret.isAttacksPlayers())
	end
	
  end
end


local function updateAttacksMobsState()
  for i = 1, #turrets, 1 do
    local turret = turrets[i]
	attacksMobsSwitches[i]:setState(turret.isAttacksMobs())
	attacksMobsSwitches[i]:draw()
  end
end

local function updateAttacksNeutralsState()
  for i = 1, #turrets, 1 do
    local turret = turrets[i]
	attacksNeutralsSwitches[i]:setState(turret.isAttacksNeutrals())
	attacksNeutralsSwitches[i]:draw()
  end
end

local function updateAttacksPlayersState()
  for i = 1, #turrets, 1 do
    local turret = turrets[i]
	attacksPlayersSwitches[i]:setState(turret.isAttacksPlayers())
	attacksPlayersSwitches[i]:draw()
  end
end


local function updateTurrets() 
  turrets = {}
  for address, name in component.list("turret", false) do
    table.insert(turrets, component.proxy(address))
  end
end


local function setAllEnabled(enabled) 
  for i = 1, #turrets, 1 do
    turrets[i].setAttacksMobs(enabled)
    turrets[i].setAttacksNeutrals(enabled)
    turrets[i].setAttacksPlayers(enabled)
  end
  updateAttacksMobsState()
  updateAttacksNeutralsState()
  updateAttacksPlayersState()
end

toggleAttacksMobsButton.onTouch = function()
  local attacks = not turrets[1].isAttacksMobs()
  for i = 1, #turrets, 1 do
    turrets[i].setAttacksMobs(attacks)
  end
  updateAttacksMobsState()
end

toggleAttacksNeutralsButton.onTouch = function()
  local attacks = not turrets[1].isAttacksNeutrals()
  for i = 1, #turrets, 1 do
    turrets[i].setAttacksNeutrals(attacks)
  end
  updateAttacksNeutralsState()
end

toggleAttacksPlayersButton.onTouch = function()
  local attacks = not turrets[1].isAttacksPlayers()
  for i = 1, #turrets, 1 do
    turrets[i].setAttacksPlayers(attacks)
  end
  updateAttacksPlayersState()
end

workspace:draw()
workspace:start()
