# Firestore Security Rules Deployment Guide

## Overview
This guide explains how to deploy the Firestore security rules to ensure proper user data isolation in the ArgentEnveloppes application.

## Prerequisites
- Firebase CLI installed: `npm install -g firebase-tools`
- Authenticated with Firebase: `firebase login`
- Firebase project initialized in the repository

## Security Rules File
The security rules are defined in `firestore.rules` at the root of the project.

## Deployment Steps

### 1. Initialize Firebase (if not already done)
```powershell
# Navigate to project root
cd c:\Users\jlelo\source\repos\ArgentEnveloppes

# Initialize Firebase
firebase init firestore
```

When prompted:
- Select "Use an existing project" and choose your Firebase project
- Accept the default Firestore rules file (`firestore.rules`)
- Accept the default Firestore indexes file (`firestore.indexes.json`)

### 2. Deploy Security Rules
```powershell
# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Or deploy all Firestore configuration
firebase deploy --only firestore
```

### 3. Verify Deployment
```powershell
# Check deployment status
firebase firestore:rules:list

# Test rules in Firebase console
# Go to https://console.firebase.google.com
# Navigate to Firestore Database > Rules
# Use the Rules Playground to test scenarios
```

## Testing Security Rules

### Test Scenarios

#### 1. Authenticated User Access (Should ALLOW)
```javascript
// Test in Firebase Console Rules Playground
{
  "auth": {
    "uid": "user123"
  },
  "resource": {
    "name": "/databases/(default)/documents/users/user123/envelopes/envelope1"
  }
}
```

#### 2. Unauthenticated Access (Should DENY)
```javascript
{
  "auth": null,
  "resource": {
    "name": "/databases/(default)/documents/users/user123/envelopes/envelope1"
  }
}
```

#### 3. Cross-User Access (Should DENY)
```javascript
{
  "auth": {
    "uid": "user123"
  },
  "resource": {
    "name": "/databases/(default)/documents/users/user456/envelopes/envelope1"
  }
}
```

### Automated Testing
Create test files for comprehensive rule testing:

```javascript
// test/firestore.test.js
const { assertFails, assertSucceeds } = require('@firebase/rules-unit-testing');

describe('Firestore Security Rules', () => {
  test('allows authenticated user to read own data', async () => {
    const db = testEnv.authenticatedContext('user123').firestore();
    const doc = db.collection('users').doc('user123').collection('envelopes').doc('envelope1');
    await assertSucceeds(doc.get());
  });

  test('denies unauthenticated access', async () => {
    const db = testEnv.unauthenticatedContext().firestore();
    const doc = db.collection('users').doc('user123').collection('envelopes').doc('envelope1');
    await assertFails(doc.get());
  });

  test('denies cross-user access', async () => {
    const db = testEnv.authenticatedContext('user123').firestore();
    const doc = db.collection('users').doc('user456').collection('envelopes').doc('envelope1');
    await assertFails(doc.get());
  });
});
```

## Security Rules Explanation

### User Document Level
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```
- Users can only access their own user document
- Requires authentication (`request.auth != null`)
- UID must match the document path (`request.auth.uid == userId`)

### Sub-Collection Level
```javascript
match /envelopes/{envelopeId} {
  allow read, write, create, delete: if request.auth != null && request.auth.uid == userId;
}
```
- Inherits the `userId` from parent path
- All CRUD operations require user authentication
- User can only access their own envelopes/categories/transactions

### Default Deny Rule
```javascript
match /{document=**} {
  allow read, write: if false;
}
```
- Explicitly denies all other access
- Provides defense in depth
- Prevents access to unexpected document paths

## Monitoring and Maintenance

### Firebase Console Monitoring
1. Navigate to Firebase Console > Firestore Database
2. Go to the "Usage" tab to monitor rule evaluations
3. Check for any denied requests that should be allowed
4. Review performance metrics for rule evaluation

### Logging and Alerts
```javascript
// Add logging to rules for debugging
allow read, write: if request.auth != null && 
  request.auth.uid == userId &&
  debug(request.auth.uid); // Logs the user ID
```

### Regular Security Audits
- Review rules monthly for any changes needed
- Test rules after any authentication changes
- Validate rules against new features
- Check for any performance issues with complex rules

## Common Issues and Solutions

### Issue: Rules not applying immediately
**Solution**: Rules deployment can take a few minutes. Wait and retry.

### Issue: Authenticated requests being denied
**Solution**: 
1. Verify Firebase Auth token is valid
2. Check that UID matches document path exactly
3. Ensure client is using correct project configuration

### Issue: Development vs Production rules
**Solution**: Use different Firebase projects for development and production with appropriate rule sets.

## Best Practices

1. **Principle of Least Privilege**: Only grant minimum necessary permissions
2. **Always Authenticate**: Never allow unauthenticated access to user data
3. **Test Thoroughly**: Use both manual and automated testing
4. **Monitor Continuously**: Set up alerts for unusual access patterns
5. **Version Control**: Keep rules in source control with proper change tracking
6. **Document Changes**: Maintain changelog for rule modifications

## Emergency Procedures

### Rollback Rules
```powershell
# Rollback to previous rules version
firebase firestore:rules:release --description "Emergency rollback"

# Or deploy a safe default deny-all rule
firebase deploy --only firestore:rules
```

### Lock Down Database
```javascript
// Emergency lockdown rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false; // Deny all access
    }
  }
}
```

This comprehensive security rules system ensures that user data in ArgentEnveloppes remains properly isolated and secure.
