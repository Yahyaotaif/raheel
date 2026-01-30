/**
 * Firebase Cloud Function Example (Node.js)
 * Deploy this to handle payment intent creation securely
 * 
 * Installation:
 * npm install firebase-functions firebase-admin stripe
 * 
 * Set your Stripe secret key as an environment variable:
 * firebase functions:config:set stripe.secret="sk_test_YOUR_KEY"
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const stripe = require('stripe')(functions.config().stripe.secret);

admin.initializeApp();

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  try {
    const { amount, currency = 'usd', description, userId, bookingId } = data;

    // Validate amount
    if (!amount || amount <= 0) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Amount must be greater than 0'
      );
    }

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Convert to cents
      currency: currency.toLowerCase(),
      description: description,
      metadata: {
        userId: userId,
        bookingId: bookingId,
        type: 'booking_payment',
      },
      // Optional: Link to Stripe customer
      // customer: stripeCustomerId,
    });

    return {
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    };
  } catch (error) {
    console.error('Payment Intent Error:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});

/**
 * Webhook to handle payment completion
 * Configure this webhook URL in Stripe Dashboard
 */
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = functions.config().stripe.webhook_secret;

  let event;

  try {
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle payment success
  if (event.type === 'payment_intent.succeeded') {
    const paymentIntent = event.data.object;
    const { userId, bookingId } = paymentIntent.metadata;

    try {
      // Update booking status in database
      await admin.firestore().collection('bookings').doc(bookingId).update({
        paymentStatus: 'completed',
        paymentIntentId: paymentIntent.id,
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log('Payment successful:', bookingId);
    } catch (error) {
      console.error('Error updating booking:', error);
    }
  }

  // Handle payment failure
  if (event.type === 'payment_intent.payment_failed') {
    const paymentIntent = event.data.object;
    const { bookingId } = paymentIntent.metadata;

    try {
      await admin.firestore().collection('bookings').doc(bookingId).update({
        paymentStatus: 'failed',
        paymentError: paymentIntent.last_payment_error?.message,
      });

      console.log('Payment failed:', bookingId);
    } catch (error) {
      console.error('Error updating booking:', error);
    }
  }

  res.json({ received: true });
});
