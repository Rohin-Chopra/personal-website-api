resource "aws_ses_template" "contact_reply_template" {
  name    = "contact-reply-template"
  subject = "Thanks for contacting me"
  html    = file("../email-templates/contact-reply-email.html")
}

resource "aws_ses_template" "contact_notify_template" {
  name    = "contact-notify-template"
  subject = "A contact form submission was made"
  html    = file("../email-templates/contact-notify-email.html")
}
