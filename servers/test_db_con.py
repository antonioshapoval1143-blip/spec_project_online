import asyncio
import json
import random
import string
import websockets

# =========================
# Налаштування
# =========================

MAX_PLAYERS_PER_ROOM = 2
ROOM_CODE_LENGTH = 4

# =========================
# Глобальні структури
# =========================

connected_players = {}
player_rooms = {}
rooms = {}

# =========================
# Допоміжні функції
# =========================

def generate_room_code():

    while True:

        code = ''.join(
            random.choices(
                string.ascii_uppercase,
                k=ROOM_CODE_LENGTH
            )
        )

        if code not in rooms:
            return code


def get_player_id(websocket):
    return str(id(websocket))


async def send_to_player(websocket, data: dict):

    try:
        await websocket.send(json.dumps(data))
    except:
        pass


async def send_to_room(room_code: str, data: dict, exclude=None):

    if room_code not in rooms:
        return

    disconnected = []

    for ws in rooms[room_code]["players"]:

        if exclude and ws == exclude:
            continue

        try:
            await ws.send(json.dumps(data))
        except:
            disconnected.append(ws)

    for ws in disconnected:
        await disconnect_player(ws)


# =========================
# CREATE LOBBY
# =========================

async def handle_create_lobby(websocket):

    # Якщо гравець уже в кімнаті
    if websocket in player_rooms:

        await send_to_player(websocket, {
            "type": "error",
            "message": "Already in room"
        })

        return

    room_code = generate_room_code()

    rooms[room_code] = {
        "players": [websocket],
        "ready": {
            websocket: False
        },
        "hp": {
            websocket: 100
        },
        "positions": {
            websocket: {
                "x": 0,
                "y": 0
            }
        }
    }

    player_rooms[websocket] = room_code

    player_id = get_player_id(websocket)

    print(f"{player_id} created lobby {room_code}")

    await send_to_player(websocket, {
        "type": "lobby_created",
        "room_code": room_code
    })


# =========================
# JOIN LOBBY
# =========================

async def handle_join_lobby(websocket, data):

    room_code = data.get("room_code", "").upper()

    player_id = get_player_id(websocket)

    # Уже в кімнаті
    if websocket in player_rooms:

        await send_to_player(websocket, {
            "type": "error",
            "message": "Already in room"
        })

        return

    # Кімната не існує
    if room_code not in rooms:

        await send_to_player(websocket, {
            "type": "join_failed",
            "reason": "Lobby not found"
        })

        return

    room = rooms[room_code]

    # Кімната заповнена
    if len(room["players"]) >= MAX_PLAYERS_PER_ROOM:

        await send_to_player(websocket, {
            "type": "join_failed",
            "reason": "Lobby full"
        })

        return

    # Додаємо гравця
    room["players"].append(websocket)
    room["ready"][websocket] = False
    room["hp"][websocket] = 100
    room["positions"][websocket] = {
        "x": 0,
        "y": 0
    }

    player_rooms[websocket] = room_code

    print(f"{player_id} joined lobby {room_code}")

    # Підтвердження новому гравцю
    await send_to_player(websocket, {
        "type": "room_joined",
        "room_id": room_code
    })

    # Повідомити інших
    await send_to_room(room_code, {
        "type": "player_joined",
        "player_id": player_id
    }, exclude=websocket)


# =========================
# QUICK MATCH
# =========================

async def handle_quick_match(websocket):

    # Уже в кімнаті
    if websocket in player_rooms:

        await send_to_player(websocket, {
            "type": "error",
            "message": "Already in room"
        })

        return

    target_room = None

    # Шукаємо вільну кімнату
    for room_code, room_data in rooms.items():

        if len(room_data["players"]) < MAX_PLAYERS_PER_ROOM:

            target_room = room_code
            break

    # Якщо нема — створюємо
    if target_room is None:

        target_room = generate_room_code()

        rooms[target_room] = {
            "players": [],
            "ready": {}
        }

    room = rooms[target_room]

    room["players"].append(websocket)
    room["ready"][websocket] = False

    player_rooms[websocket] = target_room

    player_id = get_player_id(websocket)

    print(f"{player_id} quick-joined {target_room}")

    await send_to_player(websocket, {
        "type": "room_joined",
        "room_id": target_room
    })

    await send_to_room(target_room, {
        "type": "player_joined",
        "player_id": player_id
    }, exclude=websocket)


# =========================
# READY
# =========================

async def handle_player_ready(websocket, data):

    room_code = player_rooms.get(websocket)

    if not room_code:
        return

    ready = data.get("ready", False)

    rooms[room_code]["ready"][websocket] = ready

    player_id = get_player_id(websocket)

    await send_to_room(room_code, {
        "type": "player_ready",
        "player_id": player_id,
        "ready": ready
    })

    players = rooms[room_code]["players"]

    if len(players) == MAX_PLAYERS_PER_ROOM:

        all_ready = all(
            rooms[room_code]["ready"].get(p, False)
            for p in players
        )

        if all_ready:

            print(f"Game started in {room_code}")

            await send_to_room(room_code, {
                "type": "start_game"
            })


