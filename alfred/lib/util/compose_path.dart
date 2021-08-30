String composePath({
  required final String first,
  required final String second,
}) {
  if (first.endsWith('/') && second.startsWith('/')) {
    return first + second.substring(1);
  } else if (!first.endsWith('/') && !second.startsWith('/')) {
    return first + '/' + second;
  } else {
    return first + second;
  }
}
