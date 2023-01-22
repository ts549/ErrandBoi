// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'errand_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Errand {
  Errand(
      {required this.title,
      required this.description,
      required this.requestor,
      required this.locLat,
      required this.locLng,
      required this.duration,
      required this.reward});
  Errand.fromForm();
  String? title = "";
  String? description = "";
  String? requestor = "";
  double? locLat = 0.0;
  double? locLng = 0.0;
  int? duration = 0;
  int? reward = 0;

  factory Errand.fromJson(Map<String, dynamic> json) => Errand(
      title: json["title"],
      description: json["descr"],
      requestor: json["requestor"],
      locLat: json["locLat"],
      locLng: json["locLng"],
      duration: json["duration"],
      reward: json["reward"]);
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Create errand"),
      ),
      body: const TextFormFieldDemo(),
    );
  }
}

class TextFormFieldDemo extends StatefulWidget {
  const TextFormFieldDemo({Key? key}) : super(key: key);

  @override
  TextFormFieldDemoState createState() => TextFormFieldDemoState();
}

// class PersonData {
//   String? name = '';
//   String? phoneNumber = '';
//   String? email = '';
//   String password = '';
// }

// class PasswordField extends StatefulWidget {
//   const PasswordField({
//     Key? key,
//     this.restorationId,
//     this.fieldKey,
//     this.hintText,
//     this.labelText,
//     this.helperText,
//     this.onSaved,
//     this.validator,
//     this.onFieldSubmitted,
//     this.focusNode,
//     this.textInputAction,
//   }) : super(key: key);

//   final String? restorationId;
//   final Key? fieldKey;
//   final String? hintText;
//   final String? labelText;
//   final String? helperText;
//   final FormFieldSetter<String>? onSaved;
//   final FormFieldValidator<String>? validator;
//   final ValueChanged<String>? onFieldSubmitted;
//   final FocusNode? focusNode;
//   final TextInputAction? textInputAction;

//   @override
//   State<PasswordField> createState() => _PasswordFieldState();
// }

// class _PasswordFieldState extends State<PasswordField> with RestorationMixin {
//   final RestorableBool _obscureText = RestorableBool(true);

//   @override
//   String? get restorationId => widget.restorationId;

//   @override
//   void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
//     registerForRestoration(_obscureText, 'obscure_text');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       key: widget.fieldKey,
//       restorationId: 'password_text_field',
//       obscureText: _obscureText.value,
//       maxLength: 8,
//       onSaved: widget.onSaved,
//       validator: widget.validator,
//       onFieldSubmitted: widget.onFieldSubmitted,
//       decoration: InputDecoration(
//         filled: true,
//         hintText: widget.hintText,
//         labelText: widget.labelText,
//         helperText: widget.helperText,
//         suffixIcon: IconButton(
//           onPressed: () {
//             setState(() {
//               _obscureText.value = !_obscureText.value;
//             });
//           },
//           hoverColor: Colors.transparent,
//           icon: Icon(_obscureText.value
//                   ? Icons.visibility
//                   : Icons
//                       .visibility_off /*,
//             semanticLabel: _obscureText.value
//                 ? GalleryLocalizations.of(context)!
//                     .demoTextFieldShowPasswordLabel
//                 : GalleryLocalizations.of(context)!
//                     .demoTextFieldHidePasswordLabel,*/
//               ),
//         ),
//       ),
//     );
//   }
// }

