// Module d'envoi d'emails pour Auxivie
const nodemailer = require('nodemailer');

// Configuration du transporteur email
// L'adresse expéditrice est toujours contact@auxivie.org
const createTransporter = () => {
  // Si des variables d'environnement SMTP sont configurées, les utiliser
  if (process.env.SMTP_HOST && process.env.SMTP_PORT && process.env.SMTP_USER && process.env.SMTP_PASS) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT) || 587,
      secure: process.env.SMTP_SECURE === 'true' || false, // true pour 465, false pour autres ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }
  
  // Sinon, utiliser une configuration par défaut (pour développement)
  // En production, vous devrez configurer les variables SMTP
  console.warn('⚠️  Variables SMTP non configurées. Les emails ne seront pas envoyés.');
  return null;
};

// Fonction pour envoyer un email
const sendEmail = async (to, subject, html, text = null) => {
  const transporter = createTransporter();
  
  if (!transporter) {
    console.error('❌ Transporteur email non configuré');
    return { success: false, error: 'Configuration email manquante' };
  }

  // L'adresse expéditrice est toujours contact@auxivie.org
  const fromEmail = 'contact@auxivie.org';
  const fromName = 'Auxivie';

  const mailOptions = {
    from: `"${fromName}" <${fromEmail}>`,
    to: to,
    bcc: fromEmail, // Ajouter contact@auxivie.org en copie cachée pour traçabilité
    subject: subject,
    html: html,
    text: text || html.replace(/<[^>]*>/g, ''), // Extraire le texte si HTML fourni
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email envoyé:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('❌ Erreur envoi email:', error);
    return { success: false, error: error.message };
  }
};

// Fonction pour envoyer un email de notification de message depuis l'admin
const sendAdminMessageNotification = async (userEmail, userName, messageContent) => {
  const subject = 'Nouveau message de l\'équipe Auxivie';
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8">
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
        }
        .container {
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #16a34a;
          color: white;
          padding: 20px;
          text-align: center;
          border-radius: 5px 5px 0 0;
        }
        .content {
          background-color: #f9f9f9;
          padding: 20px;
          border-radius: 0 0 5px 5px;
        }
        .message {
          background-color: white;
          padding: 15px;
          border-left: 4px solid #16a34a;
          margin: 20px 0;
        }
        .footer {
          text-align: center;
          margin-top: 20px;
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>Auxivie</h1>
        </div>
        <div class="content">
          <p>Bonjour ${userName || 'Cher utilisateur'},</p>
          <p>Vous avez reçu un nouveau message de l'équipe Auxivie :</p>
          <div class="message">
            ${messageContent.replace(/\n/g, '<br>')}
          </div>
          <p>Connectez-vous à votre application pour répondre.</p>
        </div>
        <div class="footer">
          <p>Cet email a été envoyé depuis contact@auxivie.org</p>
          <p>&copy; ${new Date().getFullYear()} Auxivie. Tous droits réservés.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  return await sendEmail(userEmail, subject, html);
};

module.exports = {
  sendEmail,
  sendAdminMessageNotification,
};

