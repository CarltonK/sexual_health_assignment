import { Logger } from '@firebase/logger';
import { firestore } from 'firebase-admin';
import NotificationHelper from '../../helper/notification_helper';

export default class ConstantReminderHandler {
    private logger: Logger = new Logger('NewUserDocument');
    private db = firestore();
    private notificationHelper: NotificationHelper = new NotificationHelper();

    constructor() {
        this.logger.setLogLevel('debug');
    }

    async timedBackgroundJob() {
        // Should be every 18 hours
        // Retrieve all user documents
        try {
            const usersQueries: FirebaseFirestore.QuerySnapshot = await this.db.collection('users').get();
            const userDocuments: FirebaseFirestore.DocumentSnapshot[] = usersQueries.docs;

            if (userDocuments.length > 0) {
                // Send a notification for each user
                // Perform job simultaneously using parallel processing
                const notificationJob: Promise<void>[] = []
                userDocuments.forEach((doc: FirebaseFirestore.DocumentSnapshot) => {
                    // Retrieve the user fcm token
                    const { token } = doc.data()!

                    if (token) {
                        notificationJob.push(this.notificationHelper.singleNotificationSend(token, 'Troglo', 'It\'s time to take a test'));
                    }
                });
                await Promise.all(notificationJob);
            }
        } catch (error) {
            this.logger.error(error);
        }
        return null;
    }
}