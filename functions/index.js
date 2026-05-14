const functions = require("firebase-functions");
const admin = require("firebase-admin");
const https = require("https");

admin.initializeApp();
const db = admin.firestore();

const ACCESS_TOKEN = "APP_USR-484266804459944-041019-a62f1c4773e8292111059a738ced3a2e-3286771561";

exports.webhookMercadoPago = functions.https.onRequest(async (req, res) => {
  const paymentId =
    req.body?.data?.id ||
    req.query?.["data.id"] ||
    req.query?.id;

  const topic = req.body?.type || req.query?.topic || req.query?.type;

  if (!paymentId || (topic && topic !== "payment")) {
    return res.sendStatus(200);
  }

  try {
    // Consulta o pagamento na API do Mercado Pago
    const pagamento = await new Promise((resolve, reject) => {
      const options = {
        hostname: "api.mercadopago.com",
        path: `/v1/payments/${paymentId}`,
        method: "GET",
        headers: { Authorization: `Bearer ${ACCESS_TOKEN}` },
      };
      const reqMP = https.request(options, (resMP) => {
        let data = "";
        resMP.on("data", (chunk) => (data += chunk));
        resMP.on("end", () => resolve(JSON.parse(data)));
      });
      reqMP.on("error", reject);
      reqMP.end();
    });

    const statusMP = pagamento.status;
    const pedidoId = pagamento.external_reference;

    if (!pedidoId) {
      console.log("Sem external_reference:", paymentId);
      return res.sendStatus(200);
    }

    const statusMap = {
      approved:   "Pago",
      pending:    "Aguardando Pagamento",
      in_process: "Aguardando Pagamento",
      rejected:   "Pagamento Recusado",
      cancelled:  "Cancelado",
      refunded:   "Reembolsado",
    };

    const novoStatus = statusMap[statusMP] || "Aguardando Pagamento";

    await db.collection("pedidos").doc(pedidoId).update({
      status: novoStatus,
      paymentId: String(paymentId),
      atualizadoEm: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`Pedido ${pedidoId} atualizado para: ${novoStatus}`);
    return res.sendStatus(200);

  } catch (err) {
    console.error("Erro no webhook:", err.message);
    return res.sendStatus(500);
  }
});