importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyDTAw1LwpO9epN9Ad9iiyeH0kmMG6YGTcY",
  authDomain: "swd-pushnotif.firebaseapp.com",
  projectId: "swd-pushnotif",
  storageBucket: "swd-pushnotif.appspot.com",
  messagingSenderId: "999904748547",
  appId: "1:999904748547:web:2b458b4e6c6cc671539a36"
});

// Retrieve Firebase Messaging instance
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);
});