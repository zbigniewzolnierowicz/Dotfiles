local function get_os_icon()
	local os = vim.uv.os_uname().sysname
	if os == "Darwin" then
		return "🍎"
	elseif os == "Linux" then
		return "🐧"
	else
		return "🪟"
	end
end

return {
	{
		"goolord/alpha-nvim",
		enabled = true,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		config = function()
			local theme = require("alpha.themes.dashboard")

      -- stylua: ignore start
      theme.section.header.val = {
        [[　　　 　　/＾>》, -―‐‐＜＾}]],
        [[　　　 　./:::/,≠´::::::ヽ.]],
        [[　　　　/::::〃::::／}::丿ハ]],
        [[　　　./:::::i{l|／　ﾉ／ }::}]],
        [[　　 /:::::::瓜イ＞　´＜ ,:ﾉ]],
        [[　 ./::::::|ﾉﾍ.{､　(_ﾌ_ノﾉイ＿]],
        [[　 |:::::::|／}｀ｽ /          /]],
        string.format(
          " 　|::::::|(_:::つ/    %s    /　neovim!", get_os_icon()),
        [[|￣￣￣￣￣￣￣＼/＿＿＿＿＿/￣￣￣￣￣]],
      }

      theme.section.buttons.val = {
        theme.button(
          "f",
          "  Find project",
          ":Telescope possession list<CR>",
          {}
        ),

        theme.button(
          "r",
          "  Recent files",
          ":lua require'telescope.builtin'.oldfiles{}<CR>",
          {}
        ),

        theme.button(
          "q",
          "  Quit",
          ":qa<CR>",
          {}
        ),
      }
      require("alpha").setup(theme.config)
		end,
	},
}
