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

  function luna.setError(err)
    luna.error = err
  end

  function luna.runResponse(type, props)
    if response[type] then
      response[type](props)
    end
  end

  function luna.updateResponse(type)
    if love[type] ~= luna[type] then
      response[type] = love[type]
    end    
  end

  function luna.populateResponse()
    luna.updateResponse('load')
    luna.updateResponse('update')
    luna.updateResponse('draw')
    luna.updateResponse('textinput')
    luna.updateResponse('keypressed')
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
    local b, status = http.request({ 
      url = addressBar.text,
      sink = ltn12.sink.table(data)
    })

    if status == 200 then
      _lunaLoadString(table.concat(data), {
        success = function()
          luna.populateResponse()
          luna.runResponse('load')
          luna.setError(false)
        end,
        error = luna.setError
      })
    else
      luna.setError(status)
    end

    luna.reset()
  end

  function luna.load()
    love.keyboard.setKeyRepeat(true)
    love.window.setMode(1000, 1000, {
      resizable = true
    })
  end

  function luna.update(dt)
    local width, height = love.window.getMode()
    suit.layout:reset(5, 5)
    suit.Input(addressBar, suit.layout:row(width - 10, 30))
    luna.runResponse('update', dt)
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
    if luna.error then
      love.graphics.print(luna.error, 5, 40)
    else
      luna.runResponse('draw')
    end

    love.graphics.reset()
    suit.draw()
  end

  luna.reset()
end

function _lunaLoadString(data, methods)
  local status, err = pcall(loadstring(data))
  if err then
    methods.error(err)
  else
    methods.success(status)
  end
end