import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:tasky/models/task.dart';
import 'package:tasky/shared/app_cubit/states.dart';

import '../../modules/archived_tasks/archived_tasks.dart';
import '../../modules/done_tasks/done_tasks.dart';
import '../../modules/tasks/new_task.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitialAppState());

  static AppCubit get(context) => BlocProvider.of(context);

  List<Task> tasks = [];

  // define a database object
  sql.Database? database;

  //  var to switch between the screens in the bottom navigation bar
  var currentIndex = 0;
  // list of screens to switch between them
  List screens = [
    const NewTask(),
    const DoneTasks(),
    const ArchivedTasks(),
  ];

  //  list of titles for the different screens
  List titles = ['Tasks', 'Done Tasks', 'Archived Tasks'];

  // bool to control the FAB icon
  var isBottomSheetShown = false;

  // a method to toggle between the screens in the bottom nav using current index var
  void changeIndex(index) {
    currentIndex = index;
    emit(ChangeNavBarAppState());
  }

  // change the icon on the bottom sheet
  void changeBottomSheet(isShown) {
    isBottomSheetShown = isShown;
    emit(ChangeBottomSheetAppState());
  }

  void createDataBase() async {
    var dbPath = await sql.getDatabasesPath();

    try {
      database = await sql.openDatabase(path.join(dbPath, 'tasks.db'),
          version: 1, onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)');
      }, onOpen: (db) async {
        getTasks(db);
      });
      emit(CreateDatabaseAppState());
    } catch (error) {
      print(error);
    }
  }

  Future<void> insertTask({
    required String title,
    required String time,
    required String date,
  }) async {
    try {
      int insertedTaskId = await database!.transaction(
        (txn) {
          return txn.rawInsert(
              'INSERT INTO tasks(title,date,time,status) VALUES("$title","$date","$time","new")');
        },
      );

      emit(InsertToDatabaseAppState());

      getTasks(database!);

      print(insertedTaskId);
    } catch (error) {
      print(error);
    }
  }

  // a method to get all the tasks in the DB
  getTasks(sql.Database database) async {
    emit(LoadingAppState());
    List<Map> data = await database.rawQuery('SELECT * FROM tasks');
    if (data.isEmpty) {
      tasks = [];
      emit(GetDatabaseAppState());
      return;
    }
    List<Task> storedTasks = data
        .map((task) => Task(
              id: task['id'],
              title: task['title'],
              date: task['date'],
              time: task['time'],
              status: task['status'],
            ))
        .toList();
    // print(storedTasks[1].status);

    tasks = storedTasks;

    emit(GetDatabaseAppState());
  }

  void updateTask({required String status, required int id}) async {
    try {
      var ont = await database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id],
      );

      print(ont);
      emit(UpdateTaskAppState());

      getTasks(database!);
    } catch (e) {
      print(e);
    }
  }

  void deleteTask({required int id}) async {
    try {
      await database!.rawDelete(
        'DELETE FROM tasks WHERE id = ?',
        [id],
      ).then((_) {
        emit(DeleteTaskAppState());
      });
      getTasks(database!);
    } catch (e) {
      print(e);
    }
  }
}
