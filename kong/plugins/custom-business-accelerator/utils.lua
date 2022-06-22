local utils =  {}

function utils.get_value_for_key( t, value )
    for k,v in pairs(t) do
      if k == value then return v end
    end
    return nil
end
return utils