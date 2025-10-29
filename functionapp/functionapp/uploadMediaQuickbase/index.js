const {
    BlobServiceClient,
    StorageSharedKeyCredential,
    generateBlobSASQueryParameters,
    BlobSASPermissions
} = require("@azure/storage-blob");

module.exports = async function (context, req) {
    const account = process.env.StorageAccount;
    const accountKey = process.env.StorageAccountKey;
    const event = req.body;

    const startDateTime = Date.now();
    console.log("start toQuickbase:", JSON.stringify(event));

    const container = event.bucket;
    const blob = event.key;
    const azureUrl = `https://${account}.blob.core.windows.net/`;
    const data = event.uploadData;
    const contentType = event.contentType;

    if (!data) {
        const duration = getDuration(startDateTime);
        const resp = {
            status: "error",
            status_message: "no data",
            app: null,
            api_duration: duration
        };
        context.res = {
            body: resp,
            headers: { "Content-Type": "application/json" }
        };
        return;
    }

    try {
        const url = await uploadToblob({
            account,
            accountKey,
            azureUrl,
            container,
            blob,
            data,
            contentType
        });

        finish(context, url, null, startDateTime);
    } catch (err) {
        finish(context, null, err, startDateTime);
    }
};

async function uploadToblob({ account, accountKey, azureUrl, container, blob, data, contentType }) {
    const sharedKeyCredential = new StorageSharedKeyCredential(account, accountKey);
    const blobServiceClient = new BlobServiceClient(azureUrl, sharedKeyCredential);
    const containerClient = blobServiceClient.getContainerClient(container);
    const blobClient = containerClient.getBlockBlobClient(blob);

    const imageBuffer = Buffer.from(data, "base64");

    await blobClient.upload(imageBuffer, imageBuffer.length, {
        blobHTTPHeaders: { blobContentType: contentType }
    });

    const expirationDate = new Date();
    expirationDate.setFullYear(expirationDate.getFullYear() + 10);

    const blobSAS = generateBlobSASQueryParameters(
        {
            containerName: container,
            blobName: blob,
            permissions: BlobSASPermissions.parse("r"),
            startsOn: new Date(),
            expiresOn: expirationDate
        },
        sharedKeyCredential
    ).toString();

    return `${blobClient.url}?${blobSAS}`;
}

function finish(context, response, err, startDateTime) {
    const duration = getDuration(startDateTime);
    console.log("finishing response");

    if (err) {
        console.error("Error:", err);
        const resp = {
            status: "error",
            status_message: err.message || "Unknown error",
            response: "",
            api_duration: duration
        };
        context.res = {
            body: resp,
            headers: { "Content-Type": "application/json" }
        };
    } else {
        console.log("finish success response:", response);
        const resp = {
            status: "success",
            status_message: "",
            response,
            api_duration: duration
        };
        context.res = {
            body: resp,
            headers: { "Content-Type": "application/json" }
        };
    }
}

function getDuration(startDateTime) {
    return (Date.now() - startDateTime).toString();
}
