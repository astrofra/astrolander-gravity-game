dofile("lua_class.lua")

LinearFilter = Class {
   filter_size = nil,
   values = nil,

   __init__ = function(self, _size)
      self.filter_size = _size
      self.values = {}
   end,

   SetNewValue = function(self, val)
		table.insert(self.values, val)
		if #self.values > self.filter_size then
			table.remove(self.values, 1)
		end
   end,

	GetFilteredValue = function(self)
		local	filtered_value
		if type(self.values[1]) == "number" then
			filtered_value = 0.0
		else
			filtered_value = gs.Vector3(0,0,0)
		end

		for _, _v in pairs(self.values) do
			filtered_value = filtered_value + _v
		end

		filtered_value = filtered_value / #self.values

		return	filtered_value
	end
}