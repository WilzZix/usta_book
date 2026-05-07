# Phone Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace email/password auth with Firebase Phone Auth (SMS OTP), behind an `IPhoneAuth` interface so an Eskiz-backed implementation can swap in later.

**Architecture:** UI → `PhoneAuthBloc` → `IPhoneAuth` (domain) ← `FirebasePhoneAuthRepository` (data). `AuthCubit` (existing) handles post-signin redirect via Firestore profile state — unchanged.

**Tech Stack:** Flutter, `firebase_auth: ^6.1.0`, `flutter_bloc: ^9.1.1`, `injectable: ^2.5.2`, `get_it: ^8.2.0`, `mocktail` (added for tests).

**Spec:** `docs/superpowers/specs/2026-05-07-phone-auth-design.md`

---

## File Map

### Created
- `lib/domain/repositories/phone_auth/i_phone_auth.dart` — interface + sealed result/error types.
- `lib/data/repositories/phone_auth/firebase_phone_auth_repository.dart` — Firebase implementation, registered as `@Singleton(as: IPhoneAuth)`.
- `lib/bloc/phone_auth/phone_auth_bloc.dart` — orchestrates send/verify/resend.
- `lib/bloc/phone_auth/phone_auth_event.dart` — event classes (part of bloc).
- `lib/bloc/phone_auth/phone_auth_state.dart` — state classes (part of bloc).
- `test/data/repositories/phone_auth/firebase_phone_auth_repository_test.dart`
- `test/bloc/phone_auth/phone_auth_bloc_test.dart`

### Modified
- `lib/core/ui_kit/components/inputs/otp.dart` — 4 → 6 boxes, expose value via `onChanged(String)` callback.
- `lib/presentation/sign_up/phone_registration/phone_registration_page.dart` — wire to `PhoneAuthBloc`.
- `lib/presentation/sign_up/otp/otp_page.dart` — wire to `PhoneAuthBloc`, accept phone via go_router extra.
- `lib/presentation/router/app_route.dart` — drop `EmailAndPassword` route, drop email tag from `publicPaths`/`authPages`.
- `lib/main.dart` — drop `SignUpAndSingInBloc` provider, add `PhoneAuthBloc` provider scoped to phone-registration sub-tree.
- `lib/core/localization/i18n/ru.i18n.json` — update OTP texts (4-digit → 6-digit) + add error keys.
- `lib/core/localization/i18n/uz.i18n.json` — same.
- `pubspec.yaml` — add `mocktail` to `dev_dependencies`.

### Deleted
- `lib/presentation/sign_up/email_and_password/email_and_password.dart`
- `lib/data/repositories/sign_in/sign_in_repository.dart`
- `lib/domain/repositories/sign_in/i_sign_in.dart`
- `lib/domain/usecases/sign_in_usecase.dart`
- `lib/bloc/sign_up_and_sing_in/sign_up_and_sing_in_bloc.dart`
- `lib/bloc/sign_up_and_sing_in/sign_up_and_sing_in_event.dart`
- `lib/bloc/sign_up_and_sing_in/sign_up_and_sing_in_state.dart`

### Auto-regenerated
- `lib/core/di/di.config.dart` (via `dart run build_runner build`)

---

## Task 1: Add mocktail dev dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add mocktail under dev_dependencies**

In `pubspec.yaml`, locate the `dev_dependencies:` block (around line 40). Add `mocktail: ^1.0.4` so the block becomes:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^5.0.0
  build_runner: ^2.8.0
  slang_build_runner: ^4.8.0
  injectable_generator: ^2.9.0
  mocktail: ^1.0.4
```

- [ ] **Step 2: Install**

Run: `flutter pub get`
Expected output: ends with `Got dependencies!`

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add mocktail for unit testing"
```

---

## Task 2: Define IPhoneAuth domain interface

**Files:**
- Create: `lib/domain/repositories/phone_auth/i_phone_auth.dart`

- [ ] **Step 1: Create the interface file**

Create `lib/domain/repositories/phone_auth/i_phone_auth.dart` with the following content:

