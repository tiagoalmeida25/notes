import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:notes/data/hive_database_folders.dart';
import 'package:notes/data/hive_database_notes.dart';
import 'package:notes/data/hive_database_tags.dart';

class FirebaseBackupService {
  static Future<void> uploadBackup() async {
    try {
      final notesData = await HiveNotesDatabase().createFirebaseBackup();
      final foldersData = await HiveFoldersDatabase().createFirebaseBackup();
      final tagsData = await HiveTagsDatabase().createFirebaseBackup();

      final data = '{"notes": $notesData, "folders": $foldersData, "tags": $tagsData}';

      final fileName = DateTime.now().toString() + '.json';

      await firebase_storage.FirebaseStorage.instance
          .ref('backups/$fileName')
          .putString(data);
    } catch (e) {
      print('Error uploading backup: $e');
    }
  }

  static Future<String> downloadBackup(String fileName) async {
    try {
      final response = await firebase_storage.FirebaseStorage.instance
          .ref('backups/$fileName')
          .getData();

      return String.fromCharCodes(response!);
    } catch (e) {
      print('Error downloading backup: $e');
      return '';
    }
  }
}
