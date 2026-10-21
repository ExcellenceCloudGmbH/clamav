import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

def send_email(subject, content):
    # Load the SendGrid API key from environment variables
    api_key = os.getenv("SENDGRID_API_KEY")
    if not api_key:
        raise ValueError("SENDGRID_API_KEY is not set")

    # Prepare the email
    message = Mail(
        from_email=os.getenv("FROM_EMAIL"),  # Replace with your sender email
        to_emails=os.getenv("TO_EMAIL"),    # Replace with the recipient's email
        subject=subject,
        plain_text_content=content,
    )

    # Send the email using SendGrid
    try:
        sg = SendGridAPIClient(api_key)
        response = sg.send(message)
        print(f"Email sent successfully: {response.status_code}")
    except Exception as e:
        print(f"Error sending email: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: send_email.py <subject> <content>")
        sys.exit(1)

    send_email(sys.argv[1], sys.argv[2])
