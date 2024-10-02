import sharp from 'sharp';
import axios from 'axios';
import {v4 as uuidv4} from 'uuid';
import fs from 'fs';
import generatePassword from 'generate-password';
import redis from "redis";

Parse.Cloud.define('usernames', async req => {
  const query = new Parse.Query(Parse.User);
  query.select('name');
  const results = await query.find({ useMasterKey: true });

  const usernames = results.map(user => user.get('name'));
  return usernames;
});

Parse.Cloud.define('objects', async req => {
  const query = new Parse.Query('Objects');
  query.limit(1000);
  let results = [];
  let hasMore = true;
  let skip = 0;

  while (hasMore) {
    query.skip(skip);
    const response = await query.find({ useMasterKey: true });
    results = results.concat(response);
    skip += response.length;
    hasMore = response.length === 1000;
  }

  return results.map(object => object.toJSON());
});

Parse.Cloud.define('sendEmail', async req => {
    try {
      return await _sendPasswordWithUnisender(req.params.email);
    }
    catch (error) {
      throw new Error(error.message);
    }
  });

Parse.Cloud.define('sendPassword', async req => {
  try {
    const user = await _searchUser(req.params.email);
    return await _sendPasswordWithUnisender(req.params.email, createNewPasswordHtml(user.getPassword()));
  }
  catch (error) {
    throw new Error(error.message);
  }
});

Parse.Cloud.define('resetPassword', async req => {
  const email = req.params.email;
  try {
    await Parse.User.requestPasswordReset(email);
    return 'Password reset request was sent successfully';
  } catch (error) {
    throw new Error(error.message);
  }
});

async function _searchUser(email) {
  const query = new Parse.Query(Parse.User);
  query.equalTo("email", email);
  try {
    const user = await query.first({ useMasterKey: true });
    if (user) {
      return user;
    } else {
      throw new Error('User not found');
    }
  } catch (error) {
    throw new Error(error.message);
  }
}

async function _sendPasswordWithUnisender(email, bodyStr) {
  const key = "6k411zoazdano1qqxrturuunaf8t196wffidrrby";
  const body = encodeURIComponent(bodyStr);
  const url =
            "https://api.unisender.com/ru/api/sendEmail?format=json&api_key="+key+"&email="+email+"&sender_name=SemesterRus&sender_email=d.berezin88@gmail.com&subject=Authorization&body="+body+"&list_id=1";
  const response = await axios.get(url);
  console.log("send email " + response.status + " " + response.statusText);
  if(response.status >= 300) {
    throw {message: response.data};
  }
  return response.data; 
}
  

async function _sendPasswordWithMaitrap(email) {
    
    var html = "<html>Пусто</html>";
    const response = await axios.post('https://send.api.mailtrap.io/api/send', {
      from: {
        email: "mailtrap@semesterrus.com",
        name: "SemesterRus"
      },
      to: [{
        email: email
      }],
      subject: "Authorization",
      html: html
    }, {
      signal: AbortSignal.timeout(15000),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 0d422a577bdc7fa8f1cf8b0fcb41f30b',
      }
    });

    if(response.status >= 300) {
      throw {message: response.data};
    }
  
    return response.data;
  }


function createNewPasswordHtml(password) {
  var html = _emailHtml2;
  var welcome = "<h2>Ваш новый пароль:</h2><p><strong>"+password+"</strong></p>";
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