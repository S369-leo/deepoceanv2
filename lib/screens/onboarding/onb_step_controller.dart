import 'package:flutter/foundation.dart';

abstract class OnbStepController extends ChangeNotifier {
  bool get canProceed;

  Future<void> save();
}
