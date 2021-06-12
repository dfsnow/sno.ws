const AWS = require('aws-sdk');
const util = require('util');
const sharp = require('sharp');
const path = require('path');
const s3 = new AWS.S3();

exports.handler = async (event, context, callback) => {

    // Read options from the event parameter.
    console.log("Reading options from event:\n", util.inspect(event, {depth: 5}));
    const srcBucket = event.Records[0].s3.bucket.name;

    // Object key may have spaces or unicode non-ASCII characters.
    const srcKey    = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const srcKeyExt = path.extname(srcKey).toLowerCase();
    const dstBucket = srcBucket;
    const dstKey = path.basename(srcKey, srcKeyExt);

    // Check that the image type is supported
    if (srcKeyExt != ".jpg" && srcKeyExt != ".png" && srcKeyExt != ".gif") {
        console.log(`Unsupported image type: ${srcKeyExt}`);
        return;
    }

    // Download the original image from the S3 source bucket.
    try {
        const params = {
            Bucket: srcBucket,
            Key: srcKey
        };
        var origimage = await s3.getObject(params).promise();
        console.log('got image');

    } catch (error) {
        console.log(error);
        return;
    }

    // Resize image and upload each version
    for (let res of [640, 1280]) {
        const filenameOrgExt = `${dstKey}-${res}${srcKeyExt}`;
        const filenameWebpExt = `${dstKey}-${res}.webp`;
        const filenameAvifExt = `${dstKey}-${res}.avif`;
        console.log(`Now generating ${res}`)

        try {
            var bufferOrg = await sharp(origimage.Body).rotate().resize(res).toBuffer();
            var bufferWebp = await sharp(origimage.Body).rotate().resize(res).webp().toBuffer();
            var bufferAvif = await sharp(origimage.Body).rotate().resize(res).avif().toBuffer();

        } catch (error) {
            console.log(error);
            return;
        }

        try {
            const destParamsOrg = {
                Bucket: dstBucket,
                Key: filenameOrgExt,
                Body: bufferOrg,
                ContentType: "image"
            };
            const destParamsWebp = {
                Bucket: dstBucket,
                Key: filenameWebpExt,
                Body: bufferWebp,
                ContentType: "image"
            };
            const destParamsAvif= {
                Bucket: dstBucket,
                Key: filenameAvifExt,
                Body: bufferAvif,
                ContentType: "image"
            };

            const putResultOrg = await s3.putObject(destParamsOrg).promise();
            const putResultWebp = await s3.putObject(destParamsWebp).promise();
            const putResultAvif = await s3.putObject(destParamsAvif).promise();

        } catch (error) {
            console.log(error);
            return;
        }
    };
    console.log('Successfully resized ' + srcBucket + '/' + srcKey);
};
