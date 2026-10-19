/// A request, complaint, claim, or suggestion written from the profile.
enum PqrsKind { petition, complaint, claim, suggestion }

class PqrsDraft {
  const PqrsDraft({required this.kind, required this.message, this.email});

  final PqrsKind kind;
  final String message;
  final String? email;
}

enum PqrsIssue { kind, messageEmpty, messageTooLong, email }

class PqrsCheck {
  const PqrsCheck(this.issues);

  final Set<PqrsIssue> issues;

  bool get ok => issues.isEmpty;

  bool has(PqrsIssue issue) => issues.contains(issue);
}

const pqrsMessageLimit = 2000;

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

PqrsCheck checkPqrs({
  required PqrsKind? kind,
  required String message,
  required String email,
}) {
  final issues = <PqrsIssue>{};
  if (kind == null) issues.add(PqrsIssue.kind);
  final text = message.trim();
  if (text.isEmpty) {
    issues.add(PqrsIssue.messageEmpty);
  } else if (text.length > pqrsMessageLimit) {
    issues.add(PqrsIssue.messageTooLong);
  }
  final address = email.trim();
  if (address.isNotEmpty && !_email.hasMatch(address)) {
    issues.add(PqrsIssue.email);
  }
  return PqrsCheck(issues);
}

PqrsDraft? draftFrom({
  required PqrsKind? kind,
  required String message,
  required String email,
}) {
  final check = checkPqrs(kind: kind, message: message, email: email);
  if (!check.ok || kind == null) return null;
  final address = email.trim();
  return PqrsDraft(
    kind: kind,
    message: message.trim(),
    email: address.isEmpty ? null : address,
  );
}

/// How a PQRS leaves the phone.
abstract class PqrsChannel {
  const PqrsChannel();

  Future<void> submit(PqrsDraft draft, {required String locale});
}

const pqrsCollection = 'pqrs';

/// Fields stored on a PQRS document, apart from the server timestamp.
Map<String, Object> pqrsFields(
  PqrsDraft draft, {
  required String platform,
  required String locale,
}) {
  return {
    'kind': draft.kind.name,
    'message': draft.message,
    'platform': platform,
    'locale': locale,
    if (draft.email != null) 'email': draft.email!,
  };
}
