import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../heroDialogRoute.dart';
import 'justifications.dart';

const Duration normalHumanReactionTime = Duration(milliseconds: 250);

//on Android: if you just deny
//the pop up can come up again and again
//the status continues to be "denied"

//on iOS: if you just deny
//the pop up can't come up again and again
//the status becomes "permanently denied"

//can Contiue on 1. Granted or 2. Limited (for photos and photo albums on iOS14+)
enum NextAction {
  Continue,
  EditManually,
  ExplainRestriction,
  TryAgainLater,
  Error
}

/// Actions that can be executed on a permission.
extension PermissionActions on Permission {
  /// Request the user for access to this [Permission], if access hasn't already
  /// been grant access before.
  ///
  /// Returns the new [PermissionStatus].
  /// or null if PermissionStatus should essentially be unknown
  Future<PermissionStatus> requestWithNull() async {
    final permissionStatus = (await [this].request())[this];
    return permissionStatus;
  }
}

//after trying, focus on the next action
Future<NextAction> tryToGetPermission(
  Permission permission,
) async {
  //grab date time here for a work around an error with the plugin
  DateTime timeBeforeRequest = DateTime.now();

  //I can't just check the status here because it does not yield the most accurate result
  PermissionStatus actualStatus = await permission.requestWithNull();
  DateTime timeAfterRequest = DateTime.now();
  //I also grab the status just to prove my point
  PermissionStatus retreivableStatus = await permission.status;
  //and I grab the request rationale to attemp to find a pattern
  bool shouldShowRequestRationale = await permission.shouldShowRequestRationale;

  //prints in the attempts to catch variable patterns to better predict the behavior
  print(
      "shouldShowRequestRationale? : " + shouldShowRequestRationale.toString());
  print("retreivable: " +
      retreivableStatus.toString() +
      " VS actual: " +
      (actualStatus != null ? actualStatus.toString() : "Unknown"));

  //!this shouldn't happen but I know that it does
  //when we permanently deny in android...
  //0. immediately after the status will be "permanently denied"
  //1. but afterwards the retreived status will be "denied"
  //2. until I request that status again and get "permanently denied"
  //* I have no 100% reliable way to check if "denied" became "permanently denied" because
  //a. the pop up came up and the user converted it
  //b. the error "converted" it
  //* but I can check the difference between the date times above to be able to tell
  //* somewhat reliably whether the pop up came up (CASE A) or whether it didn't (CASE B)
  if (retreivableStatus != actualStatus) {
    print("+\n+\n+ERROR+\n+\n+");
  }

  //I needed the null status for some checks above
  //but I didn't change anything below, so I revert back to it's default behavior
  if (actualStatus == null) {
    actualStatus = PermissionStatus.denied;
  }

  //to handle edge case that print ERROR above
  Duration timeBetweenRequestAndReturnedStatus =
      timeAfterRequest.difference(timeBeforeRequest);
  //for testing
  print("time betweeen request and the returned status: " +
      timeBetweenRequestAndReturnedStatus.toString());
  //! the error seems to "complete the request" in (110 -> 160) ms
  //! normalHumanReactionTime (250ms) might be cutting it close,
  //! the fastest I ever was to perform the action was 500ms
  //handles the edge case
  bool popUpCameUp =
      timeBetweenRequestAndReturnedStatus > normalHumanReactionTime;

  //NOTE: is Limited as of June 2nd 2021 only relates to photos and photo albums on iOS14+
  if (actualStatus.isGranted || actualStatus.isLimited) {
    return NextAction.Continue;
  } else if (actualStatus.isDenied) {
    return NextAction.TryAgainLater;
  } else {
    //! although the plugin says that "permanently denied" is only for android
    //it also comes up whenever a user denies a permission within iOS
    if (actualStatus.isPermanentlyDenied) {
      if (popUpCameUp) {
        return NextAction.TryAgainLater;
      } else {
        return NextAction.EditManually;
      }
    } else {
      //edge cases are different per platform
      if (Platform.isAndroid) {
        return NextAction.Error;
      } else if (Platform.isIOS) {
        if (actualStatus.isRestricted) {
          // restricted(only iOS [OS won't allow it])
          return NextAction.ExplainRestriction;
        } else {
          return NextAction.Error;
        }
      }
    }
  }
}

//if permission finally granted... return true... else false
Future<bool> requestPermission(
  BuildContext context, {
  PermissionStatus passedStatus,
  @required Permission permission,
  bool requestedAutomatically: false,
  @required String permissionName,
  Widget permissionJustification,
}) async {
  //if status isn't passed it must be retreived
  PermissionStatus status = passedStatus ?? await permission.status;

  //if the status is retricted by the OS -AND- we made this request automatically
  if (status.isRestricted && requestedAutomatically) {
    return false; //don't even bother telling them
  } else {
    //! We don't care about the status being restricted here becuase I don't trust it
    //I double check whether or not it's restricted by actually requesting the permission

    //deduce whether the will probably grant us permission
    bool probablyWillGrant;
    if (permissionJustification == null) {
      //if a justification isn't passed, we assume it IS NOT required
      probablyWillGrant = true;
    } else {
      //if a justification is passed, then we assume a justification IS required
      permissionJustification = await Navigator.push(
        context,
        HeroDialogRoute(
          //backing out is an implicit no
          isBarrierDismissable: true,
          //show the pop up
          builder: (BuildContext context) {
            return JustificationDialog(
              requestedAutomatically: requestedAutomatically,
              permissionName: permissionName,
              permissionJustification: permissionJustification,
            );
          },
        ),
      );
    }

    //they don't want to approve
    if (probablyWillGrant == false) {
      return false;
    } else {
      //they SAY they want to approve
      //so ask them to put their money with their mouth is
      NextAction nextAction = await tryToGetPermission(permission);

      //handle the simple reactions
      if (nextAction == NextAction.Error) {
        //TODO: come up with something better
        return false;
      } else if (nextAction == NextAction.TryAgainLater) {
        return false;
      } else if (nextAction == NextAction.Continue) {
        return true;
      } else {
        //both of these options require explanation pop ups
        //that offer the option to go into app settings
        if (nextAction == NextAction.EditManually) {
          return await Navigator.push(
            context,
            HeroDialogRoute(
              //backing out in an implicit no
              isBarrierDismissable: true,
              //show the pop up
              builder: (BuildContext context) {
                return EnableManuallyDialog(
                  permission: permission,
                  permissionName: permissionName,
                );
              },
            ),
          );
        } else if (nextAction == NextAction.ExplainRestriction) {
          return await Navigator.push(
            context,
            HeroDialogRoute(
              //backing out in an implicit no
              isBarrierDismissable: true,
              //show the pop up
              builder: (BuildContext context) {
                return ExplainRestrictionDialog(
                  permission: permission,
                  permissionName: permissionName,
                );
              },
            ),
          );
        } else {
          //TODO: come up with something better
          return false;
        }
      }
    }
  }
}
