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

function getClassName(class)
	-- Answers a string name for a supplied class object.
	-- Note, this involves a sequential search through the global table so is 
	-- not particularly fast.
	--
	for k,v in pairs(_G) do
		if v==class then
			return k
		end
	end
	return nil
end

function Object:getClass()
	return getmetatable(self)
end

function Object:enableDestructor()
	self._proxy = newproxy(true)
	getmetatable(self._proxy).__gc = function() self:_destroy() end
end

function Object:_destroy()
end

local _tween

function postToUpdateQueue(func)
	_tween=GTween.new(stage, 0.001, {}, {onComplete=function() func() _tween=nil end})
end

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

function Sprite:isChildOf(anotherSprite)
	local each=self
	while each do
		each=each:getParent()
		if each==anotherSprite then
			return true
		end
	end
	return false
end	

function Sprite:localToLocal(x, y, target)
	return target:globalToLocal(self:localToGlobal(x, y))
end

function Sprite:resetAnchor(ax, ay)
	ax=ax or 0
	ay=ay or 0	
	local x, y=self:getPosition()
	local _, _, w, h=self:getBounds(self)
	self:resetOrigin(w*ax, h*ay)
end

function Sprite:resetOrigin(rx, ry)
	local x, y=self:getPosition()
	local ox, oy=math.huge, math.huge
	for each in self:eachChild() do
		local x, y=each:getBounds(self)
		ox=math.min(ox, x)
		oy=math.min(oy, y)
	end
	for each in self:eachChild() do
		each:setX(each:getX()-ox-rx)
		each:setY(each:getY()-oy-ry)
	end		
	self:setPosition(x+ox+rx, y+oy+ry)
end

function Sprite:rotateAboutAnchor(angle, ax, ay)
	local x, y, w, h=self:getBounds(self)
	local px=ax*w
	local py=ay*h
	local gx, gy=self:localToGlobal(px, py)
	local matrix=self:getMatrix()
	matrix=matrix:translate(-gx, -gy)
	matrix=matrix:rotate(-angle)
	matrix=matrix:translate(gx, gy)
	self:setMatrix(matrix)
end

function Sprite:rotateAbout(angle, gx, gy)
	local matrix=self:getMatrix()
	matrix=matrix:translate(-gx, -gy)
	matrix=matrix:rotate(-angle)
	matrix=matrix:translate(gx, gy)
	self:setMatrix(matrix)
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

function Sprite:eachChild()
	local i=0
	local max=self:getNumChildren()
	return function() 
		i=i + 1; 
		if i<= max then 
			return self:getChildAt(i) 
		end
	end
end

