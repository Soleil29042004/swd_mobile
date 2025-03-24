import 'dart:html' as html;

void registerServiceWorker() {
  html.window.navigator.serviceWorker?.register('firebase-messaging-sw.js');
}