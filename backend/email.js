// Module d'envoi d'emails pour Aidalya
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
  const fromName = 'Aidalya';

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
  const subject = 'Nouveau message de l\'équipe Aidalya';
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
          <h1>Aidalya</h1>
        </div>
        <div class="content">
          <p>Bonjour ${userName || 'Cher utilisateur'},</p>
          <p>Vous avez reçu un nouveau message de l'équipe Aidalya :</p>
          <div class="message">
            ${messageContent.replace(/\n/g, '<br>')}
          </div>
          <p>Connectez-vous à votre application pour répondre.</p>
        </div>
        <div class="footer">
          <p>Cet email a été envoyé depuis contact@auxivie.org</p>
          <p>&copy; ${new Date().getFullYear()} Aidalya. Tous droits réservés.</p>
        </div>
      </div>
    </body>
    </html>
  `;

  return await sendEmail(userEmail, subject, html);
};

const escapeHtml = (s) =>
  String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');

/**
 * Email automatique depuis contact@auxivie.org suite à une demande sur la landing (apps pas encore en stores).
 */
const sendLandingAppSoonEmail = async (
  userEmail,
  { displayName = '', profileLabel = '', besoin = '', phone = '' } = {}
) => {
  const safeName = (displayName || '').trim().slice(0, 120);
  const greetingPlain = safeName ? `Bonjour ${safeName},` : 'Bonjour,';
  const greetingHtml = safeName ? `Bonjour ${escapeHtml(safeName)},` : 'Bonjour,';

  const subject = 'Aidalya — Confirmation de votre demande (applications mobiles)';

  const detailLines = [];
  if (profileLabel)
    detailLines.push(`<li><strong>Profil indiqué :</strong> ${escapeHtml(profileLabel)}</li>`);
  const phoneTrim = (phone || '').trim().slice(0, 30);
  if (besoin) detailLines.push(`<li><strong>Besoin principal :</strong> ${escapeHtml(besoin)}</li>`);
  if (phoneTrim)
    detailLines.push(`<li><strong>Téléphone (indiqué sur le formulaire) :</strong> ${escapeHtml(phoneTrim)}</li>`);

  const textExtras = [];
  const plPlain = (profileLabel || '').trim().slice(0, 200).replace(/\r?\n/g, ' ');
  const besoinPlain = (besoin || '').trim().slice(0, 200).replace(/\r?\n/g, ' ');
  if (plPlain) textExtras.push(`Profil indiqué : ${plPlain}`);
  if (besoinPlain) textExtras.push(`Besoin principal : ${besoinPlain}`);
  if (phoneTrim) textExtras.push(`Téléphone : ${phoneTrim}`);
  const textExtrasBlock = textExtras.length ? `\n\n${textExtras.join('\n')}` : '';

  const html = `
    <!DOCTYPE html>
    <html lang="fr">
    <head><meta charset="utf-8"/></head>
    <body style="margin:0;font-family:Arial,Helvetica,sans-serif;line-height:1.6;color:#333;background:#f4f5f7;">
      <div style="max-width:600px;margin:0 auto;padding:24px;">
        <div style="background:#0d8f6f;color:#fff;padding:22px 24px;border-radius:12px 12px 0 0;text-align:center;">
          <h1 style="margin:0;font-size:1.35rem;font-weight:700;">Aidalya</h1>
        </div>
        <div style="background:#fff;padding:28px 24px;border:1px solid #e5e7eb;border-top:none;border-radius:0 0 12px 12px;">
          <p style="margin:0 0 16px;">${greetingHtml}</p>
          <p style="margin:0 0 16px;">
            Merci pour l’intérêt que vous portez à <strong>Aidalya</strong>. Nous avons bien enregistré votre demande.
          </p>
          <p style="margin:0 0 16px;">
            Les applications mobiles <strong>Aidalya</strong> pour <strong>iOS</strong> (Apple App Store) et <strong>Android</strong>
            (Google Play) ne sont pas encore disponibles au téléchargement. Leur mise en ligne est en cours :
            nous vous informerons par email lorsqu’elles seront publiées, afin que vous puissiez créer votre compte
            et utiliser la plateforme en toute simplicité.
          </p>
          <p style="margin:0 0 16px;">
            En attendant, pour toute question ou demande particulière, vous pouvez nous écrire à l’adresse
            <a href="mailto:contact@auxivie.org" style="color:#0d8f6f;">contact@auxivie.org</a>
            — nous vous répondrons dans les meilleurs délais.
          </p>
          ${detailLines.length ? `<ul style="margin:16px 0;padding-left:20px;color:#555;">${detailLines.join('')}</ul>` : ''}
          <p style="margin:24px 0 0;font-size:0.9rem;color:#666;">
            Cordialement,<br/>
            <strong>L’équipe Aidalya</strong>
          </p>
        </div>
        <p style="text-align:center;font-size:11px;color:#999;margin-top:20px;">
          Message envoyé automatiquement depuis <a href="mailto:contact@auxivie.org">contact@auxivie.org</a>.
          Merci de ne pas répondre à cet email si votre messagerie ne permet pas la réponse directe ;
          utilisez plutôt l’adresse contact ci-dessus.
        </p>
      </div>
    </body>
    </html>
  `;

  const text = `${greetingPlain}

Merci pour l'intérêt que vous portez à Aidalya. Nous avons bien enregistré votre demande.

Les applications mobiles Aidalya pour iOS (App Store) et Android (Google Play) ne sont pas encore disponibles au téléchargement. Nous vous informerons par email lorsqu'elles seront publiées.${textExtrasBlock}

Pour toute question : contact@auxivie.org

Cordialement,
L'équipe Aidalya`;

  return await sendEmail(userEmail, subject, html, text);
};

module.exports = {
  sendEmail,
  sendAdminMessageNotification,
  sendLandingAppSoonEmail,
};

