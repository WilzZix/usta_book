# Phone Authentication — Design

**Date:** 2026-05-07
**Status:** Approved by user, ready for implementation plan

## Summary

Replace the existing email/password authentication with Firebase Phone Auth (SMS OTP). Built modularly so the OTP send/verify layer can later be swapped to a custom Eskiz-based flow if Firebase's default SMS delivery proves unreliable for +998 numbers.

## Goals

- Masters sign up and sign in only via phone number (E.164, +998 prefix).
- Existing dummy phone/OTP UI screens become functional.
- Auth state changes already handled by `AuthCubit` flow into the new sign-in path with no regression.
- Implementation isolated behind a domain interface so an Eskiz-backed implementation can replace it without touching BLoC/UI.

## Non-Goals

- No multi-provider login UI (no email button, no Google, no Apple).
- No phone-number change/recovery flow in this iteration.
- No backend SMS template work (uses Firebase's built-in SMS).

## Current State

- One Firebase Auth user exists (`cYodbRsZuwMO39DAHe92TJ6RKul2`, email `nodirbarotov0707@gmail.com`). Will be deleted along with their `masters/{uid}` document and subcollections — clean slate.
- `lib/data/repositories/sign_in/sign_in_repository.dart` only does email/password. To be removed.
- `lib/presentation/sign_up/email_and_password/email_and_password.dart` is the email login screen. To be removed.
- `lib/presentation/sign_up/phone_registration/phone_registration_page.dart` and `lib/presentation/sign_up/otp/otp_page.dart` exist but their buttons just `context.pushNamed(...)` to the next screen with no Firebase calls.
- `lib/bloc/auth/auth_cubit.dart` already subscribes to `FirebaseAuth.authStateChanges()` and emits `AuthUnauthenticated` / `AuthProfileIncomplete` / `AuthAuthenticated` based on Firestore profile state. This stays as-is.
- `lib/presentation/router/app_route.dart` already routes phone → otp → profile_settings as a public flow. Stays mostly as-is; one route (`EmailAndPassword`) gets removed.

## Architecture

### Layering

```
UI (phone_registration_page, otp_page)
  ↓ events
PhoneAuthBloc            ← new
  ↓ method calls
IPhoneAuth (domain)      ← new interface
  ↑ implemented by
FirebasePhoneAuthRepository  ← new (uses FirebaseAuth.verifyPhoneNumber)
                              ↑ later swappable for EskizPhoneAuthRepository
```

`AuthCubit` is unchanged: once `signInWithCredential` succeeds, `authStateChanges` fires and `AuthCubit` transitions to `AuthProfileIncomplete`, which the router uses to navigate to `ProfileSettings`.

### Domain interface — `IPhoneAuth`

```dart
abstract class IPhoneAuth {
  /// Sends an OTP to the given E.164 phone number.
  /// Returns a verificationId on codeSent, or completes
  /// immediately on instant verification (Android auto-retrieval).
  Future<PhoneAuthSendResult> sendCode(String phoneE164);

  /// Verifies an OTP and signs the user into FirebaseAuth.
  Future<void> verifyCode({
    required String verificationId,
    required String smsCode,
  });

  /// Resends the OTP using the previously issued forceResendingToken.
  Future<PhoneAuthSendResult> resendCode(
    String phoneE164,
    int forceResendingToken,
  );
}

sealed class PhoneAuthSendResult {}
class CodeSent extends PhoneAuthSendResult {
  final String verificationId;
  final int? forceResendingToken;
}
class AutoVerified extends PhoneAuthSendResult {} // Android instant signin
class SendFailed extends PhoneAuthSendResult {
  final PhoneAuthError error;
}

enum PhoneAuthError {
  invalidPhone,
  quotaExceeded,
  networkError,
  invalidCode,
  codeExpired,
  unknown,
}
```

The interface is the only seam between BLoC and the underlying provider. A future `EskizPhoneAuthRepository` implements the same interface using Cloud Functions + custom tokens.

### Data implementation — `FirebasePhoneAuthRepository`

- `sendCode`: calls `FirebaseAuth.verifyPhoneNumber(phoneNumber: phoneE164, timeout: 60s, ...)` and bridges its callbacks (`codeSent`, `verificationCompleted`, `verificationFailed`, `codeAutoRetrievalTimeout`) into a single `Future<PhoneAuthSendResult>` via a `Completer`.
- `verifyCode`: builds `PhoneAuthProvider.credential(verificationId, smsCode)` and calls `FirebaseAuth.signInWithCredential`. Maps `FirebaseAuthException` codes (`invalid-verification-code`, `session-expired`, etc.) to `PhoneAuthError`.
- `resendCode`: same as `sendCode` but passes `forceResendingToken`.
- Registered in `injectable` as `@Singleton(as: IPhoneAuth)`.

### BLoC — `PhoneAuthBloc`

States:
- `PhoneAuthIdle` — initial
- `PhoneAuthSendingCode` — verifyPhoneNumber in flight
- `PhoneAuthCodeSent { verificationId, forceResendingToken, phone }`
- `PhoneAuthVerifying`
- `PhoneAuthSuccess` — signed in (UI navigation handled by AuthCubit + router redirect, but state is useful for analytics/feedback)
- `PhoneAuthFailure { error: PhoneAuthError, message }`

Events:
- `PhoneAuthSubmitPhone(phoneE164)` — from phone screen
- `PhoneAuthSubmitOtp(code)` — from OTP screen
- `PhoneAuthResend()` — from OTP screen, after timer expires

The bloc is provided at the navigator level so the same instance flows from phone screen to OTP screen.

### UI changes

**`phone_registration_page.dart`:**
- Wrap with `BlocProvider<PhoneAuthBloc>` (or rely on a higher-level provider).
- Phone field: hardcoded `+998` prefix display, mask `(XX) XXX-XX-XX`. On submit, transform to E.164: `+998XXXXXXXXX`.
- "Send code" button: `bloc.add(PhoneAuthSubmitPhone(e164))`.
- `BlocListener`: on `PhoneAuthCodeSent` → `context.pushNamed(OtpPage.tag)` carrying the bloc instance via go_router `extra` or shared provider. On `PhoneAuthFailure` → snackbar.
- Loading state: button shows spinner when `PhoneAuthSendingCode`.

**`otp_page.dart`:**
- Receives bloc instance / phone number from previous screen.
- "Confirm" button: `bloc.add(PhoneAuthSubmitOtp(code))`.
- `BlocListener`: on `PhoneAuthFailure(invalidCode)` → shake animation + clear field + snackbar. On `PhoneAuthSuccess` → no manual navigation needed; `AuthCubit` will emit `AuthProfileIncomplete` and the router redirects to `ProfileSettings`.
- Replace inline 60s `OtpTimerWidget` button with bloc-driven resend: when timer hits 0, the resend button calls `bloc.add(PhoneAuthResend())`. Re-arm the timer on `PhoneAuthCodeSent`.
- Phone display: pass real phone in (currently hardcoded `+998(94) 691-49-77`).

### Routing

- Remove `EmailAndPassword` route and import from `app_route.dart`.
- Remove `EmailAndPassword.tag` from the `publicPaths` list.
- Remove `authPages` reference to `EmailAndPassword.tag`.
- Initial unauthenticated landing: `ChooseLanguage` → existing onboarding → `PhoneRegistrationPage` (already wired).
- The OTP page nested route (`/phone-registration-page/otp-page`) stays.

### Code removals

- `lib/presentation/sign_up/email_and_password/` directory.
- `lib/data/repositories/sign_in/sign_in_repository.dart` (email-only).
- `lib/domain/repositories/sign_in/i_sign_in.dart` (email-only).
- `lib/domain/usecases/sign_in_usecase.dart` (wraps email-only `ISignIn`).
- `lib/bloc/sign_up_and_sing_in/sign_up_and_sing_in_bloc.dart` and its event/state files (handles only `SignInWithEmailAndPasswordEvent` / `SignUpWithEmailAndPasswordEvent`).
- Wherever `SignUpAndSingInBloc` is `BlocProvider`-ed and `provided` to widgets (DI registration in `injection.dart` / `injection.config.dart`).
- Any `injectable` registrations and generated `.g.dart` references — regenerate via `dart run build_runner build`.

### Behavior preserved from the email bloc

The current email bloc, after a successful sign-in, calls `ShredPrefService.setMasterUID(masterUID: user.uid)`. Other blocs (`ClientsBloc` etc.) read the UID via `getMasterUID()`. The new phone flow MUST preserve this:

- After `verifyCode` succeeds (i.e., `FirebaseAuth.signInWithCredential` returns a non-null user), call `ShredPrefService.setMasterUID(masterUID: user.uid)` before emitting `PhoneAuthSuccess`.
- This keeps existing read sites working without refactor.
- A future cleanup could replace SharedPref-cached UID with `FirebaseAuth.instance.currentUser?.uid` everywhere, but that is out of scope for this spec.

### Firebase Console operations (manual, outside code)

- Authentication → Sign-in method → enable **Phone**, disable **Email/Password**.
- Authentication → Phone numbers for testing → add `+998946914977` with fixed code `123456` for development.
- Android: ensure debug + release SHA-1/SHA-256 fingerprints registered in `ustabook-c00e4` Android app config (Play Integrity / SafetyNet relies on this).
- iOS: ensure APNs auth key uploaded to Firebase project (Phone Auth on iOS uses silent push for verification).
- Delete existing user `cYodbRsZuwMO39DAHe92TJ6RKul2` from Firebase Auth.
- Delete `masters/cYodbRsZuwMO39DAHe92TJ6RKul2` document including subcollections (`clients`, `appointments`, `fcmTokens`).
- Delete leftover test docs in top-level `notification_queue/` and `push_queue/` from earlier SMS testing.

## Error handling

| FirebaseAuthException code | UI message (RU/UZ) |
|---|---|
| `invalid-phone-number` | "Telefon raqami noto'g'ri" / "Неверный номер" |
| `too-many-requests` | "Juda ko'p urinish, keyinroq qayta urining" / "Слишком много попыток" |
| `quota-exceeded` | (admin issue) "Xizmat hozir mavjud emas" / "Сервис недоступен" |
| `invalid-verification-code` | "Kod noto'g'ri" / "Неверный код" |
| `session-expired` | "Kod muddati tugagan, qayta yuboring" / "Срок кода истёк" |
| `network-request-failed` | "Internet ulanishi yo'q" / "Нет соединения" |
| (other) | "Xatolik yuz berdi" / "Произошла ошибка" |

Translations go into existing `core/localization/i18n` strings.

## Testing

- Unit: `FirebasePhoneAuthRepository` with mocked `FirebaseAuth` — verify callback bridging, error mapping.
- Unit: `PhoneAuthBloc` with mocked `IPhoneAuth` — verify state transitions for happy path, invalid code, resend, network failure.
- Manual: with the test phone `+998946914977` + fixed code `123456` configured in console, verify the full flow without consuming SMS quota. Then a real-number smoke test against the developer's actual phone.

## Migration / rollout

- One existing user, no real customers — no migration. Delete and start fresh.
- After deploy, the developer signs in with their real phone, completes profile, and re-creates any test data they need.

## Open questions / decisions deferred to implementation

- Exact phone input mask widget: reuse existing `InputField.phone` or refactor. Decide during implementation; the mask just needs to produce E.164 on submit.
- Whether to consolidate `PhoneAuthBloc` provision at app root vs. nested at the phone-registration route. Default: nested at the route; revisit if multiple screens need it.
- Eskiz fallback: out of scope for this spec. The `IPhoneAuth` seam guarantees a future `EskizPhoneAuthRepository` swap touches only DI registration.
