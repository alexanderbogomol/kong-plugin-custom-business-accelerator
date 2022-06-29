local plugin_name = "custom-business-accelerator"
local package_name = "kong-plugin-" .. plugin_name
local package_version = "0.1.0"
local rockspec_revision = "1"

local github_account_name = "Kong"
local github_repo_name = "kong-plugin"
local git_checkout = package_version == "dev" and "master" or package_version


package = package_name
version = package_version .. "-" .. rockspec_revision
supported_platforms = { "linux", "macosx" }
source = {
  url = "git+https://github.com/"..github_account_name.."/"..github_repo_name..".git",
  branch = git_checkout,
}


description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "https://"..github_account_name..".github.io/"..github_repo_name,
  license = "Apache 2.0",
}


dependencies = {
}


build = {
  type = "builtin",
  modules = {
    -- TODO: add any additional code files added to the plugin
    ["kong.plugins."..plugin_name..".handler"] = "/usr/local/custom/kong/plugins/"..plugin_name.."/handler.lua",
    ["kong.plugins."..plugin_name..".schema"] = "/usr/local/custom/kong/plugins/"..plugin_name.."/schema.lua",
    ["kong.plugins."..plugin_name..".utils"] = "/usr/local/custom/kong/plugins/"..plugin_name.."/utils.lua",
    ["kong.plugins."..plugin_name..".cachefunc"] = "/usr/local/custom/kong/plugins/"..plugin_name.."/cachefunc.lua"
  }
}