```dart
import 'package:firebase_auth/firebase_auth.dart';

enum PhoneAuthError {
  invalidPhone,
  tooManyRequests,
  quotaExceeded,
  networkError,
  invalidCode,
  codeExpired,
  unknown,
}

sealed class PhoneAuthSendResult {
  const PhoneAuthSendResult();
}

class PhoneAuthCodeSent extends PhoneAuthSendResult {
  final String verificationId;
  final int? forceResendingToken;
  const PhoneAuthCodeSent({
    required this.verificationId,
    this.forceResendingToken,
  });
}

/// Android-only: SMS auto-retrieval signed the user in immediately.
class PhoneAuthAutoVerified extends PhoneAuthSendResult {
  final UserCredential credential;
  const PhoneAuthAutoVerified(this.credential);
}

class PhoneAuthSendFailed extends PhoneAuthSendResult {
  final PhoneAuthError error;
  final String? rawCode;
  const PhoneAuthSendFailed(this.error, {this.rawCode});
}

abstract class IPhoneAuth {
  /// Sends an SMS OTP to [phoneE164] (e.g. "+998946914977").
  Future<PhoneAuthSendResult> sendCode(String phoneE164);

  /// Resends OTP using a [forceResendingToken] from a previous [PhoneAuthCodeSent].
  Future<PhoneAuthSendResult> resendCode(
    String phoneE164,
    int forceResendingToken,
  );

  /// Verifies [smsCode] against [verificationId] and signs the user in.
  /// Throws [PhoneAuthException] on failure.
  Future<UserCredential> verifyCode({
    required String verificationId,
    required String smsCode,
  });
}

class PhoneAuthException implements Exception {
  final PhoneAuthError error;
  final String? rawCode;
  PhoneAuthException(this.error, {this.rawCode});

  @override
  String toString() => 'PhoneAuthException($error, raw=$rawCode)';
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/domain/repositories/phone_auth/`
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/domain/repositories/phone_auth/i_phone_auth.dart
git commit -m "feat(domain): add IPhoneAuth interface"
```

---

## Task 3: Implement FirebasePhoneAuthRepository (TDD)

**Files:**
- Create: `test/data/repositories/phone_auth/firebase_phone_auth_repository_test.dart`
- Create: `lib/data/repositories/phone_auth/firebase_phone_auth_repository.dart`

- [ ] **Step 1: Write failing tests**

Create `test/data/repositories/phone_auth/firebase_phone_auth_repository_test.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usta_book/data/repositories/phone_auth/firebase_phone_auth_repository.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}
class _MockUserCredential extends Mock implements UserCredential {}
class _FakePhoneAuthCredential extends Fake implements PhoneAuthCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late FirebasePhoneAuthRepository repo;

  setUpAll(() {
    registerFallbackValue(_FakePhoneAuthCredential());
  });

  setUp(() {
    auth = _MockFirebaseAuth();
    repo = FirebasePhoneAuthRepository(auth);
  });

  group('sendCode', () {
    test('returns PhoneAuthCodeSent when codeSent fires', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final codeSent = invocation.namedArguments[#codeSent]
            as void Function(String, int?);
        codeSent('VID-123', 42);
      });

      final result = await repo.sendCode('+998946914977');
      expect(result, isA<PhoneAuthCodeSent>());
      final r = result as PhoneAuthCodeSent;
      expect(r.verificationId, 'VID-123');
      expect(r.forceResendingToken, 42);
    });

    test('returns PhoneAuthSendFailed with invalidPhone on invalid-phone-number',
        () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final failed = invocation.namedArguments[#verificationFailed]
            as void Function(FirebaseAuthException);
        failed(FirebaseAuthException(code: 'invalid-phone-number'));
      });

      final result = await repo.sendCode('bad');
      expect(result, isA<PhoneAuthSendFailed>());
      expect((result as PhoneAuthSendFailed).error, PhoneAuthError.invalidPhone);
    });

    test('maps too-many-requests to tooManyRequests', () async {
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
        ),
      ).thenAnswer((invocation) async {
        final failed = invocation.namedArguments[#verificationFailed]
            as void Function(FirebaseAuthException);
        failed(FirebaseAuthException(code: 'too-many-requests'));
      });

      final result = await repo.sendCode('+998946914977');
      expect((result as PhoneAuthSendFailed).error,
          PhoneAuthError.tooManyRequests);
    });
  });

  group('verifyCode', () {
    test('returns UserCredential on success', () async {
      final cred = _MockUserCredential();
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => cred);

      final result = await repo.verifyCode(
        verificationId: 'VID-123',
        smsCode: '123456',
      );
      expect(result, same(cred));
    });

    test('throws PhoneAuthException(invalidCode) on invalid-verification-code',
        () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'invalid-verification-code'),
      );

      expect(
        () => repo.verifyCode(verificationId: 'VID', smsCode: '000000'),
        throwsA(
          isA<PhoneAuthException>().having(
            (e) => e.error,
            'error',
            PhoneAuthError.invalidCode,
          ),
        ),
      );
    });

    test('throws PhoneAuthException(codeExpired) on session-expired', () async {
      when(() => auth.signInWithCredential(any())).thenThrow(
        FirebaseAuthException(code: 'session-expired'),
      );

      expect(
        () => repo.verifyCode(verificationId: 'VID', smsCode: '000000'),
        throwsA(
          isA<PhoneAuthException>().having(
            (e) => e.error,
            'error',
            PhoneAuthError.codeExpired,
          ),
        ),
      );
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/data/repositories/phone_auth/firebase_phone_auth_repository_test.dart`
Expected: fails with "Target of URI doesn't exist: 'package:usta_book/data/repositories/phone_auth/firebase_phone_auth_repository.dart'"

- [ ] **Step 3: Implement the repository**

Create `lib/data/repositories/phone_auth/firebase_phone_auth_repository.dart`:

```dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

@Singleton(as: IPhoneAuth)
class FirebasePhoneAuthRepository implements IPhoneAuth {
  final FirebaseAuth _auth;
  FirebasePhoneAuthRepository(this._auth);

  @override
  Future<PhoneAuthSendResult> sendCode(String phoneE164) =>
      _send(phoneE164, null);

  @override
  Future<PhoneAuthSendResult> resendCode(
    String phoneE164,
    int forceResendingToken,
  ) =>
      _send(phoneE164, forceResendingToken);

  Future<PhoneAuthSendResult> _send(String phoneE164, int? token) {
    final completer = Completer<PhoneAuthSendResult>();

    _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      forceResendingToken: token,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (completer.isCompleted) return;
        try {
          final user = await _auth.signInWithCredential(credential);
          completer.complete(PhoneAuthAutoVerified(user));
        } catch (e) {
          completer.complete(
            const PhoneAuthSendFailed(PhoneAuthError.unknown),
          );
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneAuthSendFailed(_mapSendError(e.code), rawCode: e.code),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        if (completer.isCompleted) return;
        completer.complete(
          PhoneAuthCodeSent(
            verificationId: verificationId,
            forceResendingToken: resendToken,
          ),
        );
      },
      codeAutoRetrievalTimeout: (_) {},
    );

    return completer.future;
  }

  @override
  Future<UserCredential> verifyCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw PhoneAuthException(_mapVerifyError(e.code), rawCode: e.code);
    }
  }

  PhoneAuthError _mapSendError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return PhoneAuthError.invalidPhone;
      case 'too-many-requests':
        return PhoneAuthError.tooManyRequests;
      case 'quota-exceeded':
        return PhoneAuthError.quotaExceeded;
      case 'network-request-failed':
        return PhoneAuthError.networkError;
      default:
        return PhoneAuthError.unknown;
    }
  }

  PhoneAuthError _mapVerifyError(String code) {
    switch (code) {
      case 'invalid-verification-code':
        return PhoneAuthError.invalidCode;
      case 'session-expired':
        return PhoneAuthError.codeExpired;
      case 'network-request-failed':
        return PhoneAuthError.networkError;
      case 'too-many-requests':
        return PhoneAuthError.tooManyRequests;
      default:
        return PhoneAuthError.unknown;
    }
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/data/repositories/phone_auth/firebase_phone_auth_repository_test.dart`
Expected: All 5 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/data/repositories/phone_auth/ test/data/repositories/phone_auth/
git commit -m "feat(data): FirebasePhoneAuthRepository with tests"
```

---

## Task 4: Add PhoneAuthBloc (TDD)

**Files:**
- Create: `lib/bloc/phone_auth/phone_auth_event.dart`
- Create: `lib/bloc/phone_auth/phone_auth_state.dart`
- Create: `lib/bloc/phone_auth/phone_auth_bloc.dart`
- Create: `test/bloc/phone_auth/phone_auth_bloc_test.dart`

- [ ] **Step 1: Write failing tests**

Create `test/bloc/phone_auth/phone_auth_bloc_test.dart`:

```dart
import 'package:bloc_test/bloc_test.dart' show MockBloc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class _MockPhoneAuth extends Mock implements IPhoneAuth {}
class _MockSharedPref extends Mock implements ShredPrefService {}
class _MockUserCredential extends Mock implements UserCredential {}
class _MockUser extends Mock implements User {}

void main() {
  late _MockPhoneAuth phoneAuth;
  late _MockSharedPref prefs;

  setUp(() {
    phoneAuth = _MockPhoneAuth();
    prefs = _MockSharedPref();
  });

  PhoneAuthBloc build() => PhoneAuthBloc(phoneAuth, prefs);

  group('SubmitPhone', () {
    test('emits SendingCode then CodeSent on success', () async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-1',
          forceResendingToken: 7,
        ),
      );
      final bloc = build();
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(states.first, isA<PhoneAuthSendingCode>());
      expect(states.last, isA<PhoneAuthCodeSentState>());
      final sent = states.last as PhoneAuthCodeSentState;
      expect(sent.verificationId, 'VID-1');
      expect(sent.phone, '+998946914977');
      expect(sent.forceResendingToken, 7);
    });

    test('emits SendingCode then Failure on send failure', () async {
      when(() => phoneAuth.sendCode('+998946914977')).thenAnswer(
        (_) async => const PhoneAuthSendFailed(PhoneAuthError.networkError),
      );
      final bloc = build();
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitPhone('+998946914977'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<PhoneAuthFailure>());
      expect((states.last as PhoneAuthFailure).error,
          PhoneAuthError.networkError);
    });
  });

  group('SubmitOtp', () {
    test('emits Verifying then Success and writes UID to prefs', () async {
      final cred = _MockUserCredential();
      final user = _MockUser();
      when(() => cred.user).thenReturn(user);
      when(() => user.uid).thenReturn('uid-xyz');
      when(() => phoneAuth.verifyCode(
            verificationId: 'VID-1',
            smsCode: '123456',
          )).thenAnswer((_) async => cred);
      when(() => prefs.setMasterUID(masterUID: 'uid-xyz'))
          .thenAnswer((_) async {});

      final bloc = build();
      // Seed state: code already sent
      bloc.emit(const PhoneAuthCodeSentState(
        verificationId: 'VID-1',
        phone: '+998946914977',
        forceResendingToken: 7,
      ));
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitOtp('123456'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(states.first, isA<PhoneAuthVerifying>());
      expect(states.last, isA<PhoneAuthSuccess>());
      verify(() => prefs.setMasterUID(masterUID: 'uid-xyz')).called(1);
    });

    test('emits Failure(invalidCode) when verifyCode throws', () async {
      when(() => phoneAuth.verifyCode(
            verificationId: 'VID-1',
            smsCode: '000000',
          )).thenThrow(PhoneAuthException(PhoneAuthError.invalidCode));

      final bloc = build();
      bloc.emit(const PhoneAuthCodeSentState(
        verificationId: 'VID-1',
        phone: '+998946914977',
        forceResendingToken: null,
      ));
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthSubmitOtp('000000'));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // Failure must preserve verificationId so user can retry typing
      expect(states.last, isA<PhoneAuthCodeSentState>());
      // Failure transient through a Failure state in between
      expect(states.any((s) => s is PhoneAuthFailure), isTrue);
    });
  });

  group('Resend', () {
    test('uses resendCode with token from current state', () async {
      when(() => phoneAuth.resendCode('+998946914977', 7)).thenAnswer(
        (_) async => const PhoneAuthCodeSent(
          verificationId: 'VID-2',
          forceResendingToken: 8,
        ),
      );

      final bloc = build();
      bloc.emit(const PhoneAuthCodeSentState(
        verificationId: 'VID-1',
        phone: '+998946914977',
        forceResendingToken: 7,
      ));
      final states = <PhoneAuthState>[];
      bloc.stream.listen(states.add);

      bloc.add(const PhoneAuthResend());
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(states.last, isA<PhoneAuthCodeSentState>());
      final sent = states.last as PhoneAuthCodeSentState;
      expect(sent.verificationId, 'VID-2');
      expect(sent.forceResendingToken, 8);
      verify(() => phoneAuth.resendCode('+998946914977', 7)).called(1);
    });
  });
}
```

Note: this plan does NOT use `bloc_test`'s `blocTest()` matcher; we use raw `stream.listen` to keep dependencies minimal. The `bloc_test` import line above is unused — REMOVE it before saving the file. (Kept here just to remind: do not pull `bloc_test` into the project.)

Apply this fix when you create the file: drop the line `import 'package:bloc_test/bloc_test.dart' show MockBloc;`.

- [ ] **Step 2: Create event file**

Create `lib/bloc/phone_auth/phone_auth_event.dart`:

```dart
part of 'phone_auth_bloc.dart';

sealed class PhoneAuthEvent {
  const PhoneAuthEvent();
}

class PhoneAuthSubmitPhone extends PhoneAuthEvent {
  final String phoneE164;
  const PhoneAuthSubmitPhone(this.phoneE164);
}

class PhoneAuthSubmitOtp extends PhoneAuthEvent {
  final String code;
  const PhoneAuthSubmitOtp(this.code);
}

class PhoneAuthResend extends PhoneAuthEvent {
  const PhoneAuthResend();
}
```

- [ ] **Step 3: Create state file**

Create `lib/bloc/phone_auth/phone_auth_state.dart`:

```dart
part of 'phone_auth_bloc.dart';

sealed class PhoneAuthState {
  const PhoneAuthState();
}

class PhoneAuthIdle extends PhoneAuthState {
  const PhoneAuthIdle();
}

class PhoneAuthSendingCode extends PhoneAuthState {
  final String phone;
  const PhoneAuthSendingCode(this.phone);
}

class PhoneAuthCodeSentState extends PhoneAuthState {
  final String verificationId;
  final String phone;
  final int? forceResendingToken;
  const PhoneAuthCodeSentState({
    required this.verificationId,
    required this.phone,
    required this.forceResendingToken,
  });
}

class PhoneAuthVerifying extends PhoneAuthState {
  const PhoneAuthVerifying();
}

class PhoneAuthSuccess extends PhoneAuthState {
  const PhoneAuthSuccess();
}

class PhoneAuthFailure extends PhoneAuthState {
  final PhoneAuthError error;
  const PhoneAuthFailure(this.error);
}
```

- [ ] **Step 4: Create bloc file**

Create `lib/bloc/phone_auth/phone_auth_bloc.dart`:

```dart
import 'package:bloc/bloc.dart';
import 'package:usta_book/data/sources/local/shared_pref.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

part 'phone_auth_event.dart';
part 'phone_auth_state.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final IPhoneAuth _phoneAuth;
  final ShredPrefService _prefs;

  PhoneAuthBloc(this._phoneAuth, this._prefs) : super(const PhoneAuthIdle()) {
    on<PhoneAuthSubmitPhone>(_onSubmitPhone);
    on<PhoneAuthSubmitOtp>(_onSubmitOtp);
    on<PhoneAuthResend>(_onResend);
  }

  Future<void> _onSubmitPhone(
    PhoneAuthSubmitPhone event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(PhoneAuthSendingCode(event.phoneE164));
    final result = await _phoneAuth.sendCode(event.phoneE164);
    _handleSendResult(result, event.phoneE164, emit);
  }

  Future<void> _onResend(
    PhoneAuthResend event,
    Emitter<PhoneAuthState> emit,
  ) async {
    final s = state;
    if (s is! PhoneAuthCodeSentState) return;
    emit(PhoneAuthSendingCode(s.phone));
    final result = s.forceResendingToken != null
        ? await _phoneAuth.resendCode(s.phone, s.forceResendingToken!)
        : await _phoneAuth.sendCode(s.phone);
    _handleSendResult(result, s.phone, emit);
  }

  void _handleSendResult(
    PhoneAuthSendResult result,
    String phone,
    Emitter<PhoneAuthState> emit,
  ) {
    switch (result) {
      case PhoneAuthCodeSent(:final verificationId, :final forceResendingToken):
        emit(PhoneAuthCodeSentState(
          verificationId: verificationId,
          phone: phone,
          forceResendingToken: forceResendingToken,
        ));
      case PhoneAuthAutoVerified(:final credential):
        final uid = credential.user?.uid;
        if (uid != null) {
          _prefs.setMasterUID(masterUID: uid);
        }
        emit(const PhoneAuthSuccess());
      case PhoneAuthSendFailed(:final error):
        emit(PhoneAuthFailure(error));
    }
  }

  Future<void> _onSubmitOtp(
    PhoneAuthSubmitOtp event,
    Emitter<PhoneAuthState> emit,
  ) async {
    final s = state;
    if (s is! PhoneAuthCodeSentState) return;
    emit(const PhoneAuthVerifying());
    try {
      final cred = await _phoneAuth.verifyCode(
        verificationId: s.verificationId,
        smsCode: event.code,
      );
      final uid = cred.user?.uid;
      if (uid != null) {
        await _prefs.setMasterUID(masterUID: uid);
      }
      emit(const PhoneAuthSuccess());
    } on PhoneAuthException catch (e) {
      // Surface the error then return to CodeSent so the user can retry typing.
      emit(PhoneAuthFailure(e.error));
      emit(s);
    }
  }
}
```

- [ ] **Step 5: Run tests to verify they pass**

Run: `flutter test test/bloc/phone_auth/`
Expected: All 5 tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/bloc/phone_auth/ test/bloc/phone_auth/
git commit -m "feat(bloc): PhoneAuthBloc with tests"
```

---

## Task 5: Update OtpInput widget to 6 boxes with onChanged callback

**Files:**
- Modify: `lib/core/ui_kit/components/inputs/otp.dart`

The current widget has 4 hardcoded boxes and no way to read the combined value. Replace it with a 6-box version that reports value changes upward.

- [ ] **Step 1: Replace the file contents**

Open `lib/core/ui_kit/components/inputs/otp.dart` and replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;

  /// Increment to clear all fields (e.g. after invalid code).
  final int clearSignal;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.clearSignal = 0,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant OtpInput old) {
    super.didUpdateWidget(old);
    if (old.clearSignal != widget.clearSignal) {
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      widget.onChanged('');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(widget.length, (i) {
        final isFirst = i == 0;
        final isLast = i == widget.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirst ? 0 : 6,
              right: isLast ? 0 : 6,
            ),
            child: SizedBox(
              height: 64,
              child: TextFormField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [LengthLimitingTextInputFormatter(1)],
                onChanged: (value) {
                  if (value.isNotEmpty && !isLast) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (value.isEmpty && !isFirst) {
                    _focusNodes[i - 1].requestFocus();
                  } else if (value.isNotEmpty && isLast) {
                    _focusNodes[i].unfocus();
                  }
                  _emit();
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `flutter analyze lib/core/ui_kit/components/inputs/otp.dart`
Expected: no issues.

- [ ] **Step 3: Commit**

```bash
git add lib/core/ui_kit/components/inputs/otp.dart
git commit -m "refactor(ui): OtpInput 6 boxes with onChanged + clearSignal"
```

---

## Task 6: Update phone_registration_page to drive PhoneAuthBloc

**Files:**
- Modify: `lib/presentation/sign_up/phone_registration/phone_registration_page.dart`

- [ ] **Step 1: Replace the file contents**

Open `lib/presentation/sign_up/phone_registration/phone_registration_page.dart` and replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/inputs.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';

class PhoneRegistrationPage extends StatefulWidget {
  const PhoneRegistrationPage({super.key});

  static const String tag = '/phone-registration-page';

  @override
  State<PhoneRegistrationPage> createState() => _PhoneRegistrationPageState();
}

class _PhoneRegistrationPageState extends State<PhoneRegistrationPage> {
  final TextEditingController _controller = TextEditingController();

  String _toE164(String masked) {
    final digits = masked.replaceAll(RegExp(r'[^0-9]'), '');
    return '+$digits';
  }

  bool _isComplete(String masked) {
    // Mask is "+### (##) ###-##-##" → 12 digits when fully entered.
    return masked.replaceAll(RegExp(r'[^0-9]'), '').length == 12;
  }

  void _submit() {
    final text = _controller.text;
    if (!_isComplete(text)) return;
    context.read<PhoneAuthBloc>().add(
          PhoneAuthSubmitPhone(_toE164(text)),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      body: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
        listenWhen: (prev, curr) =>
            curr is PhoneAuthCodeSentState || curr is PhoneAuthFailure,
        listener: (context, state) {
          if (state is PhoneAuthCodeSentState) {
            context.pushNamed(OtpPage.tag, extra: state.phone);
          } else if (state is PhoneAuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorText(tr, state.error))),
            );
          }
        },
        builder: (context, state) {
          final loading = state is PhoneAuthSendingCode;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).viewPadding.top + 20),
                Text(tr.sign_up.welcome, style: Typographies.boldH1),
                const SizedBox(height: 8),
                Text(tr.sign_up.welcome_desc, style: Typographies.regularBody),
                const SizedBox(height: 36),
                InputField.phone(
                  fieldTitle: tr.input_field.phone_field,
                  controller: _controller,
                ),
                const SizedBox(height: 36),
                MainButton.primary(
                  title: tr.buttons.send_code_phone_number,
                  onTap: loading ? () {} : _submit,
                ),
                const Spacer(),
                Text(
                  tr.sign_up.user_privacy,
                  style: Typographies.regularBody,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
              ],
            ),
          );
        },
      ),
    );
  }

  String _errorText(Translations tr, PhoneAuthError e) {
    switch (e) {
      case PhoneAuthError.invalidPhone:
        return tr.sign_up.errors.invalid_phone;
      case PhoneAuthError.tooManyRequests:
        return tr.sign_up.errors.too_many_requests;
      case PhoneAuthError.networkError:
        return tr.sign_up.errors.network;
      case PhoneAuthError.quotaExceeded:
      case PhoneAuthError.unknown:
      case PhoneAuthError.invalidCode:
      case PhoneAuthError.codeExpired:
        return tr.sign_up.errors.unknown;
    }
  }
}
```

- [ ] **Step 2: Skip compile check (depends on i18n keys added in Task 9; no commit yet)**

We will compile and commit after Task 9 adds the localization keys.

---

## Task 7: Update otp_page to drive PhoneAuthBloc

**Files:**
- Modify: `lib/presentation/sign_up/otp/otp_page.dart`

- [ ] **Step 1: Replace the file contents**

Open `lib/presentation/sign_up/otp/otp_page.dart` and replace with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/components/inputs/otp.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/domain/repositories/phone_auth/i_phone_auth.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key, required this.phone});
  final String phone;

  static const String tag = '/otp-page';

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _code = '';
  int _clearSignal = 0;
  int _resendKey = 0;

  void _confirm() {
    if (_code.length != 6) return;
    context.read<PhoneAuthBloc>().add(PhoneAuthSubmitOtp(_code));
  }

  void _resend() {
    setState(() => _resendKey++);
    context.read<PhoneAuthBloc>().add(const PhoneAuthResend());
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(tr.sign_up.back, style: Typographies.regularBody),
      ),
      body: BlocListener<PhoneAuthBloc, PhoneAuthState>(
        listener: (context, state) {
          if (state is PhoneAuthFailure) {
            setState(() => _clearSignal++);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_errorText(tr, state.error))),
            );
          }
          // PhoneAuthSuccess → AuthCubit transitions, router redirects.
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              Text(tr.sign_up.welcome, style: Typographies.boldH1),
              const SizedBox(height: 8),
              Text(
                tr.sign_up.enter_otp_code(phone: widget.phone),
                style: Typographies.regularBody,
              ),
              const SizedBox(height: 36),
              OtpInput(
                clearSignal: _clearSignal,
                onChanged: (v) => setState(() => _code = v),
              ),
              const SizedBox(height: 12),
              OtpTimerWidget(
                key: ValueKey(_resendKey),
                seconds: 60,
                onResend: _resend,
              ),
              const SizedBox(height: 36),
              BlocBuilder<PhoneAuthBloc, PhoneAuthState>(
                builder: (context, state) {
                  final verifying = state is PhoneAuthVerifying;
                  return MainButton.primary(
                    title: tr.buttons.confirm_and_continue,
                    onTap: verifying ? () {} : _confirm,
                  );
                },
              ),
              const Spacer(),
              Text(
                tr.sign_up.user_privacy,
                style: Typographies.regularBody,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  String _errorText(Translations tr, PhoneAuthError e) {
    switch (e) {
      case PhoneAuthError.invalidCode:
        return tr.sign_up.errors.invalid_code;
      case PhoneAuthError.codeExpired:
        return tr.sign_up.errors.code_expired;
      case PhoneAuthError.networkError:
        return tr.sign_up.errors.network;
      case PhoneAuthError.tooManyRequests:
        return tr.sign_up.errors.too_many_requests;
      case PhoneAuthError.invalidPhone:
      case PhoneAuthError.quotaExceeded:
      case PhoneAuthError.unknown:
        return tr.sign_up.errors.unknown;
    }
  }
}

