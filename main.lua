local utf8 = require('utf8')
local http = require('socket.http')
local ltn12 = require('ltn12')
local suit = require('suit')

function _StaticLunaThunk()
  local response = {}
  local addressBar = {
    text = 'http://luna.jtparrett.co.uk/test'
  }

  function runResponse(type)
    if response[type] then
      response[type]()
    end
  end

  function updateResponse(type, thunk)
    if love[type] ~= thunk then
      response[type] = love[type]
    end    
  end

  function populateResponse()
    updateResponse('update', update)
    updateResponse('draw', draw)
    updateResponse('textinput', textinput)
    updateResponse('keypressed', keypressed)
  end

  function reset()
    -- Public LOVE Api's
    love.load = load
    love.update = update
    love.textinput = textinput
    love.keypressed = keypressed
    love.draw = draw
  end
   
  function submit()
    local data = {}
    http.request({ 
      url = addressBar.text,
      sink = ltn12.sink.table(data)
    })

    loadstring(table.concat(data))()
    populateResponse()
    reset()
  end

  function load()
    love.graphics.setBackgroundColor(255, 255, 255, 255)
    love.keyboard.setKeyRepeat(true)
    love.window.setMode(1000, 1000, {
      resizable = true
    })
  end

  function update()
    local width, height = love.window.getMode()
    suit.layout:reset(5, 5)
    suit.Input(addressBar, suit.layout:row(width - 10, 30))
    runResponse('update')
  end
   
  function textinput(t)
    suit.textinput(t)
    runResponse('textinput')
  end

  function keypressed(key)
    suit.keypressed(key)
    runResponse('keypressed')

    if key == 'return' then
      submit()
    end
  end

  function draw()
    love.graphics.setColor(0, 0, 0, 255)
    runResponse('draw')
    suit.draw()
  end

  return { init = reset }
end

_StaticLunaThunk().init()