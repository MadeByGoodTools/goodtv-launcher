import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app.dart';
import '../providers/apps_service.dart';

class ManageAppDocksDialog extends StatelessWidget {
  final App application;

  const ManageAppDocksDialog({super.key, required this.application});

  @override
  Widget build(BuildContext context) => Consumer<AppsService>(
    builder: (context, appsService, _) {
      final docks = appsService.dockCategories;
      return AlertDialog(
        title: Text('Add ${application.name} to docks'),
        content: SizedBox(
          width: 480,
          child: docks.isEmpty
              ? const Text('Add a dock in Settings first.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: docks.length,
                  itemBuilder: (context, index) {
                    final dock = docks[index];
                    return CheckboxListTile(
                      autofocus: index == 0,
                      title: Text(appsService.dockDisplayName(dock)),
                      value: appsService.isAppInDock(application, dock),
                      onChanged: (included) => appsService.setAppInDock(
                        application,
                        dock,
                        included ?? false,
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}
