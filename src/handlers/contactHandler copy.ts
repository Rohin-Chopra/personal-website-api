import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { SESV2 } from "aws-sdk";
import {
  ADMIN_EMAIL,
  NOTIFY_EMAIL_TEMPLATE_NAME,
  NO_REPLY_EMAIL,
  REPLY_EMAIL_TEMPLATE_NAME,
} from "../lib/constants";
import { logger } from "../lib/logger";
import * as contactHandlerModule from "./contactHandler";
import { contactSchema } from "./schema";

const sesClient = new SESV2({ region: "ap-southeast-2" });

export const sendEmailToUser = async (name: string, email: string) => {
  const log = logger.child({ module: "sendEmailToUser" });
  log.info("start");

  await sesClient
    .sendEmail({
      FromEmailAddress: NO_REPLY_EMAIL,
      Destination: {
        ToAddresses: [email],
      },
      Content: {
        Template: {
          TemplateName: REPLY_EMAIL_TEMPLATE_NAME,
          TemplateData: JSON.stringify({ NAME: name }),
        },
      },
    })
    .promise();

  log.info("end");
};

export const sendEmailToMyself = async (
  name: string,
  email: string,
  message: string
) => {
  const log = logger.child({ module: "sendEmailToMyself" });
  log.info("start");

  await sesClient
    .sendEmail({
      FromEmailAddress: NO_REPLY_EMAIL,
      Destination: {
        ToAddresses: [ADMIN_EMAIL],
      },
      Content: {
        Template: {
          TemplateName: NOTIFY_EMAIL_TEMPLATE_NAME,
          TemplateData: JSON.stringify({
            NAME: name,
            EMAIL: email,
            MESSAGE: message,
          }),
        },
      },
    })
    .promise();

  log.info("end");
};

export const contactHandler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  const log = logger.child({ module: "contactHandler" });
  log.info("START");

  const body = JSON.parse(event.body!);
  const { name, email, message } = body;

  const validationResult = contactSchema.safeParse(body);
  if (!validationResult.success || email === ADMIN_EMAIL) {
    log.error("Invalid request", validationResult);
    return {
      statusCode: 400,
      body: JSON.stringify({
        message: "Invalid Request",
      }),
    };
  }
  try {
    await contactHandlerModule.sendEmailToUser(name, email);

    await contactHandlerModule.sendEmailToMyself(name, email, message);

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "success" }),
    };
  } catch (error: any) {
    log.error(error);
    return {
      statusCode: 500,
      body: JSON.stringify({
        error,
        message: "Internal Server Error",
      }),
    };
  } finally {
    log.info("END");
  }
};

class ContactHandler {
  constructor() {}

  private sendEmailToMyself() {}

  private sendEmailToUser() {}

  public handler() {
    
  }
}
