import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue, Timestamp;
import 'package:iirc/domain.dart';

import '../../network/firebase/cloud_db.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../derive_date_from_timestamp.dart';

class UsersFirebaseImpl implements UsersRepository {
  UsersFirebaseImpl({required Firebase firebase}) : db = FireStoreDb(firebase.db.instance, collectionName);

  static const String collectionName = 'users';

  final FireStoreDb db;

  @override
  Future<String> create(AccountModel account) async {
    final List<String>? names = account.displayName?.split(' ');
    await db.fetchOne(account.id).set(<String, Object>{
      'email': account.email,
      'firstName': names?.first ?? '',
      'lastName': names != null && names.length > 1 ? names.sublist(1).join(' ') : '',
      'lastSeenAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return account.id;
  }

  @override
  Future<bool> update(UpdateUserData user) async {
    await db.fetchOne(user.id).update(<String, Object>{
      'lastSeenAt': Timestamp.fromDate(user.lastSeenAt.toUtc()),
    });
    return true;
  }

  @override
  Future<UserModel?> fetch(String uid) async {
    final MapDocumentSnapshot doc = await db.fetchOne(uid).get();
    if (!doc.exists) {
      return null;
    }

    return _deriveUserModelFromJson(doc.id, doc.reference.path, doc.data()!);
  }
}

Future<UserModel> _deriveUserModelFromJson(String id, String path, DynamicMap data) async => UserModel(
      id: id,
      path: path,
      email: data['email'] as String,
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      lastSeenAt: deriveDateFromTimestamp(data['lastSeenAt'] as Timestamp),
      createdAt: deriveDateFromTimestamp(data['createdAt'] as Timestamp),
    );
