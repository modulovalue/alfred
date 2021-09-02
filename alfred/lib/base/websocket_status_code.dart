/// See: https://developer.mozilla.org/en-US/docs/Web/API/CloseEvent

const int websocketCodeNormalClosure = 1000;

const int websocketCodeGoingAway = 1001;

const int websocketCodeProtocolError = 1002;

const int websocketCodeUnsupportedData = 1003;

const int websocketCode1004 = 1004;

const int websocketCodeNoStatusReceived = 1005;

const int websocketCodeAbnormalClosure = 1006;

const int websocketCodeInvalidFramePayloadData = 1007;

const int websocketCodePolicyViolation = 1008;

const int websocketCodeMessageTooBig = 1009;

const int websocketCodeMissingExtension = 1010;

const int websocketCodeInternalError = 1011;

const int websocketCodeServiceRestart = 1012;

const int websocketCodeTryAgainLater = 1013;

const int websocketCodeBadGateway = 1014;

const int websocketCodeTLSGateway = 1015;

bool websocketStatusCodeReserverForFutureUserbyTheStandard({
  required final int code,
}) =>
    code >= 1016 && code <= 1999;

bool websocketStatusCodeReserverForExtensions({
  required final int code,
}) =>
    code >= 2000 && code <= 2999;

bool websocketStatusCodeReserverForLibrariesAndFrameworks({
  required final int code,
}) =>
    code >= 3000 && code <= 3999;

bool websocketStatusCodeReserverForApplications({
  required final int code,
}) =>
    code >= 4000 && code <= 4999;
