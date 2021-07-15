import { Logger } from '@firebase/logger';
import { firestore } from 'firebase-admin';
// import NotificationHelper from '../../helper/notification_helper';

export default class OrderHandler {
    private logger: Logger = new Logger('NewOrderDocument');
    private db = firestore();
    // private notificationHelper: NotificationHelper = new NotificationHelper();

    constructor() {
        this.logger.setLogLevel('debug');
    }

    async timedBackgroundJob() {
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
            this.logger.error(error);
        }
        return null;
    }
}