require "resty.core"

local _M = {}

local cjson = require "cjson.safe"
local memory = ngx.shared["custom_cache"]

function  _M.new(opts)
    local dict = shared[opts.dictionary_name]
    local self = {
        dict = dict,
        opts = opts,
      }
    
      return setmetatable(self, {
        __index = cachefunc,
      })
end    

function _M:fetch(key)
    if type(key) ~= "string" then
      return nil, "key must be a string"
    end
    -- retrieve object from shared dict
    local req_json, err = memory:get(key)
    if not req_json then
      if not err then
        return nil, "request object not in cache"
      else
        return nil, "empty cache"
      end
    end
    -- decode object from JSON to table
    local req_obj = cjson.decode(req_json)
    if not req_obj then
      return nil, "could not decode request object"
    end
    return req_obj,"HIT"
  end

  function _M:store(key, req_obj, req_ttl)
    local req_json = cjson.encode(req_obj)
    if not req_json then
      return nil, "could not encode request object"
    end    
    local succ, err = memory:set(key, req_json ,req_ttl/1000)
    return succ and req_json or nil, err
  end


return _M
