--[[ 
BhHelpers.lua

Some useful add-on methods to the standard Gideros and Lua library classes
 
MIT License
Copyright (C) 2012. Andy Bower, Bowerhaus LLP

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

function Sprite:isVisibleDeeply()
	-- Answer true only if the sprite and all it's a parents are visible. Normally, isVisible() will
	-- return true even if a sprite is actually not visible on screen by wont of one of it's parents
	-- being made invisible.
	--
	local try=self
	while (try) do
		if  not(try:isVisible() and try:getAlpha()>0) then
			return false
		end
		try = try:getParent()
	end
	return true
end

function Sprite:ignoreTouchHandler(event)
	-- Simple handler to ignore touches on a sprite. This blocks touches
	-- from other objects below it.
	if self:hitTestPoint(event.touch.x, event.touch.y) then
		event:stopPropagation()
	end
end

function Sprite:ignoreMouseHandler(event)
	-- Simple handler to ignore mouse events on a sprite. This blocks mouse events
	-- from other objects below it.
	if self:hitTestPoint(event.x, event.y) then
		event:stopPropagation()
	end
end

function Sprite:ignoreTouches(event)
	-- Tell a sprite to ignore (and block) all mouse and touch events
	self:addEventListener(Event.MOUSE_DOWN, self.ignoreMouseHandler, self)
	self:addEventListener(Event.TOUCHES_BEGIN, self.ignoreTouchHandler, self)
end

function Sprite:bhSetWidth(newWidth)
	-- Set a sprite's width using the scale property
	local x,y,width,height=self:getBounds(self)
	local newScale=newWidth/width
	self:setScaleX(newScale)
end
 
function Sprite:bhSetHeight(newHeight)
	-- Set a sprite's height using the scale property
	local x,y,width,height=self:getBounds(self)
	local newScale=newHeight/height
	self:setScaleY(newScale)
end

function Sprite:bhBringToFront()
	-- Bring a sprite to the front of its parent's z-order
	self:getParent():addChild(self)
end

function Sprite:bhSendToBack()
	-- Send a sprite to the back of its parent's z-order
	self:getParent():addChildAt(self, 0)
end

function Sprite:bhSetIndex(index)
	-- Set the actual z-position of a sprite
	local parent=self:getParent()
	if index<parent:getChildIndex(self) then
		index=index-1
	end
	parent:addChildAt(self, index)
end

--[[ These anchor point functions are buggy
function Sprite:bhSetAnchorPoint(x, y)
	if self.setAnchorPoint then
		self:setAnchorPoint(x, y)
	else	
		self._apx=x
		self._apy=y
	end
end

function Sprite:bhGetAnchorPoint(x, y)
	if self.getAnchorPoint then
		return self:getAnchorPoint()
	else	
		if self._apx==nil then
			self._apx=0.5
			self._apy=0.5
		end
		return self._apx, self._apy
	end
end

function Sprite:bhSetPosition(x, y)
	if self.getAnchorPoint then
		self:setPosition(x, y)
		return 
	end
	local apx, apy=self:bhGetAnchorPoint()
	local w, h=self:getWidth(), self:getHeight()
	local offsetX, offsetY=apx*w, apy*h
	self:setPosition(x-offsetX, y-offsetY)
end

function Sprite:bhGetPosition()
	if self.getAnchorPoint then
		return self:getPosition()
	end
	local apx, apy=self:bhGetAnchorPoint()
	local w, h=self:getWidth(), self:getHeight()
	local offsetX, offsetY=apx*w-w/2, apy*h-h/2
	return self:getX()+offsetX, self:getY()+offsetY
end

function Sprite:getBhX()
	local x, y=self:bhGetPosition()
	return x
end

function Sprite:getBhY()
	local x, y=self:bhGetPosition()
	return y
end
--]]

function Sprite:bhGetAnchorPoint(x, y)
	if self.getAnchorPoint then
		return self:getAnchorPoint()
	else	
		return 0, 0
	end
end

function Sprite:bhGetBounds()
	-- Answer a table containing the boundary of the sprite with
	-- {top, right, bottom, left, width, height} members
	--
	local apx, apy=self:bhGetAnchorPoint()
	local x, y=self:getPosition()
	local w, h=self:getWidth(), self:getHeight()
	local bounds={left=x-apx*w, top=y-apy*h}
	bounds.right=bounds.left+w
	bounds.bottom=bounds.top+h
	bounds.width=w
	bounds.height=h
	bounds.centerX=(bounds.left+bounds.right)/2
	bounds.centerY=(bounds.top+bounds.bottom)/2
	return bounds
end

function Sprite:bhGetCenter()
	-- Answer the center coordinates of the receiver
	local bounds=self:bhGetBounds()
	return (bounds.left+bounds.right)/2, (bounds.top+bounds.bottom)/2
end

function TexturePack.bhLoad(name)
	-- Load a texture pack using a single name to identify files that
	-- may be found along the Lua search path.
	return TexturePack.new(pathto(name..".txt"), pathto(name..".png"))
end

function Bitmap.bhLoad(name)
	-- Load a Bitmap from a PNG file that may be found along the Lua search path.
	return Bitmap.new(Texture.new(pathto(name..".png")))
end

function Stage:bhGetCenter()
	-- Answer the center coordinates of the stage, a synonym for application:bhGetCenter() 
	return application:bhGetCenter()
end

function Application:bhGetCenter()
	-- Answer the center coordinates of the application
	return self:getContentWidth()/2, self:getContentHeight()/2
end

function Shape.bhMakeRect(x, y, width, height, optStrokeColor, optFillColor, optFillTexture)
	-- Constructor for a rectanglar shape that may have an option stroke color or fill.
	local rect=Shape.new()
	rect:beginPath(Shape.NON_ZERO)
	if optFillColor then
		rect:setFillStyle(Shape.SOLID, optFillColor)
	end
	if optFillTexture then
		rect:setFillStyle(Shape.TEXTURE, optFillTexture)
	end
	if optStrokeColor then
		rect:setLineStyle(1, optStrokeColor)
	end
	rect:moveTo(x, y)
	rect:lineTo(x+width, y)
	rect:lineTo(x+width, y+height)
	rect:lineTo(x, y+height)
	rect:lineTo(x, y)
	rect:endPath()
	return rect
end

function table.copy(t)
	-- Table shallow copy
	local u = { }
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
end

function table.reverse(t)
	-- Reverse the array elements in the receiver
    local size = #t
    local newTable = {}
    for i,v in ipairs (t) do
        newTable[size-i+1] = v
    end
    return newTable
end

function math.round(num) 
	-- Round a number to the nearest integer
	return math.floor(num+.5)
end

function math.roundTo(num, factor) 
	-- Round a number to the nearest factor
	return factor*math.round(num/factor)
end

function math.pt2dDistance(x1, y1, x2, y2)
	-- Answer the distance between 2D points
	return math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2))
