const AWS = require("aws-sdk");
const sharp = require("sharp");
const path = require("path");
const s3 = new AWS.S3();

exports.handler = async (event) => {
    // Read options from the event parameter
    const srcBucket = event.Records[0].s3.bucket.name;

    // Object key may have spaces or unicode non-ASCII characters
    const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const srcKeyExt = path.extname(srcKey).toLowerCase();

    const dstKey = path.basename(srcKey, srcKeyExt);
    const dstBucket = process.env.DEST_BUCKET;
    const dstPathResized = process.env.DEST_PATH_RESIZED;
    const dstPathOriginal = process.env.DEST_PATH_ORIGINAL;

    const backupBucket = process.env.BACKUP_BUCKET;
    const backupPath = process.env.BACKUP_PATH;

    // Check that the image type is supported
    if (![".jpg", ".png", ".gif"].includes(srcKeyExt)) {
        console.log("Unsupported image type: " + srcKeyExt);
        return;
    }

    try {
        // Download the original image from the S3 source bucket
        const params = {
            Bucket: srcBucket,
            Key: srcKey
        };
        var origimage = await s3.getObject(params).promise();
        console.log("Got file: " + srcBucket + "/" + srcKey);

        // Resize image and upload each version
        for (let res of [640, 1280]) {
            const formats = [
                { ext: srcKeyExt, func: (img) => img.rotate().resize(res) },
                { ext: '.webp', func: (img) => img.rotate().resize(res).webp() },
                { ext: '.avif', func: (img) => img.rotate().resize(res).avif() }
            ];

            for (let format of formats) {
                const buffer = await format.func(sharp(origimage.Body)).toBuffer();
                const destParams = {
                    Bucket: dstBucket,
                    Key: `${dstPathResized}/${dstKey}-${res}${format.ext}`,
                    Body: buffer,
                    ContentType: "image"
                };
                await s3.putObject(destParams).promise();
                console.log("Generated size/ext: " + res + format.ext);
            }
        }

        // Strip original image of EXIF data and rotate
        const buffer = await sharp(origimage.Body).rotate().toBuffer();
        const destParams = {
            Bucket: dstBucket,
            Key: `${dstPathOriginal}/${dstKey}${srcKeyExt}`,
            Body: buffer,
            ContentType: "image"
        };
        await s3.putObject(destParams).promise();
        console.log("Stripped " + srcBucket + "/" + srcKey);

        // Copy the original image to the backup bucket, then delete
        const copyParams = {
            Bucket: backupBucket,
            CopySource: `${srcBucket}/${srcKey}`,
            Key: `${backupPath}/${dstKey}${srcKeyExt}`
        };
        await s3.copyObject(copyParams).promise();
        console.log("Copied original image to " + backupBucket);

        const deleteParams = {
            Bucket: srcBucket,
            Key: srcKey
        };
        await s3.deleteObject(deleteParams).promise();
        console.log("Deleted image " + srcBucket + "/" + srcKey);

    } catch (error) {
        console.log(error);
        return;
    }
};