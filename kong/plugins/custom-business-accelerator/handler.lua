-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------



local plugin = {
  PRIORITY = 1000, -- set the plugin priority, which determines plugin execution order
  VERSION = "0.1", -- version in X.Y.Z format. Check hybrid-mode compatibility requirements.
}

local _cjson_encode_ = require("cjson").encode
local get_value_for_key = require("kong.plugins.custom-business-accelerator.utils").get_value_for_key
local cachefunc = require("kong.plugins.custom-business-accelerator.cachefunc")
-- do initialization here, any module level code runs in the 'init_by_lua_block',
-- before worker processes are forked. So anything you add here will run once,
-- but be available in all workers.



-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()

  -- your custom code here
  kong.log.debug("saying hi from the 'init_worker' handler")

end --]]



--[[ runs in the 'ssl_certificate_by_lua_block'
-- IMPORTANT: during the `certificate` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:certificate(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'certificate' handler")

end --]]



--[[ runs in the 'rewrite_by_lua_block'
-- IMPORTANT: during the `rewrite` phase neither `route`, `service`, nor `consumer`
-- will have been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'rewrite' handler")

end --]]

function plugin:modify_query_params(plugin_conf)
  if plugin_conf.request_query_modify == true and plugin_conf.request_query_modify_mappings then
      map_list = {}
      query_mappings = plugin_conf.request_query_modify_mappings  
      -- list of modified parameters
      for k, v in string.gmatch(query_mappings, "(%w+)=(%w+)") do
        map_list[k] = v
      end
      local tab = {}
      -- 
      for k, v in pairs(kong.request.get_query()) do
        if tostring(k) == "name" then 
          local val = get_value_for_key (map_list,v)
          tab[k] = val or v
        else 
          tab[k] = v
        end
      end
    ngx.ctx.myheader = _cjson_encode_(tab)
    kong.service.request.set_query(tab)
  else 
    ngx.ctx.myheader = "Query mapping is off"
  end
end

function plugin:retrive_cache(plugin_conf)
  if  plugin_conf.response_caching_enable == true then
  kong.ctx.hashkey = kong.request.get_query_arg("name")
  local resp_obj= cachefunc:fetch(kong.ctx.hashkey)
   if  resp_obj then
    -- mocking response
    return kong.response.exit(200, resp_obj)
   end
  end
end

function plugin:store_cache(plugin_conf)
  local body = kong.response.get_raw_body()
  local succ,err = cachefunc:store(kong.ctx.hashkey,body,plugin_conf.response_caching_ttl)
end

-- runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  -- your custom code here
  kong.log.inspect(plugin_conf)   -- check the logs for a pretty-printed config!
  -- Modifying the URL query parameters 
  plugin:modify_query_params(plugin_conf)
  -- Caching 
  plugin:retrive_cache(plugin_conf)
end --]]


-- runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)
  local resp_obj,err= cachefunc:fetch(kong.ctx.hashkey)
  kong.response.set_header("caching", err)
  kong.response.set_header("Content-Type","application/json")
  -- your custom code here, for example;
  kong.response.set_header(plugin_conf.response_header, "this is on the response")
end --]]


-- runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)
  -- your custom code here
  kong.log.debug("'body_filter' handler - begin")
  plugin:store_cache(plugin_conf)
  kong.log.debug("'body_filter' handler - end")
end --]]


--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)

  -- your custom code here
  kong.log.debug("saying hi from the 'log' handler")

end --]]


-- return our plugin object
return plugin