/// Countdown widget. After expiry, shows a "Resend" tappable.
class OtpTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback onResend;

  const OtpTimerWidget({
    super.key,
    this.seconds = 60,
    required this.onResend,
  });

  @override
  State<OtpTimerWidget> createState() => _OtpTimerWidgetState();
}

class _OtpTimerWidgetState extends State<OtpTimerWidget> {
  late int _remaining = widget.seconds;
  late final Stream<int> _stream = _countdown(widget.seconds);

  Stream<int> _countdown(int from) async* {
    for (int i = from; i >= 0; i--) {
      yield i;
      if (i > 0) await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    return StreamBuilder<int>(
      stream: _stream,
      initialData: _remaining,
      builder: (context, snap) {
        final r = snap.data ?? 0;
        if (r == 0) {
          return Center(
            child: TextButton(
              onPressed: widget.onResend,
              child: Text(tr.sign_up.resend),
            ),
          );
        }
        final mm = (r ~/ 60).toString().padLeft(2, '0');
        final ss = (r % 60).toString().padLeft(2, '0');
        return Center(
          child: Text(
            tr.sign_up.timer(time: '$mm:$ss'),
            style: Typographies.regularBody2,
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Skip compile check (depends on i18n keys added in Task 9; no commit yet)**

We will compile and commit after Task 9 adds the localization keys.

---

## Task 8: Update router and main.dart

**Files:**
- Modify: `lib/presentation/router/app_route.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Edit `lib/presentation/router/app_route.dart`**

Replace the entire file with:

```dart
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/auth/auth_cubit.dart';
import 'package:usta_book/data/models/client_model.dart';
import 'package:usta_book/presentation/add_new_record/add_new_record_page.dart';
import 'package:usta_book/presentation/clients/clients_list_page.dart';
import 'package:usta_book/presentation/home/home_page.dart';
import 'package:usta_book/presentation/onboarding/choose_language/choose_language.dart';
import 'package:usta_book/presentation/sign_up/otp/otp_page.dart';
import 'package:usta_book/presentation/sign_up/phone_registration/phone_registration_page.dart';
import 'package:usta_book/presentation/sign_up/profile_settings/profile_settings.dart';

import '../bottom_nav_bar/bottom_nav_bar.dart';
import '../clients/add_new_appointment_page.dart';
import '../onboarding/allow_notifications/allow_notifications.dart';
import '../onboarding/complete_onboarding/complete_onboarding_page.dart';
import '../splash/splash_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRoute {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: SplashScreen.tag,
      debugLogDiagnostics: kDebugMode,
      overridePlatformDefaultLocation: true,
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final String targetPath = state.matchedLocation;

        if (kDebugMode) {
          print('Redirect: $authState, Path: $targetPath');
        }

        if (authState is AuthUnknown) {
          return targetPath == SplashScreen.tag ? null : SplashScreen.tag;
        }

        if (authState is AuthUnauthenticated) {
          final publicPaths = [
            ChooseLanguage.tag,
            PhoneRegistrationPage.tag,
            AllowNotifications.tag,
            CompleteOnboardingPage.tag,
          ];
          final isOnPublicPage = publicPaths.contains(targetPath) ||
              targetPath.contains(OtpPage.tag.replaceAll('/', ''));
          if (!isOnPublicPage) return ChooseLanguage.tag;
          return null;
        }

        if (authState is AuthProfileIncomplete) {
          final isRegistrationStep =
              targetPath.startsWith(PhoneRegistrationPage.tag) ||
                  targetPath.startsWith(ProfileSettings.tag) ||
                  targetPath.contains(OtpPage.tag.replaceAll('/', ''));
          if (!isRegistrationStep) return ProfileSettings.tag;
          return null;
        }

        if (authState is AuthAuthenticated) {
          final authPages = [ChooseLanguage.tag, SplashScreen.tag];
          if (authPages.contains(targetPath)) return MainHomeScreen.tag;
          return null;
        }

        return null;
      },
      routes: [
        GoRoute(path: ClientsListPage.tag, name: ClientsListPage.tag, builder: (_, __) => ClientsListPage()),
        GoRoute(
          path: AddNewAppointmentPage.tag,
          name: AddNewAppointmentPage.tag,
          builder: (_, state) => AddNewAppointmentPage(record: state.extra as ClientModel),
        ),
        GoRoute(path: MainHomeScreen.tag, name: MainHomeScreen.tag, builder: (_, __) => MainHomeScreen()),
        GoRoute(path: AddNewRecordPage.tag, name: AddNewRecordPage.tag, builder: (_, __) => AddNewRecordPage()),
        GoRoute(path: HomePage.tag, name: HomePage.tag, builder: (_, __) => HomePage()),
        GoRoute(path: SplashScreen.tag, name: SplashScreen.tag, builder: (_, __) => const SplashScreen()),
        GoRoute(path: ChooseLanguage.tag, name: ChooseLanguage.tag, builder: (_, __) => ChooseLanguage()),
        GoRoute(path: AllowNotifications.tag, name: AllowNotifications.tag, builder: (_, __) => AllowNotifications()),
        GoRoute(
          path: CompleteOnboardingPage.tag,
          name: CompleteOnboardingPage.tag,
          builder: (_, __) => CompleteOnboardingPage(),
        ),
        GoRoute(path: ProfileSettings.tag, name: ProfileSettings.tag, builder: (_, __) => ProfileSettings()),
        GoRoute(
          path: PhoneRegistrationPage.tag,
          name: PhoneRegistrationPage.tag,
          builder: (_, __) => PhoneRegistrationPage(),
          routes: [
            GoRoute(
              path: OtpPage.tag.replaceAll('/', ''),
              name: OtpPage.tag,
              builder: (_, state) => OtpPage(phone: state.extra as String),
            ),
          ],
        ),
      ],
    );
  }
}
```

Changes from existing version: removed the `EmailAndPassword` import, removed it from `publicPaths`, removed it from `authPages`, removed its `GoRoute`, and updated the OTP route builder to receive `phone: state.extra as String`.

- [ ] **Step 2: Edit `lib/main.dart`**

Apply two edits to `lib/main.dart`:

(a) Remove this line near the top of the file:
```dart
import 'bloc/sign_up_and_sing_in/sign_up_and_sing_in_bloc.dart';
```

(b) Replace the `MultiBlocProvider` `providers` list inside `_MyAppState.build`. The current list contains:
```dart
BlocProvider(create: (context) => SignUpAndSingInBloc(inject(), inject())),
```
Remove that line. Add a `PhoneAuthBloc` provider in its place. The block becomes:
```dart
providers: [
  BlocProvider(create: (context) => PhoneAuthBloc(inject(), inject())),
  BlocProvider(create: (context) => MasterBloc(inject(), inject())),
  BlocProvider(create: (context) => ScheduleCubit(inject(), inject())),
  BlocProvider(create: (context) => ClientsBloc(inject(), inject())..add(GetClientsEvent())),
  BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
  BlocProvider<ProfileCubit>(create: (context) => ProfileCubit()),
],
```

Add the import at the top:
```dart
import 'bloc/phone_auth/phone_auth_bloc.dart';
```

- [ ] **Step 3: No compile check yet — depends on Task 9 (i18n) and Task 10 (DI regen).**

---

## Task 9: Update localizations

**Files:**
- Modify: `lib/core/localization/i18n/ru.i18n.json`
- Modify: `lib/core/localization/i18n/uz.i18n.json`

- [ ] **Step 1: Edit `ru.i18n.json`**

Inside the `"sign_up"` block:
- Change `"enter_otp_code": "Введите 4-значный код, отправленный на номер $phone."` to `"enter_otp_code": "Введите 6-значный код, отправленный на номер $phone."`
- After the existing `"timer"` entry, add:

```json
"resend": "Отправить повторно",
"errors": {
  "invalid_phone": "Неверный номер",
  "too_many_requests": "Слишком много попыток, попробуйте позже",
  "invalid_code": "Неверный код",
  "code_expired": "Срок действия кода истёк",
  "network": "Нет подключения к интернету",
  "unknown": "Произошла ошибка"
}
```

(JSON requires a trailing comma on the prior line; ensure the file remains valid JSON.)

- [ ] **Step 2: Edit `uz.i18n.json`**

Inside `"sign_up"`:
- Change `"enter_otp_code": "$phone raqamiga yuborilgan 4 xonali kodni kiriting."` to `"enter_otp_code": "$phone raqamiga yuborilgan 6 xonali kodni kiriting."`
- After the existing `"timer"` entry, add:

```json
"resend": "Qayta yuborish",
"errors": {
  "invalid_phone": "Telefon raqami noto'g'ri",
  "too_many_requests": "Juda ko'p urinish, keyinroq qayta urining",
  "invalid_code": "Kod noto'g'ri",
  "code_expired": "Kod muddati tugagan",
  "network": "Internet ulanishi yo'q",
  "unknown": "Xatolik yuz berdi"
}
```

- [ ] **Step 3: Regenerate slang strings**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes successfully, no errors. Files `lib/core/localization/i18n/strings*.g.dart` are updated.

- [ ] **Step 4: Commit**

```bash
git add lib/core/localization/i18n/ru.i18n.json lib/core/localization/i18n/uz.i18n.json lib/core/localization/i18n/strings*.g.dart
git commit -m "i18n: 6-digit OTP text + phone-auth error keys"
```

---

## Task 10: Delete dead code and regenerate DI

**Files:**
- Delete: see file list below
- Modify: `lib/core/di/di.config.dart` (auto)

- [ ] **Step 1: Delete email-auth files**

```bash
rm -rf lib/presentation/sign_up/email_and_password
rm -rf lib/data/repositories/sign_in
rm -rf lib/domain/repositories/sign_in
rm lib/domain/usecases/sign_in_usecase.dart
rm -rf lib/bloc/sign_up_and_sing_in
```

- [ ] **Step 2: Regenerate injectable config**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: completes successfully. `lib/core/di/di.config.dart` no longer references `SignInRepository`, `ISignIn`, `SignInUseCase` and now registers `FirebasePhoneAuthRepository` as `IPhoneAuth`.

- [ ] **Step 3: Run static analysis on the whole project**

Run: `flutter analyze`
Expected: zero errors. Warnings about unused imports in deleted files should not appear (files are gone).

If `flutter analyze` reports errors about missing types from the deleted files, search for stragglers:
```bash
grep -rn "SignInRepository\|SignUpAndSingInBloc\|SignInUseCase\|ISignIn\|EmailAndPassword" lib/
```
Remove any remaining references.

- [ ] **Step 4: Run all tests**

Run: `flutter test`
Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor: drop email auth, regenerate DI for IPhoneAuth"
```

---

## Task 11: End-to-end smoke test (manual)

These steps are manual and require Firebase Console access. They are NOT automated by the plan.

- [ ] **Step 1: Firebase Console → Authentication → Sign-in method**

- Enable **Phone**.
- Disable **Email/Password** (if currently enabled).

- [ ] **Step 2: Add test phone number**

Authentication → Sign-in method → Phone → "Phone numbers for testing" → add:
- Phone: `+998946914977`
- Code: `123456`

This bypasses real SMS quota during development.

- [ ] **Step 3: Delete the existing user and master document**

Authentication → Users → delete `cYodbRsZuwMO39DAHe92TJ6RKul2` (`nodirbarotov0707@gmail.com`).

Firestore → delete `masters/cYodbRsZuwMO39DAHe92TJ6RKul2` (recursive: this also wipes its `clients`, `appointments`, `fcmTokens` subcollections). Also delete top-level test docs:
- `notification_queue/uyLfz16xJ6w7XRvrYRBh`
- `push_queue/uyLfz16xJ6w7XRvrYRBh_1h`
- `push_queue/uyLfz16xJ6w7XRvrYRBh_15m`

- [ ] **Step 4: Verify Android SHA fingerprints**

Firebase Console → Project Settings → Your Android app (`1:481994759203:android:dbf842562356fc76bbe596`) → SHA certificate fingerprints. Both debug and release SHA-1/SHA-256 should be listed. If not, generate via:
```bash
cd android && ./gradlew signingReport
```
and paste each SHA into the console.

- [ ] **Step 5: Build and run on a device**

```bash
flutter run
```

In the app:
1. Choose language → onboarding → land on phone registration page.
2. Enter `+998946914977`. Tap "Send code".
3. OTP page appears. Enter `123456` (the test code).
4. Confirm. App transitions to `ProfileSettings` (because no master doc exists yet).
5. Complete profile. App transitions to `MainHomeScreen`.

Expected: full flow without consuming Firebase SMS quota.

- [ ] **Step 6: Real-number smoke test**

Sign out (if a logout path exists; otherwise reinstall). Repeat the flow with the developer's real phone number. Verify SMS arrives, OTP works, profile gets created.

---

## Self-Review

**Spec coverage (each spec section → task):**
- "Goals" → Tasks 1–10 (implementation), Task 11 (rollout test).
- "Architecture > Layering" → Tasks 2 (interface), 3 (data), 4 (bloc).
- "Architecture > Domain interface IPhoneAuth" → Task 2.
- "Architecture > Data implementation FirebasePhoneAuthRepository" → Task 3.
- "Architecture > BLoC PhoneAuthBloc" → Task 4.
- "Architecture > UI changes" → Tasks 5 (OtpInput), 6 (phone page), 7 (otp page).
- "Architecture > Routing" → Task 8.
- "Architecture > Code removals" → Task 10.
- "Architecture > Behavior preserved from email bloc" → Task 4 (bloc writes UID via prefs).
- "Firebase Console operations" → Task 11 steps 1–4.
- "Error handling" → Tasks 6 & 7 `_errorText`, Task 9 i18n keys.
- "Testing" → Tasks 3, 4 (unit), Task 11 (manual smoke).
- "Migration / rollout" → Task 11 step 3 (delete user/data) + steps 5–6.

**Type consistency check:**
- `PhoneAuthCodeSent` (domain result type) vs `PhoneAuthCodeSentState` (bloc state) — distinct names, both used consistently.
- `PhoneAuthError` is the single error enum used across data, bloc, and UI.
- `IPhoneAuth.verifyCode` returns `UserCredential` and throws `PhoneAuthException`; the bloc catches that exception only (not generic).
- `OtpInput` exposes `length`, `onChanged`, `clearSignal` — used consistently by `otp_page.dart`.
- Mask digit count: `+### (##) ###-##-##` → 12 digits (3+2+3+2+2). `_isComplete` checks for 12. Consistent.

**Placeholder scan:** None. Every code step shows complete code; every command shows expected output.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-07-phone-auth-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
