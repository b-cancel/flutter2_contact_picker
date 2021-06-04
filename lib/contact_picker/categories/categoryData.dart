import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum LabelType { phone, email, address }

class CategoryData {
  static List<String> phoneLabels = [];
  static List<String> emailLabels = [];
  static List<String> addressLabels = [];

  static Map<LabelType, List<String>> labelTypeToLabels = {
    LabelType.phone: phoneLabels,
    LabelType.email: emailLabels,
    LabelType.address: addressLabels,
  };

  static Map<LabelType, String> labelTypeToCategoryName = {
    LabelType.phone: "phone number",
    LabelType.email: "email address",
    LabelType.address: "address",
  };

  //Modified so that it only inits the lists that need it
  //each of these lists are read in from their own file
  static Future init() async {
    if (phoneLabels.length == 0) {
      await listInit(LabelType.phone);
    }
    if (emailLabels.length == 0) {
      await listInit(LabelType.email);
    }
    if (addressLabels.length == 0) {
      await listInit(LabelType.address);
    }
  }

  static Future listInit(LabelType labelType) async {
    //calculate all basic params
    String fileName = labelType.toString();
    String localPath = (await getApplicationDocumentsDirectory()).path;
    String filePath = '$localPath/$fileName';
    File fileReference = File(filePath);

    //If needed create the file
    bool fileExists =
        (FileSystemEntity.typeSync(filePath) != FileSystemEntityType.notFound);
    //if(fileExists == false) await createDefault(labelType, fileReference);
    await fileReference.delete();
    await createDefault(labelType, fileReference);

    //Use the file data to populate a list
    readFile(labelType, fileReference);
  }

  static createDefault(LabelType labelType, File reference) async {
    //create the file
    reference.create();

    //fill it with defaults
    String defaultString;
    switch (labelType) {
      case LabelType.phone:
        defaultString =
            '["mobile", "home", "work", "main", "work fax", "home fax", "pager", "other"]';
        break;
      case LabelType.email:
        defaultString = '["home", "work", "other"]';
        break;
      default:
        defaultString = '["home", "work", "other"]';
        break;
    }
    defaultString = '{ "types": ' + defaultString + ' }';

    //write to file
    await reference.writeAsString(defaultString);
  }

  static readFile(LabelType labelType, File reference) async {
    String fileString = await reference.readAsString();
    Map jsonMap = json.decode(fileString);
    List<String> list =
        new List<String>.from(jsonMap[jsonMap.keys.toList()[0]]);
    switch (labelType) {
      case LabelType.phone:
        phoneLabels = list;
        break;
      case LabelType.email:
        emailLabels = list;
        break;
      default:
        addressLabels = list;
        break;
    }
  }
}
