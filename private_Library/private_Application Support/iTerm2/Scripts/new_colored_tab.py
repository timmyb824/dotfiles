#!/usr/bin/env python3.7

import iterm2
import random

def rand_color():
    return random.randint(0,255)

async def main(connection):
    app=await iterm2.async_get_app(connection)
    session=app.current_terminal_window.current_tab.current_session
    window = app.current_window
    if window is not None:
        await window.async_create_tab()
    else:
        print("No current window")

    change = iterm2.LocalWriteOnlyProfile()
    color = iterm2.Color(rand_color(),rand_color(),rand_color())

    change.set_tab_color(color)
    change.set_use_tab_color(True)
    await session.async_set_profile_properties(change)

iterm2.run_until_complete(main)
