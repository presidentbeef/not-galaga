local enemy_1 = love.graphics.newImage("images/enemy1.png")
local function reset_enemies(width)
  local enemies = {}
  table.insert(enemies, make_enemy(enemy_1, width / 2, 10, sine_down))
  table.insert(enemies, make_enemy(enemy_1, width / 2 + 30, 10, opposite))
  table.insert(enemies, make_enemy(enemy_1, width / 2 - 100, -25, sine_down))
  table.insert(enemies, make_enemy(enemy_1, width / 2 + 100, -50, sine_down))
  table.insert(enemies, make_enemy(enemy_1, width / 2 - 60, 10))

  return enemies
end

function start_missile(m, e)
  m.y = ship.y - 10
  m.x = ship.x + 29 + e
end

function ship_move(dt)
  if love.keyboard.isDown("right") then
    ship.image = ship.right_image
    ship.x = ship.x + 200 * dt
    ship.engine.image:setLinearAcceleration(-15, 50, -5, 60)
    ship.engine.image:setEmissionRate(15)
  elseif love.keyboard.isDown("left") then
    ship.image = ship.left_image
    ship.x = ship.x - 200 * dt
    ship.engine.image:setLinearAcceleration(5, 50, 15, 60)
    ship.engine.image:setEmissionRate(15)
  else
    ship.engine.image:setLinearAcceleration(0, 30, 0, 40)
    ship.engine.image:setEmissionRate(6)
    ship.image = ship.main_image
  end

  if ship.x >= ship_max_w then
    ship.x = ship_max_w
  elseif ship.x < 0 then
    ship.x = 0
  end
end

function missile_move(m, dt)
  if m.y > 0 then
    m.y = m.y - 600 * dt
  else
    m.y = -1
  end
end

function background_move(dt)
  background.y = background.y + (10 * dt)
  background2.y = background2.y + (35 * dt)

  if background.y >= 0 then
    background.y = -288 * 2
  end

  if background2.y >= 0 then
    background2.y = -288 * 2
  end
end

function engine_move(dt)
  ship.engine.image:update(dt)
  ship.engine.x = ship.x + 37
  ship.engine.y = ship.y + 71
end

function enemy_move(enemy, dt)
  enemy:movement(dt)
end

function draw_missile(m)
  if m.y > 0 then
    love.graphics.draw(m.image, m.x, m.y, 0, 0.15, 0.15)
  end
end

function draw_object(obj)
  love.graphics.draw(obj.image, obj.x, obj.y)
end

function in_box(self, obj)
  return obj.y > self.y and
  obj.y < self.y + self.h and
  obj.x > self.x and
  obj.x < self.x + self.w
end

function make_object(image, x, y)
  local obj = {
    image = image,
    x = x,
    y = y,
  }

  if image:type() == "Image" then
    obj.h = image:getHeight()
    obj.w = image:getWidth()
    obj.in_box = in_box
  end

  return obj
end

function make_enemy(image_src, x, y, movement)
  local enemy = make_object(image_src, x, y)
  enemy.mv = 1
  enemy.max_w = w_max_w - enemy.image:getWidth()

  if movement then
    enemy.movement = movement
  else
    enemy.movement = right_left_down
  end

  return enemy
end

function explode(x, y)
  local img = love.graphics.newImage("images/yellow.png")
  local psystem = love.graphics.newParticleSystem(img, 30)
  psystem:setParticleLifetime(0.1, 0.5)
  psystem:setSizeVariation(0.5)
  psystem:setLinearAcceleration(-300, -300, 300, 300)
  psystem:setSpeed(-200, 200)
  psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.
  psystem:emit(30)

  local e = make_object(psystem, x, y)

  table.insert(explosions, e)
end

--- Enemy Movement

function right_left_down(enemy, dt)
  if enemy.x > enemy.max_w then
    enemy.x = enemy.max_w
    enemy.y = enemy.y + 10
    enemy.mv = -1
  elseif enemy.x < 0 then
    enemy.x = 0
    enemy.y = enemy.y + 10
    enemy.mv = 1
  end

  if enemy.y > w_max_h then
    enemy.y = 0
  end

  enemy.x = enemy.x + (dt * enemy.mv * 250)
