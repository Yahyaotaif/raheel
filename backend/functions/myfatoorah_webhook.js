/**
 * Myfatoorah Payment Webhook Handler
 * Handles payment status callbacks from Myfatoorah
 * 
 * This function receives payment notifications from Myfatoorah and updates
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
 * HTTP triggered Cloud Function for Myfatoorah webhook
 */
exports.myfatoorahWebhook = functions.https.onRequest(async (req, res) => {
  // Only accept POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const payment = req.body;
    
    functions.logger.log('Myfatoorah webhook received:', payment);

    // Validate webhook has required data
    // Myfatoorah sends payment data in different format
    if (!payment) {
      return res.status(400).json({ error: 'Invalid payload' });
    }

    // Extract invoice ID and payment details
    const invoiceId = payment.InvoiceId || payment.invoiceId;
    const paymentStatus = payment.InvoiceStatus || payment.paymentStatus || payment.transactionStatus;
    const customFields = payment.CustomFields || {};
    
    const bookingId = customFields.bookingId;
    const userId = customFields.userId;

    if (!bookingId || !userId) {
      functions.logger.warn('Missing custom fields in webhook:', { bookingId, userId, customFields });
      // Still return 200 to acknowledge receipt
      return res.status(200).json({ success: true });
    }

    // Handle payment status based on Myfatoorah status codes
    // Myfatoorah uses: 1=Paid, 2=Pending, 3=Failed, 4=Cancelled
    let tripStatus = 'pending';
    let paymentStatusValue = 'pending';

    if (paymentStatus === 1 || paymentStatus === 'Paid' || paymentStatus === 'Success') {
      tripStatus = 'confirmed'; // or 'active' depending on your workflow
      paymentStatusValue = 'paid';
    } else if (paymentStatus === 3 || paymentStatus === 'Failed' || paymentStatus === 'failure') {
      tripStatus = 'cancelled';
      paymentStatusValue = 'failed';
    } else if (paymentStatus === 4 || paymentStatus === 'Cancelled') {
      tripStatus = 'cancelled';
      paymentStatusValue = 'cancelled';
    }

    // Update trip status
    const { error } = await supabase
      .from('trips')
      .update({ 
        payment_status: paymentStatusValue,
        status: tripStatus,
        payment_id: invoiceId,
        updated_at: new Date().toISOString()
      })
      .eq('id', bookingId);

    if (error) {
      functions.logger.error('Failed to update trip:', error);
    } else {
      functions.logger.log(`Trip updated - ID: ${bookingId}, Payment Status: ${paymentStatusValue}, Trip Status: ${tripStatus}`);
    }

    // Always respond with 200 OK to acknowledge receipt
    return res.status(200).json({ 
      success: true, 
      invoiceId: invoiceId,
      paymentStatus: paymentStatusValue 
    });
  } catch (error) {
    functions.logger.error('Webhook processing error:', error);
    // Still return 200 to prevent Myfatoorah from retrying
    return res.status(200).json({ success: false, error: error.message });
  }
});
