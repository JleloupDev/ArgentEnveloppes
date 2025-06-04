const fs = require('fs');
const path = 'build/web/index.html';
let content = fs.readFileSync(path, 'utf8');
const config = {
  apiKey: process.env.FIREBASE_WEB_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_WEB_APP_ID
};
const configString = JSON.stringify(config, null, 6).replace(/"/g, "'").replace(/^{/, '').replace(/}$/, '');
content = content.replace(/const firebaseConfig = \{[\s\S]*?\};/m, "const firebaseConfig = {" + configString + "};");
fs.writeFileSync(path, content);
console.log('Firebase config updated in index.html');
