import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/shared/app_cubit/cubit.dart';
import 'package:tasky/shared/app_cubit/states.dart';
import 'package:tasky/shared/components/default_widgets.dart';

class NewTask extends StatelessWidget {
  const NewTask({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final tasks = AppCubit.get(context)
            .tasks
            .where((task) => task.status == 'new')
            .toList();
        return tasks.isEmpty
            ? const Center(
                child: Text('No Tasks made yet!'),
              )
            : ListView.separated(
                itemBuilder: ((context, index) => ListItem(
                      task: tasks[index],
                      isArchived: false,
                      isDone: false,
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
