local utf8 = require('utf8')
local http = require('socket.http')
local ltn12 = require('ltn12')
local suit = require('suit')

if true then
  local luna = {}
  local activeTab = 1
  local tabs = {
    {
      address = {
        text = 'http://luna.jtparrett.co.uk/test'
      }
    }
  }

  function luna.setError(err)
    tabs[activeTab].error = err
  end

  function luna.setActiveTab(i)
    if tabs[i] then
      activeTab = i
    end
  end

  function luna.runResponse(type, props)
    if tabs[activeTab][type] then
      tabs[activeTab][type](props)
    end
  end

  function luna.updateResponse(type)
    if love[type] ~= luna[type] then
      tabs[activeTab][type] = love[type]
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
   
  function luna.makeRequest()
    local data, status = http.request(tabs[activeTab].address.text)
    if status == 200 then
      _lunaLoadString(data, {
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

  function luna.newTab()
    table.insert(tabs, {
      address = {
        text = ''
      }
    })

    luna.setActiveTab(table.getn(tabs))
  end

  function luna.closeTab(i)
    if i > 1 then
      luna.setActiveTab(i - 1)
      table.remove(tabs, i)
    end
  end

  function luna.update(dt)
    local width, height = love.window.getMode()
    suit.layout:reset(0, 5)
    suit.layout:padding(5, 0)
    suit.layout:row(0, 30)

    local tabWidth = math.min(100, (width - 45) / table.getn(tabs))

    for key,value in pairs(tabs) do
      if suit.Button('Tab ' .. key, suit.layout:col(tabWidth - 5)).hit then
        luna.setActiveTab(key)
      end
    end

    if suit.Button('+', suit.layout:col(35)).hit then
      luna.newTab()
    end

    suit.layout:reset(5, 40)
    suit.layout:padding(5, 0)

    suit.Button('<', suit.layout:row(35, 30))
    suit.Button('>', suit.layout:col(35))

    if suit.Input(tabs[activeTab].address, suit.layout:col(width - 90)).submitted then
      luna.makeRequest()
    end
    luna.runResponse('update', dt)
  end
   
  function luna.textinput(t)
    suit.textinput(t)
    luna.runResponse('textinput', t)
  end

  function luna.keypressed(key)
    suit.keypressed(key)
    luna.runResponse('keypressed', key)

    function keyDown(id)
      return love.keyboard.isDown(id)
    end

    if keyDown('lgui') and keyDown('r') then
      luna.makeRequest()
    end
    if keyDown('lgui') and keyDown('t') then
      luna.newTab()
    end
    if keyDown('lgui') and keyDown('w') then
      luna.closeTab(activeTab)
    end
    if keyDown('lgui') and love.keyboard.isDown(1, 2, 3, 4, 5, 6, 7, 8, 9) then
      luna.setActiveTab(tonumber(key))
    end
  end

  function luna.draw()
    if tabs[activeTab].error then
      love.graphics.print(tabs[activeTab].error, 5, 80)
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