function Sprite:getChildren()
	local children={}
	for each in self:eachChild() do
		children[#children+1]=each
	end
	return children
end

function Sprite:scaleToWidth(width)
	local scaleBy=width/self:getWidth()
	self:setScaleX(self:getScaleX()*scaleBy)
	self:setScaleY(self:getScaleY()*scaleBy)
end

function Sprite:scaleToHeight(height)
	local scaleBy=height/self:getHeight()
	self:setScaleX(self:getScaleX()*scaleBy)
	self:setScaleY(self:getScaleY()*scaleBy)
end

function Sprite:multiplyScale(scaleBy)
	self:setScaleX(self:getScaleX()*scaleBy)
	self:setScaleY(self:getScaleY()*scaleBy)
end

function Sprite:eachSibling()
	local i=0
	local parent=self:getParent()
	local max=parent:getNumChildren()
	return function() 
		i=i + 1; 
		if i<=max and parent:getChildAt(i)==self then
			i=i + 1
		end
		if i<=max then
			return parent:getChildAt(i) 
		end
	end
end

function Sprite:getSiblings()
	local siblings={}
	for each in self:eachSibling() do
		siblings[#siblings+1]=each
	end
	return siblings
end

function Sprite:getPreviousSibling()
	local parent=self:getParent()
	local index=parent:getChildIndex(self)
	if index<=1 then
		return nil
	end
	return parent:getChildAt(index-1)
end

function Sprite:getNextSibling()
	local parent=self:getParent()
	local index=parent:getChildIndex(self)
	if index>=parengt:getNumChildren() then
		return nil
	end
	return parent:getChildAt(index+1)
end


function Sprite:fadeUp(duration, optFinalAlpha, completionFunc)
	GTween.new(self, duration, { alpha=optFinalAlpha or 1 }, { onComplete=completionFunc })
end

function Sprite:fadeDown(duration, optFinalAlpha, completionFunc)
	GTween.new(self, duration, { alpha=optFinalAlpha or 0 }, { onComplete=completionFunc })
end

function Sprite:pulse(period, factor, optCount, optCompletionFunc)
	local trueXFactor=factor/self:getScaleX()
	local trueYFactor=factor/self:getScaleY()
	self._pulseTween=GTween.new(self, period/2, {scaleX=trueXFactor, scaleY=trueYFactor}, {repeatCount=optCount or 0, reflect=true, onComplete=optCompletionFunc})
end

function Sprite:cancelPulse()
	if self._pulseTween then
		self._pulseTween:toEnd()
		self._pulseTween:setPaused(true)
		self._pulseTween=nil
	end
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
	self:getParent():addChildAt(self, 1)
end

function Sprite:bhSetIndex(index)
	-- Set the actual z-position of a sprite
	local parent=self:getParent()
	if index<parent:getChildIndex(self) then
		index=index-1
	end
	parent:addChildAt(self, index+1)
end

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

function Sprite:getSize()
	return self:getWidth(), self:getHeight()
end

function Sprite:getCenterPosition()
	-- Answer the center coordinates of the receiver
	local x, y=self:getPosition()
	local w, h=self:getSize()
	return x+w/2, y+h/2
end

function Sprite:setCenterPosition(x, y)
	-- Sets the center coordinates of the receiver	
	local w, h=self:getSize()
	self:setPosition(x-w/2, y-h/2)
end

function Sprite:_onMouseDown(event)
	if self:isVisibleDeeply() and self:hitTestPoint(event.x, event.y) then
		self._mouseDown={
			x=event.x, 
			y=event.y, 
			time=os.timer() }
		self:onMouseDown(event.x, event.y)
		event:stopPropagation()
	end
end

function Sprite:_onMouseMove(event)
	if self._mouseDown then
		if not(self._mouseDrag) and math.pt2dDistance(self._mouseDown.x, self._mouseDown.y, event.x, event.y)>self._mouseHysteresis then
			-- Not yet dragging and mouse has moved beyond hysteresis limit
			self._mouseDrag={
				x=event.x, 
				y=event.y, 
				xoffset=event.x-self._mouseDown.x, 
				yoffset=event.y-self._mouseDown.y, 
				time=os.timer() }
		end
		if self._mouseDrag then
			self:onMouseMove(event.x, event.y, event.x-self._mouseDrag.xoffset,  event.y-self._mouseDrag.yoffset)
		end
		event:stopPropagation()
	end
end

function Sprite:_onMouseUp(event)
	if self._mouseDown then
		self:onMouseUp(event.x, event.y)
		if not(self._mouseDrag) then
			self:onMouseTap(event.x, event.y)
		end
		self._mouseDown=nil
		self._mouseDrag=nil
		event:stopPropagation()
	end
end

function Sprite:onMouseDown(x, y)
end

function Sprite:onMouseMove(x, y)
end

function Sprite:onMouseUp(x, y)
end

function Sprite:onMouseTap(x, y)
end

function Sprite:enableMouse(optHysteresis)
	self._mouseHysteresis=optHysteresis or 0
	self:addEventListener(Event.MOUSE_DOWN, self._onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self._onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self._onMouseUp, self)
end

function Sprite:disableMouse()
	self:removeEventListener(Event.MOUSE_DOWN, self._onMouseDown, self)
	self:removeEventListener(Event.MOUSE_MOVE, self._onMouseMove, self)
	self:removeEventListener(Event.MOUSE_UP, self._onMouseUp, self)
end

function Sprite:onUpdate()
end

function Sprite:enableUpdates(tf)
	if (tf or tf==nil) then
		self:addEventListener(Event.ENTER_FRAME, self.onUpdate, self)
	else
		self:disableUpdates()
	end
end

function Sprite:disableUpdates()
	self:removeEventListener(Event.ENTER_FRAME, self.onUpdate, self)
end

function Matrix:getData()
	return {
		m11=self:getM11(),
		m12=self:getM12(),
		m21=self:getM21(),
		m22=self:getM22(),
		tx=self:getTx(),
		ty=self:getTy()
	}
end

function Matrix:setData(data)
	self:setElements(data.m11, data.m12, data.m21, data.m22, data.tx, data.ty)
	return self
end	

function FontBase:getDescender()
	return self:getLineHeight()-self:getAscender()
end

function TextField:getTextWidth()
	-- If we have a font, use this to calculate the width as it will be more accurate.
	if self.font then
		local ls=self:getLetterSpacing()
		return self.font:getAdvanceX(self:getText(), ls)		
	else
		return self:getWidth()
	end
end

function TextField:setCenteredText(text)
	local cx=self:getX()+self:getTextWidth()/2
	self:setText(text)
	self:setX(cx-self:getTextWidth()/2)
end

function TextField:setCenteredTextWithMaxWidth(text, maxWidth, font)
	font=font or self.font
	local rotation=self:getRotation()
	local x, y=self:getPosition()
	local cx=x+self:getWidth()/2
	local cy=y-font:getDescender()
	self:setText(text)
	
	local newWidth=font:getAdvanceX(text)
	local scale=1
	if maxWidth and newWidth>maxWidth then
		scale=maxWidth/newWidth
		self:setScale(scale)
	end
	
	local yAdjust=self:getWidth()*math.sin(math.rad(rotation))/2	
	self:setPosition(cx-self:getWidth()/2, cy+font:getDescender()*scale-yAdjust)
end


function TexturePack.bhLoad(name)
	-- Load a texture pack using a single name to identify files that
	-- may be found along the Lua search path.
	return TexturePack.new(pathto(name..".txt"), pathto(name..".png"), true)
end

function Bitmap.bhLoad(name)
	-- Load a Bitmap from a PNG file that may be found along the Lua search path.
	return Bitmap.new(Texture.new(pathto(name..".png"), true))
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

AntialiasShape=Core.class(Shape)

function AntialiasShape:setFillStyle(style, color, alpha)
	self._fillStyle=style
	self._fillColor=color
	self._fillAlpha=alpha
	Shape.setFillStyle(self, style, color, alpha)
end

function AntialiasShape:setLineStyle(width, color, alpha)
	self._lineWidth=width
	self._lineColor=color
	self._lineAlpha=alpha
	Shape.setLineStyle(self, width, color, alpha)	
end

local AA_STEPS=3
local AA_FADE=1.5

function AntialiasShape:antialiasPath(steps)
	steps=steps or AA_STEPS
	self:_clear()
	
	local points=self:getPoints()
	self:setFillStyle(self._fillStyle or Shape.NONE, self._fillColor, self._fillAlpha)
	self:drawPoly(points)
	
	if self._lineWidth then
		self:setFillStyle(Shape.NONE)	
		local stepSize=1/(steps-1)
		local alpha=self._lineAlpha or 1
		local w=self._lineWidth-1+stepSize
		for i=1,steps do
			self:setLineStyle(w, self._lineColor or 0, alpha)
			self:drawPoly(points)
			w=w+stepSize
			alpha=alpha/AA_FADE
		end
	end
	Shape.endPath(self)
end

function Application:isLandscape()
	local orientation = application:getOrientation()
	return orientation == Application.LANDSCAPE_LEFT or orientation == Application.LANDSCAPE_RIGHT
end

function Application:isPortrait()
	return not(self:isLandscape())
end

function Application:getDeviceContentWidth()
	-- Answers the width of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	if self:isPortrait() then
		return application:getDeviceWidth()/application:getLogicalScaleX()
	else
		return application:getDeviceHeight()/application:getLogicalScaleY()
	end
end

function Application:getDeviceContentHeight()
	-- Answers the height of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	if self:isPortrait() then
		return application:getDeviceHeight()/application:getLogicalScaleY()
	else
		return application:getDeviceWidth()/application:getLogicalScaleX()
	end
end

function Application:getDeviceContentExtent()
	-- Answers the extent (wdth, height) of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	return self:getDeviceContentWidth(), self:getDeviceContentHeight()
end

function Application:getDeviceContentOriginX()
	-- Answers the x coordinate origin of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	if self:isPortrait() then
		return -application:getLogicalTranslateX()/application:getLogicalScaleX()
	else
		return -application:getLogicalTranslateY()/application:getLogicalScaleY()
	end
end

function Application:getDeviceContentOriginY()
	-- Answers the y coordinate origin of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	if self:isPortrait() then
		return -application:getLogicalTranslateY()/application:getLogicalScaleY()
	else
		return -application:getLogicalTranslateX()/application:getLogicalScaleX()
	end
end

function Application:getDeviceContentOrigin()
	-- Answers the origin (x, y) of the entire device screen in logical coordinates and rotated to take account
	-- of the device orientation.
	--	
	return self:getDeviceContentOriginX(), self:getDeviceContentOriginY()
end

function Application:getContentCenterX()
	-- Answers the x coordinate origin of the center in content coordinates
	--
	return self:getContentWidth()/2	
end

function Application:getContentCenterY()
	-- Answers the y coordinate origin of the center in content coordinates
	--
	return self:getContentHeight()/2	
end

function Application:getContentCenter()
	-- Answers the x, y coordinate origin of the center in content coordinates
	--
	return self:getContentCenterX(), self:getContentCenterY()	
end

function Application:getContentDiagonal()
	return math.pt2dDistance(0, 0, self:getContentWidth(), self:getContentHeight())
end

function Application:speak(text, lang)
	-- Function to speak (asynchronously) a piece of text in a given language.
	--
	if application.isIOS then
		local textToSend=text:gsub(" ", "+")
		local ttsUrl=string.format("http://translate.google.com/translate_tts?tl=%s&q=%s", lang or "en", textToSend)
		local ttsData = NSData:dataWithContentsOfURL(NSURL:URLWithString(ttsUrl))
		local avPlayer = AVAudioPlayer:initWithData_error(ttsData, nil) 
		avPlayer:play()
	end
end

SoundChannel.___set=SoundChannel.set

function SoundChannel:set(param, value)
	if param=="volume" then
		self:setVolume(value)
	elseif param=="pitch" then
		self:setPitch(value)
	else
		SoundChannel.___set(self, param, value)
	end
	return self
end
 
SoundChannel.___get=SoundChannel.get

function SoundChannel:get(param, value)
	if param=="volume" then
		return self:getVolume()
	end
	if param=="pitch" then
		return self:getPitch()
	end
	return SoundChannel.___get(self, param, value)
end

function SoundChannel:fadeIn(duration, optFinalLevel, completionFunc)
	self:setVolume(0)
	GTween.new(self, duration, { volume=optFinalLevel or 1 }, { onComplete=completionFunc })
end

function SoundChannel:fadeOut(duration, optFinalLevel, completionFunc)
	GTween.new(self, duration, { volume=finalLevel or 0 }, { onComplete=
		function() 
			self:stop()
			if completionFunc then completionFunc() end
		end
		})
end

function table.copy(t)
	-- Table shallow copy
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.copyFromTo(t, start, stop)
	local u = {}
	for i=start, stop do
		u[#u+1] = t[i] 
	end
	return u
end

function table.getValues(t)
	local u = {}
	for _, v in pairs(t) do
		u[#u+1]=v
	end
	return u
end

function table.getKeys(t)
	local u = {}
	for k, _ in pairs(t) do
		u[#u+1]=k
	end
	return u
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

function table.shuffle(t)
	local n = #t
	while n >= 2 do
		local k = math.random(n) 
		t[n], t[k] = t[k], t[n]
		n = n - 1
	end
end

function table.rotate(oldtable, index)
	local newtable={}
	for i=index, #oldtable do
		newtable[#newtable+1]=oldtable[i]
	end
	for i=1, index-1 do
		newtable[#newtable+1]=oldtable[i]
	end	
	return newtable
end

function table.contains(t, element)
	for _, value in pairs(t) do
		if value == element then
		  return true
		end
	end
	return false
end

function table.keyAtValue(t, value)
	for k,v in pairs(t) do
		if v==value then 
			return k
		end
	end
	return nil
end

function table.filter(t, predicate)
	-- Filter a table in place based on a predicate function
	local j = 1	 
	for i = 1,#t do
		local v = t[i]
		if predicate(v) then
			t[j] = v
			j = j + 1
		end
	end	 
	while t[j] ~= nil do
		t[j] = nil
		j = j + 1
	end	 
	return t
end

function pairsKeySorted(t, f)
    local a = {}    
    for n in pairs(t) do
        table.insert(a, n)
    end    
    table.sort(a, f)
 
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
 
    return iter
end

function math.round(num, factor) 
	if factor then
		-- Round a number to the nearest factor
		return factor*math.round(num/factor)
	else
		-- Round a number to the nearest integer
		return math.floor(num+.5)
	end
end

function math.roundTo(num, factor) 
	-- Round a number to the nearest factor
	return factor*math.round(num/factor)
end

function math.sign(x)
	return x>0 and 1 or x<0 and -1 or 0
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

function math.normalizeRect(x0, y0, x1, y1)
	local tlx=math.min(x0, x1)
	local brx=math.max(x0, x1)
	local tly=math.min(y0, y1)
	local bry=math.max(y0, y1)
	return tlx, tly, brx, bry
end

function math.ptInRect(px, py, x0, y0, x1, y1)
	x0, y0, x1, y1=math.normalizeRect(x0, y0, x1, y1)
	return px>=x0 and px<=x1 and py>=y0 and py<=y1
end

local _randomseed=math.randomseed

function math.randomseed(seed)
	bhDebugf("Set Random Seed(%d)", seed)
	_randomseed(seed)
	for i=1, 3 do bhDebug(math.random()) end
end

function string.findmatch(text, pattern, start)
	return string.sub(text, string.find(text, pattern, start))
end

function string.defExt(path, ext)
	local found, len, remainder = string.find(path, "^(.*)%.[^%.]*$")
	if found then
		return path
	else
		return path .. "." .. ext
	end
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

function coroutine.wait(delay)
    local co = coroutine.running()
    Timer.delayedCall(delay*1000, function() coroutine.resume(co) end)
    coroutine.yield()
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
BhDebugCrashOnError=true

function bhDebug(text, ...)
	-- Debugging trace messages that can be turned on and off
	if BhDebugOn then
		print(text, ...)
	end
end

function bhDebugf(text, ...)
	-- Debugging trace messages that can be turned on and off
	if BhDebugOn then
		print(string.format(text, ...))
	end
end

-- Crash method - raise an exception (only on iOS at present)
-- Useful to force a dump from crash loggers like Crittercism.
--
function bhCrash(type, message)
	if application.isIOS then
		local exception=NSException:exceptionWithName_reason_userInfo(type, message, nil)
		exception:raise()
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