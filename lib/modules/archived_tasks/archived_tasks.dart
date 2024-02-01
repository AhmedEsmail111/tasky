import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/shared/app_cubit/cubit.dart';
import 'package:tasky/shared/app_cubit/states.dart';
import 'package:tasky/shared/components/default_widgets.dart';

class ArchivedTasks extends StatelessWidget {
  const ArchivedTasks({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final tasks = AppCubit.get(context)
            .tasks
            .where((task) => task.status == 'archived')
            .toList();
        return tasks.isEmpty
            ? const Center(
                child: Text(' There are no Archived Tasks'),
              )
            : ListView.separated(
                itemBuilder: ((context, index) => ListItem(
                      task: tasks[index],
                      isDone: false,
                      isArchived: true,
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
