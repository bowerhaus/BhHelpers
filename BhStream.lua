--[[ 
BhStream.lua

Simple streaming to a string. Not complete, also needs a ReadStream.
 
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

WriteStream=Core.class()

function WriteStream:init()
	self.stack={""}
end

function WriteStream:put(s)
	local stack=self.stack
	table.insert(stack, s)    -- push 's' into the the stream
	for i=table.getn(stack)-1, 1, -1 do
	if string.len(stack[i]) > string.len(stack[i+1]) then
	  break
	end
	stack[i] = stack[i] .. table.remove(stack)
	end
end

function WriteStream:char(char, n)
	if n then 
		for i=1,n-1 do self:put(char) end
	end
	self:put(char)
end

function WriteStream:cr(n)
	self:char("\n", n)
end

function WriteStream:tab(n)
	self:char("\t", n)
end

function WriteStream:space(n)
	self:char(" ", n)
end

function WriteStream:contents()
	return table.concat(self.stack)
end

