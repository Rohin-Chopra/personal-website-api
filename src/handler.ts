import type { APIGatewayEvent, APIGatewayProxyResult } from "aws-lambda";
import { SESV2 } from "aws-sdk";
import { z } from "zod";
import { config } from "./config";

const sesClient = new SESV2({ region: "ap-southeast-2" });

const schema = z
  .object({
    name: z.string(),
    email: z.string().email(),
    message: z.string(),
  })
  .required();

const sendTemplatedEmail = async (
  toAddress: string,
  templateName: string,
  templateData: Record<string, unknown>
): Promise<void> => {
  await sesClient
    .sendEmail({
      FromEmailAddress: config.noReplyEmail,
      Destination: {
        ToAddresses: [toAddress],
      },
      Content: {
        Template: {
          TemplateName: templateName,
          TemplateData: JSON.stringify(templateData),
        },
      },
    })
    .promise();
};

export const contactHandler = async (
  event: APIGatewayEvent
): Promise<APIGatewayProxyResult> => {
  try {
    const validationResult = schema.safeParse(JSON.parse(event.body || ""));
    if (!validationResult.success)
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "Invalid request" }),
      };

    const { name, email, message } = validationResult.data;

    // Send email to myself about the message the user sent
    await sendTemplatedEmail(
      config.adminEmail,
      config.notifyEmailTemplateName,
      {
        NAME: name,
        EMAIL: email,
        MESSAGE: message,
      }
    );

    // Send email to the user confirming that I have received their email
    await sendTemplatedEmail(email, config.replyEmailTemplateName, {
      NAME: name,
    });

    return {
      headers: {
        "Access-Control-Allow-Origin": "*",
      },
      statusCode: 200,
      body: JSON.stringify({
        message: "Message sent",
      }),
    };
  } catch (error: any) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        message: error.message,
      }),
    };
  }
};
