return {
	"laytan/cloak.nvim",
	event = { "BufReadPre .env*", "BufNewFile .env*" },
	cmd = { "CloakToggle", "CloakEnable", "CloakDisable" },
	opts = {},
}
