 final String emailTemplateHtml = '''
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
  <html>
     <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
        <meta name="format-detection" content="telephone=no">
        <title></title>
        <style>
           .confirmbtn {
           padding: 10px;
           background: #E62365;
           border-radius: 5px;
           color: #ffffff !important;
           border: 1px solid #E62365;
           font-size: 15px;
           text-decoration: none;
           }
           h1 a {
           color: #2d3e50;
           text-decoration: none;
           }
           .workflow-header {
           border-bottom: 1px solid #ddd;
           padding: 10px;
           text-align: center;
           height: 10px;
           background: #3e3b3b;
           }
           body,
           table,
           td,
           p,
           a,
           li,
           blockquote {
           -webkit-text-size-adjust: 100%;
           -ms-text-size-adjust: 100%;
           }
           table,
           td {
           mso-table-lspace: 0pt;
           mso-table-rspace: 0pt;
           }
           img {
           -ms-interpolation-mode: bicubic;
           }
           body {
           margin: 0;
           font-family: Helvetica;
           padding: 0;
           }
           img {
           border: 0;
           height: auto;
           line-height: 100%;
           outline: none;
           text-decoration: none;
           }
           table {
           border-collapse: collapse !important;
           }
           body,
           #bodyTable,
           #bodyCell {
           height: 100% !important;
           margin: 0;
           padding: 0;
           width: 100% !important;
           }
           #bodyCell {
           padding: 20px;
           }
           #templateContainer {
           width: 600px;
           }
           body,
           #bodyTable {
           background-color: #ffffff;
           }
           h1,
           h3 {
           font-family: Helvetica;
           font-style: normal;
           line-height: 100%;
           letter-spacing: normal;
           margin-right: 0;
           margin-left: 0;
           text-align: center;
           }
           h1 {
           font-size: 36px;
           margin-top: 30px;
           margin-bottom: 10px;
           }
           h3 {
           font-size: 17px;
           margin-top: 0;
           margin-bottom: 30px;
           }
           #templateBody {
           background-color: #ffffff;
           border-top: 1px solid #FFFFFF;
           border-bottom: 1px solid #CCCCCC;
           }
           .bodyContent {
           color: #505050;
           font-family: Helvetica;
           font-size: 16px;
           line-height: 112%;
           padding-right: 30px;
           padding-bottom: 30px;
           padding-left: 30px;
           text-align: left;
           }
           .bodyContent a:link,
           .bodyContent a:visited,
           .bodyContent a .yshortcuts {
           color: #EB4102;
           font-weight: normal;
           text-decoration: underline;
           }
           .bodyContent img {
           display: inline;
           height: auto;
           min-width: 100px;
           }
           .otp {
           font-size: 25px;
           letter-spacing: 5px;
           }
           @media only screen and (max-width: 480px) {
           body,
           table,
           td,
           p,
           a,
           li,
           blockquote {
           -webkit-text-size-adjust: none !important;
           }
           body {
           width: 100% !important;
           min-width: 100% !important;
           }
           #bodyCell {
           padding: 10px !important;
           }
           #templateContainer {
           max-width: 600px !important;
           width: 100% !important;
           }
           h1 {
           font-size: 30px !important;
           line-height: 100% !important;
           }
           h3 {
           font-size: 18px !important;
           line-height: 100% !important;
           }
           #bodyImage {
           height: auto !important;
           max-width: 560px !important;
           width: 100% !important;
           }
           .bodyContent {
           font-size: 18px !important;
           line-height: 125% !important;
           }
           }
           p a {
           color: #ffffff !important;
           }
           a {
           color: #444444 !important;
           text-decoration: none !important;
           }
        </style>
     </head>
     <center>
        <table align="center" border="0" cellpadding="0" cellspacing="0" height="100%" id="bodyTable" width="100%">
           <tbody>
              <tr>
                 <td align="center" id="bodyCell" valign="top" style="background-color: #eeeeee;">
                    <table border="0" cellpadding="0" cellspacing="0" id="templateContainer" style="width: 600px;">
                       <tbody>
                          <tr>
                             <td align="center" valign="top">
                                <table bgcolor="#ebebeb" border="0" cellpadding="0" cellspacing="0" class="ct-container" style="margin: auto; background-color:#ffffff;" width="100%">
                                   <tbody>
                                      <tr>
                                         <td>
                                            <div class="workflow-header">
                                               <div style="float: left;">
                                               </div>
                                            </div>
                                            <table border="0" cellpadding="0" cellspacing="0" id="templateBody" width="100%">
                                               <tbody>
                                                  <tr>
                                                     <td class="bodyContent" mc:edit="body_content00" valign="top" style="padding-bottom:5px;">
                                                        <h3 style="color:#2d3e50; font-size:24px;font-weight:bold; text-align: center;">{{message}}</h3>
                                                     </td>
                                                  </tr>
                                               </tbody>
                                            </table>
                                         </td>
                                      </tr>
                                   </tbody>
                                </table>
                             </td>
                          </tr>
                          <tr>
                             <td align="center" valign="top">
                                <div mc:edit="footertext" style="text-align: center;background-color: #3e3b3b;font-size:13px; padding-bottom: 0px;padding-top: 10px;padding-left:10px;padding-right:10px;color: #fff;">
                                   <p style="color: #fff;">
                                      <span href="" style="color: #fff;font-size: 13px;margin-bottom:10px;text-decoration:none;font-family:arial,sans-serif;" target="">If you would prefer to no longer receive messages like this you can <a href="http://tracking.boodskap.io/tracking/unsubscribe?msgid=UJT9R_VgjMnRtBO0okU3jw2&c=1180062405439469098" target="_blank" style="color:#fff;"> Unsubscribe.</a> If you have any questions or concerns,
                                      please contact us <a href="https://boodskap.io/contact-us" style="border: none; color:#fff;text-decoration:none;">at boodskap/contact-us.</a></span>
                                   </p>
                                   <p style="color: #fff;margin-bottom:10px;text-decoration:none;font-family:arial,sans-serif;font-size: 12px; margin-bottom: 0px;">
                                      <a href="https://boodskap.io/privacy-policy" style="color: #fff;margin-bottom:0px;text-decoration:none;font-family:arial,sans-serif;">Privacy
                                      Policy</a><span style="display: inline-block; width: 4px; height: 4px; -moz-border-radius: 7.5px; -webkit-border-radius: 7.5px; border-radius: 7.5px;background-color: #fff;margin: 2px 4px;"></span><a href="https://boodskap.io/contact-us" style="border: none; text-decoration:none; color: #fff;"><span>Contact us</span></a><span style="display: inline-block; width: 4px; height: 4px; -moz-border-radius: 7.5px; -webkit-border-radius: 7.5px; border-radius: 7.5px;background-color: #fff;margin: 2px 4px;"></span><a href="https://boodskap.io/" style="border: none; text-decoration:none; color: #fff;"><span>Read our blog</span></a>
                                   </p>
                                   <div mc:edit="socialicons" style="text-align: center;background-color: #3e3b3b;padding-top: 0px;">
                                      <br>
                                      <a href="https://www.linkedin.com/company/boodskap/" style="border:none;" target="_blank">
                                      <img alt="linkedin" src="https://static.boodskap.io/linkedin.png" style="width: 22px; padding-left:16px"></a>
                                      <a href="https://www.facebook.com/boodskapiot" style="border:none;" target="_blank"><img alt="Facebook" src="https://static.boodskap.io/fb.png" style="width: 22px; padding-left:16px;"></a>
                                      <a href="https://twitter.com/boodskapiot?lang=en" style="border:none;" target="_blank"> <img alt="twitter" src="https://static.boodskap.io/twitter.png" style="width: 22px; padding-left:16px;">
                                      </a>
                                   </div>
                                   <p style="color:#fff !important;font-family:arial,sans-serif;margin-bottom: 0px; margin-top: 0px; font-size: 12px;">
                                      <br>
                                      &copy; All rights reserved.<br>
                                      <br>
                                      Powered by<a href="https://boodskap.io/" style="color:#fff; text-decoration:none"> Boodskap
                                      Inc.</a><br>
                                      <br>
                                      &nbsp;
                                   </p>
                                </div>
                             </td>
                          </tr>
                       </tbody>
                    </table>
                 </td>
              </tr>
           </tbody>
        </table>
     </center>
  </html>
  ''';