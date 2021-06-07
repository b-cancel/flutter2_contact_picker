import 'package:flutter2_contact_picker/contact_picker/utils/read_write/read.dart';
import 'package:flutter2_contact_picker/contact_picker/utils/read_write/write.dart';

Future saveList(String identifier, List list) async {
  Map labelsMap = {identifier: list};
  return await mapToFile(
    labelsMap,
    identifier,
  );
}

Future<List<String>> loadList(
  String identifier,
) async {
  Map resultMap = await fileToMap(identifier);
  print(resultMap.runtimeType.toString());
  //is empty so return empty list
  if (resultMap == null) {
    return [];
  } else {
    //confirm key
    if (resultMap.containsKey(identifier) == false) {
      return [];
    } else {
      //actually return the list
      List<String> listRead = List<String>.from(resultMap[identifier]);
      return listRead;
    }
  }
}
