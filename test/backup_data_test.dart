import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/models/category.dart';

void main() {
  late FLauncherDatabase database;

  setUp(() {
    database = FLauncherDatabase.inMemory();
  });

  tearDown(() => database.close());

  test(
    'layout backup round-trips and skips apps missing from the device',
    () async {
      await database.persistApps([
        AppsCompanion.insert(
          packageName: 'tv.present',
          name: 'Present',
          version: '1',
        ),
        AppsCompanion.insert(
          packageName: 'tv.missing',
          name: 'Missing',
          version: '1',
        ),
      ]);
      final categoryId = await database.insertCategory(
        CategoriesCompanion.insert(
          name: 'Cinema',
          order: 0,
          type: const Value(CategoryType.row),
          rowHeight: const Value(160),
        ),
      );
      await database.insertAppsCategories([
        AppsCategoriesCompanion.insert(
          categoryId: categoryId,
          appPackageName: 'tv.present',
          order: 0,
        ),
        AppsCategoriesCompanion.insert(
          categoryId: categoryId,
          appPackageName: 'tv.missing',
          order: 1,
        ),
      ]);
      await database.updateApp(
        'tv.present',
        const AppsCompanion(hidden: Value(true)),
      );

      final backup = await database.exportBackupData();

      await database.deleteApps(['tv.missing']);
      await database.deleteCategory(categoryId);
      await database.updateApp(
        'tv.present',
        const AppsCompanion(hidden: Value(false)),
      );
      await database.restoreBackupData(backup);

      final categories = await database.getCategories();
      final memberships = await database.getAppsCategories();
      final apps = await database.getApplications();

      expect(categories, hasLength(1));
      expect(categories.single.name, 'Cinema');
      expect(categories.single.type, CategoryType.row);
      expect(categories.single.rowHeight, 160);
      expect(memberships, hasLength(1));
      expect(memberships.single.appPackageName, 'tv.present');
      expect(apps.single.hidden, isTrue);
    },
  );
}
