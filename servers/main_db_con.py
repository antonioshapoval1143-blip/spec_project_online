from flask import Flask, request, jsonify
import pymysql
from pymysql.err import OperationalError


app = Flask(__name__)

DB_CONFIG = {
    'host': 'localhost',
    'port': 3812,
    'user': 'root',
    'password': '1111',
    'database': 'game_data',
    'charset': 'utf8mb4',
    'cursorclass': pymysql.cursors.DictCursor
}

def get_db_connection():
    try:
        conn = pymysql.connect(**DB_CONFIG)
        return conn
    except OperationalError as e:
        print(f"Помилка підключення: {e}")
        return None
    
@app.route('/api', methods=['GET', 'POST', 'PATCH', 'DELETE'])
def api():
    conn = get_db_connection()
    if conn is None:
        return jsonify({'error': 'Не вдалося підключитися до бази даних'}), 500
    
    try:
        with conn.cursor() as cursor:
            if request.method == 'GET':
                query = request.get_json()
                if not query or 'num' not in query:
                    return jsonify({'error': 'Неправильні дані'}), 400
                
                q_num = query['num']
                str1 = query['str1']
                str2 = query['str2']

                if q_num == 1:
                    if 'str1' not in query or 'str2' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT * FROM player_prof WHERE nickname = '{str1}' AND password_hash = '{str2}'"
                
                elif q_num == 2:
                    if 'str1' not in query or 'str2' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT * FROM `global_save` WHERE player_id = '{str1}' AND save_num = '{str2}'"
                
                elif q_num == 3:
                    sql = "SELECT t1.nickname, t2.score FROM player_prof t1 JOIN main_scores t2 ON t1.player_id = t2.player_id ORDER BY score DESC"

                elif q_num == 4:
                    if 'str1' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT * FROM main_scores WHERE player_id = '{str1}'"

                elif q_num == 5:
                    if 'str1' not in query or 'str2' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT EXISTS (SELECT 1 FROM global_save WHERE player_id = '{str1}' AND save_num = '{str2}') AS check_exist"

                elif q_num == 6:
                    if 'str1' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT EXISTS (SELECT 1 FROM `main_scores` WHERE player_id = '{str1}') AS check_exist"
                
                elif q_num == 7:
                    if 'str1' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"SELECT nickname FROM player_prof WHERE player_id = '{str1}'"
                
                elif q_num == 8:
                    if 'str1' not in query or 'str2' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    if str1 == 1:
                        sql = f'SELECT t2.nickname AS "Host", t3.nickname AS "Guest", t4.nickname AS "Winner" FROM mp_results t1 JOIN player_prof t2 on t1.lobby_creator = t2.player_id JOIN player_prof t3 on t1.joined = t3.player_id JOIN player_prof t4 on t1.winner = t4.player_id ORDER BY match_id'
                    elif str1 == 2:
                        sql = f'SELECT t2.nickname AS "Host", t3.nickname AS "Guest", t4.nickname AS "Winner" FROM mp_results t1 JOIN player_prof t2 on t1.lobby_creator = t2.player_id JOIN player_prof t3 on t1.joined = t3.player_id JOIN player_prof t4 on t1.winner = t4.player_id WHERE t1.lobby_creator = "{str2}" OR t1.joined = "{str2}" ORDER BY match_id'
                    elif str1 == 3:
                        sql = f'SELECT t2.nickname AS "Host", t3.nickname AS "Guest", t4.nickname AS "Winner" FROM mp_results t1 JOIN player_prof t2 on t1.lobby_creator = t2.player_id JOIN player_prof t3 on t1.joined = t3.player_id JOIN player_prof t4 on t1.winner = t4.player_id WHERE t1.winner = "{str2}" ORDER BY match_id'
                    # if 'str1' not in query:
                    #     return jsonify({'error': 'Неправильні дані'}), 400
                    # sql = f"SELECT "


                # print(sql)
                cursor.execute(sql)
                data = cursor.fetchall()
                return jsonify(data)
            
            
            elif request.method == 'POST':
                data = request.get_json()
                if not data or 'num' not in data:
                    return jsonify({'error': 'Неправильні дані'}), 400
                
                q_num = data['num']
                str1 = data['str1']
                str2 = data['str2']
                str3 = data['str3']
                str4 = data['str4']

                if q_num == 1:
                    if 'str1' not in data or 'str2' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"INSERT INTO `player_prof` (`player_id`, `nickname`, `password_hash`) VALUES (NULL, '{str1}', '{str2}') "
                    
                
                elif q_num == 2:
                    if 'str1' not in data or 'str2' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"INSERT INTO `main_scores` (`player_id`, `score`) VALUES ('{str1}', '{str2}') "
                    

                elif q_num == 3:
                    if 'str1' not in data or 'str2' not in data or 'str3' not in data or 'str4' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"INSERT INTO `global_save` (`save_id`, `player_id`, `save_num`, `save_data`, `current_score`) VALUES (NULL, '{str1}', '{str2}', '{str3}', '{str4}') "
                    
                elif q_num == 4:
                    if 'str1' not in data or 'str2' not in data or 'str3' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"INSERT INTO `mp_results` (`match_id`, `lobby_creator`, `joined`, `winner`) VALUES (NULL, '{str1}', '{str2}', '{str3}') "
                
                cursor.execute(sql)
                conn.commit()

                return jsonify({'succes': True, 'id': cursor.lastrowid}), 201

            elif request.method == 'PATCH':
                data = request.get_json()
                if not data or 'num' not in data:
                    return jsonify({'error': 'Неправильні дані'}), 400
                
                q_num = data['num']
                str1 = data['str1']
                str2 = data['str2']
                str3 = data['str3']
                str4 = data['str4']

                if q_num == 1:
                    if 'str1' not in data or 'str2' not in data or 'str3' not in data or 'str4' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"UPDATE `global_save` SET `save_data` = '{str3}', `current_score` = '{str4}' WHERE `global_save`.`player_id` = '{str1}' AND `save_num` = '{str2}'"
                
                elif q_num == 2:
                    if 'str1' not in data or 'str2' not in data:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"UPDATE `main_scores` SET `score` = '{str2}' WHERE `main_scores`.`player_id` = '{str1}' "

                
                cursor.execute(sql)
                conn.commit()
                return jsonify({'success': True, 'deleted': cursor.rowcount}), 200
            
            elif request.method == 'DELETE':
                query = request.get_json()
                if not query or 'num' not in query:
                    return jsonify({'error': 'Неправильні дані'}), 400
                
                q_num = query['num']
                str1 = query['str1']
                str2 = query['str2']

                if q_num == 1:
                    if 'str1' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"DELETE FROM `player_prof` WHERE `player_prof`.`player_id` = '{str1}'"
                
                elif q_num == 2:
                    if 'str1' not in query or 'str2' not in query:
                        return jsonify({'error': 'Неправильні дані'}), 400
                    sql = f"DELETE FROM `global_save` WHERE `global_save`.`player_id` = '{str1}' AND `global_save`.`save_num` = '{str2}'"
                
                
                cursor.execute(sql)
                conn.commit()
                return jsonify({'success': True, 'deleted': cursor.rowcount}), 200


            
    except Exception as e:
        print(f"Помилка в API: {str(e)}")
        return jsonify({'error': f'Помилка запиту: {str(e)}'}), 500
    
    finally:
        conn.close()


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
