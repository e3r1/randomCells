Buttons = {}

function Buttons:new(text, x, y, width, height)
	local obj= {}
        obj.text = text
        obj.x = x
        obj.y = y
        obj.width = width
        obj.height = height

        obj.state = default
        obj.click = 
        function()
        	return print(text .. " is clicked!")
        end

    function obj:draw()
    	local buttonColor = {0.3, 0.3, 0.4}
    	local textColor   = {1, 1, 1}
    	local font        = love.graphics.getFont()
		local textWidth   = font:getWidth(text)
		local textHeight  = font:getHeight()

    	love.graphics.setColor(buttonColor)
    	love.graphics.rectangle("fill", x, y, width, height)
    	love.graphics.setColor(textColor)
    	love.graphics.print(text, x+width/2, y+height/2, 0, 1, 1, textWidth/2, textHeight/2)
    end

    setmetatable(obj, self)
    self.__index = self; 
    table.insert(Buttons, obj)
    return obj
end

function updateUI(type, params)
    if type == 'mouse' then
        local mouseX, mouseY, mouseButton = unpack(params)
        for i,btn in ipairs(Buttons) do
            if (mouseX > btn.x and mouseX < btn.x + btn.width) and
                (mouseY > btn.y and mouseY < btn.y + btn.height) and
                mouseButton == 1 then
                    btn.click()
            end
        end
    end
    
end
