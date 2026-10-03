import 'package:drift_dev/api/migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goodtv_launcher/database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v5.dart' as v5;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('oldest supported database upgrades to the current schema', () async {
    final schema = await verifier.schemaAt(1);
    final oldDb = v1.DatabaseAtV1(schema.newConnection().executor);
    await oldDb.into(oldDb.apps).insert(
          v1.AppsCompanion.insert(
            packageName: 'me.efesser.flauncher',
            name: 'FLauncher',
            className: '.MainActivity',
            version: '0.0.1',
          ),
        );
    await oldDb.close();

    final db = FLauncherDatabase(schema.newConnection());
    final app = await db.select(db.apps).getSingle();

    expect(app.packageName, 'me.efesser.flauncher');
    expect(app.name, 'FLauncher');
    expect(app.version, '0.0.1');
    expect(app.hidden, isFalse);
    expect(app.lastLaunchedAt, isNull);
    await db.close();
  });

  test('last legacy database upgrades without losing apps', () async {
    final schema = await verifier.schemaAt(5);
    final oldDb = v5.DatabaseAtV5(schema.newConnection().executor);
    await oldDb.into(oldDb.apps).insert(
          v5.AppsCompanion.insert(
            packageName: 'ca.goodtools.sample',
            name: 'Sample App',
            version: '1.0.0',
          ),
        );
    await oldDb.close();

    final db = FLauncherDatabase(schema.newConnection());
    final app = await db.select(db.apps).getSingle();

    expect(app.packageName, 'ca.goodtools.sample');
    expect(app.name, 'Sample App');
    expect(app.hidden, isFalse);
    expect(app.lastLaunchedAt, isNull);
    await db.close();
  });
}
