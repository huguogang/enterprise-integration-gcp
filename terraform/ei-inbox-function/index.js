const { Storage } = require('@google-cloud/storage');
const storage = new Storage();

const ARCHIVE_BUCKET = storage.bucket("developertips-ei-archive");
const ERROR_BUCKET = storage.bucket("developertips-ei-error");

/**
 * Handles new data files uploaded to inbox. It is triggered by Cloud Pub/Sub.
 *
 * @param {object} pubSubEvent The event payload.
 * @param {object} context The event metadata.
 */
exports.handleInboxNotification = (pubSubEvent, context) => {
    console.dir(pubSubEvent);
    console.dir(context);
    
    const bucketId = pubSubEvent.attributes.bucketId;
    const objectId = pubSubEvent.attributes.objectId;
    const eventType = pubSubEvent.attributes.eventType;

    // TODO: check timestamp and stop retry if exceeds threashold.

    if (eventType == "OBJECT_FINALIZE") {
        const file = storage.bucket(bucketId).file(objectId);
        const seed = (new Date()).getMilliseconds() % 100;
        
        if(seed > 20) {
            return Promise.reject(new Error("Simulated retriable failure"));
        }
        else if(seed > 8) {
            // Simulate non-retriable failure. Move file to error bucket.
            return file.move(ERROR_BUCKET.file(objectId))
            .then((response) => {
                console.dir(response);
            })
            .catch(err => {
                console.error('Error moving file to error box:', err);
            });
        }
        else {
            // Simulate data process success. Move file to archive bucket.
            return file.move(ARCHIVE_BUCKET.file(objectId))
                .then((response) => {
                    console.dir(response);
                })
                .catch(err => {
                    console.error('Error moving file to archive box:', err);
                });
        }
    }
};