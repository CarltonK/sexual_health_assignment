import * as functions from 'firebase-functions';
import { Logger } from '@firebase/logger';
import * as admin from 'firebase-admin';

admin.initializeApp();

import UserDocumentHandler from './handler/firestore/newUserDocument';
import ConstantReminderHandler from './handler/pubsub/constantReminder';
import OrderHandler from './handler/pubsub/orderHandler';

const logger = new Logger('Root');
logger.setLogLevel('debug');

// Define functions
const runOptions: functions.RuntimeOptions = {
  timeoutSeconds: 60,
  memory: '128MB',
  ingressSettings: 'ALLOW_INTERNAL_ONLY',
};
const regionalFunctions = functions.runWith(runOptions).region('europe-west3');

const GlobalUserDocumentHandler = new UserDocumentHandler();
const GlobalConstantReminderHandler = new ConstantReminderHandler();
const GlobalOrderHandler = new OrderHandler();

/******************
* Firestore Trigger(s)
******************/

export const newUserDocument = regionalFunctions.firestore.document('users/{user}')
  .onCreate(GlobalUserDocumentHandler
    .newUserDocumentHandler.bind(GlobalUserDocumentHandler));

/******************
* Pubsub Trigger(s)
******************/

export const constantReminder = regionalFunctions.pubsub.schedule('every 18 hours')
  .timeZone('Africa/Nairobi')
  .onRun(GlobalConstantReminderHandler
    .timedBackgroundJob.bind(GlobalConstantReminderHandler));

export const orderHandler = regionalFunctions.pubsub.schedule('every 45 mins')
  .timeZone('Africa/Nairobi')
  .onRun(GlobalOrderHandler
    .timedBackgroundJob.bind(GlobalOrderHandler));
