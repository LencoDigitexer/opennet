import 'package:enough_convert/enough_convert.dart';

main() {
  final codec = const Windows1252Codec(allowInvalid: false);
  final input = 'Il faut être bête quand même.';
  final encoded = codec.encode(input);
  final decoded = codec.decode([...encoded]);
  print('${codec.name}: encode "$input" to "$encoded"');
  print('${codec.name}: decode $encoded to "$decoded"');

}
