# spec_project_online

## Description
2D platformer with singleplayer campain and pvp multiplayer mode

## Structure
- Client (Game on Godot Engine)
- Server (2 python apps: Flask REST-like API server for database connection; WebSocket server for multiplayer mode)

## How to use?
# Warning: Use Hamachi or similar apps for correct work. Then change the URL adress in "db_connection" and "online_mode" on the server host's one before turning game on.

1. Create and connect to Hamachi VPN Server (or use LAN, but be careful, the LAN and other technologies weren't tested yet);
2. Turn on both "main_db_con" and "test_db_con" on the host users;
3. Then turn on the game;
4. Go to "New Game" if you want to play offline campain (creating an account isn't necessary);
5. Go to "Load Game" if you have saved game (local or in database);
6. Go to "Profile"? where you can create new account or use existed one (alows you to use database saving and multiplayer mode);
7. In Profile you can enter leaderscore table, enter lading menu too and enter in Multiplayer menu;
8. In Multiplayer menu you can start MP mode (create or join lobby if you have it's code. One lobby onlyfor two players) and see the results of MP rounds;
9. In Lobby you can press ready checkbox. If two players are ready, the game will starts;
10. The round will ends if one of the players' HP equal 0 (the result of the game will be added to the mp_results) or if one of the players disconnects from the game.

## Control Keys

Left and right arrows - movement;
z - jump
a - shoot
Esc - Pause
Space - Weapon menu (Singleplay campain only)
