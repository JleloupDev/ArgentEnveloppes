import 'package:argentenveloppes/data/models/user_model.dart';
import 'package:argentenveloppes/domain/entities/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_model_test.mocks.dart';

@GenerateMocks([firebase_auth.User])
void main() {
  late MockUser mockFirebaseUser;

  setUp(() {
    mockFirebaseUser = MockUser();
  });

  group('UserModel', () {
    const tUid = 'test-uid';
    const tEmail = 'test@example.com';
    const tDisplayName = 'Test User';
    const tPhotoURL = 'https://example.com/photo.jpg';
    const tIsAnonymous = false;
    const tEmailVerified = true;

    test('should be a subclass of User entity', () {
      // arrange
      final userModel = UserModel(
        uid: tUid,
        email: tEmail,
        displayName: tDisplayName,
        photoURL: tPhotoURL,
        isAnonymous: tIsAnonymous,
        emailVerified: tEmailVerified,
      );
      
      // assert
      expect(userModel, isA<User>());
    });

    test('should create a UserModel from a firebase User', () {
      // arrange
      when(mockFirebaseUser.uid).thenReturn(tUid);
      when(mockFirebaseUser.email).thenReturn(tEmail);
      when(mockFirebaseUser.displayName).thenReturn(tDisplayName);
      when(mockFirebaseUser.photoURL).thenReturn(tPhotoURL);
      when(mockFirebaseUser.isAnonymous).thenReturn(tIsAnonymous);
      when(mockFirebaseUser.emailVerified).thenReturn(tEmailVerified);
      
      // act
      final result = UserModel.fromFirebaseUser(mockFirebaseUser);
      
      // assert
      expect(result.uid, tUid);
      expect(result.email, tEmail);
      expect(result.displayName, tDisplayName);
      expect(result.photoURL, tPhotoURL);
      expect(result.isAnonymous, tIsAnonymous);
      expect(result.emailVerified, tEmailVerified);
    });

    test('should convert UserModel to User entity', () {
      // arrange
      final userModel = UserModel(
        uid: tUid,
        email: tEmail,
        displayName: tDisplayName,
        photoURL: tPhotoURL,
        isAnonymous: tIsAnonymous,
        emailVerified: tEmailVerified,
      );
      
      // act
      final result = userModel.toEntity();
      
      // assert
      expect(result, isA<User>());
      expect(result.uid, tUid);
      expect(result.email, tEmail);
      expect(result.displayName, tDisplayName);
      expect(result.photoURL, tPhotoURL);
      expect(result.isAnonymous, tIsAnonymous);
      expect(result.emailVerified, tEmailVerified);
    });
  });
}
