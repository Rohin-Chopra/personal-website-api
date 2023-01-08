import { z } from "zod";

const  contactSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  message: z.string(),
});

export { contactSchema };
