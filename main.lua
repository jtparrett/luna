local utf8 = require('utf8')
local http = require('socket.http')
local ltn12 = require('ltn12')
local suit = require('suit')

if true then
  local luna = {}
  local response = {}
  local addressBar = {
    text = 'http://luna.jtparrett.co.uk/test'
  }

  function luna.runResponse(type)
    if response[type] then
      response[type]()
    end
  end

  function luna.updateResponse(type, thunk)
    if love[type] ~= thunk then
      response[type] = love[type]
    end    
  end

  function luna.populateResponse()
    luna.updateResponse('update', luna.update)
    luna.updateResponse('draw', luna.draw)
    luna.updateResponse('textinput', luna.textinput)
    luna.updateResponse('keypressed', luna.keypressed)
  end

  function luna.reset()
    -- Public LOVE Api's
    love.load = luna.load
    love.update = luna.update
    love.textinput = luna.textinput
    love.keypressed = luna.keypressed
    love.draw = luna.draw
  end
   
  function luna.submit()
    local data = {}
    http.request({ 
      url = addressBar.text,
      sink = ltn12.sink.table(data)
    })

    loadstring(table.concat(data))()
    luna.populateResponse()
    luna.reset()
  end

  function luna.load()
    love.graphics.setBackgroundColor(255, 255, 255, 255)
    love.keyboard.setKeyRepeat(true)
    love.window.setMode(1000, 1000, {
      resizable = true
    })
  end

  function luna.update()
    local width, height = love.window.getMode()
    suit.layout:reset(5, 5)
    suit.Input(addressBar, suit.layout:row(width - 10, 30))
    luna.runResponse('update')
  end
   
  function luna.textinput(t)
    suit.textinput(t)
    luna.runResponse('textinput')
  end

  function luna.keypressed(key)
    suit.keypressed(key)
    luna.runResponse('keypressed')

    if key == 'return' then
      luna.submit()
    end
  end

  function luna.draw()
    love.graphics.setColor(0, 0, 0, 255)
    luna.runResponse('draw')
    suit.draw()
  end

  luna.reset()
end