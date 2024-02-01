import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasky/models/task.dart';
import 'package:tasky/shared/app_cubit/cubit.dart';
import 'package:tasky/shared/app_cubit/states.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    required this.task,
    required this.isDone,
    required this.isArchived,
  });

  final Task task;
  final bool isDone;
  final bool isArchived;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        return Dismissible(
          key: UniqueKey(),
          background: Container(
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          onDismissed: (direction) {
            cubit.deleteTask(id: task.id);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(defaultSnackBar(
              context: context,
              text: 'You have deleted the Task permanently.',
            ));
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withOpacity(0.5),
              ),
              height: 80,
              width: 80,
              alignment: Alignment.center,
              child: Text(
                task.time,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(task.date),
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  if (isDone != true && isArchived != true)
                    IconButton(
                        onPressed: () async {
                          playLocalAsset();
                          cubit.updateTask(status: 'done', id: task.id);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(defaultSnackBar(
                              context: context,
                              text: 'Good Job for completing a task.',
                            ));
                          }
                        },
                        icon: Icon(
                          Icons.task_alt_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                  if (isDone == true) const Spacer(),
                  if (isArchived != true)
                    IconButton(
                      onPressed: () {
                        cubit.updateTask(status: 'archived', id: task.id);
                        // ScaffoldMessenger.of(context).clearSnackBars();
                        // ScaffoldMessenger.of(context)
                        //     .showSnackBar(defaultSnackBar(
                        //   context: context,
                        //   text: 'The task went to Archived.',
                        // ));
                      },
                      icon: Icon(
                        Icons.archive,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

SnackBar defaultSnackBar({
  required context,
  required text,
}) =>
    SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
      content: Text(
        text,
        style: const TextStyle().copyWith(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );

playLocalAsset() async {
  AudioPlayer cache = AudioPlayer();
  //At the next line, DO NOT pass the entire reference such as assets/yes.mp3. This will not work.
  //Just pass the file name only.
  await cache.play(AssetSource('click.wav'));
}
