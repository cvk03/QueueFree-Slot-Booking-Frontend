import 'package:flutter/material.dart';

class SignInModel {
  /// Tab Controller
  TabController? tabBarController;

  int get tabBarCurrentIndex =>
      tabBarController != null ? tabBarController!.index : 0;

  int get tabBarPreviousIndex =>
      tabBarController != null ? tabBarController!.previousIndex : 0;

  /// Sign In fields
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;

  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  bool passwordVisibility = false;

  /// Sign Up fields
  FocusNode? emailAddressCreateFocusNode;
  TextEditingController? emailAddressCreateTextController;

  FocusNode? nameSignUpFocusNode;
  TextEditingController? nameSignUpTextController;

  FocusNode? misNumberCreateFocusNode;
  TextEditingController? misNumberCreateTextController;

  FocusNode? hostelSignUpFocusNode;
  TextEditingController? hostelSignUpTextController;

  FocusNode? phoneNumberCreateFocusNode;
  TextEditingController? phoneNumberCreateTextController;

  FocusNode? passwordCreateFocusNode;
  TextEditingController? passwordCreateTextController;
  bool passwordCreateVisibility = false;

  FocusNode? passwordConfirmFocusNode;
  TextEditingController? passwordConfirmTextController;
  bool passwordConfirmVisibility = false;

  /// Initialize controllers
  void init() {
    emailAddressFocusNode = FocusNode();
    emailAddressTextController = TextEditingController();

    passwordFocusNode = FocusNode();
    passwordTextController = TextEditingController();

    emailAddressCreateFocusNode = FocusNode();
    emailAddressCreateTextController = TextEditingController();

    nameSignUpFocusNode = FocusNode();
    nameSignUpTextController = TextEditingController();

    misNumberCreateFocusNode = FocusNode();
    misNumberCreateTextController = TextEditingController();

    hostelSignUpFocusNode = FocusNode();
    hostelSignUpTextController = TextEditingController();

    phoneNumberCreateFocusNode = FocusNode();
    phoneNumberCreateTextController = TextEditingController();

    passwordCreateFocusNode = FocusNode();
    passwordCreateTextController = TextEditingController();

    passwordConfirmFocusNode = FocusNode();
    passwordConfirmTextController = TextEditingController();
  }

  /// Dispose controllers
  void dispose() {
    tabBarController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();

    emailAddressCreateFocusNode?.dispose();
    emailAddressCreateTextController?.dispose();

    nameSignUpFocusNode?.dispose();
    nameSignUpTextController?.dispose();

    misNumberCreateFocusNode?.dispose();
    misNumberCreateTextController?.dispose();

    hostelSignUpFocusNode?.dispose();
    hostelSignUpTextController?.dispose();

    phoneNumberCreateFocusNode?.dispose();
    phoneNumberCreateTextController?.dispose();

    passwordCreateFocusNode?.dispose();
    passwordCreateTextController?.dispose();

    passwordConfirmFocusNode?.dispose();
    passwordConfirmTextController?.dispose();
  }
}