-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")


-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

-- load the base plugin object and create a subclass
local plugin = require("kong.plugins.base_plugin"):extend()


local ngx_log = ngx.log
local DEBUG = ngx.DEBUG
local INFO = ngx.INFO

-- constructor
function plugin:new()
  plugin.super.new(self, plugin_name)

  ngx_log(INFO, "________SZILARD here in plugin => \"", plugin_name)

  -- do initialization here, runs in the 'init_by_lua_block', before worker processes are forked

end





---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
--
-- The call to `.super.xxx(self)` is a call to the base_plugin, which does nothing, except logging
-- that the specific handler was executed.
---------------------------------------------------------------------------------------------


-- handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'

function plugin:init_worker()
  plugin.super.init_worker(self)

  -- your custom code here

end





-- runs in the ssl_certificate_by_lua_block handler

function plugin:certificate(plugin_conf)
  plugin.super.certificate(self)

  -- your custom code here

end




-- runs in the 'rewrite_by_lua_block' (from version 0.10.2+)
-- IMPORTANT: during the `rewrite` phase neither the `api` nor the `consumer` will have
-- been identified, hence this handler will only be executed if the plugin is
-- configured as a global plugin!

function plugin:rewrite(plugin_conf)
  plugin.super.rewrite(self)

  -- your custom code here

end








-- runs in the 'access_by_lua_block'

function plugin:access(plugin_conf)
  plugin.super.access(self)

  -- Requests that match route /local 

  ngx_log(INFO, "________upstream_name => \"", plugin_conf.upstream_name)
  kong.log.inspect(plugin_conf.upstream_name)

  -- your custom code here
  ngx.req.set_header("Hello-World", "this is on a request")





  local path = kong.request.get_path()
  local header = kong.request.get_header("X-Country")

  if path == "/local" then
      ngx_log(INFO, "!!!!!____EUROPE CLUSTER")
      kong.service.request.set_path("/")
      kong.service.set_upstream("europe-cluster")
      kong.service.set_target("europe-cluster", 8080)
  elseif header == "Italy" then
      ngx_log(INFO, "!!!!!____ITALY CLUSTER")
      kong.service.set_upstream("italy-cluster")
      kong.service.set_target("italy-cluster", 8080)
  end


  ngx_log(INFO, "____PATH: ", path)
  ngx_log(INFO, "____HEADER: ", header)


  -- ngx_log(INFO, "____HOST: ", kong.request.get_host())
  -- ngx_log(INFO, "____FORWARDED HOST: ", kong.request.get_forwarded_host())


  -- ngx_log(INFO, "____NGX REQ: ", ngx.req)
  -- ngx.var.upstream_host = "italy-cluster"
  -- ngx.ctx.upstream_url = "italy-cluster:8080"
  -- ngx_log(INFO, "____UPSTREAM HOST: ", ngx.var.upstream_host)
  -- ngx_log(INFO, "____UPSTREAM URL: ", ngx.ctx.upstream_url)

end








-- runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)
  plugin.super.header_filter(self)

  -- your custom code here, for example;
  ngx.header["Bye-World"] = "this is on the response"
  ngx.header["SZILARD"] = "!!!!!!!! HERE !!!!!!!!"

end





-- runs in the 'body_filter_by_lua_block'

function plugin:body_filter(plugin_conf)
  plugin.super.body_filter(self)

  -- your custom code here

end






-- runs in the 'log_by_lua_block'

function plugin:log(plugin_conf)
  plugin.super.log(self)

  -- your custom code here

end



-- set the plugin priority, which determines plugin execution order
plugin.PRIORITY = 1000

-- return our plugin object
return plugin



