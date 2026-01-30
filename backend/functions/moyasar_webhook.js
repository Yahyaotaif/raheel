/**
 * Moyasar Payment Webhook Handler
 * Handles payment status callbacks from Moyasar
 * 
 * This function receives payment notifications from Moyasar and updates
 * the trip status in Supabase accordingly.
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
  admin.initializeApp();
}

// Initialize Supabase client
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL || 'YOUR_SUPABASE_URL';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'YOUR_SUPABASE_KEY';
const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * HTTP triggered Cloud Function for Moyasar webhook
 */
exports.moyasarWebhook = functions.https.onRequest(async (req, res) => {
  // Only accept POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const payment = req.body;
    
    functions.logger.log('Moyasar webhook received:', payment);

    // Validate webhook has required data
    if (!payment || !payment.id) {
      return res.status(400).json({ error: 'Invalid payload' });
    }

    const { id, status, metadata } = payment;
    
    // Extract metadata
    const bookingId = metadata?.bookingId;
    const userId = metadata?.userId;

    if (!bookingId || !userId) {
      functions.logger.warn('Missing metadata in webhook:', { bookingId, userId });
      // Still return 200 to acknowledge receipt
      return res.status(200).json({ success: true });
    }

    // Handle payment status
    if (status === 'paid') {
      // Update trip status to 'paid'
      const { error } = await supabase
        .from('trips')
        .update({ 
          payment_status: 'paid',
          payment_id: id,
          updated_at: new Date().toISOString()
        })
        .eq('id', bookingId);

      if (error) {
        functions.logger.error('Failed to update trip:', error);
      } else {
        functions.logger.log('Trip marked as paid:', bookingId);
      }
    } else if (status === 'failed' || status === 'cancelled') {
      // Update trip status to 'payment_failed'
      const { error } = await supabase
        .from('trips')
        .update({ 
          payment_status: 'failed',
          updated_at: new Date().toISOString()
        })
        .eq('id', bookingId);

      if (error) {
        functions.logger.error('Failed to update trip status:', error);
      } else {
        functions.logger.log('Trip marked as payment failed:', bookingId);
      }
    }

    // Always respond with 200 OK to acknowledge receipt
    return res.status(200).json({ success: true, paymentId: id });
  } catch (error) {
    functions.logger.error('Webhook processing error:', error);
    // Still return 200 to prevent Moyasar from retrying
    return res.status(200).json({ success: false, error: error.message });
  }
});
