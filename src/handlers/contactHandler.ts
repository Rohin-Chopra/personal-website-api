import { APIGatewayProxyEvent, APIGatewayProxyResult } from "aws-lambda";
import { SESV2 } from "aws-sdk";
import {
  ADMIN_EMAIL,
  NOTIFY_EMAIL_TEMPLATE_NAME,
  NO_REPLY_EMAIL,
} from "../lib/constants";
import { logger } from "../lib/logger";
import { REPLY_EMAIL_TEMPLATE_NAME } from "./../lib/constants";
import { contactSchema } from "./schema";

interface ContactRequestBody {
  name: string;
  email: string;
  message: string;
}

class ContactHandler {
  private sesClient: SESV2;

  constructor() {
    this.sesClient = new SESV2({ region: "ap-southeast-2" });
  }

  private async sendEmailToMyself(
    name: string,
    email: string,
    message: string
  ) {
    const log = logger.child({ module: "sendEmailToMyself" });
    log.info("start");

    await this.sesClient
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
  }

  private async sendEmailToUser(name: string, email: string) {
    const log = logger.child({ module: "sendEmailToUser" });
    log.info("start");

    await this.sesClient
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
  }

  private validate(body: ContactRequestBody): boolean {
    const validationResult = contactSchema.safeParse(body);
    return !validationResult.success || body.email === ADMIN_EMAIL;
  }

  public async handler(
    event: APIGatewayProxyEvent
  ): Promise<APIGatewayProxyResult> {
    const log = logger.child({ module: "contactHandler" });
    log.info("START");

    const body: ContactRequestBody = JSON.parse(event.body!);
    if (!this.validate(body)) {
      log.error("Invalid request");
      return {
        statusCode: 400,
        body: JSON.stringify({
          message: "Invalid Request",
        }),
      };
    }
    const { name, email, message } = body;

    try {
      await this.sendEmailToUser(name, email);
      await this.sendEmailToMyself(name, email, message);

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
  }
}

export { ContactHandler };
