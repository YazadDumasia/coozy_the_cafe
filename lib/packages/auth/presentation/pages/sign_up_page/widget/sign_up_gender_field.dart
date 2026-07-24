import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/packages/auth/presentation/pages/sign_up_page/cubit/sign_up_cubit.dart';

// Assuming RadioGroup is a custom widget provided by the project or a library.
// If it's not found, it might be a part of a generic implementation.
// Note: In the original file, it was used with a child containing Radio buttons.

class SignUpGenderField extends StatelessWidget {
  const SignUpGenderField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onGenderChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onGenderChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: context.watch<SignUpCubit>().genderController,
      builder: (context, snapshot) {
        return Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, top: 15),
              child: TextFormField(
                focusNode: focusNode,
                controller: controller,
                cursorColor: Colors.transparent,
                readOnly: true,
                onChanged: (value) {
                  onGenderChanged(snapshot.data ?? ' ');
                },
                validator: (value) {
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.trim().isEmpty) {
                    return 'Please select your gender';
                  }
                  if (snapshot.hasError) {
                    return snapshot.error.toString();
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText:
                      context.tr(
                        shared.LocaleKeys.commonGenderLabel,
                        track: shared.TrackConstants.signUpTrack,
                      ) ??
                      'Gender',
                  isDense: true,
                  contentPadding: EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).disabledColor,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(0)),
                      ),
                      child: RadioGroup<String>(
                        groupValue: snapshot.data,
                        onChanged: (value) => onGenderChanged(value!),
                        child: Scrollbar(
                          interactive: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            primary: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  onTap: () => onGenderChanged('Male'),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Radio<String>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: 'Male',
                                      ),
                                      Flexible(
                                        child: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .commonGenderMaleLabel,
                                                track: shared
                                                    .TrackConstants
                                                    .commonTrack,
                                              ) ??
                                              'Male',
                                        ).paddingOnly(right: 5.0),
                                      ),
                                    ],
                                  ),
                                ).inMartialInkwell(
                                  radius: BorderRadius.circular(5.0),
                                ),
                                InkWell(
                                  onTap: () => onGenderChanged('Female'),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Radio<String>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: 'Female',
                                      ),
                                      Flexible(
                                        child: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .commonGenderFemaleLabel,
                                                track: shared
                                                    .TrackConstants
                                                    .commonTrack,
                                              ) ??
                                              'Female',
                                        ).paddingOnly(right: 5.0),
                                      ),
                                    ],
                                  ),
                                ).inMartialInkwell(
                                  radius: BorderRadius.circular(5.0),
                                ),
                                InkWell(
                                  onTap: () => onGenderChanged('Others'),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Radio<String>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: 'Others',
                                      ),
                                      Flexible(
                                        child: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .commonGenderOtherLabel,
                                                track: shared
                                                    .TrackConstants
                                                    .commonTrack,
                                              ) ??
                                              'Others',
                                        ).paddingOnly(right: 5.0),
                                      ),
                                    ],
                                  ),
                                ).inMartialInkwell(
                                  radius: BorderRadius.circular(5.0),
                                ),
                                InkWell(
                                  onTap: () => onGenderChanged('Unknown'),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Radio<String>(
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        value: 'Unknown',
                                      ),
                                      Flexible(
                                        child: Text(
                                          context.tr(
                                                shared
                                                    .LocaleKeys
                                                    .commonGenderNoToSayGenderLabel,
                                                track: shared
                                                    .TrackConstants
                                                    .commonTrack,
                                              ) ??
                                              'Prefer to say',
                                        ).paddingOnly(right: 5.0),
                                      ),
                                    ],
                                  ),
                                ).inMartialInkwell(
                                  radius: BorderRadius.circular(5.0),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).inExpandedRow();
  }
}
