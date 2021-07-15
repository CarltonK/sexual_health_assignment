import { Logger } from '@firebase/logger';
import { firestore } from 'firebase-admin';
import NotificationHelper from '../../helper/notification_helper';


export default class PubsubHandler {
    private logger: Logger = new Logger('PubsubHandler');
    private db = firestore();
    private notificationHelper: NotificationHelper = new NotificationHelper();

    constructor() {
        this.logger.setLogLevel('debug');
    }

    async constantReminderJob() {
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
            this.logger.error('constantReminderJob Error: ', error);
        }
        return null;
    }

    async orderProcessingJob() {
        const timeRightNow: firestore.Timestamp = firestore.Timestamp.now();
        // Should be every 45 mins. THIS IS AN ASSUMPTION
        // Retrieve all order documents without a resultReleasedAt field which means a result hasn't been posted
        try {
            const orderQueries: FirebaseFirestore.QuerySnapshot = await this.db.collection('orders').where('resultReleasedAt', '==', null).get();
            const orderDocuments: FirebaseFirestore.DocumentSnapshot[] = orderQueries.docs;

            // Decide if user is going to be sick randomly
            const sicknessOptions = [true, false];
            const randomElement = sicknessOptions[Math.floor(Math.random() * sicknessOptions.length)];
            const result: string = randomElement ? 'sick' : 'healthy';

            console.log('The result is: ', result);

            if (randomElement) {
                if (orderDocuments.length > 0) {
                    // Send a result for each document
                    // Perform job simultaneously using parallel processing
                    const promiseJobs: Promise<firestore.WriteResult>[] = [];
                    orderDocuments.forEach(async (doc: FirebaseFirestore.DocumentSnapshot) => {
                        // Retrieve the user and their tests
                        const { owner, test } = doc.data()!;
                        const testDocument = await this.db.collection('tests').doc(test).get();
                        if (testDocument.exists) {
                            const { sicknessPeriod, name } = testDocument.data()!;
                            console.log(`${owner} infected with ${name} for ${sicknessPeriod} hours`);
                            // Calculate sick until
                            const timeRightNowMilli = timeRightNow.toMillis();
                            const sicknessPeriodMIlli = sicknessPeriod * 24 * 60 * 60 * 1000;
                            const sickUntilInMilli = timeRightNowMilli + sicknessPeriodMIlli;
                            const sickUntil = firestore.Timestamp.fromMillis(sickUntilInMilli);

                            const ownerWrite = this.db.collection('users').doc(owner).update({
                                'isSick': true,
                                'sickUntil': sickUntil,
                                'isSickWith': name,
                            });
                            promiseJobs.push(ownerWrite);

                            // Update order doc
                            const orderWrite = this.db.collection('orders').doc(doc.id).update({
                                'resultReleasedAt': timeRightNow,
                                'result': result,
                            });
                            promiseJobs.push(orderWrite);
                        }
                    });
                    await Promise.all(promiseJobs);
                }
            }
        } catch (error) {
            this.logger.error('orderProcessingJob Error', error);
        }
        return null;
    }

    async healthCheckingJob() {
        const timeRightNow: firestore.Timestamp = firestore.Timestamp.now();
        try {

            const usersQueries: FirebaseFirestore.QuerySnapshot = await this.db.collection('users').get();
            const userDocuments: FirebaseFirestore.DocumentSnapshot[] = usersQueries.docs;

            const updateHealthJob: Promise<firestore.WriteResult>[] = [];

            userDocuments.forEach((doc: FirebaseFirestore.DocumentSnapshot) => {
                // Check if isSick
                const { isSick, sickUntil } = doc.data()!;
                // Check if time right now > sickUntil
                if (isSick && (timeRightNow.toDate() > sickUntil.toDate())) {
                    updateHealthJob.push(this.db.collection('users').doc(doc.id).update({
                        isSick: false,
                        sickUntil: null,
                        isSickWith: null,
                    }))
                }
            });

            await Promise.all(updateHealthJob);

        } catch (error) {
            this.logger.error('healthCheckingJob Error', error);
        }
        return null;
    }
}