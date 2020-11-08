# TTT Event Viewer
![Example of Event Viewer](https://s.gvid.me/s/2020/11/08/clt285.png)
# About
This is the Throne Ridge Event Viewer for exploring TTT damagelogs.
### Server Usage
The server-component does **not** work without (simple) rewrites to the stock TTT code.
It would be fairly trivial to get basic functionality working by using hooks, PRs welcome.
### Client Usage
Just enter `ttt_damagelogs_ui` in the console.
Only admins can get damagelogs during the round.
## Documentation
Currently documentation is on our private wiki, however most of the public functions are also documented in-code.
It's largely modular, except for the event data structure itself, but there are version flags for handling that if it's really needed.
