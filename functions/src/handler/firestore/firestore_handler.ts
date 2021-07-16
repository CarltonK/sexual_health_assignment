import { Logger } from '@firebase/logger';
import * as functions from 'firebase-functions';
import { firestore } from 'firebase-admin';
import NotificationHelper from '../../helper/notification_helper';

export default class FirestoreHandler {

    private logger: Logger = new Logger('FirestoreHandler');
    private db = firestore();
    private notificationHelper: NotificationHelper = new NotificationHelper();

    constructor() {
        this.logger.setLogLevel('debug');
    }

    async newUserDocument(snapshot: firestore.QueryDocumentSnapshot, context: functions.EventContext) {

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
            this.logger.error('newUserDocument Error: ',error);
        }
        return;
    }

    async sicknessNotifier(change: functions.Change<firestore.QueryDocumentSnapshot>) {
        try {
            // Check if result field has changed and get order owner
            const { result, owner, test } = change.after.data();

            // Get the token of the owner
            const ownerDoc = await this.db.collection('users').doc(owner).get();

            // Get the test details
            const testDoc = await this.db.collection('tests').doc(test).get();
            const { name, sicknessPeriod } = testDoc.data()!;

            // Send a notification iff the owner exists
            if (ownerDoc.exists) {
                const { token } = ownerDoc.data()!;
                // Notification draft
                const title: string = 'The results are in!';
                const message: string = result === 'healthy' ? 'You are healthy' : `You have ${name}. You need to remain sexually quarantined for ${sicknessPeriod} hours.`
                await this.notificationHelper.singleNotificationSend(
                    token,
                    title,
                    message
                );
            }

        } catch (error) {
            this.logger.error('sicknessNotifier Error: ',error);
        }
        return;
    }
}