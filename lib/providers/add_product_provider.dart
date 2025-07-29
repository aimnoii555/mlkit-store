import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final imageProvider = StateProvider<XFile?>((ref) => null);

