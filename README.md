# treesitter_statusline_utils

Just a simple function (`treesitter_statusline_utils.get_current_display_nodes`) to get a list of the nodes of various types at the current position in the file based on [treesitter](https://github.com/nvim-treesitter/nvim-treesitter) objects. Then, the statusline component can be generated however one wants.  Node detection is as generic as possible to avoid having to individually support each new file type, which is a huge hassle, though this could lead to issues with certain filetypes. 

Example:

```lua
provider = function() -- display the innermost node only
	local current_nodes = get_current_display_nodes()
	if #current_nodes > 0 then
		return current_nodes[1]
	end
end
```

