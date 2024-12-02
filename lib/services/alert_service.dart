import 'package:flutter/material.dart';
// import 'package:quickalert/quickalert.dart';

class AlertService {
  // MATERIAL
  // SHOW BANNER
  void showBanner(BuildContext context, String message) {
    hideBanner(context);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => hideBanner(context),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  // HIDE BANNER
  void hideBanner(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
  }

  // // QUICKALERTS
  // // LOADING
  // void showLoading(BuildContext context, {String? title, String? text}) {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.loading,
  //     title: title,
  //     text: text,
  //   );
  // }

  // // WARNING
  // void showWarning(BuildContext context, {String? title, String? text}) {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.warning,
  //     title: title,
  //     text: text,
  //   );
  // }

  // // ERROR
  // void showError(BuildContext context, {String? title, String? text}) {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.error,
  //     title: title,
  //     text: text,
  //   );
  // }

  // // SUCCESS
  // void showSuccess(BuildContext context, {String? title, String? text}) {
  //   QuickAlert.show(
  //     context: context,
  //     type: QuickAlertType.success,
  //     title: title,
  //     text: text,
  //   );
  // }
}
