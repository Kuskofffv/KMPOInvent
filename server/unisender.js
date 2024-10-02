import axios from 'axios';

export class UnisenderMailAdapter {
  constructor(options) {
    this.apiKey = options.apiKey;
    this.senderName = options.senderName;
    this.senderEmail = options.senderEmail;
  }

  async sendMail(data, message) {
    console.log(JSON.stringify(data));
    const data2 = JSON.parse(JSON.stringify(data));
    const body = encodeURIComponent(message);
    const email = data2.user.email;
    const url = `https://api.unisender.com/ru/api/sendEmail?format=json&api_key=${this.apiKey}&email=${email}&sender_name=${this.senderName}&sender_email=${this.senderEmail}&subject=invent&body=${body}&list_id=1`;
    console.log(url);
    try {
      const response = await axios.get(url);
      return response.data;
    } catch (error) {
      console.log(error);
      throw new Error(`Failed to send email: ${error.message}`);
    }
  }
   sendVerificationEmail(data) {
     return this.sendMail(data, createVerificationHtml(data.link));
   }

   async sendPasswordResetEmail(data) {
     return this.sendMail(data, createNewPasswordHtml(data.link));
   }
}

function createVerificationHtml(link) {
    var html = _emailHtml2;
    var welcome = "<h2>Подтверждение пароля:</h2><p><a href='"+link+"'><strong>Ссылка</strong></a></p>";
    return html.replace("{welcome}", welcome);
  }

function createNewPasswordHtml(link) {
    var html = _emailHtml2;
    var welcome = "<h2>Восстановление пароля:</h2><p><a href='"+link+"'><strong>Ссылка</strong></a></p>";
    return html.replace("{welcome}", welcome);
  }
  
    const _emailHtml2 = `<!DOCTYPE html>
  <html lang="ru">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Invent</title>
      <style>
          body {
              font-family: Arial, sans-serif;
              margin: 0;
              padding: 20px;
              background-color: #f4f4f4;
          }
          .container {
              max-width: 500px;
              margin: auto;
              margin-bottom: 40px;
              background: #fff;
              padding: 30px;
              border-radius: 8px;
              box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
          }
          h2 {
              color: #333;
          }
          .h22 {
              font-size: 0.9em;
              color: #555;
          }
          p {
              color: #666;
          }
          .p2 {
              font-size: 0.9em;
              color: #888;
          }
          .footer {
              margin-top: 20px;
              text-align: center;
              font-size: 0.9em;
              color: #777;
          }
      </style>
  </head>
  <body>
      <div class="container">
          {welcome}
      </div>
  </body>
  </html>`;