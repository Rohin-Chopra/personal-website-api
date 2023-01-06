import { constructAPIGwEvent } from "../../utils/helpers";

import { ContactHandler } from "../../../src/handlers/contactHandler";

jest.mock("aws-sdk");

const contactHandler = new ContactHandler();

describe("Test ContactHandler", () => {
  it("should return a 200 and a success message", async () => {
    jest.spyOn(ContactHandler.prototype as any, "sendEmailToMyself");
    jest.spyOn(ContactHandler.prototype as any, "sendEmailToUser");

    const event = constructAPIGwEvent(
      {
        name: "foo",
        email: "rr",
        message: "",
      },
      { method: "POST", path: "/contact" }
    );

    const result = await contactHandler.handler(event);

    const expectedResult = {
      statusCode: 200,
      body: JSON.stringify({ message: "success" }),
    };

    // Compare the result with the expected result
    expect(result).toEqual(expectedResult);
  });
});
``;
