import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tasky/shared/app_cubit/cubit.dart';
import 'package:tasky/shared/app_cubit/states.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // create a scaffold key
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // a global form key
  final _formKey = GlobalKey<FormState>();

  // vars to hold the entered task title
  var _enteredTitle = '';

  // controllers of the text fields
  final _textTimeEditingController = TextEditingController();
  final _textDateEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => AppCubit()..createDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: ((context, state) {
          if (state is InsertToDatabaseAppState) {
            Navigator.of(context).pop();
          }
        }),
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            body: cubit.screens[cubit.currentIndex],
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                if (cubit.isBottomSheetShown) {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await cubit.insertTask(
                      title: _enteredTitle,
                      time: _textTimeEditingController.text,
                      date: _textDateEditingController.text,
                    );
                  }
                } else {
                  cubit.changeBottomSheet(true);
                  _scaffoldKey.currentState
                      ?.showBottomSheet((ctx) => _bottomSheet())
                      .closed
                      .then((value) {
                    cubit.changeBottomSheet(false);
                  });
                }
              },
              tooltip: 'add',
              child: cubit.isBottomSheetShown
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit),
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.task),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.task_alt_rounded),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.archive_rounded),
                    label: 'Archived',
                  ),
                ]),
          );
        },
      ),
    );
  }

// a method to create a bottom sheet with all the relevant component
  Widget _bottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              keyboardType: TextInputType.name,
              maxLength: 50,
              decoration: const InputDecoration(
                prefix: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.title_outlined),
                ),
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty || value.trim().length < 3) {
                  return 'Please enter a valid title ';
                }
                return null;
              },
              onSaved: (newValue) {
                _enteredTitle = newValue!;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _textTimeEditingController,
              onTap: _timePicker,
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(
                prefix: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.watch_later_outlined),
                ),
                labelText: 'Task Time',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a valid time ';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _textDateEditingController,
              onTap: _datePicker,
              keyboardType: TextInputType.none,
              decoration: const InputDecoration(
                prefix: Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Icon(Icons.calendar_today),
                ),
                labelText: 'Task Date',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a valid date ';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // function to show a time picker
  void _timePicker() async {
    var time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time == null) {
      return;
    }
    if (context.mounted) {
      _textTimeEditingController.text = time.format(context);
      ;
    }
  }

// a method to show a date picker and manipulate the selected one if any
  void _datePicker() async {
    var date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.parse('2024-12-31'),
    );

    if (date == null) {
      return;
    }
    if (context.mounted) {
      _textDateEditingController.text = intl.DateFormat.yMMMd().format(date);
      print(_textDateEditingController.text);
    }
  }
}
