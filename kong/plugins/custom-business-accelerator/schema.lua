local typedefs = require "kong.db.schema.typedefs"


local PLUGIN_NAME = "custom-business-accelerator"


local schema = {
  name = PLUGIN_NAME,
  fields = {
    -- the 'fields' array is the top-level entry with fields defined by Kong
    { consumer = typedefs.no_consumer },  -- this plugin cannot be configured on a consumer (typical for auth plugins)
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
          -- a standard defined field (typedef), with some customizations
          { request_header = typedefs.header_name {
              required = true,
              default = "Hello-World" } },
          { response_header = typedefs.header_name {
              required = true,
              default = "Bye-World" } },
              { response_caching_enable = { -- self defined field
              type = "boolean",
              default = false,
              required = false,
               } },
               { response_caching_ttl = { -- self defined field
               type = "integer",
               default = 3000,
               required = true,
                } },
            { request_query_modify = { -- self defined field
            type = "boolean",
            default = false,
            required = false,
             } },
             { request_query_modify_mappings = { -- self defined field
             type = "string",
             required = false,
              } },
             { ttl = { -- self defined field
              type = "integer",
              default = 600,
              required = true,
              gt = 0, }}, -- adding a constraint for the value
        },
        entity_checks = {
          -- add some validation rules across fields
          -- the following is silly because it is always true, since they are both required
          { at_least_one_of = { "request_header", "response_header" }, },
          -- We specify that both header-names cannot be the same
          { distinct = { "request_header", "response_header"} },
        },
      },
    },
  },
}

return schema
