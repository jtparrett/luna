local http = require('socket.http')

return function(url)
  local data = http.request(url)
  local filedata = love.filesystem.newFileData(data, '', 'file')
  local imagedata = love.image.newImageData(filedata)
  return love.graphics.newImage(imagedata)
end