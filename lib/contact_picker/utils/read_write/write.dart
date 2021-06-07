import 'dart:convert';
import 'dart:io';

import 'helper.dart';

//This utility file does 2 things
//Since writing to a file may happen often (before the previous change is written)
//1. we only process 1 write request at a time
//EX: write X, write Y, write Z... when X finishes it writes Z... since Y is already outdated
//TODO: this bit isn't done yet, but maybe in the future if the issue is frequent enough we can dive into it
//2. after the write is done we write to a back up file so we know atleast one will work

//keep track of the files currently being written to
Set<File> _filesWeAreWritingTo = new Set<File>();

//keep track of the newest waiting data
Map<File, String> _fileToNextStringToBeWritten = new Map<File, String>();

//NOTE: this assumes that the file atleast exists
mapToFile(Map map, String fileName) async {
  File fileReference = await nameToFileReference(fileName);

  //if it doesn't exists, create it
  if (await fileReference.exists() == false) {
    await fileReference.create();
  }

  //decode map into string
  String string = jsonEncode(map);

  //If the file is already being written to
  if (_filesWeAreWritingTo.contains(fileReference)) {
    //save our data for writing after it completes
    //NOTE: may have overwritten old waiting data
    _fileToNextStringToBeWritten[fileReference] = string;
  } else {
    _writeToFile(fileReference, string);
  }
}

//write to file is a seperate function so we can easily recurse
_writeToFile(File file, String data) async {
  //mark this file as being written into
  _filesWeAreWritingTo.add(file);

  //write into it
  await file.writeAsString(
    data,
    //overwrite the file if its already been written to and opens it only for writing
    mode: FileMode.writeOnly,
    //ensure data integrity but takes a bit longer
    flush: true,
  );

  //TODO: we finished writing to our file... if the file isn't a backup file... back it up

  //once finished check if something else was waiting
  if (_fileToNextStringToBeWritten.containsKey(file)) {
    //grab data waiting
    String data = _fileToNextStringToBeWritten.remove(file);
    //NOTE: we keep the being written to flag on
    _writeToFile(file, data);
  } else {
    //we finished writing to this file (for now)
    _filesWeAreWritingTo.remove(file);
  }
}
