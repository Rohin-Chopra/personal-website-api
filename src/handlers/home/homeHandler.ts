import { APIGatewayProxyResult } from "aws-lambda";

export const homeHandler = async (): Promise<APIGatewayProxyResult> => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: `Welcome to Rohin Chopra's API` }),
  };
};
