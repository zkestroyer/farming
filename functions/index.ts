// D:\Farming\farming\functions\index.ts
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";

admin.initializeApp();

// --- Environment Configuration ---
const WEATHER_API_KEY = functions.config().weather.key;
const AI_API_KEY = functions.config().ai.key;

// --- EXISTING FUNCTION 1: Daily Weather ---
export const sendDailyWeatherAlerts = functions.pubsub
  .schedule("0 8 * * *")
  .timeZone("Asia/Karachi")
  .onRun(async (context) => {
    // (Your existing weather alert code is here)
    // ...
    console.log("Weather alert function ran.");
  });

// --- EXISTING FUNCTION 2: AI Query Response ---
export const getAIResponseForQuery = functions.firestore
  .document("queries/{queryId}")
  .onCreate(async (snap, context) => {
    // (Your existing AI response code is here)
    // ...
    console.log("AI response function ran.");
    return null;
  });

// --- NEW FUNCTION 1: Post Crop for Sale ---
/**
 * A callable function that allows an authenticated user
 * to post their crop to the marketplace.
 */
export const postCropForSale = functions.https.onCall(
  async (data, context) => {
    // Check if the user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "You must be logged in to post."
      );
    }

    // Validate the data from the app
    const { cropName, urduName, quantity, price, unit } = data;
    if (!cropName || !quantity || !price || !unit) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required fields."
      );
    }

    const uid = context.auth.uid;

    // Add to the 'crops_for_sale' collection in Firestore
    try {
      await admin.firestore().collection("crops_for_sale").add({
        sellerId: uid,
        cropName: cropName,
        urduName: urduName || "",
        quantity: quantity,
        price: price,
        unit: unit, // e.g., "kg" or "40kg bag"
        status: "available", // So you can manage sold items
        postedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`New crop posted by ${uid}: ${quantity} ${unit} of ${cropName}`);
      return { success: true, message: "Crop posted successfully!" };
    } catch (error) {
      console.error("Error posting crop:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while posting your crop."
      );
    }
  }
);

// --- NEW FUNCTION 2: Update Market Rates (Admin) ---
/**
 * A callable function (for admin use) to update the
 * official market rates for various crops.
 */
export const updateMarketRates = functions.https.onCall(
  async (data, context) => {
    // Note: In a real app, you'd check if context.auth.uid is an admin.
    // For now, we'll allow it.

    const rates = data.rates; // Expect an array of rate objects
    if (!Array.isArray(rates) || rates.length === 0) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Rates must be a non-empty array."
      );
    }

    const db = admin.firestore();
    const batch = db.batch();
    const collectionRef = db.collection("market_rates");

    console.log("Updating market rates...");

    rates.forEach((rate: any) => {
      // Use the crop name (in lowercase) as the document ID
      const docId = rate.name.toLowerCase();
      const docRef = collectionRef.doc(docId);
      
      // We use 'set' with 'merge: true' to create or update
      batch.set(docRef, {
        name: rate.name,
        urduName: rate.urduName || "",
        price: rate.price, // e.g., "3900"
        unit: rate.unit,   // e.g., "/ 40kg"
        region: rate.region || "Punjab", // Default region
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    });

    try {
      await batch.commit();
      console.log("Successfully updated market rates.");
      return { success: true, message: "Market rates updated." };
    } catch (error) {
      console.error("Error updating market rates:", error);
      throw new functions.https.HttpsError(
        "internal",
        "An error occurred while updating rates."
      );
    }
  }
);