end

function sine_down(enemy, dt)
  enemy.y = enemy.y + (dt * 100)
  enemy.x = enemy.x + (math.sin(dt * enemy.y * math.pi / 2) * 1.25)
  if enemy.x > enemy.max_w then
    enemy. x = 0
  end

  if enemy.y > w_max_h then
    enemy.y = 0
  end
end

function opposite(enemy, dt)
  if math.abs(enemy.x - ship.x) < 50 then
    if enemy.x > ship.x then
      enemy.x = enemy.x + 1
    else
      enemy.x = enemy.x - 1
    end
  elseif math.abs(enemy.x - ship.x) > 60 then
    if enemy.x > ship.x then
      enemy.x = enemy.x - 1
    else
      enemy.x = enemy.x + 1
    end
  end

  if enemy.x > enemy.max_w then
    enemy.x = enemy.max_w
  elseif enemy.x < 0 then
    enemy.x = 0
  end
end

function love.load()
  love.window.setMode(244 * 2, 288 * 2)
  love.window.setTitle("Not Galaga")

  local width, height, _ = love.window.getMode()
  ship_max_w = width - 70
  w_max_w = width
  w_max_h = height

  ship = make_object(love.graphics.newImage("images/ship.png"), width / 2, height - 100)

  ship.main_image = ship.image
  ship.left_image = love.graphics.newImage("images/ship_left.png")
  ship.right_image = love.graphics.newImage("images/ship_right.png")

  enemies = reset_enemies(width)
  background = make_object(love.graphics.newImage("images/background1.png"), 0, -288 * 2)
  background2 = make_object(love.graphics.newImage("images/background2.png"), 0, -288 * 2)

  missile = {}
  local missile_image = love.graphics.newImage("images/missile.png")
  missile[0] = make_object(missile_image, -1, -1)
  missile[1] = make_object(missile_image, -1, -1)

  local img = love.graphics.newImage("images/red.png")

  local psystem = love.graphics.newParticleSystem(img, 30)
  psystem:setParticleLifetime(1, 2)
  psystem:setEmissionRate(6)
  psystem:setSizeVariation(0.1)
  psystem:setLinearAcceleration(0, 10, 0, 10)
  psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

  ship.engine = make_object(psystem, ship.x + 37, ship.y + 71)
  bg_flicker = 0
  explosions = {}
end

function love.draw()
  love.graphics.setColor(255, 255, 255, (223 + math.sin(bg_flicker) * 32))
  draw_object(background)
  love.graphics.reset()
  draw_object(background2)
  draw_object(ship.engine)
  love.graphics.draw(ship.image, ship.x, ship.y, 0, 0.25, 0.25)
  for _, e in ipairs(enemies) do
    draw_object(e)
  end
  draw_missile(missile[0])
  draw_missile(missile[1])
  for _, e in ipairs(explosions) do
    draw_object(e)
  end
end

function love.update(dt)
  ship_move(dt)
  engine_move(dt)
  for _, e in ipairs(enemies) do
    enemy_move(e, dt)
  end
  missile_move(missile[0], dt)
  missile_move(missile[1], dt)

  local deleted = {}

  for i, enemy in ipairs(enemies) do
    if enemy:in_box(missile[0]) then
      explode(missile[0].x, missile[0].y)
      missile[0].y = -1000
      enemy.y = -1000
      table.insert(deleted, i)
    elseif enemy:in_box(missile[1]) then
      explode(missile[1].x, missile[1].y)
      missile[1].y = -1000
      table.insert(deleted, i)
    end
  end

  background_move(dt)
  bg_flicker = bg_flicker + dt

  for _, e in ipairs(explosions) do
    e.image:update(dt)
  end

  for _, d in ipairs(deleted) do
    table.remove(enemies, d)
  end

  if #enemies == 0 then
    enemies = reset_enemies(w_max_w)
  end
end

function love.keypressed(key)
  if key == " " or key == "a" or key == "s" then
    if missile[0].y < 0 then
      start_missile(missile[0], 0)
    elseif missile[1].y < 0 then
      start_missile(missile[1], 8)
    end
  elseif key == "escape" then
    love.event.push('quit')
  end
end
