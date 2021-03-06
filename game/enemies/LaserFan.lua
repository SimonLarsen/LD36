local PlayerBullet = require("game.PlayerBullet")
local BaseLaser = require("game.enemies.BaseLaser")

local LaserFan = class("game.enemies.LaserFan", BaseLaser)

local MOVE_SPEED = 60
local ROTATION_SPEED = 1

function LaserFan:enter(properties)
	assert(#properties.points == 2, "LaserFan needs two points.")
	BaseLaser.enter(self)

	local p1, p2 = properties.points[1], properties.points[2]
	if p1.x > p2.x then
		p1, p2 = p2, p1
	end

	local xdist = p2.x - p1.x
	local ydist = p1.y - p2.y
	self.dist = math.sqrt(xdist^2 + ydist^2)

	self.x = math.floor((p1.x + p2.x) / 2 + 0.5)
	self.y = math.floor((p1.y + p2.y) / 2 + 0.5)
	self.dir = math.atan2(ydist, xdist)
	self.speed = properties.speed or MOVE_SPEED
	self.rotation_speed = properties.rotation_speed or ROTATION_SPEED

	self.hc_rect = HC.rectangle(0, 0, self.dist, 16)
	self.hc_rect:setRotation(self.dir)

	self.turret_anim = prox.Animation("data/animations/enemies/laser_fan.lua")
	self.orbit_anim = prox.Animation("data/animations/enemies/laser_fan_orbit.lua")

	self.beamw = (self.dist - 54) / 2
	self.beam_anim1 = prox.Animation("data/animations/enemies/laser_beam_orthogonal.lua")
	self.beam_anim1:setScale(self.beamw+2, 1)
	self.beam_anim2 = prox.Animation("data/animations/enemies/laser_beam_orthogonal.lua")
	self.beam_anim2:setScale(self.beamw+2, 1)

	self.beam_tip1 = prox.Animation("data/animations/enemies/laser_tip.lua")
	self.beam_tip2 = prox.Animation("data/animations/enemies/laser_tip.lua")

	self:setRenderer(prox.MultiRenderer())
	self:getRenderer():addRenderer(self.beam_anim1)
	self:getRenderer():addRenderer(self.beam_anim2)
	self:getRenderer():addRenderer(self.turret_anim)
	self:getRenderer():addRenderer(self.orbit_anim)
	self:getRenderer():addRenderer(self.beam_tip1)
	self:getRenderer():addRenderer(self.beam_tip2)
end

function LaserFan:update(dt, rt)
	BaseLaser.update(self, dt, rt)
	self.y = self.y + self.speed * dt
	self.dir = self.dir + self.rotation_speed * dt

	self.hc_rect:moveTo(self.x, self.y)
	self.hc_rect:setRotation(self.dir)
	self.orbit_anim:setRotation(self.dir+math.pi/2)

	self.beam_anim1:setRotation(self.dir)
	self.beam_anim2:setRotation(self.dir)
	self.beam_tip1:setRotation(self.dir-math.pi/2)
	self.beam_tip2:setRotation(self.dir+math.pi/2)

	local ox = math.cos(self.dir) * (27 + self.beamw / 2)
	local oy = math.sin(self.dir) * (27 + self.beamw / 2)
	self:getRenderer():setOffset(1, -ox, -oy)
	self:getRenderer():setOffset(2, ox, oy)

	ox = math.cos(self.dir) * (27 + self.beamw)
	oy = math.sin(self.dir) * (27 + self.beamw)
	self:getRenderer():setOffset(5, -ox, -oy)
	self:getRenderer():setOffset(6, ox, oy)

	for i,v in ipairs(self:getScene():findAll(PlayerBullet)) do
		if self.hc_rect:collidesWith(v:getHCShape()) then
			v:kill(true)
		end
	end

	if self.y > prox.window.getHeight() + self.dist / 2 + 16 then
		self:remove()
	end
end

function LaserFan:getHCShape()
	return self.hc_rect
end

return LaserFan
