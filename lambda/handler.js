// lambda@edge function to inject cache control header into S3 content
exports.handler = async (event, context) => {
    const response = event.Records[0].cf.response;
    const headers = response.headers;
    const defaultTimeToLive = 60 * 60 * 24 * 30; // 30 days

    if (!headers["cache-control"]) {
        headers["cache-control"] = [
            {
                key: "Cache-Control",
                value: `public, max-age=${defaultTimeToLive}, immutable`
            }
        ];
        console.log("Response header modified!");
    }

    return response;
};
