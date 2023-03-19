local component = require("component")
local robot = component.robot
local sides = require("sides")
local geo = component.geolyzer
local inv = component.inventory_controller
 
local function check_crop_below()
  local data = geo.analyze(sides.down)
  if data["crop:name"] == -1 then
    return false
  else
    return true
  end
end
 
local function break_crop()
--select the hoe
    if inv.getStackInInternalSlot(1).name == "ic2cropstools:itemSpade" then
        robot.select(1)
        inv.equip()
    end
    robot.use(sides.down)
end
 
local function place_crop_below_twice()
--select the crop IC2:blockCrop
    if inv.getStackInInternalSlot(1).name == "IC2:blockCrop" then
        robot.select(1)
        inv.equip()
    end
    robot.use(sides.down)
    robot.use(sides.down)
end
 
local function do_cycle()
    even = false
    even_line = false
    while true do
        passable, reason = robot.move(sides.front)
        if not passable then
            if even_line then
                robot.turn(false)
            else
                robot.turn(true)
            end
            passable, reason = robot.move(sides.front)
            if passable then
                if even_line then
                    robot.turn(false)
                else
                    robot.turn(true)
                end
                even_line = not even_line
                even = not even
            else
                if even_line then
                    robot.turn(false)
                else
                    robot.turn(true)
                end
            end
        else
            even = not even
        end
        if even then
            if check_crop_below() then
                break_crop()
            end
            place_crop_below_twice()
        end
        if inv.getStackInInternalSlot(1).name == "IC2:blockCrop" then
            if inv.getStackInInternalSlot(1).size < 10 then
                break
            end
        end
        if inv.getInventorySize(sides.up) ~= nil then
            if inv.getInventorySize(sides.up) > 4 then
                if inv.getStackInInternalSlot(1).name == "ic2cropstools:itemSpade" then
                    robot.select(1)
                    inv.equip()
                end
                if inv.getStackInSlot(sides.up, 1) ~= nil then
                    if inv.getStackInSlot(sides.up, 1).name == "IC2:blockCrop" then
                        inv.suckFromSlot(sides.up, 1, 64)
                    end
                end
            end
        end
    end
end
 
do_cycle()
