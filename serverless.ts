import type { AWS } from "@serverless/typescript";

const serverlessConfiguration: AWS = {
  service: "personal-website-api",
  frameworkVersion: "3",
  plugins: [
    "serverless-plugin-typescript",
    "serverless-dotenv-plugin",
    "serverless-offline",
  ],
  provider: {
    name: "aws",
    region: "ap-southeast-2",
    runtime: "nodejs16.x",
    apiGateway: {
      minimumCompressionSize: 1024,
      shouldStartNameWithService: true,
      apiKeys: ["personal-website-api-key"],
    },
    iam: {
      role: {
        name: "personal-website-api-role",
        statements: [
          {
            Effect: "Allow",
            Action: "ses:SendTemplatedEmail",
            Resource: "*",
          },
        ],
      },
    },
    environment: {
      AWS_NODEJS_CONNECTION_REUSE_ENABLED: "1",
      NODE_OPTIONS: "--enable-source-maps --stack-trace-limit=1000",
    },
  },
  functions: {
    contactHandler: {
      handler: "./src/handler.contactHandler",
      events: [
        {
          http: {
            method: "POST",
            path: "contact",
            private: true,
          },
        },
      ],
    },
  },
};

module.exports = serverlessConfiguration;
