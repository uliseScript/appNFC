import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'loading_component_model.dart';
export 'loading_component_model.dart';

class LoadingComponentWidget extends StatefulWidget {
  const LoadingComponentWidget({super.key});

  @override
  State<LoadingComponentWidget> createState() => _LoadingComponentWidgetState();
}

class _LoadingComponentWidgetState extends State<LoadingComponentWidget> {
  late LoadingComponentModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LoadingComponentModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Lottie.asset(
              'assets/jsons/Animation_-_1751041711319_(1).json',
              width: 350.0,
              height: 300.0,
              fit: BoxFit.contain,
              reverse: true,
              animate: true,
            ),
          ),
        ),
      ],
    );
  }
}
