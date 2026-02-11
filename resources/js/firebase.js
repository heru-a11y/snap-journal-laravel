import { initializeApp } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";

const firebaseConfig = {
  apiKey: "AIzaSyD04fiiI6WibEi27EMs3kx7_WE6Rimhl8U",
  authDomain: "snap-journal-laravel-487103.firebaseapp.com",
  projectId: "snap-journal-laravel-487103",
  storageBucket: "snap-journal-laravel-487103.firebasestorage.app",
  messagingSenderId: "870206383777",
  appId: "1:870206383777:web:d3de08791d4d1db170f2e0",
  measurementId: "G-2T99R79S6C"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const messaging = getMessaging(app);

export const requestPermission = async () => {
  try {
    const token = await getToken(messaging, {
      vapidKey: "BIqhSq-JOX7XpGliIvPDlO5A3sbLw6NYeRgZMysnxH5I9bD7zuOa6wpkEO9WCFAcPbhIVNCmCYDkVShe6Ac7fzY"
    });
    return token;
  } catch (err) {
    console.error("Token error", err);
    return null;
  }
};

export const onMessageListener = () =>
  new Promise((resolve) => {
    onMessage(messaging, (payload) => {
      resolve(payload);
    });
  });