import psycopg2
from psycopg2 import Error
import matplotlib.pyplot as plt


def plot_logs_data():
    try:
        # Подключение к базе данных
        connection = psycopg2.connect(user="postgres",
                                      password="postgres",
                                      host="192.168.24.151",
                                      port="5432",
                                      database="testdb")
        cursor = connection.cursor()

        # Выполнение запроса к таблице logs
        cursor.execute("SELECT num, time_insert, time_select, time_update FROM logs")
        records = cursor.fetchall()

        # Разделение данных на отдельные списки для каждого типа времени
        num = [record[0] for record in records]
        time_insert = [record[1] for record in records]
        time_select = [record[2] for record in records]
        time_update = [record[3] for record in records]

        # Создание графика
        plt.figure(figsize=(10, 6))
        plt.plot(num, time_insert, label='T вставки')
        plt.plot(num, time_select, label='T поиска')
        plt.plot(num, time_update, label='T обновления')
        plt.xlabel('Количество записей (млн.)')
        plt.ylabel('Время (сек.)')
        plt.title('Операции в БД без индексов')
        plt.legend()
        plt.grid(True)
        plt.show()

    except (Exception, Error) as error:
        print("Ошибка работы с Postgres", error)

    finally:
        # Закрытие соединения
        if connection:
            cursor.close()
            connection.close()
            print("Соединеие закрыто успешно!")

# Вызов функции для построения графика
plot_logs_data()
