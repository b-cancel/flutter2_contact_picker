import 'dart:io';

import 'package:path_provider/path_provider.dart';

//one file reference per filename
Map<String, File> _fileNameToFileReference = Map();

//assume one file reference per filename
Future<File> nameToFileReference(String fileName) async {
  //grab the reference the first time
  if (_fileNameToFileReference.containsKey(fileName) == false) {
    String localPath = (await getApplicationDocumentsDirectory()).path;
    String filePath = '$localPath/$fileName';
    _fileNameToFileReference[fileName] = File(filePath);
  }

  //return saved value
  return _fileNameToFileReference[fileName];
}
