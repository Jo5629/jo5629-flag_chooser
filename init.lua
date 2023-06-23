local flag_pos

minetest.register_tool("flag_chooser:chooser", {
    description = "Flag Chooser\nChoose a specific flag with this tool",
    inventory_image = "chooser.png",
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        flag_pos = pointed_thing.under

        local node = minetest.get_node(flag_pos)
        if node.name ~= "pride_flags:upper_mast" then
            return
        end

        local formspec = {
            "formspec_version[4]",
            "size[11,9]",
            "dropdown[0.375,2.3;5,2;Dropdown;"..table.concat(pride_flags.get_flags(), ",")  ..";1]",
            "field[0.375,0.5;3,0.8;flag_name;Choose Flag;".. pride_flags.get_flag_at(flag_pos) .. "]",
            "button[4.125,0.5;2,0.8;find;Find]",
            "button[6.25,0.5;2,0.8;choose;Choose]",
            "button_exit[8.375,0.5;2,0.8;exit;Exit]",
        }
        local formspec = table.concat(formspec, "")

        minetest.show_formspec(user:get_player_name(), "flag_chooser:chooser", formspec)
    end,
})

local function table_contains(tbl, x) --> https://snippets.bentasker.co.uk/page-2106050929-Check-if-value-exists-in-table-LUA.html
    local found = false
    for _, v in pairs(tbl) do
        if v == x then
            found = true
        end
    end
    return found
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    if formname ~= "flag_chooser:chooser" then
        return
    end

    if fields.find or fields.key_enter_field == "flag_name" then
        local image = fields.Dropdown
        if fields.flag_name ~= nil then
            image = fields.flag_name
        else
           image = fields.Dropdown
        end

        if not table_contains(pride_flags.get_flags(), fields.flag_name) then
                image = fields.Dropdown
        end

        local formspec = {
            "formspec_version[4]",
            "size[11,9]",
            "dropdown[0.375,2.3;5,2;Dropdown;"..table.concat(pride_flags.get_flags(), ",")  ..";1]",
            "field[0.375,0.5;3,0.8;flag_name;Choose Flag;" .. image .. "]",
            "button[4.125,0.5;2,0.8;find;Find]",
            "button[6.25,0.5;2,0.8;choose;Choose]",
            "button_exit[8.375,0.5;2,0.8;exit;Exit]",
            "image[0.375,5;6,3;".. "prideflag_" .. image .. ".png" ..";]",
        }
        local formspec = table.concat(formspec, "")
        minetest.show_formspec(name, "flag_chooser:chooser", formspec)
    end

    if fields.choose then
        if minetest.is_protected(flag_pos, name) and not
        minetest.check_player_privs(name, "protection_bypass") then
            minetest.record_protection_violation(flag_pos, name)
            return
        end
        minetest.close_formspec(name, "flag_chooser:chooser")
        local flag_name = fields.flag_name
        if flag_name ~= nil then
            pride_flags.set_flag_at(flag_pos, flag_name)
        end
    end
end)

local ingot_steel
if minetest.get_modpath("default") then
    ingot_steel = "default:steel_ingot"
    minetest.register_craft({
        output = "flag_chooser:chooser",
        recipe = {
            {"", ingot_steel, ""},
            {ingot_steel, "pride_flags:upper_mast", ingot_steel},
            {"", ingot_steel, ""},
        }
    })
end