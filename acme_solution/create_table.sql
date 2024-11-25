DROP TABLE IF EXISTS CloudTrailLogs CASCADE;
CREATE TABLE CloudTrailLogs (
    cloudTrailLogsId SERIAL PRIMARY KEY,
    eventVersion varchar(255),
    eventTime varchar(255),
    eventSource varchar(255),
    eventName varchar(255),

    typeIdentity varchar(255),
    principalId varchar(255),
    arnIdentity varchar(255),
    accountIdIdentity varchar(255),
    accessKeyId varchar(255),
    userName varchar(255),
    sessionContext JSON,

    accountId varchar(255),
    type varchar(255),
    arn varchar(255),

    tlsVersion varchar(255),
    cipherSuite varchar(255),
    clientProvidedHostHeader varchar(255),

    requestParameters JSONB,
    responseElements JSONB,
    additionalEventData JSONB,
    serviceEventDetails JSONB
);