/**
 * Handles new data files uploaded to inbox. It is triggered by Cloud Pub/Sub.
 *
 * @param {object} pubSubEvent The event payload.
 * @param {object} context The event metadata.
 */
exports.handleInboxNotification = (pubSubEvent, context) => {
  console.log(`pubSubEvent: ${pubSubEvent}`);
  console.log(`context: ${context}`);
  // TODO: random leave files in bucket, move to error or stays in archive
  // File that are left in inbox won't have retry 
};