# =========================
# POSITION UPDATE
# =========================

async def handle_update_position(websocket, data):

    room_code = player_rooms.get(websocket)

    if not room_code:
        return

    rooms[room_code]["positions"][websocket] = {
        "x": data.get("x"),
        "y": data.get("y")
    }

    player_id = get_player_id(websocket)

    await send_to_room(room_code, {
        "type": "game_state",
        "player_id": player_id,
        "x": data.get("x"),
        "y": data.get("y"),
        "vx": data.get("vx"),
        "vy": data.get("vy"),
        "anim": data.get("anim"),
        "flip_h": data.get("flip_h"),
        "shooting": data.get("shooting")
    }, exclude=websocket)


# =========================
# DISCONNECT
# =========================

async def disconnect_player(websocket):

    player_id = get_player_id(websocket)

    room_code = player_rooms.get(websocket)

    if room_code and room_code in rooms:

        room = rooms[room_code]

        if websocket in room["players"]:
            room["players"].remove(websocket)

        if websocket in room["ready"]:
            del room["ready"][websocket]

        await send_to_room(room_code, {
            "type": "player_left",
            "player_id": player_id
        })

        # Якщо кімната порожня — видалити
        if len(room["players"]) == 0:

            del rooms[room_code]

            print(f"Lobby {room_code} deleted")

    if websocket in player_rooms:
        del player_rooms[websocket]

    if websocket in connected_players:
        del connected_players[websocket]

    print(f"{player_id} disconnected")




async def handle_bullet_spawn(websocket, data):
    room_code = player_rooms.get(websocket)
    if not room_code:
        return
    
    player_id = get_player_id(websocket)
    
    await send_to_room(room_code, {
        "type": "bullet_spawn",
        "player_id": player_id,
        "x": data.get("x"),
        "y": data.get("y"),
        "dir_x": data.get("dir_x"),
        "dir_y": data.get("dir_y")
    }, exclude=websocket)  # не відправляємо назад тому, хто вистрілив


async def handle_bullet_hit(websocket, data):
    room_code = player_rooms.get(websocket)
    if not room_code or room_code not in rooms:
        return
    
    target_id = data.get("target_id")
    room = rooms[room_code]
    
    # Знаходимо websocket цілі
    target_ws = None
    for ws in room["players"]:
        if get_player_id(ws) == target_id:
            target_ws = ws
            break
    
    if not target_ws or target_ws == websocket:
        return
    
    # Нанесення шкоди
    if target_ws in room["hp"]:
        room["hp"][target_ws] -= 20
        hp = room["hp"][target_ws]
        
        await send_to_room(room_code, {
            "type": "player_hit",
            "player_id": target_id,
            "hp": hp
        })
        
        if hp <= 0:
            await send_to_room(room_code, {
                "type": "player_died",
                "player_id": target_id
            })
    
async def handle_player_profile(websocket, data):

    room_code = player_rooms.get(websocket)

    if not room_code:
        return

    await send_to_room(room_code, {
        "type": "player_profile",
        "player_id": get_player_id(websocket),
        "profile_id": data.get("profile_id")
    }, exclude=websocket)    


# =========================
# MAIN HANDLER
# =========================

async def handler(websocket):

    player_id = get_player_id(websocket)

    connected_players[websocket] = {
        "id": player_id
    }

    print(f"Player connected: {player_id}")

    # Підтвердження підключення
    await send_to_player(websocket, {
        "type": "connected",
        "player_id": player_id
    })

    try:

        async for message in websocket:

            try:
                data = json.loads(message)
            except:
                continue

            msg_type = data.get("type")

            # =========================
            # CREATE LOBBY
            # =========================
            if msg_type == "create_lobby":

                await handle_create_lobby(websocket)

            # =========================
            # JOIN LOBBY
            # =========================
            elif msg_type == "join_lobby":

                await handle_join_lobby(websocket, data)

            # =========================
            # QUICK MATCH
            # =========================
            elif msg_type == "join_room":

                await handle_quick_match(websocket)

            # =========================
            # READY
            # =========================
            elif msg_type == "player_ready":

                await handle_player_ready(websocket, data)

            # =========================
            # POSITION
            # =========================
            elif msg_type == "update_position":

                await handle_update_position(websocket, data)

            # =========================
            # SHOOT
            # =========================
           

            elif msg_type == "bullet_spawn":
                await handle_bullet_spawn(websocket, data)

            elif msg_type == "bullet_hit":
                await handle_bullet_hit(websocket, data)

            elif msg_type == "player_profile":
                await handle_player_profile(websocket, data)

            elif msg_type == "player_disconection":
                await disconnect_player(websocket)

    except websockets.exceptions.ConnectionClosed:
        pass

    finally:
        await disconnect_player(websocket)


# =========================
# SERVER START
# =========================

async def main():

    print("Game server started on port 8765")

    async with websockets.serve(
        handler,
        "0.0.0.0",
        8765,
        ping_interval=20,
        ping_timeout=20
    ):        
        await asyncio.Future()



if __name__ == "__main__":
    asyncio.run(main())