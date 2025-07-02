local utils = require("utils.lsp")
local cfg = utils.lang_server()

cfg:add_server("docker_compose_language_service", {})
cfg:add_server("dockerls", {})

cfg:set_linters({ "dockerfile" }, { "hadolint" })

return cfg:get()
