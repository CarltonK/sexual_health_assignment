import * as functions from 'firebase-functions';
import { Logger } from '@firebase/logger';
import * as admin from 'firebase-admin';

admin.initializeApp();

import UserDocumentHandler from './handler/firestore/newUserDocument';

const logger = new Logger('Root');
logger.setLogLevel('debug');

// Define functions
const runOptions: functions.RuntimeOptions = {
  timeoutSeconds: 60,
  memory: '128MB',
  ingressSettings: 'ALLOW_ALL',
};
const regionalFunctions = functions.runWith(runOptions).region('europe-west3');

const GlobalUserDocumentHandler = new UserDocumentHandler();

/******************
* Firestore Trigger(s)
******************/

export const newUserDocument = regionalFunctions.firestore.document('users/{user}').onCreate(
  GlobalUserDocumentHandler.newUserDocumentHandler.bind(GlobalUserDocumentHandler)
);