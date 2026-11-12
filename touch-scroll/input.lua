-- One-finger sideways swipe scrolls the columns when the workspace layout is
-- scrolling. Hyprland's scroll_move gesture only hears the trackpad, so this
-- goes through hyprgrass, which turns the touchscreen drag into that gesture.
-- A tap and a vertical drag still go to the app. The swipe starts after a
-- short movement, then the columns follow the finger and snap on release.
local hyprgrass_path = (os.getenv("HOME") or "") .. "/.local/lib/hypr/libhyprgrass.so"
local hyprgrass_file = io.open(hyprgrass_path, "r")
if hyprgrass_file then
  hyprgrass_file:close()

  hl.plugin.load(hyprgrass_path)

  if hl.plugin.hyprgrass then
    -- 4 makes the swipe claim the finger after ~40px instead of ~150px.
    hl.config({
      plugin = {
        hyprgrass = {
          sensitivity = 4,
          resize_on_border_long_press = false,
        },
      },
    })

    local swipe_armed = false
    local swipe_scale = nil

    local function swipe_spec(action, scale)
      return {
        pattern = { kind = "swipe", fingers = 1, direction = "horizontal" },
        action = action,
        scale = scale,
      }
    end

    -- scroll_move measures the drag in trackpad units, where the whole screen
    -- is gestures:workspace_swipe_distance (300). Scale that up to the logical
    -- screen width so the columns move with the finger.
    local function swipe_scale_now()
      local mon = hl.get_active_monitor()
      local logical = 1280
      if mon and mon.width and mon.scale and mon.scale > 0 then
        logical = mon.width / mon.scale
      end
      local distance = tonumber(hl.get_config("gestures:workspace_swipe_distance")) or 300
      if distance < 1 then
        distance = 300
      end
      local scale = logical / distance
      if scale < 0.1 then
        scale = 0.1
      elseif scale > 10 then
        scale = 10
      end
      return math.floor(scale * 100 + 0.5) / 100
    end

    local function workspace_is_scrolling()
      local ws = hl.get_active_workspace()
      return ws and ws.tiled_layout == "scrolling"
    end

    local function sync_touch_scroll()
      if not hl.plugin.hyprgrass then
        return
      end

      local want = workspace_is_scrolling()
      local scale = swipe_scale_now()

      if want and swipe_armed and swipe_scale == scale then
        return
      end

      if swipe_armed and swipe_scale then
        hl.plugin.hyprgrass.gesture(swipe_spec("unset", swipe_scale))
        swipe_armed = false
        swipe_scale = nil
      end

      if want then
        hl.plugin.hyprgrass.gesture(swipe_spec("scroll_move", scale))
        swipe_armed = true
        swipe_scale = scale
      end
    end

    sync_touch_scroll()

    -- Layout toggles do not reload the config, so keep the swipe in step.
    hl.timer(function()
      pcall(sync_touch_scroll)
    end, { type = "repeat", timeout = 400 })
  end
end
