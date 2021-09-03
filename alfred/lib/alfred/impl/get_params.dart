Map<String, String>? getParams({
  required final String route,
  required final String input,
}) {
  final routeParts = route.split('/')..remove('');
  final inputParts = input.split('/')..remove('');
  if (inputParts.length != routeParts.length) {
    // TODO expose the reason for the empty map.
    return null;
  } else {
    final output = <String, String>{};
    for (var i = 0; i < routeParts.length; i++) {
      final routePart = routeParts[i];
      final inputPart = inputParts[i];
      if (routePart.contains(':')) {
        final routeParams = routePart.split(':')..remove('');
        for (final item in routeParams) {
          output[item] = Uri.decodeComponent(inputPart);
        }
      }
    }
    return output;
  }
}
