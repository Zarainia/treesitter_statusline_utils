local table = require "table"
local ts_utils = require "nvim-treesitter.ts_utils"

local M = {}

function M.is_function_declaration(node)
    local node_type = node:type()
    return node_type == "function" or node_type == "local_function" or node_type == "function_definition" or
        node_type == "function_declaration" or
        node_type == "constructor_definition" or
        node_type == "constructor_declaration" or
        node_type == "method_definition" or
        node_type == "method_declaration" or
        node_type == "function_signature" or
        node_type == "method_signature"
end

function M.is_function_declaration_adjacent(node)
    local node_type = node:type()
    return node_type == "function_body"
end

function M.is_function_name(node)
    local node_type = node:type()
    return node_type:find("function") or node_type == "identifier" or node_type:find("word")
end

function M.is_class_declaration(node)
    local node_type = node:type()
    return node_type == "class" or node_type == "local_class" or node_type == "class_definition" or
        node_type == "class_declaration"
end

function M.is_class_declaration_adjacent(node)
    local node_type = node:type()
    return node_type == "class_body"
end

function M.is_class_name(node)
    local node_type = node:type()
    return node_type:find("class") or node_type == "identifier" or node_type:find("word")
end

M.node_detectors = {
    ["function"] = {
        is_node = M.is_function_declaration,
        is_adjacent = M.is_function_declaration_adjacent,
        is_name = M.is_function_name
    },
    class = {is_node = M.is_class_declaration, is_adjacent = M.is_class_declaration_adjacent, is_name = M.is_class_name}
}

local function get_display_node_name(node, type, functions)
    if functions.is_node(node) then
        local children = ts_utils.get_named_children(node)
        for _, child_node in pairs(children) do
            if functions.is_name(child_node) then
                local name = ts_utils.get_node_text(child_node)[1]
                local match = name:match("^%s*%w+%s+([%w_]+)%s*%(")
                if match then
                    name = match
                else
                    match = name:match("^%s*%w+%s+%w+%s+([%w_]+)%s*%(")
                    if match then
                        name = match
                    end
                    if not name:match("^[%w_]+$") then
                        name = nil -- yor you lua, no continue
                    end
                end
                if name then
                    return {type = type, name = name}
                end
            end
        end
    end
end

function M.get_current_display_nodes()
    local node_stack = {}
    local node = ts_utils.get_node_at_cursor()
    while node do
        for type, functions in pairs(M.node_detectors) do
            local result = get_display_node_name(node, type, functions)
            if result then
                table.insert(node_stack, result)
                break
            elseif functions.is_adjacent(node) then
                local prev_node = ts_utils.get_previous_node(node)
                result = get_display_node_name(prev_node, type, functions)
                if result then
                    table.insert(node_stack, result)
                    break
                end
            end
        end
        node = node:parent()
    end
    return node_stack
end

function M.current_nodes_available()
    local results = M.get_current_display_nodes()
    return #results ~= 0
end

function M._node_stack()
    local node = ts_utils.get_node_at_cursor()
    while node do
        local node_type = node:type()
        print('"' .. node_type .. '"')
        node = node:parent()
    end
end

function M._node_children(desired_type)
    local node = ts_utils.get_node_at_cursor()
    while node do
        local node_type = node:type()
        if node_type == desired_type then
            local children = ts_utils.get_named_children(node)
            for _, child_node in pairs(children) do
                print(ts_utils.get_node_text(child_node)[1] or "")
                print(child_node:type())
            end
            return
        end
        node = node:parent()
    end
end

return M
