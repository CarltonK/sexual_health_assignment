import { Logger } from '@firebase/logger';
import * as functions from 'firebase-functions';
import { firestore } from 'firebase-admin';
import NotificationHelper from '../../helper/notification_helper';

export default class UserDocumentHandler {

    private logger: Logger = new Logger('NewUserDocument');
    private db = firestore();
    private notificationHelper: NotificationHelper = new NotificationHelper();

    constructor() {
        this.logger.setLogLevel('debug');
    }

    async newUserDocumentHandler(snapshot: firestore.QueryDocumentSnapshot, context: functions.EventContext) {

        try {
            // Identifiers
            const uid: string = snapshot.id;
            const userDocRef: firestore.DocumentReference = this.db.collection('users').doc(uid);
            const createdAt: firestore.Timestamp = firestore.Timestamp.now();
            const { token } = snapshot.data();

            if (token) {
                await this.notificationHelper.singleNotificationSend(
                    token,
                    'Welcome',
                    'Glad to have you on board'
                );
            }
            this.logger.info(`The user identified by ${uid} was created at ${createdAt.toDate()}`);
            await userDocRef.update({ createdAt: createdAt });
        } catch (error) {
            this.logger.error(error);
        }
        return;
    }
}