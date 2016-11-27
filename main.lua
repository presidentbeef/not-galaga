function love.load()
  love.window.setMode(244 * 2, 288 * 2)
  love.window.setTitle("Not Galaga")

  local width, height = love.window.getDimensions()
  max_w = width - 70
  
  ship = make_object(love.graphics.newImage("images/ship.png"), width / 2, height - 100)

  ship.main_image = ship.image 
  ship.left_image = love.graphics.newImage("images/ship_left.png")
  ship.right_image = love.graphics.newImage("images/ship_right.png")

  background = make_object(love.graphics.newImage("images/background1.png"), 0, -288 * 2)
  background2 = make_object(love.graphics.newImage("images/background2.png"), 0, -288 * 2)

  missile = {}
  missile[0] = make_object(love.graphics.newImage("images/missile.png"), -1, -1)
  missile[1] = make_object(love.graphics.newImage("images/missile.png"), -1, -1)

  local img = love.graphics.newImage("images/red.png")

  local psystem = love.graphics.newParticleSystem(img, 30)
  psystem:setParticleLifetime(1, 2)
  psystem:setEmissionRate(6)
  psystem:setSizeVariation(0.1)
  psystem:setLinearAcceleration(0, 10, 0, 10)
  psystem:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to transparency.

  ship.engine = make_object(psystem, ship.x + 37, ship.y + 71) 
  bg_flicker = 0
end

function love.draw()
  love.graphics.setColor(255, 255, 255, (223 + math.sin(bg_flicker) * 32))
  draw_object(background)
  love.graphics.reset()
  draw_object(background2)
  draw_object(ship.engine)
  love.graphics.draw(ship.image, ship.x, ship.y, 0, 0.25, 0.25)
  draw_missile(missile[0])
  draw_missile(missile[1])
end

function love.update(dt)
  ship_move(dt)
  engine_move(dt)
  missile_move(missile[0], dt)
  missile_move(missile[1], dt)
  background_move(dt)
  bg_flicker = bg_flicker + dt
end

function love.keypressed(key)
  if key == " " or key == "a" or key == "s" then
    if missile[0].y < 0 then
      start_missile(missile[0], 0)
    elseif missile[1].y < 0 then
      start_missile(missile[1], 8)
    end
  end
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

  if ship.x >= max_w then
    ship.x = max_w
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
    
function draw_missile(m)
  if m.y > 0 then
    love.graphics.draw(m.image, m.x, m.y, 0, 0.15, 0.15)
  end
end

function draw_object(obj)
  love.graphics.draw(obj.image, obj.x, obj.y)
end

function make_object(image, x, y)
  return {
    image = image,
    x = x,
    y = y
  }
end
