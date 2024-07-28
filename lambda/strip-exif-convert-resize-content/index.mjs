import { S3Client, GetObjectCommand, PutObjectCommand, CopyObjectCommand, DeleteObjectCommand } from "@aws-sdk/client-s3";
import sharp from "sharp";
import path from "path";

const s3 = new S3Client({});

export const handler = async (event) => {
    const srcBucket = event.Records[0].s3.bucket.name;
    const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const srcKeyExt = path.extname(srcKey).toLowerCase();

    const dstKey = path.basename(srcKey, srcKeyExt);
    const dstBucket = process.env.DEST_BUCKET;
    const dstPathResized = process.env.DEST_PATH_RESIZED;
    const dstPathOriginal = process.env.DEST_PATH_ORIGINAL;

    const backupBucket = process.env.BACKUP_BUCKET;
    const backupPath = process.env.BACKUP_PATH;

    if (![".jpg", ".png", ".gif"].includes(srcKeyExt)) {
        console.log("Unsupported image type: " + srcKeyExt);
        return;
    }

    try {
        const origimage = await s3.send(new GetObjectCommand({ Bucket: srcBucket, Key: srcKey }));
        const origimageByteArray = await origimage.Body.transformToByteArray();
        const origimageBody = Buffer.from(origimageByteArray);
        console.log("Got file: " + srcBucket + "/" + srcKey);

        for (let res of [640, 1280]) {
            const formats = [
                { ext: srcKeyExt, func: (img) => img.rotate().resize(res) },
                { ext: '.webp', func: (img) => img.rotate().resize(res).webp() },
                { ext: '.avif', func: (img) => img.rotate().resize(res).avif() }
            ];

            for (let format of formats) {
                const buffer = await format.func(sharp(origimageBody)).toBuffer();
                await s3.send(new PutObjectCommand({
                    Bucket: dstBucket,
                    Key: `${dstPathResized}/${dstKey}-${res}${format.ext}`,
                    Body: buffer,
                    ContentType: "image"
                }));
                console.log("Generated size/ext: " + res + format.ext);
            };
        };

        const buffer = await sharp(origimageBody).rotate().toBuffer();
        await s3.send(new PutObjectCommand({
            Bucket: dstBucket,
            Key: `${dstPathOriginal}/${dstKey}${srcKeyExt}`,
            Body: buffer,
            ContentType: "image"
        }));
        console.log("Stripped " + srcBucket + "/" + srcKey);

        await s3.send(new CopyObjectCommand({
            Bucket: backupBucket,
            CopySource: `${srcBucket}/${srcKey}`,
            Key: `${backupPath}/${dstKey}${srcKeyExt}`
        }));
        console.log("Copied original image to " + backupBucket);

        await s3.send(new DeleteObjectCommand({ Bucket: srcBucket, Key: srcKey }));
        console.log("Deleted image " + srcBucket + "/" + srcKey);

    } catch (error) {
        console.log(error);
        return;
    }
};