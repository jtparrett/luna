local utf8 = require('utf8')
local http = require('socket.http')
local ltn12 = require('ltn12')

function load()
  url = 'http://luna.jtparrett.co.uk/test'

  local width, height = love.window.getMode()
  love.keyboard.setKeyRepeat(true)
  love.graphics.setBackgroundColor(255, 255, 255, 255)
  love.window.setMode(width, height, {
    resizable = true
  })
end
 
function textinput(t)
  if loadTextinput then
    loadTextinput()
  end

  url = url .. t
end
 
function keypressed(key)
  if loadKeypressed then
    loadKeypressed(key)
  end

  if key == 'backspace' then
    local byteoffset = utf8.offset(url, -1)
    if byteoffset then
      url = string.sub(url, 1, byteoffset - 1)
    end
  end

  if key == 'return' then
    local response = {}
    http.request{ 
      url = url,
      sink = ltn12.sink.table(response)
    }

    loadstring(table.concat(response))()
    if love.textinput ~= textinput then
      loadTextinput = love.textinput
    end
    if love.keypressed ~= keypressed then
      loadKeypressed = love.keypressed
    end
    if love.draw ~= draw then
      loadDraw = love.draw
    end
    reset()
  end
end

function draw()
  love.graphics.setColor(0, 0, 0, 255)
  if loadDraw then
    loadDraw()
  end

  local width = love.graphics.getWidth()
  love.graphics.setColor(0, 0, 0, 100)
  love.graphics.rectangle('fill', 0, 0, width, 20)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(url, 10, 3)
end

function reset()
  love.load = load
  love.textinput = textinput
  love.keypressed = keypressed
  love.draw = draw
end

reset()