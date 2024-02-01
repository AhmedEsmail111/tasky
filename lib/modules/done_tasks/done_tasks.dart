import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/shared/app_cubit/cubit.dart';
import 'package:tasky/shared/app_cubit/states.dart';
import 'package:tasky/shared/components/default_widgets.dart';

class DoneTasks extends StatelessWidget {
  const DoneTasks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final tasks = AppCubit.get(context)
            .tasks
            .where((task) => task.status == 'done')
            .toList();
        return tasks.isEmpty
            ? const Center(
                child: Text('There are no Done Tasks '),
              )
            : ListView.separated(
                itemBuilder: ((context, index) => ListItem(
                      task: tasks[index],
                      isArchived: false,
                      isDone: true,
                    )),
                separatorBuilder: (context, index) => Container(
                  color: Colors.grey[300],
                  width: double.infinity,
                  height: 1,
                ),
                itemCount: tasks.length,
              );
      },
    );
  }
}
