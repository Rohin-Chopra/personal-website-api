import { APIGatewayProxyEvent } from "aws-lambda";
import "source-map-support/register";
import { ContactHandler } from "./contactHandler";

const contactHandler = new ContactHandler();
export const handler = (event: APIGatewayProxyEvent) => {
  return contactHandler.handler(event);
};
