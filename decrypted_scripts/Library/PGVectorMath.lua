
-- All "Vector" values referred to in this set of library functions are lua tables that
-- include numerical values for their 'x', 'y' and 'z' entries. These entries ARE CASE
-- SENSITIVE.
--
-- All "Scalar" values referred to in this set of library functions are simple lua numbers.

require("PGBase")

-- PG_Vector_Add - Takes the two vector parameters, adds them together and returns
-- the resulting vector.
function PG_Vector_Add(v1, v2)
	local result = { x = v1.x + v2.x, y = v1.y + v2.y, z = v1.z + v2.z }
	return result
end


-- PG_Vector_Multiply_Scalar - Takes a vector parameter, multiplies it by a scalar
-- parameter and returns the resulting vector.
function PG_Vector_Multiply_Scalar(v, s)
	local result = { x = v.x * s, y = v.y * s, z = v.z * s }
	return result
end


-- PG_Vector_Normalize - Takes a vector parameter and returns a normalized version of
-- that vector.
function PG_Vector_Normalize(v)
	local result = Vector.normalize(v)
	return result
end


