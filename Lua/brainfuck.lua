-- Autho: 月波 清火 (tukinami seika)
-- License: MIT

ZeroInitArray = {
   new = function()
      local obj = {}

      setmetatable(obj, {
          __index = function(self, index)
             return 0 or self[index]
          end
      })

      return obj
   end;
}

--[[https://qiita.com/demoin/items/fe2d243fa79745977758]]
function instance(class, super, ...)
    local self = (super and super.new(...) or {})
    setmetatable(self, {__index = class})
    setmetatable(class, {__index = super})
    return self
end

Memory = {
   new = function()
      local obj = instance(Memory)

      obj.m_pointer = 1
      obj.m_body = ZeroInitArray:new()

      return obj
   end;

   increase_pointed_value = function(self)
      self.m_body[self.m_pointer] = self.m_body[self.m_pointer] + 1
   end;

   decrease_pointed_value = function(self)
      self.m_body[self.m_pointer] = self.m_body[self.m_pointer] - 1
   end;

   increase_pointer = function(self)
      self.m_pointer = self.m_pointer + 1
   end;

   decrease_pointer = function(self)
      self.m_pointer = self.m_pointer - 1
   end;

   set_pointer = function(self, new_pointer)
      assert(type(new_pointer) == "number")
      self.m_pointer = new_pointer
   end;

   get_pointed_value = function(self)
      return self.m_body[self.m_pointer]
   end;

   init = function(self)
      self:set_pointer(1)
      self.m_body = ZeroInitArray:new()
   end;
}

Source = {
   new = function(src)
      local obj = instance(Source)

      assert(type(src) == "string")
      obj.m_pointer = 1
      obj.m_body = src
      obj.m_bracket_stack = Source.create_bracket_stack(src)

      return obj
   end;

   create_bracket_stack = function(src)
      local result = {}
      local left_bracket_stack = {}

      for i = 1, src:len() do
         local char = src:sub(i, i)

         if char == "[" then
            table.insert(left_bracket_stack, i)
         elseif char == "]" then
            assert(#left_bracket_stack > 0, "[] is not match.")

            local left_index = table.remove(left_bracket_stack)
            table.insert(result, {left_index, i})
         end
      end

      assert(#left_bracket_stack == 0, "[] is not match.")

      return result
   end;

   increase_pointer = function(self)
      self.m_pointer = self.m_pointer + 1
   end;

   set_pointer = function(self, new_pointer)
      assert(type(new_pointer) == "number")
      self.m_pointer = new_pointer
   end;

   get_pointed_value = function(self)
      return string.sub(self.m_body, self.m_pointer, self.m_pointer)
   end;

   search_matching_right_bracket = function(self)
      local result = nil
      for _, value in pairs(self.m_bracket_stack) do
         if value[1] == self.m_pointer then
            result = value[2]
            break
         end
      end

      return result
   end;

   search_matching_left_bracket = function(self)
      local result = nil
      for _, value in pairs(self.m_bracket_stack) do
         if value[2] == self.m_pointer then
            result = value[1]
            break
         end
      end
      return result
   end;

   init = function(self)
      self:set_pointer(1)
   end;
}

Output = {
   new = function()
      local obj = instance(Output)

      obj.m_body = ""

      return obj
   end;

   push_char_from_byte = function(self, byte)
      assert(type(byte) == "number")

      local char = string.char(byte)
      self.m_body = self.m_body .. char
   end;

   get_body = function(self)
      return self.m_body
   end;

   init = function(self)
      self.m_body = ""
   end;
}

Bf = {
   new = function(src)
      local obj = instance(Bf)

      obj.m_memory = Memory.new()
      obj.m_source = Source.new(src)
      obj.m_output = Output.new()

      return obj
   end;

   init = function(self)
      self.m_memory:init()
      self.m_source:init()
      self.m_output:init()
   end;

   step = function(self)
      local char = self.m_source:get_pointed_value()
      if char == "" then
         return true
      end

      if char == ">" then
         self.m_memory:increase_pointer()
      elseif char == "<" then
         self.m_memory:decrease_pointer()
      elseif char == "+" then
         self.m_memory:increase_pointed_value()
      elseif char == "-" then
         self.m_memory:decrease_pointed_value()
      elseif char == "." then
         local byte = self.m_memory:get_pointed_value()
         self.m_output:push_char_from_byte(byte)
      elseif char == "[" then
         local byte = self.m_memory:get_pointed_value()

         if byte == 0 then
            local new_pointer = self.m_source:search_matching_right_bracket()
            if new_pointer == nil then
               return true
             end
            self.m_source:set_pointer(new_pointer)
         end
      elseif char == "]" then
         local byte = self.m_memory:get_pointed_value()

         if byte ~= 0 then
            local new_pointer = self.m_source:search_matching_left_bracket()
            if new_pointer == nil then
               return true
            end
            self.m_source:set_pointer(new_pointer)
         end
      end

      self.m_source:increase_pointer()

      return false
   end;

   batch = function(self)
      while not self:step() do
      end

      return self.m_output:get_body()
   end;
}

local bf = Bf.new(arg[1])
bf:init()
print(bf:batch())