end

function math.pt2dAngle(x0, y0, x1, y1)
	-- Answer the angle between two lines subtended from the origin
	local dist=math.pt2dDistance(x0, y0, x1, y1)
	local angle=math.deg(math.asin((y1-y0)/dist))	
	if x1-x0<0 then
		angle=180-angle
	elseif y1-y0<0 then
		angle=360+angle
	end
	return angle
end

function io.exists(filename)
	-- Answer true if a file identified by filename exists
	local file = io.open(filename)
	if file then
		io.close(file)
		return true
	else
		return false
		end
end

function pathto(name)
	-- Attempt to find a readable file with (name) on the Lua search path. If found, the full
	-- path to the file is returned, otherwise nil.
	for x in string.gmatch(package.path, "[^;]+") do
		local filePath=string.gsub(x, "\?\.lua", name)
--	print("try=", filePath)
		local f=io.open(filePath,"r")
		if f~=nil then 
			io.close(f) 
--	print("found=", filePath)			
			return filePath
		end
	end	
	print("failed to find ".. name)
	return nil
end

BhDebugOn=true
function bhDebug(text, ...)
	-- Debugging trace messages that can be turned on and off
	if BhDebugOn then
		print(text, ...)
	end
end

function timeToRun(func, name)
	-- Time and report the execution of a named function
	local time0=os.timer()
	func()
	local time1=os.timer()
	local diff=time1-time0
	if name then
		bhDebug(string.format("Time to run %s=%0.2fms", name, diff*1000))
	end
	return diff
end