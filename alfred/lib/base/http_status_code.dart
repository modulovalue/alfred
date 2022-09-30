/// See https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
// TODO add title.
// TODO add description.

// region Informative
const int httpStatusContinue100 = 100;

const int httpStatusSwitchingProtocols101 = 101;

const int httpStatusProcessing102 = 102;

const int httpStatusEarlyHints103 = 103;
// endregion

// region Success
const int httpStatusOk200 = 200;

const int httpStatusCreated201 = 201;

const int httpStatusAccepted202 = 202;

const int httpStatusNonAuthoritativeInformation203 = 203;

const int httpStatusNoContent204 = 204;

const int httpStatusResetContent205 = 205;

const int httpStatusPartialContent206 = 206;

const int httpStatusMultiStatus207 = 207;

const int httpStatusAlreadyReported208 = 208;

const int httpStatusIMUsed226 = 226;
// endregion

// region Redirection
const int httpStatusMultipleChoices300 = 300;

const int httpStatusMovedPermanently301 = 301;

const int httpStatusFound302 = 302;

const int httpStatusSeeOther303 = 303;

const int httpStatusNotModified304 = 304;

const int httpStatusUseProxy305 = 305;

const int httpStatusSwitchProxy306 = 306;

const int httpStatusTemporaryRedirect307 = 307;

const int httpStatusPermanentRedirect308 = 308;
// endregion

// region Client error
const int httpStatusBadRequest400 = 400;

const int httpStatusUnauthorized401 = 401;

const int httpStatusPaymentRequired402 = 402;

const int httpStatusNotFound404 = 404;

const int httpStatusMethodNotAllowed405 = 405;

const int httpStatusNotAcceptable406 = 406;

const int httpStatusProxyAuthenticationRequired407 = 407;

const int httpStatusRequestTimeout408 = 408;

const int httpStatusConflict409 = 409;

const int httpStatusGone410 = 410;

const int httpStatusLengthRequired411 = 411;

const int httpStatusPreconditionFailed412 = 412;

const int httpStatusPayloadTooLarge413 = 413;

const int httpStatusUriTooLong414 = 414;

const int httpStatusUnsupportedMediaType415 = 415;

const int httpStatusRangeNotSatisfiable416 = 416;

const int httpStatusExpectationFailed417 = 417;

const int httpStatusImATeapot418 = 418;

const int httpStatusMisdirectedRequest421 = 421;

const int httpStatusUnprocessableEntity422 = 422;

const int httpStatusLocked423 = 423;

const int httpStatusFailedDependency424 = 424;

const int httpStatusTooEarly425 = 425;

const int httpStatusUpgradeRequired426 = 426;

const int httpStatusPreconditionRequired428 = 428;

const int httpStatusTooManyRequests429 = 429;

const int httpStatusRequestHeaderFieldsTooLarge431 = 431;

const int httpStatusUnavailableForLegalReasons451 = 451;
// endregion

// region Server error
const int httpStatusInternalServerError500 = 500;

const int httpStatusNotImplemented501 = 501;

const int httpStatusBadGateway502 = 502;

const int httpStatusServiceUnavailable503 = 503;

const int httpStatusGatewayTimeout504 = 504;

const int httpStatusHttpVersionNotSupported505 = 505;

const int httpStatusVariantAlsoNegotiates506 = 506;

const int httpStatusInsufficientStorage507 = 507;

const int httpStatusLoopDetected508 = 508;

const int httpStatusNotExtended510 = 510;

const int httpStatusNetworkAuthenticationRequired511 = 511;
// endregion

// region Caching warning
const int httpStatusResponseIsStale110 = 110;

const int httpStatusRevalidationFailed111 = 111;

const int httpStatusDisconnectedOperation = 112;

const int httpStatusHeuristicExpiration113 = 113;

const int httpStatusMiscellaneousWarning199 = 199;

const int httpStatusTransformationApplied214 = 214;

const int httpStatusMiscellaneousPersistWarning299 = 299;
// endregion

// region Unofficial codes
const int httpStatusCheckpoint103 = 103;

const int httpStatusThisIsFine218 = 218;

const int httpStatusPageExpired419 = 419;

const int httpStatusMethodFailure420 = 420;

const int httpStatusEnhanceYourCalm420 = 420;

const int httpStatusBlockedByWindowsParentalControls450 = 450;

const int httpStatusInvalidToken498 = 498;

const int httpStatusTokenRequired499 = 499;

const int httpStatusBandwidthLimitExceeded509 = 509;

const int httpStatusSiteIsOverloaded529 = 529;

const int httpStatusSiteIsFrozen530 = 530;

const int httpStatusNetworkReadTimeoutError598 = 598;
// endregion

// region Internet information services
const int httpStatusLoginTimeout440 = 440;

const int httpStatusRetryWith449 = 449;

const int httpStatusRedirect451 = 451;
// endregion

// region Nginx
const int httpStatusNoResponse444 = 444;

const int httpStatusRequestHeaderTooLarge494 = 494;

const int httpStatusSSLCertificateRequired496 = 496;

const int httpStatusHTTPRequestSentToHTTPSPort497 = 497;

const int httpStatusClientClosedRequest499 = 499;
// endregion

// region Cloudflare
const int httpStatusWebServerReturnedAnUnknownError520 = 520;

const int httpStatusWebServerIsDown521 = 521;

const int httpStatusConnectionTimedOut522 = 522;

const int httpStatusOriginUnreachable523 = 523;

const int httpStatusATimeoutOccurred524 = 524;

const int httpStatusSSLHandshakeFailed525 = 525;

const int httpStatusInvalidSSLCertificate526 = 526;

const int httpStatusRailgunError527 = 527;
// endregion
