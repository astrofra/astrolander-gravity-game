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
		if type(self.values[0]) == "number" then
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

-- return LinearFilter

-- //------------------
-- class	LinearFilter
-- //------------------
-- {

-- 	filter_size		=	0
-- 	values			=	0

-- 	constructor(_size)
-- 	{
-- 		filter_size	=	_size
-- 		values = []
-- 	}

-- 	function	SetNewValue(val)
-- 	{
-- 		values.append(val)
-- 		if (values.len() > filter_size)
-- 			values.remove(0)
-- 	}

-- 	function	GetFilteredValue()
-- 	{
-- 		local	filtered_value
-- 		if ((typeof values[0]) == "float")
-- 			filtered_value = 0.0
-- 		else
-- 			filtered_value = Vector(0,0,0)

-- 		foreach(_v in values)
-- 			filtered_value += _v

-- 		filtered_value /= (values.len().tofloat())

-- 		return	filtered_value
-- 	}

-- }