class TextFormFieldDemoState extends State<TextFormFieldDemo>
    with RestorationMixin {
//  PersonData person = PersonData();
  Errand errand = Errand.fromForm();

  late FocusNode _phoneNumber, _email, _lifeStory, _password, _retypePassword;

  @override
  void initState() {
    super.initState();
    _phoneNumber = FocusNode();
    _email = FocusNode();
    _lifeStory = FocusNode();
    _password = FocusNode();
    _retypePassword = FocusNode();
  }

  @override
  void dispose() {
    _phoneNumber.dispose();
    _email.dispose();
    _lifeStory.dispose();
    _password.dispose();
    _retypePassword.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  String get restorationId => 'text_field_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_autoValidateModeIndex, 'autovalidate_mode');
  }

  final RestorableInt _autoValidateModeIndex =
      RestorableInt(AutovalidateMode.disabled.index);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      _autoValidateModeIndex.value =
          AutovalidateMode.always.index; // Start validating on every change.
      /* showInSnackBar(
        GalleryLocalizations.of(context)!.demoTextFieldFormErrors,
      );*/
    } else {
      form.save();
      ErrandProvider().addErrand(errand.title, errand.description, "lucy", 12.2,
          100.3, 10, errand.reward);
      //  showInSnackBar(GalleryLocalizations.of(context)!
      //      .demoTextFieldNameHasPhoneNumber(person.name!, person.phoneNumber!));
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      //return GalleryLocalizations.of(context)!.demoTextFieldNameRequired;
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    /* if (!nameExp.hasMatch(value)) {
      return GalleryLocalizations.of(context)!
          .demoTextFieldOnlyAlphabeticalChars;
    }*/
    return null;
  }

  final _dateC = TextEditingController();
  final _timeC = TextEditingController();
  var _title = TextEditingController();

  ///Date
  DateTime selected = DateTime.now();
  DateTime initial = DateTime(2000);
  DateTime last = DateTime(2025);

  ///Time
  TimeOfDay timeOfDay = TimeOfDay.now();

  Future displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(context: context, initialTime: timeOfDay);

    if (time != null) {
      setState(() {
        _timeC.text = "${time.hour}:${time.minute}";
      });
    }
  }

  Future displayDatePicker(BuildContext context) async {
    var date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );

    if (date != null) {
      setState(() {
        _dateC.text = date.toLocal().toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    //final localizations = GalleryLocalizations.of(context)!;
    final ScrollController sCtr = ScrollController();

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.values[_autoValidateModeIndex.value],
      child: Scrollbar(
        controller: sCtr,
        child: SingleChildScrollView(
          controller: sCtr,
          restorationId: 'text_field_demo_scroll_view',
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(children: [
                sizedBoxSpace,
                SizedBox(
                    width: 200,
                    child: TextFormField(
                      controller: _title,
                      restorationId: 'name_field',
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        filled: true,
                        icon: const Icon(Icons.directions_run),
                        labelText: "Errand title",
                      ),
                      onSaved: (value) {
                        //person.name = value;
                        errand.title = value;
                        //_phoneNumber.requestFocus();
                      },
                      //validator: _validateName,
                    )),
                SizedBox(
                    width: 100,
                    child: TextFormField(
                      restorationId: 'reward_field',
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        icon: const Icon(Icons.attach_money),
                        labelText: "Reward",
                        suffixText: "USD",
                      ),
                      onSaved: (value) {
                        if (value == null) {
                          print("needs reward value");
                        } else {
                          errand.reward = int.parse(value);
                        }
                      },
                      maxLines: 1,
                    ))
              ]),
              sizedBoxSpace,
              TextFormField(
                restorationId: 'life_story_field',
                focusNode: _lifeStory,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: "Tell us more about your errand.",
                    labelText: "Errand description"),
                onSaved: (value) {
                  errand.description = value;
                },
                maxLines: 3,
              ),
              sizedBoxSpace,
              TextFormField(
                controller: _dateC,
                decoration: const InputDecoration(
                    labelText: 'Date picker', border: OutlineInputBorder()),
              ),
              sizedBoxSpace,
              TextFormField(
                controller: _timeC,
                decoration: const InputDecoration(
                    labelText: 'Time picker', border: OutlineInputBorder()),
              ),
              sizedBoxSpace,
              Row(children: [
                sizedBoxSpace,
                ElevatedButton(
                    onPressed: () => displayDatePicker(context),
                    child: const Text("Pick Date")),
                sizedBoxSpace,
                ElevatedButton(
                    onPressed: () => displayTimePicker(context),
                    child: const Text("Pick Time")),
              ]),
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmitted,
                  child: Text("SUBMIT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
