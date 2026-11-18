import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import '../utils/date_utils_ext.dart';

class BackupService {
  final AppDatabase _db;
  BackupService(this._db);

  Future<String> exportBackupAndShare() async {
    final tables = await _db.exportAllTables();
    final payload = {
      'app': 'DayPilot',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'data': tables,
    };

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateUtilsExt.toDateKey(DateTime.now());
    final file = File('${dir.path}/daypilot_backup_$stamp.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));

    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'DayPilot Offline Backup ($stamp)',
      );
    } catch (_) {
      // File is still saved locally even if share sheet is dismissed
    }
    return file.path;
  }

  Future<bool> importBackupFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) {
      return false;
    }
    final file = File(result.files.single.path!);
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
      await _db.restoreAllTables(decoded['data'] as Map<String, dynamic>);
      return true;
    }
    return false;
  }
}
