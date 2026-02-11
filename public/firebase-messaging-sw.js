importScripts("https://www.gstatic.com/firebasejs/10.14.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyD04fiiI6WibEi27EMs3kx7_WE6Rimhl8U",
  authDomain: "snap-journal-laravel-487103.firebaseapp.com",
  projectId: "snap-journal-laravel-487103",
  storageBucket: "snap-journal-laravel-487103.firebasestorage.app",
  messagingSenderId: "870206383777",
  appId: "1:870206383777:web:d3de08791d4d1db170f2e0",
  measurementId: "G-2T99R79S6C"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: "/logo.png",
  });
});