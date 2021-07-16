import * as functions from 'firebase-functions';
import { Logger } from '@firebase/logger';
import * as admin from 'firebase-admin';

admin.initializeApp();

import FirestoreHandler from './handler/firestore/firestore_handler';
import PubsubHandler from './handler/pubsub/pubsub_handler';

const logger = new Logger('Root');
logger.setLogLevel('debug');

// Define functions
const runOptions: functions.RuntimeOptions = {
  timeoutSeconds: 60,
  memory: '128MB',
  ingressSettings: 'ALLOW_INTERNAL_ONLY',
};
const regionalFunctions = functions.runWith(runOptions).region('europe-west3');

const GlobalFirestoreHandler = new FirestoreHandler();
const GlobalPubsubHandler = new PubsubHandler();

/******************
* Firestore Trigger(s)
******************/

export const newUserDocument = regionalFunctions.firestore.document('users/{user}')
  .onCreate(GlobalFirestoreHandler
    .newUserDocument.bind(GlobalFirestoreHandler));

export const sicknessNotifier = regionalFunctions.firestore.document('orders/{order}')
  .onUpdate(GlobalFirestoreHandler
    .sicknessNotifier.bind(GlobalFirestoreHandler));

/******************
* Pubsub Trigger(s)
******************/

export const constantReminder = regionalFunctions.pubsub.schedule('every 18 hours')
  .timeZone('Africa/Nairobi')
  .onRun(GlobalPubsubHandler
    .constantReminderJob.bind(GlobalPubsubHandler));

export const orderHandler = regionalFunctions.pubsub.schedule('every 45 mins')
  .timeZone('Africa/Nairobi')
  .onRun(GlobalPubsubHandler
    .orderProcessingJob.bind(GlobalPubsubHandler));

export const healthChecker = regionalFunctions.pubsub.schedule('every 24 hours')
  .timeZone('Africa/Nairobi')
  .onRun(GlobalPubsubHandler
    .healthCheckingJob.bind(GlobalPubsubHandler));
